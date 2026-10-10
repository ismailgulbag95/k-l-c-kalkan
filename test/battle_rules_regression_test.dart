import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _combatStats = Stats(
  might: 8,
  agility: 8,
  precision: 30,
  vitality: 40,
  guard: 8,
  stamina: 8,
  arcana: 20,
);

GameSave _save({
  Set<String> ownedItems = const {},
  Set<String> masteries = const {},
  Map<String, String> equippedItems = const {},
  int healingSalves = 0,
  int effortTonics = 0,
}) => GameSave(
  hasHero: true,
  level: 20,
  stats: _combatStats,
  ownedItems: ownedItems,
  masteries: masteries,
  equippedItems: equippedItems,
  healingSalves: healingSalves,
  effortTonics: effortTonics,
);

Combatant _durableOpponent() => Combatant(
  name: 'Test Rakibi',
  stats: const Stats(might: 4, agility: 2, precision: 2, guard: 8),
  level: 1,
  maxHealth: 5000,
  maxEffort: 40,
  maxMana: 0,
  weaponPower: 1,
  family: WeaponFamily.shortSword,
  armor: 12,
  ammo: 0,
  aiStyle: true,
);

BattleEngine _newBattle({required int seed, required GameSave save}) =>
    BattleEngine(
      save: save,
      encounter: getEncounter(1),
      seed: seed,
      opponentOverride: _durableOpponent(),
    );

BattleEngine _battleThatHits(BattleAction action, GameSave save) {
  for (var seed = 0; seed < 512; seed++) {
    final battle = _newBattle(seed: seed, save: save);
    battle.perform(action);
    if (battle.snapshot.events.any(
      (event) =>
          event.type == BattleEventType.attackHit &&
          event.actor == BattleActor.player &&
          event.action == action,
    )) {
      return battle;
    }
  }
  throw StateError('Could not find a seeded hit for $action.');
}

int _burnTicks(BattleEngine battle) => battle.snapshot.messages
    .where((message) => message.id == 'battle.log.damageOverTime')
    .where((message) => message.arguments['status'] == StatusKind.burn)
    .length;

void main() {
  group('planned battle rules', () {
    test(
      'spell previews and resolved damage ignore weapon family and range',
      () {
        const weapons = ['sword_1', 'maul_1', 'spear_1'];
        for (final range in RangeBand.values) {
          final previews = <(int, int)>[];
          final damages = <int>[];
          for (final weaponId in weapons) {
            final battle = _newBattle(
              seed: 570 + range.index,
              save: _save(
                ownedItems: {'spell_emberSpear', weaponId},
                equippedItems: {'weapon': weaponId},
              ),
            )..distance = range;
            final preview = battle.preview(BattleAction.emberSpear);
            previews.add((preview.hitChance, preview.estimatedDamage));
            battle.perform(BattleAction.emberSpear);
            final hit = battle.snapshot.events.where(
              (event) =>
                  event.type == BattleEventType.attackHit &&
                  event.actor == BattleActor.player &&
                  event.action == BattleAction.emberSpear,
            );
            damages.add(hit.isEmpty ? 0 : hit.first.amount ?? 0);
          }
          expect(previews.toSet(), hasLength(1), reason: range.name);
          expect(damages.toSet(), hasLength(1), reason: range.name);
        }
      },
    );

    test(
      'consumables are disabled when their resolved effect would be zero',
      () {
        final battle = _newBattle(
          seed: 568,
          save: _save(healingSalves: 1, effortTonics: 1),
        );

        expect(battle.preview(BattleAction.salve).canUse, isFalse);
        expect(battle.perform(BattleAction.salve), isNotNull);
        expect(battle.metrics.salveUsed, isFalse);
        expect(battle.metrics.turn, 0);

        expect(battle.preview(BattleAction.tonic).canUse, isFalse);
        expect(battle.perform(BattleAction.tonic), isNotNull);
        expect(battle.metrics.tonicUsed, isFalse);
        expect(battle.metrics.turn, 0);
      },
    );

    test(
      'salve preview includes damage-over-time at the start of the turn',
      () {
        final battle = _newBattle(seed: 569, save: _save(healingSalves: 1));
        battle.player.statuses[StatusKind.bleed] = 1;
        battle.player.statusTurnsRemaining[StatusKind.bleed] = 1;

        expect(battle.preview(BattleAction.salve).canUse, isTrue);
        expect(battle.perform(BattleAction.salve), isNull);
        expect(battle.metrics.salveUsed, isTrue);
        expect(
          battle.snapshot.events.any(
            (event) =>
                event.type == BattleEventType.healed &&
                event.actor == BattleActor.player &&
                (event.amount ?? 0) > 0,
          ),
          isTrue,
        );
      },
    );

    test('restored ammunition is clamped to the equipped bow capacity', () {
      final save = _save(
        ownedItems: const {'bow_4'},
        equippedItems: const {'bow': 'bow_4'},
      );
      final original = BattleEngine(
        save: save,
        encounter: getEncounter(1),
        seed: 571,
      );
      final checkpoint = original.toCheckpointJson();
      final player = Map<String, dynamic>.from(checkpoint['player'] as Map)
        ..['ammo'] = 99;
      checkpoint['player'] = player;

      final restored = BattleEngine.restoreFromCheckpoint(
        save: save,
        encounter: getEncounter(1),
        checkpoint: checkpoint,
      );

      expect(restored.player.ammo, 6);
    });

    test('burn keeps its stacks for two target turns and expires cleanly', () {
      final battle = _battleThatHits(
        BattleAction.ashBurst,
        _save(
          ownedItems: const {'spell_ashBurst'},
          masteries: const {'seal_3'},
        ),
      );

      expect(battle.opponent.statuses[StatusKind.burn], 1);
      expect(battle.opponent.statusTurnsRemaining[StatusKind.burn], 1);
      expect(_burnTicks(battle), 1);
      expect(battle.opponent.burnBonusPercent, .01);

      expect(battle.perform(BattleAction.guard), isNull);

      expect(_burnTicks(battle), 2);
      expect(battle.opponent.statuses.containsKey(StatusKind.burn), isFalse);
      expect(
        battle.opponent.statusTurnsRemaining.containsKey(StatusKind.burn),
        isFalse,
      );
      expect(battle.opponent.burnBonusPercent, 0);
    });

    test('burn refreshes its duration and caps at two simultaneous stacks', () {
      final battle = _battleThatHits(
        BattleAction.ashBurst,
        _save(ownedItems: const {'spell_ashBurst'}),
      );
      for (var application = 0; application < 2; application++) {
        battle.perform(BattleAction.ashBurst);
      }

      expect(battle.opponent.statuses[StatusKind.burn], 2);
      expect(battle.opponent.statusTurnsRemaining[StatusKind.burn], 1);

      battle.perform(BattleAction.ashBurst);

      expect(battle.opponent.statuses[StatusKind.burn], 2);
      expect(battle.opponent.statusTurnsRemaining[StatusKind.burn], 1);
    });

    test('bleed duration counts down without consuming its stack', () {
      final battle = _newBattle(seed: 91, save: _save());
      battle.player.statuses[StatusKind.bleed] = 2;
      battle.player.statusTurnsRemaining[StatusKind.bleed] = 2;

      battle.perform(BattleAction.guard);

      expect(battle.player.statuses[StatusKind.bleed], 2);
      expect(battle.player.statusTurnsRemaining[StatusKind.bleed], 1);

      battle.perform(BattleAction.guard);

      expect(battle.player.statuses.containsKey(StatusKind.bleed), isFalse);
      expect(
        battle.player.statusTurnsRemaining.containsKey(StatusKind.bleed),
        isFalse,
      );
    });

    test('Shore Step is disabled until its skill is owned', () {
      final locked = _newBattle(seed: 92, save: _save());
      expect(locked.preview(BattleAction.shoreStep).canUse, isFalse);

      final unlocked = _newBattle(
        seed: 92,
        save: _save(ownedItems: const {'spell_shoreStep'}),
      );
      expect(unlocked.preview(BattleAction.shoreStep).canUse, isTrue);
    });

    test('preview includes mana restored at the start of the third turn', () {
      final battle = _newBattle(
        seed: 93,
        save: _save(
          ownedItems: const {'spell_emberSpear'},
          masteries: const {'seal_2'},
        ),
      )..metrics.turn = 2;
      battle.player.mana = 4;

      expect(battle.preview(BattleAction.emberSpear).canUse, isTrue);
      expect(battle.perform(BattleAction.emberSpear), isNull);
      expect(battle.player.mana, 0);
    });

    test('a successful Sweep applies Broken Guard for the following round', () {
      final battle = _battleThatHits(BattleAction.sweep, _save());
      expect(battle.opponent.statuses[StatusKind.brokenGuard], 1);
      expect(
        battle.snapshot.messages.any(
          (message) => message.id == 'battle.log.brokenGuard',
        ),
        isTrue,
      );
      final vulnerableDamage = battle
          .preview(BattleAction.quick)
          .estimatedDamage;
      battle.opponent.statuses.remove(StatusKind.brokenGuard);
      final normalDamage = battle.preview(BattleAction.quick).estimatedDamage;
      battle.opponent.statuses[StatusKind.brokenGuard] = 1;
      expect(vulnerableDamage, greaterThan(normalDamage));

      battle.perform(BattleAction.quick);
      expect(battle.opponent.statuses[StatusKind.brokenGuard], 1);

      battle.perform(BattleAction.guard);
      expect(
        battle.opponent.statuses.containsKey(StatusKind.brokenGuard),
        isFalse,
      );
      expect(battle.opponent.brokenGuardExpiresAfterTurn, isNull);
    });
  });
}
