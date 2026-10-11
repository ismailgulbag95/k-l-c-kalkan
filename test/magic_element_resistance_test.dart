import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/domain/balance.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant _opponent({
  required int arcana,
  Set<CombatElement> immunities = const {},
}) => Combatant(
  name: 'Direnç Testi',
  stats: Stats(agility: 2, precision: 2, vitality: 2, guard: 0, arcana: arcana),
  level: 1,
  maxHealth: 5000,
  maxEffort: 40,
  maxMana: 0,
  weaponPower: 1,
  family: WeaponFamily.shortSword,
  armor: 0,
  elementalImmunities: immunities,
  ammo: 0,
  aiStyle: true,
);

GameSave _save({Set<String> ownedItems = const {}}) => GameSave(
  hasHero: true,
  level: 20,
  stats: const Stats(
    might: 8,
    agility: 8,
    precision: 20,
    vitality: 20,
    guard: 8,
    stamina: 8,
    arcana: 8,
  ),
  ownedItems: ownedItems,
);

BattleEngine _battle({
  required int arcana,
  int seed = 17,
  Set<CombatElement> immunities = const {},
}) => BattleEngine(
  save: _save(ownedItems: const {'spell_emberSpear', 'spell_ashBurst'}),
  encounter: getEncounter(1),
  seed: seed,
  opponentOverride: _opponent(arcana: arcana, immunities: immunities),
);

int? _playerDamage(BattleEngine battle, BattleAction action) {
  final hits = battle.snapshot.events.where(
    (event) =>
        event.type == BattleEventType.attackHit &&
        event.actor == BattleActor.player &&
        event.action == action,
  );
  return hits.isEmpty ? null : hits.first.amount;
}

int? _dotDamage(BattleEngine battle, StatusKind status) {
  final ticks = battle.snapshot.messages.where(
    (message) =>
        message.id == 'battle.log.damageOverTime' &&
        message.arguments['status'] == status,
  );
  return ticks.isEmpty ? null : ticks.first.arguments['damage'] as int;
}

void main() {
  group('magic and elemental resistance', () {
    test('encounter card immunities reach their combatant', () {
      const encounter = Encounter(
        id: 99,
        name: 'Kül Bağışıklığı Denetimi',
        arenaId: 'kul',
        chapter: 1,
        level: 1,
        kind: EncounterKind.regular,
        archetype: 'vurucu',
        gold: 0,
        xp: 0,
        might: 2,
        agility: 2,
        vitality: 2,
        guard: 2,
        stamina: 2,
        arcana: 2,
        weaponPower: 1,
        weaponFamily: WeaponFamily.shortSword,
        elementalImmunities: {CombatElement.ember},
      );

      expect(Combatant.opponent(encounter).elementalImmunities, {
        CombatElement.ember,
      });
    });

    test('target Arcana mitigates direct spell damage and its preview', () {
      final lowResistance = _battle(arcana: 2);
      final highResistance = _battle(arcana: 18);

      expect(
        lowResistance.preview(BattleAction.emberSpear).estimatedDamage,
        greaterThan(
          highResistance.preview(BattleAction.emberSpear).estimatedDamage,
        ),
      );

      var resolved = false;
      for (var seed = 0; seed < 128 && !resolved; seed++) {
        final low = _battle(arcana: 2, seed: seed)
          ..perform(BattleAction.emberSpear);
        final high = _battle(arcana: 18, seed: seed)
          ..perform(BattleAction.emberSpear);
        final lowDamage = _playerDamage(low, BattleAction.emberSpear);
        final highDamage = _playerDamage(high, BattleAction.emberSpear);
        if (lowDamage == null || highDamage == null) continue;

        expect(lowDamage, greaterThan(highDamage));
        resolved = true;
      }
      expect(resolved, isTrue, reason: 'A shared seed should produce a hit.');
    });

    test('Arcana mitigates elemental burn ticks', () {
      int burnTick(int arcana) {
        final battle = _battle(arcana: arcana);
        battle.opponent
          ..statuses[StatusKind.burn] = 1
          ..statusTurnsRemaining[StatusKind.burn] = 2;
        battle.perform(BattleAction.guard);
        return _dotDamage(battle, StatusKind.burn)!;
      }

      expect(burnTick(18), lessThan(burnTick(2)));
    });

    test('Arcana does not mitigate non-elemental bleed ticks', () {
      int bleedTick(int arcana) {
        final battle = _battle(arcana: arcana);
        battle.opponent
          ..statuses[StatusKind.bleed] = 1
          ..statusTurnsRemaining[StatusKind.bleed] = 2;
        battle.perform(BattleAction.guard);
        return _dotDamage(battle, StatusKind.bleed)!;
      }

      expect(bleedTick(2), bleedTick(18));
    });

    test('Arcana alone is not an implicit elemental immunity', () {
      BattleEngine? battleWithBurn;
      for (var seed = 0; seed < 128 && battleWithBurn == null; seed++) {
        final candidate = _battle(arcana: 20, seed: seed);
        candidate.perform(BattleAction.ashBurst);
        if (_playerDamage(candidate, BattleAction.ashBurst) != null) {
          battleWithBurn = candidate;
        }
      }

      expect(battleWithBurn, isNotNull);
      expect(battleWithBurn!.opponent.statuses[StatusKind.burn], 1);
    });

    test('an explicitly listed Ember immunity prevents Burn after a hit', () {
      BattleEngine? immuneBattle;
      for (var seed = 0; seed < 128 && immuneBattle == null; seed++) {
        final candidate = _battle(
          arcana: 20,
          seed: seed,
          immunities: const {CombatElement.ember},
        );
        candidate.perform(BattleAction.ashBurst);
        if (_playerDamage(candidate, BattleAction.ashBurst) != null) {
          immuneBattle = candidate;
        }
      }

      expect(immuneBattle, isNotNull);
      final resolvedBattle = immuneBattle!;
      expect(resolvedBattle.opponent.statuses[StatusKind.burn], isNull);
      expect(
        resolvedBattle.snapshot.messages.any(
          (message) => message.id == 'battle.log.statusImmune',
        ),
        isTrue,
      );
    });

    test('the Kızıl Ocak Şefi blocks Burn but still takes Ember damage', () {
      final encounter = mainEncounters.singleWhere((item) => item.id == 14);
      expect(encounter.elementalImmunities, {CombatElement.ember});

      BattleEngine? battleWithHit;
      for (var seed = 0; seed < 128 && battleWithHit == null; seed++) {
        final candidate = BattleEngine(
          save: _save(ownedItems: const {'spell_emberSpear', 'spell_ashBurst'}),
          encounter: encounter,
          seed: seed,
        )..perform(BattleAction.ashBurst);
        if (_playerDamage(candidate, BattleAction.ashBurst) != null) {
          battleWithHit = candidate;
        }
      }

      expect(battleWithHit, isNotNull);
      expect(
        battleWithHit!.opponent.health,
        lessThan(battleWithHit.opponent.maxHealth),
      );
      expect(battleWithHit.opponent.statuses[StatusKind.burn], isNull);
      expect(
        battleWithHit.snapshot.messages.any(
          (message) => message.id == 'battle.log.statusImmune',
        ),
        isTrue,
      );
    });

    test(
      'an Ember immune target clears restored Burn before its next tick',
      () {
        final encounter = mainEncounters.singleWhere((item) => item.id == 14);
        final battle = BattleEngine(
          save: _save(ownedItems: const {'spell_emberSpear', 'spell_ashBurst'}),
          encounter: encounter,
          seed: 17,
        );
        battle.opponent
          ..statuses[StatusKind.burn] = 1
          ..statusTurnsRemaining[StatusKind.burn] = 2;
        final restored = BattleEngine.restoreFromCheckpoint(
          save: battle.save,
          encounter: encounter,
          checkpoint: battle.toCheckpointJson(),
        );
        final healthBefore = restored.opponent.health;

        restored.perform(BattleAction.guard);

        expect(restored.opponent.health, healthBefore);
        expect(restored.opponent.statuses[StatusKind.burn], isNull);
        expect(
          restored.snapshot.messages.where(
            (message) => message.id == 'battle.log.damageOverTime',
          ),
          isEmpty,
        );
      },
    );

    test(
      'Arcana resistance clamps below zero and damage stays at least one',
      () {
        expect(GameBalance.magicResistanceFromArcana(-5), 0);
        expect(
          GameBalance.magicEffectiveArmor(physicalArmor: 10, arcana: 5),
          9,
        );
        expect(
          GameBalance.magicEffectiveArmor(physicalArmor: 10, arcana: -5),
          4,
        );
        expect(
          GameBalance.damageAfterArcanaResistance(damage: 50, arcana: -5),
          50,
        );
        expect(
          GameBalance.damageAfterArcanaResistance(damage: 1, arcana: 100000),
          1,
        );
      },
    );
  });
}
