import 'dart:math';

import '../data/content.dart';
import 'balance.dart';
import 'models.dart';

int _checkpointInt(Object? value, int fallback) =>
    value is num ? value.toInt() : fallback;

bool _checkpointBool(Object? value, bool fallback) =>
    value is bool ? value : fallback;

Map<String, dynamic> _checkpointMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

T _checkpointEnum<T extends Enum>(
  Iterable<T> values,
  Object? value,
  T fallback,
) => values.where((entry) => entry.name == value).firstOrNull ?? fallback;

class _CheckpointRandom {
  _CheckpointRandom(int seed) : _random = Random(seed);

  _CheckpointRandom.restore(int seed, Object? raw) : _random = Random(seed) {
    if (raw is! List) return;
    for (final value in raw.whereType<Map>()) {
      final kind = value['kind'];
      final bound = value['bound'];
      if (kind == 'int' && bound is num && bound.toInt() > 0) {
        final normalizedBound = bound.toInt();
        _random.nextInt(normalizedBound);
        _calls.add({'kind': 'int', 'bound': normalizedBound});
      }
    }
  }

  final Random _random;
  final List<Map<String, Object>> _calls = [];

  int nextInt(int max) {
    _calls.add({'kind': 'int', 'bound': max});
    return _random.nextInt(max);
  }

  List<Map<String, Object>> get checkpointCalls =>
      _calls.map((call) => Map<String, Object>.from(call)).toList();
}

class CombatItemStats {
  const CombatItemStats({
    this.weaponPower = 0,
    this.armor = 0,
    this.statusResistance = 0,
    this.might = 0,
    this.agility = 0,
    this.precision = 0,
    this.arcana = 0,
    this.family,
    this.ammoCapacity = 0,
  });
  final int weaponPower;
  final int armor;
  final int statusResistance;
  final int might;
  final int agility;
  final int precision;
  final int arcana;
  final WeaponFamily? family;
  final int ammoCapacity;
}

CombatItemStats _itemStats(String? id) {
  if (id == null) return const CombatItemStats();
  for (final item in shopItems) {
    if (item.id == id) {
      return CombatItemStats(
        weaponPower: item.weaponPower,
        armor: item.armor,
        statusResistance: item.statusResistance,
        might: item.might,
        agility: item.agility,
        precision: item.precision,
        arcana: item.arcana,
        family: item.family,
        ammoCapacity: item.family == WeaponFamily.bow
            ? GameBalance.startingAmmo[item.act - 1]
            : 0,
      );
    }
  }
  return const CombatItemStats();
}

class Combatant {
  Combatant({
    required this.name,
    required this.stats,
    required this.level,
    required this.maxHealth,
    required this.maxEffort,
    required this.maxMana,
    required this.weaponPower,
    required this.family,
    required this.armor,
    this.statusResistance = 0,
    this.elementalImmunities = const {},
    required this.ammo,
    this.ammoCapacity = 0,
    required this.aiStyle,
    int? health,
    int? effort,
    int? mana,
    this.bowPower = 0,
    this.masteries = const {},
  }) : health = health ?? maxHealth,
       effort = effort ?? maxEffort,
       mana = mana ?? maxMana;

  final String name;
  final Stats stats;
  final int level;
  final int maxHealth;
  final int maxEffort;
  final int maxMana;
  final int weaponPower;
  final int bowPower;
  final WeaponFamily family;
  final int armor;
  final int statusResistance;
  final Set<CombatElement> elementalImmunities;
  final bool aiStyle;
  final Set<String> masteries;
  final int ammoCapacity;
  int health;
  int effort;
  int mana;
  int ammo;
  int shield = 0;
  bool guarding = false;
  bool evasionReady = false;
  int accuracyBonus = 0;
  int phase = 1;
  double burnBonusPercent = 0;
  bool firstSpellUsed = false;
  bool counterCritReady = false;
  final Map<StatusKind, int> statuses = {};
  final Map<StatusKind, int> statusTurnsRemaining = {};
  int? brokenGuardExpiresAfterTurn;

  bool get alive => health > 0;
  bool get isPlayer => !aiStyle;

  factory Combatant.player(GameSave save) {
    final weapon = _itemStats(save.weaponId);
    final bow = _itemStats(save.bowId);
    final head = _itemStats(save.equippedItems['head']);
    final armor = _itemStats(save.equippedItems['body']);
    final boots = _itemStats(save.equippedItems['boots']);
    final charm = _itemStats(save.talismanId);
    final equipmentStats = save.stats.copyWith(
      might:
          save.stats.might +
          weapon.might +
          head.might +
          armor.might +
          boots.might +
          charm.might,
      agility:
          save.stats.agility +
          weapon.agility +
          bow.agility +
          head.agility +
          armor.agility +
          boots.agility +
          charm.agility,
      precision:
          save.stats.precision +
          weapon.precision +
          bow.precision +
          head.precision +
          armor.precision +
          boots.precision +
          charm.precision,
      arcana:
          save.stats.arcana +
          weapon.arcana +
          head.arcana +
          armor.arcana +
          boots.arcana +
          charm.arcana,
    );
    return Combatant(
      name: save.heroName,
      stats: equipmentStats,
      level: save.level,
      maxHealth: save.health,
      maxEffort: save.effort,
      maxMana: save.mana,
      weaponPower: weapon.weaponPower == 0 ? 8 : weapon.weaponPower,
      bowPower: bow.weaponPower,
      family: weapon.family ?? WeaponFamily.shortSword,
      armor: head.armor + armor.armor + boots.armor,
      statusResistance: head.statusResistance,
      ammo: bow.ammoCapacity,
      ammoCapacity: bow.ammoCapacity,
      aiStyle: false,
      masteries: save.masteries,
    );
  }

  factory Combatant.mirror(GameSave save) {
    final hero = Combatant.player(save);
    int normalized(int value) => value.clamp(2, 20).toInt();
    final stats = Stats(
      might: normalized(hero.stats.might),
      agility: normalized(hero.stats.agility),
      precision: normalized(hero.stats.precision),
      vitality: normalized(hero.stats.vitality),
      guard: normalized(hero.stats.guard),
      stamina: normalized(hero.stats.stamina),
      arcana: normalized(hero.stats.arcana),
    );
    final useBow = hero.bowPower > 0 && hero.stats.precision > hero.stats.might;
    final family = useBow ? WeaponFamily.bow : hero.family;
    final weaponPower = useBow ? hero.bowPower : hero.weaponPower;
    return Combatant(
      name: 'Ayna Dövüşçü',
      stats: stats,
      level: 20,
      maxHealth: hero.maxHealth,
      maxEffort: hero.maxEffort,
      maxMana: hero.maxMana,
      weaponPower: weaponPower,
      bowPower: useBow ? hero.bowPower : 0,
      family: family,
      armor: hero.armor,
      statusResistance: hero.statusResistance,
      ammo: useBow ? hero.ammo : 0,
      ammoCapacity: useBow ? hero.ammoCapacity : 0,
      aiStyle: true,
      masteries: hero.masteries,
    );
  }

  factory Combatant.opponent(Encounter encounter) {
    final ammoCapacity = encounter.weaponFamily == WeaponFamily.bow
        ? GameBalance.startingAmmo[encounter.chapter - 1]
        : 0;
    return Combatant(
      name: encounter.name,
      stats: encounter.stats,
      level: encounter.level,
      maxHealth: encounter.maxHealth,
      maxEffort: encounter.maxEffort,
      maxMana: encounter.maxMana,
      weaponPower: encounter.weaponPower,
      family: encounter.weaponFamily,
      armor: 0,
      elementalImmunities: encounter.elementalImmunities,
      ammo: ammoCapacity,
      ammoCapacity: ammoCapacity,
      aiStyle: true,
    );
  }
}

class BattleMetrics {
  int turn = 0;
  int playerGuards = 0;
  int hazardDamageTaken = 0;
  int rangeChanges = 0;
  int spellGuards = 0;
  int rangePenaltyAttacks = 0;
  int? spellGuardIntentTurn;
  bool receivedStatus = false;
  bool receivedBleed = false;
  bool usedSweepOrSpell = false;
  bool appliedStatusWithSpell = false;
  bool salveUsed = false;
  bool tonicUsed = false;
  final Set<int> statusPhases = {};
  final Set<String> audienceActionFamilies = {};
  bool answeredAttackIntent = false;
}

class AudienceRule {
  const AudienceRule(this.label, this.completed, {required this.message});

  final String label;
  final bool completed;
  final BattleMessage message;
}

/// Stable presentation message for player-facing battle text.
/// The legacy log strings remain available for existing callers and saves.
enum BattleActor { player, opponent }

class BattleMessage {
  const BattleMessage(this.id, [this.arguments = const {}]);

  final String id;
  final Map<String, Object?> arguments;
}

/// Typed presentation events emitted by the deterministic battle simulation.
/// UI animation, audio, haptics and analytics can consume these without
/// inspecting localized combat-log strings.
enum BattleEventType {
  turnStarted,
  actionStarted,
  attackStarted,
  attackHit,
  attackMiss,
  guardRaised,
  spellCast,
  spellTelegraphed,
  statusApplied,
  statusRemoved,
  damageTaken,
  healed,
  resourceRestored,
  shieldRaised,
  rangeChanged,
  hazardWarned,
  hazardAvoided,
  hazardHit,
  phaseChanged,
  turnEnded,
  battleWon,
  battleLost,
}

class BattleEvent {
  const BattleEvent({
    required this.sequence,
    required this.turn,
    required this.type,
    this.actor,
    this.target,
    this.action,
    this.status,
    this.amount,
    this.healthDamage,
    this.shieldAbsorbed,
  });

  final int sequence;
  final int turn;
  final BattleEventType type;
  final BattleActor? actor;
  final BattleActor? target;
  final BattleAction? action;
  final StatusKind? status;
  final int? amount;
  final int? healthDamage;
  final int? shieldAbsorbed;
}

class AudienceReport {
  const AudienceReport(this.rules);

  final List<AudienceRule> rules;
  int get score => rules.where((rule) => rule.completed).length;
}

List<String> audienceRuleLabels(Encounter encounter) => [
  'En az iki farklı taktik yaklaşım kullan',
  'Gösterilen saldırı niyetine gardla karşılık ver',
  encounter.hazard.isNotEmpty
      ? 'Arena tehlikesinden hasar almadan çık'
      : 'Mesafeyi en az bir kez değiştir',
];

List<BattleMessage> audienceRuleMessages(Encounter encounter) => [
  const BattleMessage('battle.audience.tactics'),
  const BattleMessage('battle.audience.answerAttack'),
  BattleMessage(
    encounter.hazard.isNotEmpty
        ? 'battle.audience.avoidHazard'
        : 'battle.audience.changeRange',
  ),
];

List<AudienceRule> audienceRulesFor(
  Encounter encounter,
  BattleMetrics metrics,
) {
  final labels = audienceRuleLabels(encounter);
  final messages = audienceRuleMessages(encounter);
  return [
    AudienceRule(
      labels[0],
      metrics.audienceActionFamilies.length >= 2,
      message: messages[0],
    ),
    AudienceRule(labels[1], metrics.answeredAttackIntent, message: messages[1]),
    AudienceRule(
      labels[2],
      encounter.hazard.isNotEmpty
          ? metrics.hazardDamageTaken == 0
          : metrics.rangeChanges > 0,
      message: messages[2],
    ),
  ];
}

AudienceReport evaluateAudienceReport(
  Encounter encounter,
  BattleMetrics metrics,
) => AudienceReport(audienceRulesFor(encounter, metrics));

class BattleSnapshot {
  const BattleSnapshot({
    required this.player,
    required this.opponent,
    required this.distance,
    required this.opponentIntent,
    required this.intentLabel,
    required this.intentMessage,
    required this.log,
    required this.messages,
    required this.events,
    required this.done,
    required this.playerWon,
    required this.phase,
    required this.telegraphedHazard,
    required this.hazardWarningTurnsRemaining,
    required this.metrics,
  });
  final Combatant player;
  final Combatant opponent;
  final RangeBand distance;
  final BattleAction opponentIntent;
  final String intentLabel;
  final BattleMessage intentMessage;
  final List<String> log;
  final List<BattleMessage> messages;
  final List<BattleEvent> events;
  final bool done;
  final bool playerWon;
  final int phase;
  final bool telegraphedHazard;
  final int? hazardWarningTurnsRemaining;
  final BattleMetrics metrics;
}

class ActionPreview {
  const ActionPreview({
    required this.hitChance,
    required this.estimatedDamage,
    required this.cost,
    required this.canUse,
    required this.note,
    required this.costMessage,
    required this.noteMessage,
  });
  final int hitChance;
  final int estimatedDamage;
  final String cost;
  final bool canUse;
  final String note;
  final BattleMessage costMessage;
  final BattleMessage? noteMessage;
}

class BattleEngine {
  BattleEngine({
    required this.save,
    required this.encounter,
    required int seed,
    Combatant? opponentOverride,
  }) : _seed = seed,
       _random = _CheckpointRandom(seed),
       player = Combatant.player(save),
       opponent = opponentOverride ?? Combatant.opponent(encounter) {
    _addLog(
      '${encounter.name} sahaya çıkıyor. Rakip: ${encounter.archetype}.',
      'battle.log.encounterIntro',
      {'opponent': BattleActor.opponent, 'archetype': encounter.archetype},
    );
    if (encounter.hazard.isNotEmpty) {
      _addLog(
        'Arena kuralı: ${encounter.hazard}. Tehlike yaklaşırken yer değiştir.',
        'battle.log.arenaRule',
        {'hazard': encounter.hazard},
      );
    }
    _setHazardTelegraphForNextTurn();
    _intent = _chooseIntent();
    _setIntentTelegraph();
  }

  BattleEngine.restoreFromCheckpoint({
    required this.save,
    required this.encounter,
    required Map<String, dynamic> checkpoint,
    Combatant? opponentOverride,
  }) : _seed = _checkpointInt(checkpoint['seed'], 1),
       _random = _CheckpointRandom.restore(
         _checkpointInt(checkpoint['seed'], 1),
         checkpoint['randomCalls'],
       ),
       player = Combatant.player(save),
       opponent = opponentOverride ?? Combatant.opponent(encounter) {
    _restoreCheckpoint(checkpoint);
  }

  final GameSave save;
  final Encounter encounter;
  final int _seed;
  final _CheckpointRandom _random;
  final Combatant player;
  final Combatant opponent;
  final BattleMetrics metrics = BattleMetrics();
  RangeBand distance = RangeBand.medium;
  BattleAction _intent = BattleAction.quick;
  bool _done = false;
  bool _playerWon = false;
  bool _movedThisTurn = false;
  bool _spellGuardedThisTurn = false;
  bool _telegraphedHazard = false;
  int _phaseIntentIndex = 0;
  final List<String> _log = [];
  final List<BattleMessage> _messages = [];
  final List<BattleEvent> _events = [];

  BattleSnapshot get snapshot => BattleSnapshot(
    player: player,
    opponent: opponent,
    distance: distance,
    opponentIntent: _intent,
    intentLabel: _intentLabel(),
    intentMessage: _intentMessage(),
    log: List.unmodifiable(_log),
    messages: List.unmodifiable(_messages),
    events: List.unmodifiable(_events),
    done: _done,
    playerWon: _playerWon,
    phase: opponent.phase,
    telegraphedHazard: _telegraphedHazard,
    hazardWarningTurnsRemaining: _hazardWarningTurnsRemaining,
    metrics: metrics,
  );

  Map<String, dynamic> toCheckpointJson() => {
    'version': 1,
    'seed': _seed,
    'randomCalls': _random.checkpointCalls,
    'player': _combatantCheckpoint(player),
    'opponent': _combatantCheckpoint(opponent),
    'distance': distance.name,
    'intent': _intent.name,
    'done': _done,
    'playerWon': _playerWon,
    'movedThisTurn': _movedThisTurn,
    'spellGuardedThisTurn': _spellGuardedThisTurn,
    'telegraphedHazard': _telegraphedHazard,
    'phaseIntentIndex': _phaseIntentIndex,
    'supplyUsed': _supplyUsed,
    'metrics': _metricsCheckpoint(),
    'log': _log,
    'messages': [for (final message in _messages) _messageCheckpoint(message)],
    'events': [for (final event in _events) _eventCheckpoint(event)],
  };

  void _restoreCheckpoint(Map<String, dynamic> checkpoint) {
    _restoreCombatant(player, _checkpointMap(checkpoint['player']));
    _restoreCombatant(opponent, _checkpointMap(checkpoint['opponent']));
    distance = _checkpointEnum(
      RangeBand.values,
      checkpoint['distance'],
      RangeBand.medium,
    );
    _intent = _checkpointEnum(
      BattleAction.values,
      checkpoint['intent'],
      BattleAction.quick,
    );
    _done = _checkpointBool(checkpoint['done'], false);
    _playerWon = _checkpointBool(checkpoint['playerWon'], false);
    _movedThisTurn = _checkpointBool(checkpoint['movedThisTurn'], false);
    _spellGuardedThisTurn = _checkpointBool(
      checkpoint['spellGuardedThisTurn'],
      false,
    );
    _telegraphedHazard = _checkpointBool(
      checkpoint['telegraphedHazard'],
      false,
    );
    _phaseIntentIndex = _checkpointInt(
      checkpoint['phaseIntentIndex'],
      0,
    ).clamp(0, 1000000);
    _restoreMetrics(_checkpointMap(checkpoint['metrics']));
    if (encounter.hazardSchedule != null) {
      _telegraphedHazard = _hazardWarningTurnsRemaining != null;
    }
    _supplyUsed = _checkpointBool(
      checkpoint['supplyUsed'],
      metrics.salveUsed || metrics.tonicUsed,
    );
    _log
      ..clear()
      ..addAll(
        (checkpoint['log'] as List? ?? const []).map((value) => '$value'),
      );
    _messages
      ..clear()
      ..addAll(
        (checkpoint['messages'] as List? ?? const []).whereType<Map>().map(
          _messageFromCheckpoint,
        ),
      );
    _events
      ..clear()
      ..addAll(
        (checkpoint['events'] as List? ?? const []).whereType<Map>().map(
          _eventFromCheckpoint,
        ),
      );
  }

  Map<String, dynamic> _combatantCheckpoint(Combatant combatant) => {
    'health': combatant.health,
    'effort': combatant.effort,
    'mana': combatant.mana,
    'ammo': combatant.ammo,
    'shield': combatant.shield,
    'guarding': combatant.guarding,
    'evasionReady': combatant.evasionReady,
    'accuracyBonus': combatant.accuracyBonus,
    'phase': combatant.phase,
    'burnBonusPercent': combatant.burnBonusPercent,
    'firstSpellUsed': combatant.firstSpellUsed,
    'counterCritReady': combatant.counterCritReady,
    'statuses': {
      for (final entry in combatant.statuses.entries)
        entry.key.name: entry.value,
    },
    'statusTurnsRemaining': {
      for (final entry in combatant.statusTurnsRemaining.entries)
        entry.key.name: entry.value,
    },
    'brokenGuardExpiresAfterTurn': combatant.brokenGuardExpiresAfterTurn,
  };

  void _restoreCombatant(Combatant combatant, Map<String, dynamic> data) {
    combatant.health = _checkpointInt(
      data['health'],
      combatant.maxHealth,
    ).clamp(0, combatant.maxHealth);
    combatant.effort = _checkpointInt(
      data['effort'],
      combatant.maxEffort,
    ).clamp(0, combatant.maxEffort);
    combatant.mana = _checkpointInt(
      data['mana'],
      combatant.maxMana,
    ).clamp(0, combatant.maxMana);
    combatant.ammo = _checkpointInt(
      data['ammo'],
      combatant.ammo,
    ).clamp(0, combatant.ammoCapacity);
    combatant.shield = _checkpointInt(data['shield'], 0).clamp(0, 9999);
    combatant.guarding = _checkpointBool(data['guarding'], false);
    combatant.evasionReady = _checkpointBool(data['evasionReady'], false);
    combatant.accuracyBonus = _checkpointInt(
      data['accuracyBonus'],
      0,
    ).clamp(-100, 100);
    combatant.phase = _checkpointInt(data['phase'], 1).clamp(1, 10);
    final burnBonus = data['burnBonusPercent'];
    combatant.burnBonusPercent = burnBonus is num && burnBonus.isFinite
        ? burnBonus.toDouble().clamp(0, 1).toDouble()
        : 0;
    combatant.firstSpellUsed = _checkpointBool(data['firstSpellUsed'], false);
    combatant.counterCritReady = _checkpointBool(
      data['counterCritReady'],
      false,
    );
    combatant.statuses
      ..clear()
      ..addAll(_statusMap(data['statuses']));
    combatant.statusTurnsRemaining
      ..clear()
      ..addAll(_statusMap(data['statusTurnsRemaining']));
    final expiry = data['brokenGuardExpiresAfterTurn'];
    combatant.brokenGuardExpiresAfterTurn = expiry is num
        ? expiry.toInt().clamp(0, 9999)
        : null;
  }

  Map<StatusKind, int> _statusMap(Object? raw) {
    final result = <StatusKind, int>{};
    if (raw is! Map) return result;
    for (final entry in raw.entries) {
      final status = _checkpointEnum(
        StatusKind.values,
        '${entry.key}',
        StatusKind.stagger,
      );
      if (!StatusKind.values.any((candidate) => candidate.name == entry.key)) {
        continue;
      }
      final value = _checkpointInt(entry.value, 0);
      if (value > 0) result[status] = value.clamp(1, 2);
    }
    return result;
  }

  Map<String, dynamic> _metricsCheckpoint() => {
    'turn': metrics.turn,
    'playerGuards': metrics.playerGuards,
    'hazardDamageTaken': metrics.hazardDamageTaken,
    'rangeChanges': metrics.rangeChanges,
    'spellGuards': metrics.spellGuards,
    'rangePenaltyAttacks': metrics.rangePenaltyAttacks,
    'spellGuardIntentTurn': metrics.spellGuardIntentTurn,
    'receivedStatus': metrics.receivedStatus,
    'receivedBleed': metrics.receivedBleed,
    'usedSweepOrSpell': metrics.usedSweepOrSpell,
    'appliedStatusWithSpell': metrics.appliedStatusWithSpell,
    'salveUsed': metrics.salveUsed,
    'tonicUsed': metrics.tonicUsed,
    'statusPhases': metrics.statusPhases.toList()..sort(),
    'audienceActionFamilies': metrics.audienceActionFamilies.toList()..sort(),
    'answeredAttackIntent': metrics.answeredAttackIntent,
  };

  void _restoreMetrics(Map<String, dynamic> data) {
    metrics.turn = _checkpointInt(data['turn'], 0).clamp(0, 9999);
    metrics.playerGuards = _checkpointInt(
      data['playerGuards'],
      0,
    ).clamp(0, 9999);
    metrics.hazardDamageTaken = _checkpointInt(
      data['hazardDamageTaken'],
      0,
    ).clamp(0, 999999);
    metrics.rangeChanges = _checkpointInt(
      data['rangeChanges'],
      0,
    ).clamp(0, 9999);
    metrics.spellGuards = _checkpointInt(data['spellGuards'], 0).clamp(0, 9999);
    metrics.rangePenaltyAttacks = _checkpointInt(
      data['rangePenaltyAttacks'],
      0,
    ).clamp(0, 9999);
    final spellGuardTurn = data['spellGuardIntentTurn'];
    metrics.spellGuardIntentTurn = spellGuardTurn is num
        ? spellGuardTurn.toInt().clamp(0, 9999)
        : null;
    metrics.receivedStatus = _checkpointBool(data['receivedStatus'], false);
    metrics.receivedBleed = _checkpointBool(data['receivedBleed'], false);
    metrics.usedSweepOrSpell = _checkpointBool(data['usedSweepOrSpell'], false);
    metrics.appliedStatusWithSpell = _checkpointBool(
      data['appliedStatusWithSpell'],
      false,
    );
    metrics.salveUsed = _checkpointBool(data['salveUsed'], false);
    metrics.tonicUsed = _checkpointBool(data['tonicUsed'], false);
    metrics.statusPhases
      ..clear()
      ..addAll(
        (data['statusPhases'] as List? ?? const []).whereType<num>().map(
          (value) => value.toInt().clamp(1, 10),
        ),
      );
    metrics.audienceActionFamilies
      ..clear()
      ..addAll(
        (data['audienceActionFamilies'] as List? ?? const [])
            .map((value) => '$value')
            .where((value) => value.length <= 40),
      );
    metrics.answeredAttackIntent = _checkpointBool(
      data['answeredAttackIntent'],
      false,
    );
  }

  Map<String, dynamic> _messageCheckpoint(BattleMessage message) => {
    'id': message.id,
    'arguments': {
      for (final entry in message.arguments.entries)
        entry.key: _encodeCheckpointValue(entry.value),
    },
  };

  BattleMessage _messageFromCheckpoint(Map data) {
    final arguments = _checkpointMap(data['arguments']);
    return BattleMessage(
      '${data['id'] ?? ''}',
      arguments.map(
        (key, value) => MapEntry(key, _decodeCheckpointValue(value)),
      ),
    );
  }

  Object? _encodeCheckpointValue(Object? value) {
    if (value is Enum) {
      return {'_enum': value.runtimeType.toString(), 'name': value.name};
    }
    if (value is Map) {
      return value.map(
        (key, child) => MapEntry('$key', _encodeCheckpointValue(child)),
      );
    }
    if (value is Iterable) return value.map(_encodeCheckpointValue).toList();
    return value;
  }

  Object? _decodeCheckpointValue(Object? value) {
    if (value is List) return value.map(_decodeCheckpointValue).toList();
    if (value is! Map) return value;
    final enumType = value['_enum'];
    final enumName = value['name'];
    if (enumType is String && enumName is String) {
      return switch (enumType) {
        'BattleActor' => _checkpointEnum(
          BattleActor.values,
          enumName,
          BattleActor.player,
        ),
        'BattleAction' => _checkpointEnum(
          BattleAction.values,
          enumName,
          BattleAction.quick,
        ),
        'StatusKind' => _checkpointEnum(
          StatusKind.values,
          enumName,
          StatusKind.stagger,
        ),
        'TaughtTactic' => _checkpointEnum(
          TaughtTactic.values,
          enumName,
          TaughtTactic.striker,
        ),
        'RangeBand' => _checkpointEnum(
          RangeBand.values,
          enumName,
          RangeBand.medium,
        ),
        _ => enumName,
      };
    }
    return value.map(
      (key, child) => MapEntry('$key', _decodeCheckpointValue(child)),
    );
  }

  Map<String, dynamic> _eventCheckpoint(BattleEvent event) => {
    'sequence': event.sequence,
    'turn': event.turn,
    'type': event.type.name,
    'actor': event.actor?.name,
    'target': event.target?.name,
    'action': event.action?.name,
    'status': event.status?.name,
    'amount': event.amount,
    'healthDamage': event.healthDamage,
    'shieldAbsorbed': event.shieldAbsorbed,
  };

  BattleEvent _eventFromCheckpoint(Map data) {
    final actorName = data['actor'];
    final targetName = data['target'];
    final actionName = data['action'];
    final statusName = data['status'];
    return BattleEvent(
      sequence: _checkpointInt(data['sequence'], 0),
      turn: _checkpointInt(data['turn'], metrics.turn),
      type: _checkpointEnum(
        BattleEventType.values,
        data['type'],
        BattleEventType.turnStarted,
      ),
      actor: actorName == null
          ? null
          : _checkpointEnum(BattleActor.values, actorName, BattleActor.player),
      target: targetName == null
          ? null
          : _checkpointEnum(BattleActor.values, targetName, BattleActor.player),
      action: actionName == null
          ? null
          : _checkpointEnum(
              BattleAction.values,
              actionName,
              BattleAction.quick,
            ),
      status: statusName == null
          ? null
          : _checkpointEnum(StatusKind.values, statusName, StatusKind.stagger),
      amount: _optionalCheckpointInt(data['amount']),
      healthDamage: _optionalCheckpointInt(data['healthDamage']),
      shieldAbsorbed: _optionalCheckpointInt(data['shieldAbsorbed']),
    );
  }

  int? _optionalCheckpointInt(Object? value) =>
      value is num ? value.toInt() : null;

  void _addLog(
    String legacyText,
    String messageId, [
    Map<String, Object?> arguments = const {},
  ]) {
    _log.add(legacyText);
    _messages.add(BattleMessage(messageId, arguments));
  }

  void _emitEvent(
    BattleEventType type, {
    BattleActor? actor,
    BattleActor? target,
    BattleAction? action,
    StatusKind? status,
    int? amount,
    int? healthDamage,
    int? shieldAbsorbed,
  }) {
    _events.add(
      BattleEvent(
        sequence: _events.length,
        turn: metrics.turn,
        type: type,
        actor: actor,
        target: target,
        action: action,
        status: status,
        amount: amount,
        healthDamage: healthDamage,
        shieldAbsorbed: shieldAbsorbed,
      ),
    );
  }

  BattleActor _battleActor(Combatant combatant) =>
      combatant.isPlayer ? BattleActor.player : BattleActor.opponent;

  int hitChance(
    Combatant attacker,
    Combatant defender,
    BattleAction action, {
    bool preview = false,
  }) {
    var chance =
        GameBalance.standardHitChance +
        1.25 * (attacker.stats.precision - defender.stats.agility);
    if (action == BattleAction.quick) chance += 10;
    if (action == BattleAction.heavy) chance -= 10;
    if (action == BattleAction.emberSpear) chance += 5;
    if (action == BattleAction.ashBurst) chance -= 10;
    if (action == BattleAction.bow && distance == RangeBand.close) chance -= 15;
    chance += attacker.accuracyBonus;
    if (attacker.statuses.containsKey(StatusKind.stagger)) chance -= 10;
    if (action == BattleAction.quick && attacker.masteries.contains('duel_1')) {
      chance += 3;
    }
    if (_isSpell(action) &&
        attacker.masteries.contains('seal_1') &&
        !attacker.firstSpellUsed) {
      chance += 5;
    }
    if (defender.evasionReady) chance -= 10;
    if (action != BattleAction.bow && !_isSpell(action)) {
      if (attacker.family == WeaponFamily.shortSword &&
          distance == RangeBand.close) {
        chance += 8;
      }
      if ((attacker.family == WeaponFamily.shortSword ||
              attacker.family == WeaponFamily.maul) &&
          distance == RangeBand.far) {
        chance -= 30;
      }
      if (attacker.family == WeaponFamily.spear && distance == RangeBand.far) {
        chance += 8;
      }
      if (attacker.family == WeaponFamily.spear && distance == RangeBand.close) {
        chance -= 5;
      }
    }
    if (action == BattleAction.bow && distance == RangeBand.far) chance += 5;
    return GameBalance.hitChance(chance);
  }

  ActionPreview preview(BattleAction action) {
    final cost = _cost(action, player);
    final isSpell = _isSpell(action);
    final needsUnlock = isSpell || action == BattleAction.shoreStep;
    final hasSpell =
        !needsUnlock || save.ownedItems.contains('spell_${action.name}');
    final nextTurn = metrics.turn + 1;
    final manaAtAction = min(
      player.maxMana,
      player.mana +
          (nextTurn % 3 == 0
              ? (player.masteries.contains('seal_2') ? 4 : 2)
              : 0),
    );
    final hasSupply = switch (action) {
      BattleAction.salve =>
        save.healingSalves > 0 && _projectedSalveHealing(player) > 0,
      BattleAction.tonic =>
        save.effortTonics > 0 && _projectedTonicRestoration(player) > 0,
      _ => true,
    };
    final canUse =
        !_done && hasSpell && (!isSpell || manaAtAction >= cost.mana);
    final canUseSupply = canUse && hasSupply && !_supplyUsed;
    final freeAction =
        action == BattleAction.guard ||
        action == BattleAction.salve ||
        action == BattleAction.tonic;
    final canUseCost =
        freeAction ||
        (isSpell
            ? canUse
            : min(player.maxEffort, player.effort + 4) >= cost.effort &&
                  (action != BattleAction.bow || player.ammo > 0));
    final can = action == BattleAction.salve || action == BattleAction.tonic
        ? canUseSupply && canUseCost
        : canUse && canUseCost;
    final canChangeRange = switch (action) {
      BattleAction.closeDistance => distance != RangeBand.close,
      BattleAction.openDistance => distance != RangeBand.far,
      _ => true,
    };
    final noteMessage =
        action == BattleAction.bow && distance == RangeBand.close
        ? const BattleMessage('battle.preview.note.bowPenalty')
        : action == BattleAction.sweep
        ? const BattleMessage('battle.preview.note.sweepArmor')
        : action == BattleAction.guard
        ? const BattleMessage('battle.preview.note.guard')
        : null;
    return ActionPreview(
      hitChance: _isAttack(action)
          ? hitChance(player, opponent, action, preview: true)
          : 0,
      estimatedDamage: _estimatedDamage(player, opponent, action),
      cost: _costLabel(action, player),
      canUse: can && canChangeRange,
      note: action == BattleAction.bow && distance == RangeBand.close
          ? 'Yakında −15 isabet'
          : action == BattleAction.sweep
          ? 'Zırhın %35’ini yok sayar'
          : action == BattleAction.guard
          ? 'Sonraki hasarı %45 azaltır, 4 efor kazanır'
          : '',
      costMessage: _costMessage(action, player),
      noteMessage: noteMessage,
    );
  }

  String? perform(BattleAction action) {
    if (_done) return 'Düello tamamlandı.';
    final available = preview(action);
    if (!available.canUse) return 'Bu hamle şu anda kullanılamıyor.';
    metrics.turn++;
    _expireBrokenGuard(player);
    _expireBrokenGuard(opponent);
    _emitEvent(BattleEventType.turnStarted, actor: BattleActor.player);
    metrics.audienceActionFamilies.add(_audienceFamily(action));
    if (action == BattleAction.guard && _isAttack(_intent)) {
      metrics.answeredAttackIntent = true;
    }
    final playerTurn = metrics.turn;
    player.effort = min(player.maxEffort, player.effort + 4);
    if (playerTurn % 3 == 0) {
      player.mana = min(
        player.maxMana,
        player.mana + (player.masteries.contains('seal_2') ? 4 : 2),
      );
    }
    _tickDamageStatuses(player, actor: BattleActor.player);
    if (!player.alive) {
      _finish(false);
      return null;
    }
    _movedThisTurn = false;
    _spellGuardedThisTurn = false;

    _performAction(player, opponent, action, playerAction: true);
    _removeStatus(player, StatusKind.stagger);
    if (!opponent.alive) {
      _finish(true);
      return null;
    }

    _resolvePhaseChange();
    if (_done) return null;
    _resolveHazard();
    if (!player.alive) {
      _finish(false);
      return null;
    }

    _tickDamageStatuses(opponent, actor: BattleActor.opponent);
    if (!opponent.alive) {
      _finish(true);
      return null;
    }
    opponent.effort = min(opponent.maxEffort, opponent.effort + 4);
    if (playerTurn % 3 == 0) {
      opponent.mana = min(opponent.maxMana, opponent.mana + 2);
    }
    if (_intent == BattleAction.guard && _random.nextInt(100) < 68) {
      opponent.guarding = true;
      opponent.effort = min(opponent.maxEffort, opponent.effort + 4);
      _emitEvent(
        BattleEventType.guardRaised,
        actor: BattleActor.opponent,
        action: BattleAction.guard,
      );
      _addLog('${opponent.name} gard aldı.', 'battle.log.guard', {
        'actor': BattleActor.opponent,
      });
    } else if (_intent == BattleAction.closeDistance ||
        _intent == BattleAction.openDistance) {
      _moveOpponent();
    } else {
      _performAction(opponent, player, _intent, playerAction: false);
    }
    _removeStatus(opponent, StatusKind.stagger);
    _spellGuardedThisTurn =
        _spellGuardedThisTurn ||
        (_intent == BattleAction.emberSpear ||
            _intent == BattleAction.ashBurst ||
            _intent == BattleAction.tideWard);
    if (_spellGuardedThisTurn && action == BattleAction.guard) {
      metrics.spellGuards++;
    }
    if (!player.alive) {
      _finish(false);
      return null;
    }
    if (action == BattleAction.guard &&
        player.masteries.contains('duel_3') &&
        _isAttack(_intent)) {
      player.counterCritReady = true;
    }
    _resolvePhaseChange();
    _setHazardTelegraphForNextTurn();
    _intent = _chooseIntent();
    _setIntentTelegraph();
    _emitEvent(BattleEventType.turnEnded, actor: BattleActor.player);
    return null;
  }

  bool _supplyUsed = false;

  void _performAction(
    Combatant actor,
    Combatant target,
    BattleAction action, {
    required bool playerAction,
  }) {
    final cost = _cost(action, actor);
    final actorId = _battleActor(actor);
    _emitEvent(BattleEventType.actionStarted, actor: actorId, action: action);
    if (_isAttack(action)) {
      _emitEvent(
        BattleEventType.attackStarted,
        actor: actorId,
        target: _battleActor(target),
        action: action,
      );
    } else if (_isSpell(action)) {
      _emitEvent(
        BattleEventType.spellCast,
        actor: actorId,
        target: _battleActor(target),
        action: action,
      );
    }
    switch (action) {
      case BattleAction.guard:
        _emitEvent(BattleEventType.guardRaised, actor: actorId, action: action);
        actor.guarding = true;
        actor.effort = min(
          actor.maxEffort,
          actor.effort + 4 + (actor.masteries.contains('front_3') ? 2 : 0),
        );
        if (playerAction) metrics.playerGuards++;
        _addLog('${actor.name} gard aldı.', 'battle.log.guard', {
          'actor': _battleActor(actor),
        });
        return;
      case BattleAction.closeDistance:
        _changeDistance(-1);
        _emitEvent(
          BattleEventType.rangeChanged,
          actor: actorId,
          action: action,
          amount: RangeBand.values.indexOf(distance),
        );
        _movedThisTurn = true;
        if (playerAction && actor.masteries.contains('duel_2')) {
          actor.evasionReady = true;
        }
        if (playerAction) metrics.rangeChanges++;
        actor.effort = max(0, actor.effort - cost.effort);
        _addLog(
          '${actor.name} mesafeyi kapatıyor: ${distance.label}.',
          'battle.log.closeDistance',
          {'actor': _battleActor(actor), 'range': distance},
        );
        return;
      case BattleAction.openDistance:
        _changeDistance(1);
        _emitEvent(
          BattleEventType.rangeChanged,
          actor: actorId,
          action: action,
          amount: RangeBand.values.indexOf(distance),
        );
        _movedThisTurn = true;
        if (playerAction && actor.masteries.contains('duel_2')) {
          actor.evasionReady = true;
        }
        if (playerAction) metrics.rangeChanges++;
        actor.effort = max(0, actor.effort - cost.effort);
        _addLog(
          '${actor.name} geri çekiliyor: ${distance.label}.',
          'battle.log.openDistance',
          {'actor': _battleActor(actor), 'range': distance},
        );
        return;
      case BattleAction.salve:
        _supplyUsed = true;
        if (playerAction) metrics.salveUsed = true;
        final healed = min(
          actor.maxHealth - actor.health,
          (actor.maxHealth * GameBalance.salveFraction).round(),
        );
        actor.health += healed;
        _emitEvent(BattleEventType.healed, actor: actorId, amount: healed);
        _addLog(
          '${actor.name} şifa merhemi kullandı: +$healed sağlık.',
          'battle.log.salve',
          {'actor': _battleActor(actor), 'amount': healed},
        );
        return;
      case BattleAction.tonic:
        _supplyUsed = true;
        if (playerAction) metrics.tonicUsed = true;
        final restored = min(actor.maxEffort - actor.effort, 10);
        actor.effort = min(actor.maxEffort, actor.effort + 10);
        _emitEvent(
          BattleEventType.resourceRestored,
          actor: actorId,
          amount: restored,
        );
        _addLog(
          '${actor.name} efor toniği kullandı: +10 efor.',
          'battle.log.tonic',
          {'actor': _battleActor(actor), 'amount': 10},
        );
        return;
      case BattleAction.tideWard:
        actor.mana -= cost.mana;
        actor.shield = 20 + 2 * actor.stats.arcana;
        _emitEvent(
          BattleEventType.shieldRaised,
          actor: actorId,
          amount: actor.shield,
          action: action,
        );
        _addLog(
          '${actor.name}, ${actor.shield} hasar emen bir siper kurdu.',
          'battle.log.tideWard',
          {'actor': _battleActor(actor), 'amount': actor.shield},
        );
        return;
      case BattleAction.saltCleanse:
        actor.mana -= cost.mana;
        if (actor.statuses.isNotEmpty) {
          final removed = actor.statuses.keys.first;
          _removeStatus(actor, removed);
          _emitEvent(
            BattleEventType.statusRemoved,
            actor: actorId,
            target: actorId,
            status: removed,
            action: action,
          );
        }
        final healed = min(
          actor.maxHealth - actor.health,
          8 + actor.stats.arcana,
        );
        actor.health += healed;
        _emitEvent(
          BattleEventType.healed,
          actor: actorId,
          amount: healed,
          action: action,
        );
        _addLog(
          '${actor.name} olumsuz etkiyi arındırdı ve $healed sağlık kazandı.',
          'battle.log.saltCleanse',
          {'actor': _battleActor(actor), 'amount': healed},
        );
        return;
      case BattleAction.swiftBreeze:
        actor.mana -= cost.mana;
        actor.evasionReady = true;
        actor.accuracyBonus = 8;
        _addLog(
          '${actor.name} çevik esintiyle sonraki hamlesini hazırladı.',
          'battle.log.swiftBreeze',
          {'actor': _battleActor(actor)},
        );
        return;
      case BattleAction.shoreStep:
        actor.effort -= cost.effort;
        actor.evasionReady = true;
        _changeDistance(distance == RangeBand.far ? -1 : 1);
        _emitEvent(
          BattleEventType.rangeChanged,
          actor: actorId,
          action: action,
          amount: RangeBand.values.indexOf(distance),
        );
        _movedThisTurn = true;
        if (playerAction) metrics.rangeChanges++;
        _addLog(
          '${actor.name} kıyı sıçrayışıyla mesafeyi değiştirdi.',
          'battle.log.shoreStep',
          {'actor': _battleActor(actor), 'range': distance},
        );
        return;
      default:
        break;
    }

    if (cost.mana > 0) {
      actor.mana -= cost.mana;
    } else {
      actor.effort = max(0, actor.effort - cost.effort);
    }
    if (action == BattleAction.bow) {
      actor.ammo = max(0, actor.ammo - 1);
    }
    if (playerAction && _isAttack(action) && _hasRangePenalty(actor, action)) {
      metrics.rangePenaltyAttacks++;
    }
    if (playerAction && (action == BattleAction.sweep || _isSpell(action))) {
      metrics.usedSweepOrSpell = true;
    }
    final chance = hitChance(actor, target, action);
    if (_isSpell(action)) actor.firstSpellUsed = true;
    final roll = _random.nextInt(100);
    if (roll >= chance) {
      _emitEvent(
        BattleEventType.attackMiss,
        actor: actorId,
        target: _battleActor(target),
        action: action,
      );
      _addLog(
        '${actor.name} — ${action.label}: ıskaladı (%$chance).',
        'battle.log.miss',
        {'actor': _battleActor(actor), 'action': action, 'chance': chance},
      );
      actor.evasionReady = false;
      actor.accuracyBonus = 0;
      target.evasionReady = false;
      return;
    }

    if (action == BattleAction.ashBurst) {
      final damage = _damage(actor, target, action);
      _dealDamage(target, damage);
      _emitEvent(
        BattleEventType.attackHit,
        actor: actorId,
        target: _battleActor(target),
        action: action,
        amount: damage,
      );
      _tryApplyStatus(
        target,
        StatusKind.burn,
        2,
        baseChance: 100,
        viaSpell: playerAction,
        source: actorId,
        element: CombatElement.ember,
        burnBonusPercent: actor.masteries.contains('seal_3') ? .01 : 0,
      );
      _addLog(
        '${actor.name}, ${action.label} ile $damage hasar ve yanma uyguladı.',
        'battle.log.ashBurstHit',
        {'actor': _battleActor(actor), 'action': action, 'damage': damage},
      );
    } else if (action == BattleAction.emberSpear ||
        action == BattleAction.quick ||
        action == BattleAction.heavy ||
        action == BattleAction.sweep ||
        action == BattleAction.bow) {
      final damage = _damage(actor, target, action);
      _dealDamage(target, damage);
      _emitEvent(
        BattleEventType.attackHit,
        actor: actorId,
        target: _battleActor(target),
        action: action,
        amount: damage,
      );
      _addLog(
        '${actor.name}, ${action.label} ile $damage hasar verdi (%$chance).',
        'battle.log.hit',
        {
          'actor': _battleActor(actor),
          'action': action,
          'damage': damage,
          'chance': chance,
        },
      );
      if (action == BattleAction.sweep) {
        final applied = _tryApplyStatus(
          target,
          StatusKind.brokenGuard,
          1,
          baseChance: 100,
          viaSpell: false,
          source: actorId,
        );
        if (applied) {
          _addLog(
            '${target.name} gardı kırıldı: zırhı bir sonraki tur %20 azalır.',
            'battle.log.brokenGuard',
            {'target': _battleActor(target)},
          );
        }
      }
      if (action == BattleAction.heavy &&
          _tryApplyStatus(
            target,
            StatusKind.stagger,
            1,
            baseChance: 15,
            viaSpell: false,
            source: actorId,
          )) {
        _addLog('${target.name} sendeledi.', 'battle.log.stagger', {
          'target': _battleActor(target),
        });
      }
      if (actor.aiStyle &&
          encounter.archetype.contains('durum etkili') &&
          (action == BattleAction.quick || action == BattleAction.sweep) &&
          _tryApplyStatus(
            target,
            StatusKind.bleed,
            2,
            baseChance: 30,
            viaSpell: false,
            source: actorId,
          )) {
        _addLog('${target.name} kanama etkisi aldı.', 'battle.log.bleed', {
          'target': _battleActor(target),
        });
      }
    }
    actor.evasionReady = false;
    actor.accuracyBonus = 0;
    target.evasionReady = false;
  }

  ({int effort, int mana}) _cost(BattleAction action, [Combatant? actor]) =>
      switch (action) {
        BattleAction.quick => (effort: 5, mana: 0),
        BattleAction.heavy => (effort: 12, mana: 0),
        BattleAction.sweep => (effort: 8, mana: 0),
        BattleAction.bow => (effort: 6, mana: 0),
        BattleAction.emberSpear => (effort: 0, mana: 8),
        BattleAction.ashBurst => (effort: 0, mana: 16),
        BattleAction.tideWard => (effort: 0, mana: 10),
        BattleAction.saltCleanse => (effort: 0, mana: 12),
        BattleAction.swiftBreeze => (effort: 0, mana: 10),
        BattleAction.shoreStep => (effort: 12, mana: 0),
        BattleAction.closeDistance || BattleAction.openDistance => (
          effort: actor == null
              ? 4
              : GameBalance.movementEffortCost(actor.stats.agility),
          mana: 0,
        ),
        _ => (effort: 0, mana: 0),
      };

  String _costLabel(BattleAction action, Combatant actor) {
    final cost = _cost(action, actor);
    if (action == BattleAction.bow) return '${cost.effort} efor · 1 fişek';
    if (cost.mana > 0) return '${cost.mana} mana';
    return cost.effort == 0 ? 'Ücretsiz' : '${cost.effort} efor';
  }

  BattleMessage _costMessage(BattleAction action, Combatant actor) {
    final cost = _cost(action, actor);
    if (action == BattleAction.bow) {
      return BattleMessage('battle.preview.cost.bow', {
        'effort': cost.effort,
        'ammo': 1,
      });
    }
    if (cost.mana > 0) {
      return BattleMessage('battle.preview.cost.mana', {'mana': cost.mana});
    }
    if (cost.effort == 0) {
      return const BattleMessage('battle.preview.cost.free');
    }
    return BattleMessage('battle.preview.cost.effort', {'effort': cost.effort});
  }

  bool _isSpell(BattleAction action) => switch (action) {
    BattleAction.emberSpear ||
    BattleAction.ashBurst ||
    BattleAction.tideWard ||
    BattleAction.saltCleanse ||
    BattleAction.swiftBreeze => true,
    _ => false,
  };

  int _projectedSalveHealing(Combatant target) {
    var projectedHealth = target.health;
    for (final status in [StatusKind.burn, StatusKind.bleed]) {
      final stacks = target.statuses[status] ?? 0;
      final turns = target.statusTurnsRemaining[status] ?? 0;
      if (stacks <= 0 || turns <= 0) continue;
      if (_isImmuneToStatus(target, status)) continue;
      projectedHealth -= _damageOverTime(target, status, stacks);
    }
    if (projectedHealth <= 0) return 0;
    return min(
      target.maxHealth - projectedHealth,
      (target.maxHealth * GameBalance.salveFraction).round(),
    );
  }

  int _projectedTonicRestoration(Combatant target) {
    final effortAfterRegen = min(target.maxEffort, target.effort + 4);
    return target.maxEffort - effortAfterRegen;
  }

  void _expireBrokenGuard(Combatant target) {
    final expiresAfter = target.brokenGuardExpiresAfterTurn;
    if (expiresAfter == null || metrics.turn <= expiresAfter) return;
    _removeStatus(target, StatusKind.brokenGuard);
  }

  void _removeStatus(Combatant target, StatusKind status) {
    target.statuses.remove(status);
    target.statusTurnsRemaining.remove(status);
    if (status == StatusKind.burn) target.burnBonusPercent = 0;
    if (status == StatusKind.brokenGuard) {
      target.brokenGuardExpiresAfterTurn = null;
    }
  }

  String _audienceFamily(BattleAction action) {
    if (_isSpell(action)) return 'magic';
    return switch (action) {
      BattleAction.quick ||
      BattleAction.heavy ||
      BattleAction.sweep ||
      BattleAction.bow => 'attack',
      BattleAction.guard => 'defense',
      BattleAction.closeDistance ||
      BattleAction.openDistance ||
      BattleAction.shoreStep => 'positioning',
      BattleAction.salve || BattleAction.tonic => 'support',
      _ => action.name,
    };
  }

  bool _hasRangePenalty(Combatant attacker, BattleAction action) {
    if (action == BattleAction.bow) return distance == RangeBand.close;
    if (attacker.family == WeaponFamily.spear) {
      return distance == RangeBand.close;
    }
    if (attacker.family == WeaponFamily.shortSword ||
        attacker.family == WeaponFamily.maul) {
      return distance == RangeBand.far;
    }
    return false;
  }

  bool _isAttack(BattleAction action) => switch (action) {
    BattleAction.quick ||
    BattleAction.heavy ||
    BattleAction.sweep ||
    BattleAction.bow ||
    BattleAction.emberSpear ||
    BattleAction.ashBurst => true,
    _ => false,
  };

  int _estimatedDamage(
    Combatant attacker,
    Combatant defender,
    BattleAction action,
  ) {
    double base = switch (action) {
      BattleAction.quick =>
        attacker.weaponPower * .8 + 1.6 * attacker.stats.might,
      BattleAction.heavy =>
        attacker.weaponPower * 1.5 + 1.6 * attacker.stats.might,
      BattleAction.sweep =>
        attacker.weaponPower * .65 + 1.6 * attacker.stats.might,
      BattleAction.bow =>
        (attacker.bowPower == 0 ? attacker.weaponPower : attacker.bowPower) +
            1.6 * attacker.stats.might,
      BattleAction.emberSpear => 4 + 1.5 * attacker.stats.arcana,
      BattleAction.ashBurst => 10 + 1.5 * attacker.stats.arcana,
      _ => 0,
    };
    if (action == BattleAction.heavy) base += 15;
    var armor = GameBalance.armorFromGuard(
      defender.armor,
      defender.stats.guard,
    );
    if (defender.statuses.containsKey(StatusKind.brokenGuard)) {
      armor = (armor * .8).round();
    }
    if (action == BattleAction.sweep) {
      armor = (armor * GameBalance.sweepArmorMultiplier).round();
    }
    if (action == BattleAction.heavy &&
        attacker.masteries.contains('front_2')) {
      armor = (armor * .9).round();
    }
    if (!_isSpell(action) &&
        attacker.family == WeaponFamily.maul &&
        distance == RangeBand.close) {
      base += 3;
    }
    if (action == BattleAction.emberSpear || action == BattleAction.ashBurst) {
      armor = GameBalance.magicEffectiveArmor(
        physicalArmor: armor,
        arcana: defender.stats.arcana,
      );
    }
    final guarded = defender.guarding
        ? (defender.masteries.contains('front_1')
              ? GameBalance.masteryGuardMultiplier
              : GameBalance.guardMultiplier)
        : 1.0;
    return max(0, (base * 100 / (100 + armor) * guarded).round());
  }

  int _damage(Combatant attacker, Combatant defender, BattleAction action) {
    double base = switch (action) {
      BattleAction.quick =>
        attacker.weaponPower * .8 + 1.6 * attacker.stats.might,
      BattleAction.heavy =>
        attacker.weaponPower * 1.5 + 1.6 * attacker.stats.might + 15,
      BattleAction.sweep =>
        attacker.weaponPower * .65 + 1.6 * attacker.stats.might,
      BattleAction.bow =>
        (attacker.bowPower == 0 ? attacker.weaponPower : attacker.bowPower) +
            1.6 * attacker.stats.might,
      BattleAction.emberSpear => 4 + 1.5 * attacker.stats.arcana,
      BattleAction.ashBurst => 10 + 1.5 * attacker.stats.arcana,
      _ => 0,
    };
    if (!_isSpell(action) &&
        attacker.family == WeaponFamily.maul &&
        distance == RangeBand.close) {
      base += 3;
    }
    if (attacker.aiStyle && attacker.phase > 1) {
      base *= 1 + .12 * (attacker.phase - 1);
    }
    var armor = GameBalance.armorFromGuard(
      defender.armor,
      defender.stats.guard,
    );
    if (defender.statuses.containsKey(StatusKind.brokenGuard)) {
      armor = (armor * .8).round();
    }
    if (action == BattleAction.sweep) {
      armor = (armor * GameBalance.sweepArmorMultiplier).round();
    }
    if (action == BattleAction.heavy &&
        attacker.masteries.contains('front_2')) {
      armor = (armor * .9).round();
    }
    if (action == BattleAction.emberSpear || action == BattleAction.ashBurst) {
      armor = GameBalance.magicEffectiveArmor(
        physicalArmor: armor,
        arcana: defender.stats.arcana,
      );
    }
    final diff = attacker.stats.agility - defender.stats.agility;
    final critBonus = action == BattleAction.quick && attacker.counterCritReady
        ? 5
        : 0;
    final critChance = (5 + .4 * diff + critBonus).round().clamp(5, 25);
    final critical = !_isSpell(action) && _random.nextInt(100) < critChance;
    if (action == BattleAction.quick) attacker.counterCritReady = false;
    if (critical) base *= GameBalance.criticalMultiplier;
    final wasGuarding = defender.guarding;
    defender.guarding = false;
    final damage = GameBalance.mitigatedDamage(
      baseDamage: base,
      effectiveArmor: armor,
      guarded: wasGuarding,
      guardMastery: defender.masteries.contains('front_1'),
    );
    return damage;
  }

  void _dealDamage(Combatant target, int damage) {
    var remaining = damage;
    var absorbed = 0;
    if (target.shield > 0) {
      absorbed = min(target.shield, remaining);
      target.shield -= absorbed;
      remaining -= absorbed;
      if (absorbed > 0) {
        _addLog(
          '${target.name} siperi $absorbed hasar emdi.',
          'battle.log.shieldAbsorb',
          {'target': _battleActor(target), 'amount': absorbed},
        );
      }
    }
    target.health = max(0, target.health - remaining);
    if (damage > 0) {
      _emitEvent(
        BattleEventType.damageTaken,
        target: _battleActor(target),
        amount: damage,
        healthDamage: remaining,
        shieldAbsorbed: absorbed,
      );
    }
  }

  void _applyStatus(
    Combatant target,
    StatusKind status,
    int turns, {
    required bool viaSpell,
    BattleActor? source,
    double burnBonusPercent = 0,
  }) {
    if (status == StatusKind.bleed || status == StatusKind.burn) {
      target.statuses[status] = min(2, (target.statuses[status] ?? 0) + 1);
      target.statusTurnsRemaining[status] = max(
        target.statusTurnsRemaining[status] ?? 0,
        turns,
      );
    } else if (status == StatusKind.brokenGuard) {
      target.statuses[status] = 1;
      target.brokenGuardExpiresAfterTurn = metrics.turn + turns;
    } else {
      target.statuses[status] = max(target.statuses[status] ?? 0, turns);
    }
    if (status == StatusKind.stagger) {
      target.statusTurnsRemaining[status] = max(
        target.statusTurnsRemaining[status] ?? 0,
        turns,
      );
    }
    if (status == StatusKind.burn) {
      target.burnBonusPercent = max(
        target.burnBonusPercent,
        burnBonusPercent,
      ).toDouble();
    }
    _emitEvent(
      BattleEventType.statusApplied,
      actor:
          source ??
          (viaSpell
              ? BattleActor.player
              : target.isPlayer
              ? BattleActor.opponent
              : null),
      target: _battleActor(target),
      status: status,
      amount: target.statuses[status],
    );
    if (target.isPlayer) {
      metrics.receivedStatus = true;
      if (status == StatusKind.bleed) metrics.receivedBleed = true;
    } else {
      metrics.statusPhases.add(target.phase);
      if (viaSpell) metrics.appliedStatusWithSpell = true;
    }
  }

  bool _tryApplyStatus(
    Combatant target,
    StatusKind status,
    int turns, {
    required int baseChance,
    required bool viaSpell,
    BattleActor? source,
    CombatElement? element,
    double burnBonusPercent = 0,
  }) {
    final protectedElement = element ?? _elementForStatus(status);
    if (protectedElement != null &&
        target.elementalImmunities.contains(protectedElement)) {
      _addLog(
        '${target.name} ${status.label} etkisine bağışık.',
        'battle.log.statusImmune',
        {
          'target': _battleActor(target),
          'element': protectedElement,
          'status': status,
        },
      );
      return false;
    }

    final chance = GameBalance.statusChance(
      baseChance,
      target.statusResistance,
    );
    final roll = switch (chance) {
      100 => 0,
      0 => 100,
      _ => _random.nextInt(100),
    };
    if (roll >= chance) {
      if (chance < baseChance && (chance == 0 || roll < baseChance)) {
        _addLog(
          '${target.name} ${status.label} etkisine direndi.',
          'battle.log.statusResisted',
          {
            'target': _battleActor(target),
            'status': status,
            'resistance': target.statusResistance,
          },
        );
      }
      return false;
    }
    _applyStatus(
      target,
      status,
      turns,
      viaSpell: viaSpell,
      source: source,
      burnBonusPercent: burnBonusPercent,
    );
    return true;
  }

  void _tickDamageStatuses(Combatant target, {required BattleActor actor}) {
    for (final status in [StatusKind.burn, StatusKind.bleed]) {
      final stack = target.statuses[status] ?? 0;
      final turns = target.statusTurnsRemaining[status] ?? 0;
      if (stack <= 0 || turns <= 0) continue;
      if (_isImmuneToStatus(target, status)) {
        _removeStatus(target, status);
        continue;
      }
      final damage = _damageOverTime(target, status, stack);
      _dealDamage(target, damage);
      _addLog(
        '${actor == BattleActor.player ? 'Oyuncu' : 'Rakip'}: ${status.label} $damage hasar verdi.',
        'battle.log.damageOverTime',
        {'actor': actor, 'status': status, 'damage': damage},
      );
      if (turns == 1) {
        _removeStatus(target, status);
      } else {
        target.statusTurnsRemaining[status] = turns - 1;
      }
    }
  }

  CombatElement? _elementForStatus(StatusKind status) => switch (status) {
    StatusKind.burn => CombatElement.ember,
    _ => null,
  };

  bool _isImmuneToStatus(Combatant target, StatusKind status) {
    final element = _elementForStatus(status);
    return element != null && target.elementalImmunities.contains(element);
  }

  int _damageOverTime(Combatant target, StatusKind status, int stacks) {
    final fraction = status == StatusKind.burn
        ? GameBalance.burnDamageFraction + target.burnBonusPercent
        : GameBalance.bleedDamageFraction;
    final damage = GameBalance.dotDamage(
      maxHealth: target.maxHealth,
      fraction: fraction,
      stacks: stacks,
    );
    if (status != StatusKind.burn) return damage;
    return GameBalance.damageAfterArcanaResistance(
      damage: damage,
      arcana: target.stats.arcana,
    );
  }

  BattleAction _chooseIntent() {
    final phaseTactics = encounter.tacticsForPhase(opponent.phase);
    if (phaseTactics != null && phaseTactics.intentSequence.isNotEmpty) {
      final sequence = phaseTactics.intentSequence;
      final requested = sequence[_phaseIntentIndex % sequence.length];
      _phaseIntentIndex++;
      return _usablePhaseIntent(requested);
    }

    if (_hazardWarningTurnsRemaining == 1) return BattleAction.guard;
    if (opponent.health < opponent.maxHealth * .28 && _random.nextInt(100) < 38) {
      return BattleAction.guard;
    }
    if (opponent.aiStyle &&
        encounter.archetype.contains('menzil') &&
        opponent.ammo > 0 &&
        distance != RangeBand.close) {
      return BattleAction.bow;
    }
    if (opponent.aiStyle &&
        (encounter.archetype.contains('büyü') ||
            encounter.archetype.contains('mühür') ||
            encounter.isChampion) &&
        opponent.mana >= 16 &&
        _random.nextInt(100) < 28) {
      return BattleAction.ashBurst;
    }
    if (encounter.archetype.contains('kalkan') && _random.nextInt(100) < 48) {
      return BattleAction.guard;
    }
    if (encounter.archetype.contains('çevik') && distance == RangeBand.far) {
      return BattleAction.closeDistance;
    }
    if (encounter.archetype.contains('ağır') ||
        encounter.archetype.contains('vurucu')) {
      if (opponent.effort >= 12) return BattleAction.heavy;
    }
    if (distance == RangeBand.far &&
        opponent.family != WeaponFamily.spear &&
        opponent.family != WeaponFamily.bow) {
      return BattleAction.closeDistance;
    }
    if (distance == RangeBand.close && opponent.family == WeaponFamily.spear) {
      return BattleAction.openDistance;
    }
    if (opponent.effort < 5) return BattleAction.guard;
    return _random.nextInt(100) < 24 ? BattleAction.sweep : BattleAction.quick;
  }

  BattleAction _usablePhaseIntent(BattleAction requested) {
    final cost = _cost(requested, opponent);
    if (requested == BattleAction.bow &&
        (opponent.ammo <= 0 || opponent.effort < cost.effort)) {
      return BattleAction.guard;
    }
    if (_isSpell(requested) && opponent.mana < cost.mana) {
      return BattleAction.guard;
    }
    if ((requested == BattleAction.quick ||
            requested == BattleAction.heavy ||
            requested == BattleAction.sweep) &&
        opponent.effort < cost.effort) {
      return BattleAction.guard;
    }
    if (requested == BattleAction.closeDistance &&
        distance == RangeBand.close) {
      return BattleAction.guard;
    }
    if (requested == BattleAction.openDistance && distance == RangeBand.far) {
      return BattleAction.guard;
    }
    return requested;
  }

  String _intentLabel() {
    return switch (_intent) {
      BattleAction.quick => 'Hızlı vuruş hazırlıyor',
      BattleAction.heavy => 'Güçlü vuruş hazırlıyor',
      BattleAction.guard => 'Gard alacak',
      BattleAction.sweep => 'Çelme hazırlıyor',
      BattleAction.bow => 'Yayını geriyor',
      BattleAction.ashBurst => 'Kül Patlaması hazırlıyor',
      BattleAction.closeDistance => 'Mesafeyi kapatacak',
      BattleAction.openDistance => 'Geri çekilecek',
      _ => '${_intent.label} hazırlıyor',
    };
  }

  BattleMessage _intentMessage() {
    return BattleMessage('battle.intent.${_intent.name}');
  }

  void _setIntentTelegraph() {
    if (_intent == BattleAction.ashBurst ||
        _intent == BattleAction.emberSpear) {
      _addLog(
        '${opponent.name} büyü hazırlıyor: ${_intent.label}.',
        'battle.log.spellTelegraph',
        {'opponent': BattleActor.opponent, 'action': _intent},
      );
      _emitEvent(
        BattleEventType.spellTelegraphed,
        actor: BattleActor.opponent,
        target: BattleActor.player,
        action: _intent,
      );
    }
  }

  void _resolveHazard() {
    if (encounter.hazard.isEmpty) return;
    final schedule = encounter.hazardSchedule;
    final due =
        schedule?.impactsAfterTurn(metrics.turn) ?? (metrics.turn % 4 == 3);
    if (!due) return;
    if (_movedThisTurn || player.guarding) {
      player.guarding = false;
      _emitEvent(BattleEventType.hazardAvoided, actor: BattleActor.player);
      _addLog(
        'İşaretli arena tehlikesinden zamanında uzaklaştın.',
        'battle.log.hazardAvoided',
      );
      return;
    }
    final damage = max(
      1,
      (player.maxHealth * GameBalance.hazardDamageFraction).round(),
    );
    _emitEvent(
      BattleEventType.hazardHit,
      actor: BattleActor.opponent,
      target: BattleActor.player,
      amount: damage,
    );
    _dealDamage(player, damage);
    metrics.hazardDamageTaken += damage;
    _addLog('Arena tehlikesi $damage hasar verdi.', 'battle.log.hazardDamage', {
      'damage': damage,
    });
  }

  int? get _hazardWarningTurnsRemaining {
    if (encounter.hazard.isEmpty) return null;
    final schedule = encounter.hazardSchedule;
    if (schedule != null) {
      return schedule.warningTurnsRemainingOn(metrics.turn + 1);
    }
    return (metrics.turn + 1) % 4 == 3 ? 1 : null;
  }

  void _setHazardTelegraphForNextTurn() {
    final turnsRemaining = _hazardWarningTurnsRemaining;
    _telegraphedHazard = turnsRemaining != null;
    if (turnsRemaining == null) return;
    _emitEvent(
      BattleEventType.hazardWarned,
      actor: BattleActor.opponent,
      target: BattleActor.player,
      amount: turnsRemaining,
    );
    _addLog(
      'Arena tehlikesi $turnsRemaining tur içinde vuracak: yer değiştir veya gard al.',
      'battle.log.hazardApproaching',
      {'turns': turnsRemaining},
    );
  }

  void _resolvePhaseChange() {
    if (!opponent.alive || opponent.phase >= encounter.phaseCount) return;
    final boundary =
        opponent.maxHealth * (1 - opponent.phase / encounter.phaseCount);
    if (opponent.health <= boundary) {
      opponent.phase++;
      final recoveryFraction =
          encounter.phaseRecoveryFraction ?? (1 / encounter.phaseCount);
      final restore = (opponent.maxHealth * recoveryFraction)
          .round()
          .clamp(0, opponent.maxHealth)
          .toInt();
      opponent.health = min(opponent.maxHealth, opponent.health + restore);
      opponent.guarding = false;
      opponent.effort = opponent.maxEffort;
      opponent.mana = opponent.maxMana;
      _emitEvent(
        BattleEventType.phaseChanged,
        actor: BattleActor.opponent,
        amount: opponent.phase,
      );
      final phaseLabel = switch (opponent.phase) {
        2 => 'ikinci',
        3 => 'üçüncü',
        _ => '${opponent.phase}.',
      };
      _addLog(
        '${opponent.name} $phaseLabel faza geçti. İpucu: ${encounter.archetype} saldırıları güçleniyor.',
        'battle.log.phaseChange',
        {
          'opponent': BattleActor.opponent,
          'phase': opponent.phase,
          'archetype': encounter.archetype,
        },
      );
      final taughtTactics =
          encounter.tacticsForPhase(opponent.phase)?.taughtTactics ??
          const <TaughtTactic>[];
      if (taughtTactics.isNotEmpty) {
        _addLog(
          'Rakip yeni bir taktik gösteriyor: ${taughtTactics.map((value) => value.name).join(', ')}.',
          'battle.log.phaseTactics',
          {'tactics': taughtTactics},
        );
      }
      _phaseIntentIndex = 0;
    }
  }

  void _moveOpponent() {
    if (_intent == BattleAction.closeDistance) _changeDistance(-1);
    if (_intent == BattleAction.openDistance) _changeDistance(1);
    opponent.effort = max(
      0,
      opponent.effort - GameBalance.movementEffortCost(opponent.stats.agility),
    );
    _emitEvent(
      BattleEventType.rangeChanged,
      actor: BattleActor.opponent,
      action: _intent,
      amount: RangeBand.values.indexOf(distance),
    );
    _addLog(
      '${opponent.name} mesafeyi değiştirdi: ${distance.label}.',
      'battle.log.opponentRangeChange',
      {'opponent': BattleActor.opponent, 'range': distance},
    );
  }

  void _changeDistance(int direction) {
    final values = RangeBand.values;
    final index = (values.indexOf(distance) + direction).clamp(
      0,
      values.length - 1,
    );
    distance = values[index];
  }

  void _finish(bool won) {
    if (_done) return;
    _done = true;
    _playerWon = won;
    _emitEvent(
      won ? BattleEventType.battleWon : BattleEventType.battleLost,
      actor: won ? BattleActor.player : BattleActor.opponent,
    );
    _addLog(
      won
          ? 'Zafer! ${encounter.gold} Sikke ve ${encounter.xp} deneyim kazanıldı.'
          : 'Düello kaybedildi. Kampanya ilerlemen korundu.',
      won ? 'battle.log.victory' : 'battle.log.defeat',
      {'gold': encounter.gold, 'xp': encounter.xp},
    );
  }
}

class BattleResolution {
  const BattleResolution({
    required this.won,
    required this.playerHealth,
    required this.turns,
    required this.metrics,
    required this.audienceReport,
  });
  final bool won;
  final int playerHealth;
  final int turns;
  final BattleMetrics metrics;
  final AudienceReport audienceReport;
}
