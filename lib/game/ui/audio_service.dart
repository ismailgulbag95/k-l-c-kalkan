import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data/content.dart';
import '../domain/battle_engine.dart';
import '../domain/models.dart';

/// Owns all runtime audio and haptics at the presentation boundary.
///
/// The battle engine only publishes typed events. This class maps those events
/// to the original assets in `assets/audio/`, applies saved mix settings, and
/// keeps looping audio aligned with the current menu, chapter, or arena.
class GameAudioService {
  AudioPlayer? _musicPlayer;
  AudioPlayer? _ambiencePlayer;
  AudioPlayer? _stingerPlayer;
  final Map<String, Future<AudioPool?>> _poolLoads = {};
  final Set<AudioPool> _pools = {};
  Future<void> _syncQueue = Future<void>.value();

  GameSave _save = const GameSave();
  Encounter? _activeEncounter;
  int _homeChapter = 1;
  bool _campaignComplete = false;
  bool _hasHero = false;
  bool _foreground = true;
  bool _disposed = false;
  String? _musicTrack;
  String? _ambienceTrack;

  static String musicTrackFor({
    required bool hasHero,
    required bool campaignComplete,
    required int chapter,
    Encounter? encounter,
  }) {
    if (encounter?.kind == EncounterKind.postgame ||
        (encounter == null && campaignComplete)) {
      return 'champions_road';
    }
    if (encounter != null) {
      if (encounter.isChampion) {
        return 'champion_${encounter.chapter.clamp(1, 4)}';
      }
      return 'chapter_${encounter.chapter.clamp(1, 4)}';
    }
    if (!hasHero) return 'menu_theme';
    return 'chapter_${chapter.clamp(1, 4)}';
  }

  static String? sfxForBattleEvent(BattleEvent event) => switch (event.type) {
    BattleEventType.attackStarted => switch (event.action) {
      BattleAction.heavy => 'attack_heavy',
      BattleAction.bow => 'arrow',
      BattleAction.quick || BattleAction.sweep => 'attack_quick',
      _ => null,
    },
    BattleEventType.attackHit => 'hit',
    BattleEventType.attackMiss => 'miss',
    BattleEventType.guardRaised || BattleEventType.shieldRaised => 'block',
    BattleEventType.spellCast => 'spell',
    BattleEventType.statusApplied => 'status',
    BattleEventType.hazardHit => 'hazard',
    BattleEventType.healed => 'heal',
    BattleEventType.battleWon => 'victory',
    BattleEventType.battleLost => 'defeat',
    _ => null,
  };

  void syncHome({
    required GameSave save,
    required int chapter,
    required bool campaignComplete,
  }) {
    if (_disposed) return;
    _save = save;
    _hasHero = save.hasHero;
    _homeChapter = chapter.clamp(1, 4);
    _campaignComplete = campaignComplete;
    _queueSync();
  }

  void enterBattle(Encounter encounter) {
    if (_disposed) return;
    _activeEncounter = encounter;
    _queueSync();
  }

  void leaveBattle({
    required GameSave save,
    required int chapter,
    required bool campaignComplete,
  }) {
    if (_disposed) return;
    _activeEncounter = null;
    syncHome(save: save, chapter: chapter, campaignComplete: campaignComplete);
  }

  void setMusicVolume(double value) {
    if (_disposed) return;
    _save = _save.copyWith(musicVolume: value.clamp(0.0, 1.0).toDouble());
    _queueSync();
  }

  void setSfxVolume(double value) {
    if (_disposed) return;
    _save = _save.copyWith(sfxVolume: value.clamp(0.0, 1.0).toDouble());
  }

  void handleLifecycle(AppLifecycleState state) {
    if (_disposed) return;
    _foreground = state == AppLifecycleState.resumed;
    _queueSync();
  }

  void userInteraction() {
    if (_disposed) return;
    // Browsers often require a gesture before media playback can begin.
    _queueSync();
  }

  Future<void> playUiCue(String cue) async {
    if (_disposed) return;
    userInteraction();
    await _playSfx(cue);
  }

  Future<void> playBattleEvent(BattleEvent event) async {
    if (_disposed) return;
    userInteraction();
    final cue = sfxForBattleEvent(event);
    if (cue != null) unawaited(_playSfx(cue));

    if (!_save.vibrationEnabled || kIsWeb || isInTest) return;
    final haptic = switch (event.type) {
      BattleEventType.hazardHit ||
      BattleEventType.phaseChanged => HapticFeedback.heavyImpact,
      BattleEventType.attackHit ||
      BattleEventType.damageTaken => event.actor == BattleActor.player &&
              (event.action == BattleAction.heavy ||
                  event.action == BattleAction.sweep)
          ? HapticFeedback.heavyImpact
          : HapticFeedback.mediumImpact,
      BattleEventType.spellCast => HapticFeedback.mediumImpact,
      BattleEventType.attackMiss ||
      BattleEventType.hazardAvoided => HapticFeedback.selectionClick,
      BattleEventType.battleWon => HapticFeedback.heavyImpact,
      BattleEventType.battleLost => HapticFeedback.mediumImpact,
      BattleEventType.guardRaised ||
      BattleEventType.shieldRaised ||
      BattleEventType.statusApplied ||
      BattleEventType.healed ||
      BattleEventType.resourceRestored => HapticFeedback.lightImpact,
      _ => null,
    };
    if (haptic != null) {
      try {
        await haptic();
      } on Object {
        // Unsupported haptic hardware should not affect the battle flow.
      }
    }
  }

  static bool get isInTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> playIntermissionStinger(int chapter) async {
    if (_disposed || isInTest || !_foreground || _save.musicVolume <= 0) return;
    final player = _stingerPlayer ??= AudioPlayer();
    final cue = ((chapter - 1) % 4) + 1;
    try {
      await player.stop();
      await player.setSource(
        AssetSource('audio/stingers/intermission_$cue.mp3'),
      );
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_save.musicVolume);
      if (_foreground) await player.resume();
    } on Object {
      // Asset or platform audio failures remain non-fatal.
    }
  }

  Future<void> _playSfx(String cue) async {
    if (_disposed ||
        isInTest ||
        !_foreground ||
        !_save.sfxEnabled ||
        _save.sfxVolume <= 0) {
      return;
    }
    final pending = _poolLoads.putIfAbsent(cue, () => _loadPool(cue));
    final pool = await pending;
    if (_disposed || !_foreground || pool == null || !_save.sfxEnabled) return;
    try {
      await pool.start(volume: _save.sfxVolume);
    } on Object {
      // A missing plugin or unavailable output device should be recoverable.
    }
  }

  Future<AudioPool?> _loadPool(String cue) async {
    try {
      final pool = await AudioPool.createFromAsset(
        path: 'audio/sfx/$cue.wav',
        minPlayers: 1,
        maxPlayers: 3,
      );
      if (_disposed) {
        await pool.dispose();
        return null;
      }
      _pools.add(pool);
      return pool;
    } on Object {
      _poolLoads.remove(cue);
      return null;
    }
  }

  void _queueSync() {
    _syncQueue = _syncQueue
        .then((_) => _applyDesiredAudio())
        .catchError((Object _) {});
  }

  Future<void> _applyDesiredAudio() async {
    if (_disposed || isInTest) return;
    final encounter = _activeEncounter;
    final track = musicTrackFor(
      hasHero: _hasHero,
      campaignComplete: _campaignComplete,
      chapter: _homeChapter,
      encounter: encounter,
    );
    final arena = encounter == null ? null : _ambienceFor(encounter.arenaId);
    final musicVolume = _save.musicVolume.clamp(0.0, 1.0).toDouble();
    await _syncLoop(
      player: _musicPlayer ??= AudioPlayer(),
      currentTrack: _musicTrack,
      nextTrack: track,
      folder: 'music',
      volume: musicVolume,
      onTrackChanged: (value) => _musicTrack = value,
    );
    final ambienceVolume = (musicVolume * 0.28).clamp(0.0, 0.28).toDouble();
    await _syncLoop(
      player: _ambiencePlayer ??= AudioPlayer(),
      currentTrack: _ambienceTrack,
      nextTrack: arena,
      folder: 'ambience',
      volume: ambienceVolume,
      onTrackChanged: (value) => _ambienceTrack = value,
    );
  }

  Future<void> _syncLoop({
    required AudioPlayer player,
    required String? currentTrack,
    required String? nextTrack,
    required String folder,
    required double volume,
    required void Function(String?) onTrackChanged,
  }) async {
    if (!_foreground) {
      if (player.state == PlayerState.playing) await player.pause();
      return;
    }
    if (nextTrack == null) {
      if (currentTrack != null) await player.stop();
      onTrackChanged(null);
      return;
    }
    if (currentTrack == nextTrack) {
      await player.setVolume(volume);
      if (player.state != PlayerState.playing) await player.resume();
      return;
    }

    if (currentTrack != null && player.state == PlayerState.playing) {
      await _fade(player, from: volume, to: 0);
    }
    await player.stop();
    onTrackChanged(null);
    try {
      final extension = folder == 'music' ? 'mp3' : 'wav';
      await player.setSource(
        AssetSource('audio/$folder/$nextTrack.$extension'),
      );
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0);
      await player.resume();
      onTrackChanged(nextTrack);
      await _fade(player, from: 0, to: volume);
    } on Object {
      onTrackChanged(null);
    }
  }

  Future<void> _fade(
    AudioPlayer player, {
    required double from,
    required double to,
  }) async {
    const steps = 6;
    for (var step = 1; step <= steps; step++) {
      if (_disposed || !_foreground) return;
      final progress = step / steps;
      await player.setVolume(from + (to - from) * progress);
      await Future<void>.delayed(const Duration(milliseconds: 35));
    }
  }

  String? _ambienceFor(String arenaId) => switch (arenaId) {
    'kul' => 'harbor',
    'kor' => 'forge',
    'firtina' => 'observatory',
    'gelgit' => 'tide',
    'tac' => 'fortress',
    'halka' => 'crown_ring',
    _ => null,
  };

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _syncQueue;
    await Future.wait(_poolLoads.values);
    await Future.wait([
      if (_musicPlayer != null) _musicPlayer!.dispose(),
      if (_ambiencePlayer != null) _ambiencePlayer!.dispose(),
      if (_stingerPlayer != null) _stingerPlayer!.dispose(),
      ..._pools.map((pool) => pool.dispose()),
    ]);
    _pools.clear();
  }
}

class GameAudioScope extends InheritedWidget {
  const GameAudioScope({
    super.key,
    required this.service,
    required super.child,
  });

  final GameAudioService service;

  static GameAudioService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameAudioScope>()?.service;

  @override
  bool updateShouldNotify(GameAudioScope oldWidget) =>
      !identical(service, oldWidget.service);
}

class GameAudioNavigatorObserver extends NavigatorObserver {
  GameAudioNavigatorObserver(this.audio);

  final GameAudioService audio;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    unawaited(audio.playUiCue('ui_back'));
    super.didPop(route, previousRoute);
  }
}
