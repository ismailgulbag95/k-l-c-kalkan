import 'dart:convert';

import 'balance.dart';

enum Stat { might, agility, precision, vitality, guard, stamina, arcana }

extension StatLabel on Stat {
  String get label => switch (this) {
    Stat.might => 'Kuvvet',
    Stat.agility => 'Çeviklik',
    Stat.precision => 'İsabet',
    Stat.vitality => 'Dayanıklılık',
    Stat.guard => 'Savunma',
    Stat.stamina => 'Kondisyon',
    Stat.arcana => 'Büyü',
  };

  String get key => name;
}

enum WeaponFamily { shortSword, maul, spear, bow }

extension WeaponFamilyLabel on WeaponFamily {
  String get label => switch (this) {
    WeaponFamily.shortSword => 'Kısa kılıç',
    WeaponFamily.maul => 'Tokmak',
    WeaponFamily.spear => 'Mızrak',
    WeaponFamily.bow => 'Yay',
  };
}

enum RangeBand { close, medium, far }

extension RangeLabel on RangeBand {
  String get label => switch (this) {
    RangeBand.close => 'Yakın',
    RangeBand.medium => 'Orta',
    RangeBand.far => 'Uzak',
  };
}

enum StatusKind { stagger, bleed, burn, brokenGuard }

extension StatusLabel on StatusKind {
  String get label => switch (this) {
    StatusKind.stagger => 'Sendeleme',
    StatusKind.bleed => 'Kanama',
    StatusKind.burn => 'Yanma',
    StatusKind.brokenGuard => 'Kırık gard',
  };
}

enum BattleAction {
  quick,
  heavy,
  guard,
  sweep,
  bow,
  emberSpear,
  ashBurst,
  tideWard,
  saltCleanse,
  swiftBreeze,
  shoreStep,
  closeDistance,
  openDistance,
  salve,
  tonic,
}

extension BattleActionLabel on BattleAction {
  String get label => switch (this) {
    BattleAction.quick => 'Hızlı vuruş',
    BattleAction.heavy => 'Güçlü vuruş',
    BattleAction.guard => 'Gard al',
    BattleAction.sweep => 'Çelme',
    BattleAction.bow => 'Menzilli atış',
    BattleAction.emberSpear => 'Köz Mızrağı',
    BattleAction.ashBurst => 'Kül Patlaması',
    BattleAction.tideWard => 'Siper Dalgası',
    BattleAction.saltCleanse => 'Tuz Arındırması',
    BattleAction.swiftBreeze => 'Çevik Esinti',
    BattleAction.shoreStep => 'Kıyı Sıçrayışı',
    BattleAction.closeDistance => 'Yaklaş',
    BattleAction.openDistance => 'Uzaklaş',
    BattleAction.salve => 'Şifa merhemi',
    BattleAction.tonic => 'Efor toniği',
  };
}

class Stats {
  const Stats({
    this.might = 2,
    this.agility = 2,
    this.precision = 2,
    this.vitality = 2,
    this.guard = 2,
    this.stamina = 2,
    this.arcana = 2,
  });

  final int might;
  final int agility;
  final int precision;
  final int vitality;
  final int guard;
  final int stamina;
  final int arcana;

  int operator [](Stat stat) => switch (stat) {
    Stat.might => might,
    Stat.agility => agility,
    Stat.precision => precision,
    Stat.vitality => vitality,
    Stat.guard => guard,
    Stat.stamina => stamina,
    Stat.arcana => arcana,
  };

  Stats withStat(Stat stat, int value) => switch (stat) {
    Stat.might => copyWith(might: value),
    Stat.agility => copyWith(agility: value),
    Stat.precision => copyWith(precision: value),
    Stat.vitality => copyWith(vitality: value),
    Stat.guard => copyWith(guard: value),
    Stat.stamina => copyWith(stamina: value),
    Stat.arcana => copyWith(arcana: value),
  };

  Stats copyWith({
    int? might,
    int? agility,
    int? precision,
    int? vitality,
    int? guard,
    int? stamina,
    int? arcana,
  }) => Stats(
    might: might ?? this.might,
    agility: agility ?? this.agility,
    precision: precision ?? this.precision,
    vitality: vitality ?? this.vitality,
    guard: guard ?? this.guard,
    stamina: stamina ?? this.stamina,
    arcana: arcana ?? this.arcana,
  );

  Map<String, dynamic> toJson() => {
    'might': might,
    'agility': agility,
    'precision': precision,
    'vitality': vitality,
    'guard': guard,
    'stamina': stamina,
    'arcana': arcana,
  };

  factory Stats.fromJson(Map<String, dynamic>? json) => Stats(
    might: json?['might'] as int? ?? 2,
    agility: json?['agility'] as int? ?? 2,
    precision: json?['precision'] as int? ?? 2,
    vitality: json?['vitality'] as int? ?? 2,
    guard: json?['guard'] as int? ?? 2,
    stamina: json?['stamina'] as int? ?? 2,
    arcana: json?['arcana'] as int? ?? 2,
  );
}

class GameSave {
  const GameSave({
    this.schemaVersion = 9,
    this.hasHero = false,
    this.heroName = 'Kıyı Dövüşçüsü',
    this.appearance = 'Kıyı',
    this.headOptionId = 'head_01',
    this.skinToneId = 'skin_01',
    this.bodyProportionId = 'body_01',
    this.facialHairId = 'facial_hair_00',
    this.level = 1,
    this.xp = 0,
    this.gold = GameBalance.startingGold,
    this.unspentStatPoints = 0,
    this.unspentMasteryPoints = 0,
    this.stats = const Stats(),
    this.completedMatches = const {},
    this.audienceBestScores = const {},
    this.lossSupportPaid = const {},
    this.completedContracts = const {},
    this.ownedItems = const {},
    this.equippedItems = const {},
    this.healingSalves = 0,
    this.effortTonics = 0,
    this.masteries = const {},
    this.rebirthCredits = 0,
    this.championsRunBest = 0,
    this.storyBeat = 0,
    this.seenStoryEvidence = const {},
    this.intermissionChoices = const {},
    this.sfxEnabled = true,
    this.musicVolume = 0.65,
    this.sfxVolume = 0.75,
    this.vibrationEnabled = true,
    this.reducedMotion = false,
    this.language = 'tr',
    this.battleCheckpoint,
  });

  final int schemaVersion;
  final bool hasHero;
  final String heroName;
  final String appearance;
  final String headOptionId;
  final String skinToneId;
  final String bodyProportionId;
  final String facialHairId;
  final int level;
  final int xp;
  final int gold;
  final int unspentStatPoints;
  final int unspentMasteryPoints;
  final Stats stats;
  final Set<String> completedMatches;
  final Map<String, int> audienceBestScores;
  final Set<String> lossSupportPaid;
  final Set<String> completedContracts;
  final Set<String> ownedItems;
  final Map<String, String> equippedItems;
  final int healingSalves;
  final int effortTonics;
  final Set<String> masteries;
  final int rebirthCredits;
  final int championsRunBest;
  final int storyBeat;
  final Set<String> seenStoryEvidence;
  final Map<String, String> intermissionChoices;
  final bool sfxEnabled;
  final double musicVolume;
  final double sfxVolume;
  final bool vibrationEnabled;
  final bool reducedMotion;
  final String language;
  final Map<String, dynamic>? battleCheckpoint;

  int get health => GameBalance.maxHealth(stats.vitality, level);
  int get effort => GameBalance.maxEffort(stats.stamina);
  int get mana => GameBalance.maxMana(stats.arcana);
  String? get weaponId => equippedItems['weapon'];
  String? get bowId => equippedItems['bow'];
  String? get armorId => equippedItems['armor'];
  String? get talismanId => equippedItems['talisman'];

  GameSave copyWith({
    int? schemaVersion,
    bool? hasHero,
    String? heroName,
    String? appearance,
    String? headOptionId,
    String? skinToneId,
    String? bodyProportionId,
    String? facialHairId,
    int? level,
    int? xp,
    int? gold,
    int? unspentStatPoints,
    int? unspentMasteryPoints,
    Stats? stats,
    Set<String>? completedMatches,
    Map<String, int>? audienceBestScores,
    Set<String>? lossSupportPaid,
    Set<String>? completedContracts,
    Set<String>? ownedItems,
    Map<String, String>? equippedItems,
    int? healingSalves,
    int? effortTonics,
    Set<String>? masteries,
    int? rebirthCredits,
    int? championsRunBest,
    int? storyBeat,
    Set<String>? seenStoryEvidence,
    Map<String, String>? intermissionChoices,
    bool? sfxEnabled,
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    bool? reducedMotion,
    String? language,
    Map<String, dynamic>? battleCheckpoint,
    bool clearBattleCheckpoint = false,
  }) => GameSave(
    schemaVersion: schemaVersion ?? this.schemaVersion,
    hasHero: hasHero ?? this.hasHero,
    heroName: heroName ?? this.heroName,
    appearance: appearance ?? this.appearance,
    headOptionId: headOptionId ?? this.headOptionId,
    skinToneId: skinToneId ?? this.skinToneId,
    bodyProportionId: bodyProportionId ?? this.bodyProportionId,
    facialHairId: facialHairId ?? this.facialHairId,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    gold: gold ?? this.gold,
    unspentStatPoints: unspentStatPoints ?? this.unspentStatPoints,
    unspentMasteryPoints: unspentMasteryPoints ?? this.unspentMasteryPoints,
    stats: stats ?? this.stats,
    completedMatches: completedMatches ?? this.completedMatches,
    audienceBestScores: audienceBestScores ?? this.audienceBestScores,
    lossSupportPaid: lossSupportPaid ?? this.lossSupportPaid,
    completedContracts: completedContracts ?? this.completedContracts,
    ownedItems: ownedItems ?? this.ownedItems,
    equippedItems: equippedItems ?? this.equippedItems,
    healingSalves: healingSalves ?? this.healingSalves,
    effortTonics: effortTonics ?? this.effortTonics,
    masteries: masteries ?? this.masteries,
    rebirthCredits: rebirthCredits ?? this.rebirthCredits,
    championsRunBest: championsRunBest ?? this.championsRunBest,
    storyBeat: storyBeat ?? this.storyBeat,
    seenStoryEvidence: seenStoryEvidence ?? this.seenStoryEvidence,
    intermissionChoices: intermissionChoices ?? this.intermissionChoices,
    sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    musicVolume: musicVolume ?? this.musicVolume,
    sfxVolume: sfxVolume ?? this.sfxVolume,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    language: language ?? this.language,
    battleCheckpoint: clearBattleCheckpoint
        ? null
        : battleCheckpoint ?? this.battleCheckpoint,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'hasHero': hasHero,
    'heroName': heroName,
    'appearance': appearance,
    'headOptionId': headOptionId,
    'skinToneId': skinToneId,
    'bodyProportionId': bodyProportionId,
    'facialHairId': facialHairId,
    'level': level,
    'xp': xp,
    'gold': gold,
    'unspentStatPoints': unspentStatPoints,
    'unspentMasteryPoints': unspentMasteryPoints,
    'stats': stats.toJson(),
    'completedMatches': completedMatches.toList()..sort(),
    'audienceBestScores': audienceBestScores,
    'lossSupportPaid': lossSupportPaid.toList()..sort(),
    'completedContracts': completedContracts.toList()..sort(),
    'ownedItems': ownedItems.toList()..sort(),
    'equippedItems': equippedItems,
    'healingSalves': healingSalves,
    'effortTonics': effortTonics,
    'masteries': masteries.toList()..sort(),
    'rebirthCredits': rebirthCredits,
    'championsRunBest': championsRunBest,
    'storyBeat': storyBeat,
    'seenStoryEvidence': seenStoryEvidence.toList()..sort(),
    'intermissionChoices': Map.fromEntries(
      intermissionChoices.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    ),
    'sfxEnabled': sfxEnabled,
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'vibrationEnabled': vibrationEnabled,
    'reducedMotion': reducedMotion,
    'language': language,
    if (battleCheckpoint != null) 'battleCheckpoint': battleCheckpoint,
  };

  String encode() => jsonEncode(toJson());

  factory GameSave.fromJson(Map<String, dynamic> json) {
    final equipped =
        (json['equippedItems'] as Map?)?.map(
          (key, value) => MapEntry('$key', '$value'),
        ) ??
        <String, String>{};
    Set<String> readSet(String key) =>
        ((json[key] as List?) ?? const []).map((value) => '$value').toSet();
    double readVolume(String key, double fallback) {
      final value = json[key];
      if (value is! num || !value.isFinite) return fallback;
      return value.toDouble().clamp(0.0, 1.0);
    }

    return GameSave(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      hasHero: json['hasHero'] as bool? ?? false,
      heroName: json['heroName'] as String? ?? 'Kıyı Dövüşçüsü',
      appearance: json['appearance'] as String? ?? 'Kıyı',
      headOptionId: json['headOptionId'] as String? ?? 'head_01',
      skinToneId: json['skinToneId'] as String? ?? 'skin_01',
      bodyProportionId: json['bodyProportionId'] as String? ?? 'body_01',
      facialHairId: json['facialHairId'] as String? ?? 'facial_hair_00',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      gold: json['gold'] as int? ?? 160,
      unspentStatPoints: json['unspentStatPoints'] as int? ?? 0,
      unspentMasteryPoints: json['unspentMasteryPoints'] as int? ?? 0,
      stats: Stats.fromJson(json['stats'] as Map<String, dynamic>?),
      completedMatches: readSet('completedMatches'),
      audienceBestScores:
          (json['audienceBestScores'] as Map?)?.map(
            (key, value) =>
                MapEntry('$key', (value as num).toInt().clamp(0, 3)),
          ) ??
          const <String, int>{},
      lossSupportPaid: readSet('lossSupportPaid'),
      completedContracts: readSet('completedContracts'),
      ownedItems: readSet('ownedItems'),
      equippedItems: equipped,
      healingSalves: json['healingSalves'] as int? ?? 0,
      effortTonics: json['effortTonics'] as int? ?? 0,
      masteries: readSet('masteries'),
      rebirthCredits: json['rebirthCredits'] as int? ?? 0,
      championsRunBest: json['championsRunBest'] as int? ?? 0,
      storyBeat: json['storyBeat'] as int? ?? 0,
      seenStoryEvidence: readSet('seenStoryEvidence'),
      intermissionChoices:
          (json['intermissionChoices'] as Map?)?.map(
            (key, value) => MapEntry('$key', '$value'),
          ) ??
          const <String, String>{},
      sfxEnabled: json['sfxEnabled'] as bool? ?? true,
      musicVolume: readVolume('musicVolume', 0.65),
      sfxVolume: readVolume('sfxVolume', 0.75),
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      language: json['language'] as String? ?? 'tr',
      battleCheckpoint: json['battleCheckpoint'] is Map
          ? Map<String, dynamic>.from(json['battleCheckpoint'] as Map)
          : null,
    );
  }
}
