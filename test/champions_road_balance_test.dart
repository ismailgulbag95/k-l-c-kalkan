import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RoadBuild {
  const _RoadBuild({
    required this.name,
    required this.stats,
    required this.weapon,
    required this.mastery,
    this.bow = false,
    this.arcane = false,
  });

  final String name;
  final Stats stats;
  final String weapon;
  final String mastery;
  final bool bow;
  final bool arcane;
}

const _roadBuilds = [
  _RoadBuild(
    name: 'Kuvvet / Tokmak',
    stats: Stats(
      might: 20,
      agility: 8,
      precision: 8,
      vitality: 20,
      guard: 16,
      stamina: 16,
      arcana: 2,
    ),
    weapon: 'maul',
    mastery: 'front',
  ),
  _RoadBuild(
    name: 'Çeviklik / Kısa kılıç',
    stats: Stats(
      might: 12,
      agility: 20,
      precision: 14,
      vitality: 14,
      guard: 10,
      stamina: 16,
      arcana: 2,
    ),
    weapon: 'sword',
    mastery: 'duel',
  ),
  _RoadBuild(
    name: 'İsabet / Yay',
    stats: Stats(
      might: 10,
      agility: 16,
      precision: 20,
      vitality: 14,
      guard: 10,
      stamina: 16,
      arcana: 2,
    ),
    weapon: 'sword',
    mastery: 'duel',
    bow: true,
  ),
  _RoadBuild(
    name: 'Büyü / Mızrak',
    stats: Stats(
      might: 10,
      agility: 10,
      precision: 10,
      vitality: 16,
      guard: 12,
      stamina: 16,
      arcana: 20,
    ),
    weapon: 'spear',
    mastery: 'seal',
    arcane: true,
  ),
];

void main() {
  test('all four endgame builds can clear Champions Road without reward farming', () async {
    for (final build in _roadBuilds) {
      final result = await _runRoad(build);
      expect(
        result.failure,
        isNull,
        reason:
            '${build.name}: stopped at stage ${result.failure}; '
            'gold ${result.gold}, supplies ${result.salves}/${result.tonics}. '
            '${result.log.join(' | ')}',
      );
      expect(result.completedStages, 8, reason: build.name);
      expect(result.gold, 0, reason: '${build.name} must not farm gold');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

Future<
  ({
    int completedStages,
    int? failure,
    int gold,
    int salves,
    int tonics,
    List<String> log,
  })
>
_runRoad(_RoadBuild build) async {
  final initialGold = 0;
  final save = GameSave(
    hasHero: true,
    heroName: build.name,
    level: 20,
    xp: 5358,
    gold: initialGold,
    stats: build.stats,
    completedMatches: {
      for (var id = 1; id <= 32; id++) 'M${id.toString().padLeft(2, '0')}',
    },
    ownedItems: {
      for (final item in shopItems.where((item) => item.act == 4)) item.id,
      if (build.arcane) ...{
        for (final spell in spells) 'spell_${spell.action.name}',
      },
    },
    equippedItems: {
      'weapon': '${build.weapon}_4',
      if (build.bow) 'bow': 'bow_4',
      'head': 'helm_4',
      'body': 'coat_4',
      'boots': 'boots_4',
      'talisman': 'charm_4',
    },
    healingSalves: 3,
    effortTonics: 3,
    masteries: {for (var tier = 1; tier <= 3; tier++) '${build.mastery}_$tier'},
  );
  final controller = GameController(storage: MemorySaveStorage()..value = save);
  await controller.initialize();
  final originalGold = controller.save.gold;

  for (var stage = 1; stage <= 8; stage++) {
    var won = false;
    final attempts = <String>[];
    for (var attempt = 0; attempt < 3 && !won; attempt++) {
      await controller.startChampionsRoad(stage, seed: stage * 1000 + attempt);
      for (
        var turn = 0;
        turn < 120 && !controller.battle!.snapshot.done;
        turn++
      ) {
        final battle = controller.battle!;
        final action = _chooseRoadAction(battle, build);
        final error = await controller.performAction(action);
        if (error != null) {
          attempts.add('turn $turn: $error');
          break;
        }
      }
      final battle = controller.battle!;
      final result = await controller.resolveBattle();
      won = result?.won ?? false;
      attempts.add(
        '#${attempt + 1}: HP ${battle.player.health}/${battle.player.maxHealth}; '
        'opponent ${battle.opponent.health}/${battle.opponent.maxHealth}; '
        'turn ${battle.metrics.turn}; supplies '
        '${controller.save.healingSalves}/${controller.save.effortTonics}',
      );
      if (!won) attempts.addAll(_tail(battle.snapshot.log, 18));
    }

    if (!won) {
      final result = (
        completedStages: controller.save.championsRunBest,
        failure: stage,
        gold: controller.save.gold,
        salves: controller.save.healingSalves,
        tonics: controller.save.effortTonics,
        log: attempts,
      );
      controller.dispose();
      return result;
    }
  }

  final result = (
    completedStages: controller.save.championsRunBest,
    failure: null,
    gold: controller.save.gold,
    salves: controller.save.healingSalves,
    tonics: controller.save.effortTonics,
    log: <String>['gold before ${originalGold}, after ${controller.save.gold}'],
  );
  controller.dispose();
  return result;
}

BattleAction _chooseRoadAction(BattleEngine battle, _RoadBuild build) {
  final player = battle.player;
  final snapshot = battle.snapshot;
  final intent = snapshot.opponentIntent;
  const attackIntents = {
    BattleAction.quick,
    BattleAction.heavy,
    BattleAction.sweep,
    BattleAction.bow,
    BattleAction.emberSpear,
    BattleAction.ashBurst,
  };
  final attacking = attackIntents.contains(intent);
  final healthRatio = player.health / player.maxHealth;
  const attacks = [
    BattleAction.quick,
    BattleAction.heavy,
    BattleAction.sweep,
    BattleAction.bow,
    BattleAction.emberSpear,
    BattleAction.ashBurst,
  ];

  BattleAction? finisher;
  var finisherChance = -1;
  for (final action in attacks) {
    final preview = battle.preview(action);
    if (!preview.canUse || preview.estimatedDamage < battle.opponent.health) {
      continue;
    }
    if (preview.hitChance > finisherChance) {
      finisherChance = preview.hitChance;
      finisher = action;
    }
  }
  if (finisher != null) return finisher;

  if (snapshot.telegraphedHazard) {
    for (final move in [
      BattleAction.openDistance,
      BattleAction.closeDistance,
    ]) {
      if (battle.preview(move).canUse) return move;
    }
  }
  if (build.arcane &&
      attacking &&
      player.shield == 0 &&
      battle.preview(BattleAction.tideWard).canUse) {
    return BattleAction.tideWard;
  }
  // Spending one salve before a telegraphed heavy hit is often better than
  // guarding: the heal can exceed the reduced damage and keep the player in
  // the fight. Guard remains the no-supply answer to lethal attacks.
  if (healthRatio < .68 && battle.preview(BattleAction.salve).canUse) {
    return BattleAction.salve;
  }
  final lethalHeavy =
      intent == BattleAction.heavy &&
      player.health <= battle.preview(BattleAction.heavy).estimatedDamage;
  final lethalSpell =
      intent == BattleAction.ashBurst &&
      player.health <= battle.preview(BattleAction.ashBurst).estimatedDamage;
  if (attacking && (lethalHeavy || lethalSpell)) {
    return BattleAction.guard;
  }

  final wantedRange = build.bow || player.family == WeaponFamily.spear
      ? RangeBand.far
      : RangeBand.close;
  if (snapshot.distance != wantedRange && !attacking) {
    final move = snapshot.distance.index < wantedRange.index
        ? BattleAction.openDistance
        : BattleAction.closeDistance;
    if (battle.preview(move).canUse) return move;
  }

  BattleAction? best;
  var bestScore = -1.0;
  for (final action in attacks) {
    final preview = battle.preview(action);
    if (!preview.canUse) continue;
    final score = preview.estimatedDamage * preview.hitChance / 100;
    if (score > bestScore) {
      bestScore = score;
      best = action;
    }
  }
  if (best != null) return best;
  if (battle.preview(BattleAction.tonic).canUse) return BattleAction.tonic;
  return BattleAction.guard;
}

List<String> _tail(Iterable<String> source, int count) =>
    source.toList().reversed.take(count).toList().reversed.toList();
