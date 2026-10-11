import 'dart:math';

/// Single tuning source for player progression, arena combat and recovery.
class GameBalance {
  GameBalance._();

  static const startingGold = 160;
  static const minHitChance = 15;
  static const maxHitChance = 95;
  static const standardHitChance = 75;
  static const guardMultiplier = .55;
  static const masteryGuardMultiplier = .50;
  static const criticalMultiplier = 1.5;
  static const sweepArmorMultiplier = .65;
  static const magicArmorMultiplier = .40;
  static const hazardDamageFraction = .08;
  static const bleedDamageFraction = .02;
  static const burnDamageFraction = .015;
  static const firstLossFraction = .30;
  static const salveFraction = .20;
  static const mirrorPhaseRecoveryFraction = .10;
  static const startingAmmo = [3, 4, 5, 6];
  static const salvePrices = [55, 80, 115, 150];
  static const tonicPrices = [45, 70, 100, 130];
  static const spellPrices = [140, 340, 700, 1400];

  static int maxHealth(int vitality, int level) =>
      80 + 14 * vitality + 2 * level;
  static int maxEffort(int stamina) => 24 + 8 * stamina;
  static int maxMana(int arcana) => 16 + 8 * arcana;

  /// One Arcana point adds one flat point to magic defense.
  static int magicResistanceFromArcana(int arcana) => max(0, arcana);

  static int magicEffectiveArmor({
    required int physicalArmor,
    required int arcana,
  }) =>
      (physicalArmor * magicArmorMultiplier).round() +
      magicResistanceFromArcana(arcana);

  /// Applies Arcana-based resistance to an already-computed elemental tick.
  static int damageAfterArcanaResistance({
    required int damage,
    required int arcana,
  }) => max(
    1,
    (damage * 100 / (100 + magicResistanceFromArcana(arcana))).round(),
  );

  static int movementEffortCost(int agility) =>
      max(1, 4 - ((agility - 2) / 6).floor());

  /// Total XP needed to reach [level], matching the 5,358 XP level-20 curve.
  static int xpThreshold(int level) =>
      level <= 1 ? 0 : (level - 1) * (120 + 9 * (level - 2));

  static int hitChance(double chance) =>
      chance.round().clamp(minHitChance, maxHitChance);

  /// Resistance subtracts percentage points from a status effect's proc chance.
  static int statusChance(int baseChance, int resistance) =>
      (baseChance - resistance.clamp(0, 30)).clamp(0, 100).toInt();

  static int armorFromGuard(int itemArmor, int guard) =>
      itemArmor + (guard * .7).floor();

  static int mitigatedDamage({
    required double baseDamage,
    required int effectiveArmor,
    required bool guarded,
    required bool guardMastery,
  }) {
    final block = guarded
        ? (guardMastery ? masteryGuardMultiplier : guardMultiplier)
        : 1.0;
    return max(1, (baseDamage * 100 / (100 + effectiveArmor) * block).round());
  }

  static int dotDamage({
    required int maxHealth,
    required double fraction,
    required int stacks,
  }) => max(1, (maxHealth * fraction * stacks).round());

  static int firstLossGold(int firstWinGold) =>
      (firstWinGold * firstLossFraction).round();

  static int consumablePrice(int chapter, {required bool salve}) {
    final prices = salve ? salvePrices : tonicPrices;
    return prices[(chapter - 1).clamp(0, prices.length - 1)];
  }
}
