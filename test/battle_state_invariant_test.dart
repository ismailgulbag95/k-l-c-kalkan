import 'dart:math';

import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _allSpells = {
  'spell_emberSpear',
  'spell_ashBurst',
  'spell_tideWard',
  'spell_saltCleanse',
  'spell_swiftBreeze',
  'spell_shoreStep',
};

GameSave _saveFor(String weapon, {bool bow = false}) => GameSave(
  hasHero: true,
  heroName: 'Deneme Dövüşçüsü',
  level: 20,
  stats: const Stats(
    might: 20,
    agility: 20,
    precision: 20,
    vitality: 20,
    guard: 20,
    stamina: 20,
    arcana: 20,
  ),
  ownedItems: {
    ..._allSpells,
    'sword_4',
    'maul_4',
    'spear_4',
    'bow_4',
    'helm_4',
    'coat_4',
    'boots_4',
    'charm_4',
  },
  equippedItems: {
    'weapon': '${weapon}_4',
    if (bow) 'bow': 'bow_4',
    'head': 'helm_4',
    'body': 'coat_4',
    'boots': 'boots_4',
    'talisman': 'charm_4',
  },
  healingSalves: 3,
  effortTonics: 3,
);

void _expectResourcesInRange(BattleEngine battle) {
  for (final fighter in [battle.player, battle.opponent]) {
    expect(fighter.health, inInclusiveRange(0, fighter.maxHealth));
    expect(fighter.effort, inInclusiveRange(0, fighter.maxEffort));
    expect(fighter.mana, inInclusiveRange(0, fighter.maxMana));
    expect(fighter.ammo, greaterThanOrEqualTo(0));
    expect(fighter.ammo, lessThanOrEqualTo(fighter.ammoCapacity));
    expect(fighter.shield, greaterThanOrEqualTo(0));
    expect(fighter.statuses.values, everyElement(greaterThan(0)));
  }
  expect(battle.distance, isIn(RangeBand.values));
}

void main() {
  test('every player action resolves from a legal opening state', () {
    for (final action in BattleAction.values) {
      final battle = BattleEngine(
        save: _saveFor('sword', bow: true),
        encounter: getEncounter(1),
        seed: 8100 + action.index,
      );

      if (action == BattleAction.salve) {
        battle.player.health = battle.player.maxHealth - 1;
      }
      if (action == BattleAction.tonic) {
        battle.player.effort = 0;
      }

      expect(
        battle.preview(action).canUse,
        isTrue,
        reason: '${action.name} should be legal at the opening state',
      );
      expect(
        battle.perform(action),
        isNull,
        reason: '${action.name} should resolve after a legal preview',
      );
      expect(
        battle.snapshot.events.any(
          (event) =>
              event.type == BattleEventType.actionStarted &&
              event.actor == BattleActor.player &&
              event.action == action,
        ),
        isTrue,
        reason: '${action.name} should emit its typed action event',
      );
      _expectResourcesInRange(battle);
    }
  });

  test('seeded legal-action sequences preserve combat state invariants', () {
    const loadouts = [
      ('sword', false),
      ('maul', false),
      ('spear', false),
      ('sword', true),
    ];
    var caseCount = 0;

    for (final encounter in mainEncounters) {
      for (final (weapon, bow) in loadouts) {
        final seed = encounter.id * 100 + loadouts.indexOf((weapon, bow));
        final battle = BattleEngine(
          save: _saveFor(weapon, bow: bow),
          encounter: encounter,
          seed: seed,
        );
        final random = Random(seed);

        for (var turn = 0; turn < 48 && !battle.snapshot.done; turn++) {
          final legalActions = BattleAction.values
              .where((action) => battle.preview(action).canUse)
              .toList();
          expect(legalActions, isNotEmpty);
          final action = legalActions[random.nextInt(legalActions.length)];
          expect(
            battle.perform(action),
            isNull,
            reason:
                '${encounter.key}, $weapon, seed $seed, turn $turn, '
                'action ${action.name}',
          );
          _expectResourcesInRange(battle);
        }

        expect(
          battle.snapshot.events.map((event) => event.sequence).toList(),
          orderedEquals(
            List.generate(battle.snapshot.events.length, (index) => index),
          ),
        );
        if (battle.snapshot.done) {
          expect(
            battle.snapshot.events.last.type,
            anyOf(BattleEventType.battleWon, BattleEventType.battleLost),
          );
        }
        caseCount++;
      }
    }

    expect(caseCount, 128);
  });
}
