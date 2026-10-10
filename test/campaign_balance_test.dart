import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/intermission_decisions.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/balance.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _GrowthStep {
  const _GrowthStep(this.stat, this.target);

  final Stat stat;
  final int target;
}

class _Build {
  const _Build({
    required this.name,
    required this.stats,
    required this.weapon,
    required this.growthPlan,
    required this.masteryTree,
    this.precision = false,
    this.arcane = false,
  });

  final String name;
  final Stats stats;
  final String weapon;
  final List<_GrowthStep> growthPlan;
  final String masteryTree;
  final bool precision;
  final bool arcane;
}

const _builds = [
  _Build(
    name: 'Kuvvet / Tokmak',
    stats: Stats(might: 5, vitality: 3, stamina: 4),
    weapon: 'maul',
    growthPlan: [
      _GrowthStep(Stat.might, 12),
      _GrowthStep(Stat.vitality, 8),
      _GrowthStep(Stat.guard, 8),
      _GrowthStep(Stat.might, 20),
      _GrowthStep(Stat.stamina, 12),
      _GrowthStep(Stat.vitality, 20),
      _GrowthStep(Stat.guard, 20),
    ],
    masteryTree: 'front',
  ),
  _Build(
    name: 'Çeviklik / Kısa kılıç',
    stats: Stats(agility: 5, precision: 3, vitality: 4),
    weapon: 'sword',
    growthPlan: [
      _GrowthStep(Stat.agility, 12),
      _GrowthStep(Stat.precision, 10),
      _GrowthStep(Stat.agility, 20),
      _GrowthStep(Stat.might, 12),
      _GrowthStep(Stat.vitality, 12),
      _GrowthStep(Stat.guard, 12),
    ],
    masteryTree: 'duel',
  ),
  _Build(
    name: 'İsabet / Yay',
    stats: Stats(might: 3, precision: 5, vitality: 4),
    weapon: 'sword',
    growthPlan: [
      _GrowthStep(Stat.precision, 12),
      _GrowthStep(Stat.might, 10),
      _GrowthStep(Stat.agility, 10),
      _GrowthStep(Stat.precision, 20),
      _GrowthStep(Stat.vitality, 12),
      _GrowthStep(Stat.guard, 12),
    ],
    masteryTree: 'duel',
    precision: true,
  ),
  _Build(
    name: 'Büyü / Mızrak',
    stats: Stats(agility: 3, vitality: 4, arcana: 5),
    weapon: 'spear',
    growthPlan: [
      _GrowthStep(Stat.arcana, 12),
      _GrowthStep(Stat.vitality, 10),
      _GrowthStep(Stat.precision, 10),
      _GrowthStep(Stat.arcana, 20),
      _GrowthStep(Stat.agility, 12),
      _GrowthStep(Stat.stamina, 12),
    ],
    masteryTree: 'seal',
    arcane: true,
  ),
];

void main() {
  test('four builds clear the campaign across all 16 intermission decision sequences', () async {
    List<int>? rewardBaseline;
    for (final build in _builds) {
      for (var decisionMask = 0; decisionMask < 16; decisionMask++) {
        final result = await _run(build, decisionMask: decisionMask);
        final label = '${build.name}, decision path $decisionMask';
        expect(
          result.failure,
          isNull,
          reason:
              '$label: stopped at match ${result.failure}, '
              'level ${result.level}, ${result.gold} Sikke. '
              '${result.log.join(' | ')}',
        );
        expect(result.wins, 32, reason: label);
        expect(result.choices, 4, reason: label);
        expect(result.matchRewards, hasLength(32), reason: label);
        rewardBaseline ??= result.matchRewards;
        expect(
          result.matchRewards,
          rewardBaseline,
          reason: '$label changed a main-match first-win payout',
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

typedef _CampaignResult = ({
  int wins,
  int level,
  int gold,
  int? failure,
  List<String> log,
  List<int> matchRewards,
  int choices,
});

Future<_CampaignResult> _run(_Build build, {required int decisionMask}) async {
  final controller = GameController(storage: MemorySaveStorage());
  await controller.initialize();
  await controller.createHero(name: build.name, stats: build.stats);
  var wins = 0;
  var choices = 0;
  final matchRewards = <int>[];

  for (var id = 1; id <= 32; id++) {
    var won = false;
    var lastLog = <String>[];
    final attempts = <String>[];
    for (var attempt = 0; attempt < 3 && !won; attempt++) {
      await _spendProgression(controller, build);
      await _shop(controller, build);
      final encounter = getEncounter(id);
      final matchKey = 'M${id.toString().padLeft(2, '0')}';
      final firstClear = !controller.save.completedMatches.contains(matchKey);
      final supportAlreadyPaid = controller.save.lossSupportPaid.contains(
        matchKey,
      );
      final goldBeforeBattle = controller.save.gold;
      await controller.startEncounter(id, seed: id * 37 + attempt * 17);
      final battle = controller.battle!;
      for (var turn = 0; turn < 100 && !battle.snapshot.done; turn++) {
        final action = _chooseAction(battle, build);
        final error = controller.performAction(action);
        if (error != null) {
          lastLog = _lastLines([...battle.snapshot.log, error], 32);
          break;
        }
      }
      final result = await controller.resolveBattle();
      won = result?.won ?? false;
      if (won && firstClear) {
        final actualPayout = controller.save.gold - goldBeforeBattle;
        final normalizedPayout =
            actualPayout +
            (supportAlreadyPaid
                ? GameBalance.firstLossGold(encounter.gold)
                : 0);
        matchRewards.add(normalizedPayout);
      }
      attempts.add(
        '#${attempt + 1}: HP ${battle.player.health}/${battle.player.maxHealth}; '
        'rakip ${battle.opponent.health}/${battle.opponent.maxHealth}; '
        'faz ${battle.opponent.phase}; tur ${battle.metrics.turn}; '
        'sarf ${battle.metrics.salveUsed}; bakiye ${controller.save.gold}',
      );
      if (!won) {
        lastLog = [
          'HP ${battle.player.health}/${battle.player.maxHealth}; '
              'rakip ${battle.opponent.health}/${battle.opponent.maxHealth}; '
              'faz ${battle.opponent.phase}; tur ${battle.metrics.turn}; '
              'sarf ${battle.metrics.salveUsed}',
          ..._lastLines(battle.snapshot.log, 32),
        ];
      } else if (controller.pendingIntermissionDecision case final decision?) {
        final decisionIndex = intermissionDecisions.indexWhere(
          (entry) => entry.id == decision.id,
        );
        final takesSponsorship = (decisionMask & (1 << decisionIndex)) != 0;
        final trainingStat = _intermissionTrainingStat(controller.save, build);
        final accepted = takesSponsorship || trainingStat == null
            ? await controller.chooseIntermissionReward(
                decision.id,
                reward: IntermissionReward.sponsorship,
              )
            : await controller.chooseIntermissionReward(
                decision.id,
                reward: IntermissionReward.training,
                stat: trainingStat,
              );
        if (accepted) choices++;
      }
    }
    if (!won) {
      final level = controller.save.level;
      final gold = controller.save.gold;
      controller.dispose();
      return (
        wins: wins,
        level: level,
        gold: gold,
        failure: id,
        log: [...attempts, ...lastLog],
        matchRewards: matchRewards,
        choices: choices,
      );
    }
    wins++;
  }

  final result = (
    wins: wins,
    level: controller.save.level,
    gold: controller.save.gold,
    failure: null,
    log: const <String>[],
    matchRewards: matchRewards,
    choices: choices,
  );
  controller.dispose();
  return result;
}

Stat? _intermissionTrainingStat(GameSave save, _Build build) {
  for (final step in build.growthPlan) {
    if (save.stats[step.stat] < 20) return step.stat;
  }
  for (final stat in Stat.values) {
    if (save.stats[stat] < 20) return stat;
  }
  return null;
}

Future<void> _spendProgression(GameController controller, _Build build) async {
  while (controller.save.unspentStatPoints > 0) {
    Stat? stat;
    for (final step in build.growthPlan) {
      if (controller.save.stats[step.stat] < step.target) {
        stat = step.stat;
        break;
      }
    }
    stat ??= Stat.values.cast<Stat?>().firstWhere(
      (candidate) => controller.save.stats[candidate!] < 20,
      orElse: () => null,
    );
    if (stat == null) return;
    await controller.spendStat(stat);
  }

  for (var tier = 1; tier <= 3; tier++) {
    final id = '${build.masteryTree}_$tier';
    if (controller.save.unspentMasteryPoints > 0 &&
        !controller.save.masteries.contains(id)) {
      await controller.unlockMastery(id);
    }
  }
}

Future<void> _shop(GameController controller, _Build build) async {
  final act = controller.unlockedAct;
  final preferredWeapon = shopItems.where(
    (item) => item.id == '${build.weapon}_$act',
  );
  if (controller.save.weaponId == null &&
      (preferredWeapon.isEmpty ||
          preferredWeapon.first.price > controller.save.gold)) {
    for (final item in shopItems) {
      if (item.category != 'weapon' ||
          item.act != act ||
          item.price > controller.save.gold) {
        continue;
      }
      if (await controller.buyItem(item) == null) {
        await controller.equip(item.id);
      }
      break;
    }
  }

  final itemIds = ['${build.weapon}_$act', 'coat_$act'];
  for (final id in itemIds) {
    for (final item in shopItems) {
      if (item.id != id) continue;
      if (controller.save.ownedItems.contains(id)) {
        await controller.equip(id);
        break;
      }
      final error = await controller.buyItem(item);
      if (error == null) await controller.equip(id);
      break;
    }
  }

  if (controller.save.healingSalves == 0) {
    await controller.buyConsumable(salve: true);
  }

  if (build.arcane) {
    final spells = switch (act) {
      1 => [BattleAction.emberSpear, BattleAction.ashBurst],
      2 => [BattleAction.tideWard, BattleAction.saltCleanse],
      _ => [BattleAction.swiftBreeze],
    };
    for (final spell in spells) {
      await controller.buySpell(spell);
    }
  }
  if (build.precision) {
    final bow = shopItems.firstWhere((item) => item.id == 'bow_$act');
    if (controller.save.ownedItems.contains(bow.id)) {
      await controller.equip(bow.id);
    } else if (await controller.buyItem(bow) == null) {
      await controller.equip(bow.id);
    }
  }
}

BattleAction _chooseAction(BattleEngine battle, _Build build) {
  final player = battle.player;
  final snapshot = battle.snapshot;
  final intent = snapshot.opponentIntent;
  final attackIntent = const {
    BattleAction.quick,
    BattleAction.heavy,
    BattleAction.sweep,
    BattleAction.bow,
    BattleAction.emberSpear,
    BattleAction.ashBurst,
  }.contains(intent);
  final healthRatio = player.health / player.maxHealth;
  final attacks = [
    BattleAction.quick,
    BattleAction.heavy,
    BattleAction.sweep,
    BattleAction.bow,
    BattleAction.emberSpear,
    BattleAction.ashBurst,
  ];
  BattleAction? finishAction;
  var finishScore = -1;
  if (snapshot.phase >= battle.encounter.phaseCount) {
    for (final action in attacks) {
      final preview = battle.preview(action);
      if (!preview.canUse || preview.estimatedDamage < battle.opponent.health) {
        continue;
      }
      if (preview.hitChance > finishScore) {
        finishScore = preview.hitChance;
        finishAction = action;
      }
    }
  }
  if (finishAction != null) return finishAction;

  if (snapshot.telegraphedHazard) {
    final move = player.family == WeaponFamily.spear
        ? BattleAction.openDistance
        : BattleAction.closeDistance;
    final alternate = move == BattleAction.openDistance
        ? BattleAction.closeDistance
        : BattleAction.openDistance;
    if (battle.preview(move).canUse) return move;
    if (battle.preview(alternate).canUse) return alternate;
    return BattleAction.guard;
  }

  if (build.arcane &&
      attackIntent &&
      player.shield == 0 &&
      battle.preview(BattleAction.tideWard).canUse) {
    return BattleAction.tideWard;
  }
  if (healthRatio < .65 &&
      (!attackIntent ||
          (intent != BattleAction.heavy && intent != BattleAction.ashBurst)) &&
      battle.preview(BattleAction.salve).canUse) {
    return BattleAction.salve;
  }
  if (player.statuses.isNotEmpty &&
      !attackIntent &&
      battle.preview(BattleAction.saltCleanse).canUse) {
    return BattleAction.saltCleanse;
  }
  if (attackIntent &&
      ((intent == BattleAction.heavy && healthRatio < .55) ||
          (intent == BattleAction.ashBurst && healthRatio < .68))) {
    return BattleAction.guard;
  }

  final wantedRange =
      (build.precision && player.bowPower > 0) ||
          player.family == WeaponFamily.spear
      ? RangeBand.far
      : RangeBand.close;
  if (snapshot.distance != wantedRange && !attackIntent) {
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

List<String> _lastLines(Iterable<String> source, int count) =>
    source.toList().reversed.take(count).toList().reversed.toList();
