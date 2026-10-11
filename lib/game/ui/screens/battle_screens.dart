part of '../screens.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({
    super.key,
    required this.controller,
    this.resumeFromCheckpoint = false,
  });
  final GameController controller;
  final bool resumeFromCheckpoint;

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattleMotionPulse {
  const _BattleMotionPulse(this.motion, this.sequence, this.actionPose);

  final FighterMotion motion;
  final int sequence;
  final HeroActionPose? actionPose;
}

int? _statusRemainingTurns(
  BattleEngine engine,
  Combatant combatant,
  StatusKind status,
) {
  final turns = combatant.statusTurnsRemaining[status];
  if (turns != null) return turns;
  if (status == StatusKind.brokenGuard) {
    final expiresAfter = combatant.brokenGuardExpiresAfterTurn;
    if (expiresAfter != null) {
      final remaining = expiresAfter - engine.metrics.turn;
      return remaining < 0 ? 0 : remaining;
    }
  }
  return null;
}

class CombatStatusBadge extends StatelessWidget {
  const CombatStatusBadge({
    super.key,
    required this.status,
    int? stacks,
    int? stackCount,
    int? remainingTurns,
    int? turnsRemaining,
  }) : stacks = stacks ?? stackCount,
       remainingTurns = remainingTurns ?? turnsRemaining;

  final StatusKind status;
  final int? stacks;
  final int? remainingTurns;

  int? get stackCount => stacks;
  int? get turnsRemaining => remainingTurns;

  @override
  Widget build(BuildContext context) {
    final localizedLabel = gameText(context, 'label.status.${status.name}');
    final color = switch (status) {
      StatusKind.stagger => GamePalette.gold,
      StatusKind.bleed => GamePalette.rust,
      StatusKind.burn => const Color(0xFFE57338),
      StatusKind.brokenGuard => GamePalette.effort,
    };
    final glyph = glyphForStatusKind(status);

    final hasStacks = stacks != null && stacks! > 1;
    final hasTurns = remainingTurns != null && remainingTurns! > 0;

    final String semanticLabel;
    if (hasTurns && hasStacks) {
      semanticLabel = gameText(context, 'ui.battle.status.semantics.full', {
        'status': localizedLabel,
        'stacks': stacks!,
        'turns': remainingTurns!,
      });
    } else if (hasTurns) {
      semanticLabel = gameText(context, 'ui.battle.status.semantics.turns', {
        'status': localizedLabel,
        'turns': remainingTurns!,
      });
    } else {
      semanticLabel = localizedLabel;
    }

    final String? detailsText;
    if (hasStacks && hasTurns) {
      final turnText = gameText(context, 'ui.battle.status.turns', {
        'turns': remainingTurns!,
      });
      detailsText = '×$stacks · $turnText';
    } else if (hasTurns) {
      detailsText = gameText(context, 'ui.battle.status.turns', {
        'turns': remainingTurns!,
      });
    } else if (hasStacks) {
      detailsText = '×$stacks';
    } else {
      detailsText = null;
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xEE101719),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.75), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameGlyph(
                glyph,
                size: 13,
                color: color,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 3.5),
              Flexible(
                child: Text(
                  localizedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GamePalette.parchment,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .3,
                  ),
                ),
              ),
              if (detailsText != null) ...[
                const SizedBox(width: 3.5),
                Text(
                  detailsText,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BattleMotionCue {
  const _BattleMotionCue(this.actor, this.motion, {this.actionPose});

  final BattleActor actor;
  final FighterMotion motion;
  final HeroActionPose? actionPose;
}

int battleEffectFrameForEvent(BattleEvent? event) {
  if (event == null) return BattleEffectFrame.impact.index;
  if (event.type == BattleEventType.attackStarted &&
      event.action == BattleAction.bow) {
    return BattleEffectFrame.arrow.index;
  }
  if (event.type == BattleEventType.actionStarted &&
      (event.action == BattleAction.salve ||
          event.action == BattleAction.tonic)) {
    return BattleEffectFrame.healing.index;
  }
  return switch (event.type) {
    BattleEventType.guardRaised ||
    BattleEventType.shieldRaised => BattleEffectFrame.block.index,
    BattleEventType.rangeChanged => BattleEffectFrame.dust.index,
    BattleEventType.healed => BattleEffectFrame.healing.index,
    BattleEventType.spellCast => switch (event.action) {
      BattleAction.tideWard => BattleEffectFrame.tide.index,
      BattleAction.saltCleanse => BattleEffectFrame.healing.index,
      BattleAction.swiftBreeze ||
      BattleAction.shoreStep => BattleEffectFrame.wind.index,
      _ => BattleEffectFrame.fire.index,
    },
    BattleEventType.attackHit ||
    BattleEventType.hazardHit ||
    BattleEventType.damageTaken => BattleEffectFrame.impact.index,
    _ => BattleEffectFrame.impact.index,
  };
}

bool _battleEventHasVisualEffect(BattleEvent event) => switch (event.type) {
  BattleEventType.actionStarted ||
  BattleEventType.attackStarted ||
  BattleEventType.attackHit ||
  BattleEventType.guardRaised ||
  BattleEventType.spellCast ||
  BattleEventType.damageTaken ||
  BattleEventType.healed ||
  BattleEventType.shieldRaised ||
  BattleEventType.rangeChanged ||
  BattleEventType.hazardHit => true,
  _ => false,
};

class _BattlePageState extends State<BattlePage> {
  bool _started = false;
  bool _resultShown = false;
  bool _working = false;
  int _motionSequence = 0;
  _BattleMotionPulse? _playerMotion;
  _BattleMotionPulse? _opponentMotion;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    if (widget.resumeFromCheckpoint) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.battle?.snapshot.done == true) {
          unawaited(_showResultWhenDone());
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant BattlePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _act(BattleAction action) async {
    if (_working) return;
    final currentEngine = widget.controller.battle;
    final firstNewEvent = currentEngine?.snapshot.events.length ?? 0;
    final errorMessageId = currentEngine == null
        ? 'ui.battle.notFound'
        : currentEngine.snapshot.done
        ? 'ui.battle.error.done'
        : 'ui.battle.error.unavailable';
    setState(() => _working = true);
    final error = await widget.controller.performAction(action);
    if (!mounted) return;
    if (error != null) {
      setState(() => _working = false);
      final saveFailed = error.startsWith('Kayıt yazılamadı:');
      final message = saveFailed
          ? gameText(context, 'ui.error.saveFailed')
          : gameText(context, errorMessageId);
      _showMessage(
        context,
        message,
        actionLabel: saveFailed ? gameText(context, 'ui.common.retry') : null,
        onAction: saveFailed ? () => unawaited(_act(action)) : null,
      );
      return;
    }
    setState(() {});
    final engine = widget.controller.battle;
    if (engine == null) {
      setState(() => _working = false);
      return;
    }
    final events = engine.snapshot.events.skip(firstNewEvent).toList();
    await _animateBattleEvents(events);
    if (!mounted) return;
    await _showResultWhenDone();
    if (mounted &&
        identical(widget.controller.battle, engine) &&
        !engine.snapshot.done) {
      setState(() => _working = false);
    }
  }

  Future<void> _animateBattleEvents(List<BattleEvent> events) async {
    final audio = GameAudioScope.maybeOf(context);
    if (audio != null) {
      for (final event in events) {
        unawaited(audio.playBattleEvent(event));
      }
    }
    if (widget.controller.save.reducedMotion ||
        widget.controller.save.skipBattleAnimations) {
      return;
    }
    final cues = <_BattleMotionCue>[];
    for (final event in events) {
      final actor = event.actor;
      final target = event.target;
      switch (event.type) {
        case BattleEventType.actionStarted:
          if (actor == BattleActor.player &&
              (event.action == BattleAction.salve ||
                  event.action == BattleAction.tonic)) {
            cues.add(
              _BattleMotionCue(
                actor!,
                FighterMotion.heal,
                actionPose: HeroActionPose.consumable,
              ),
            );
          }
        case BattleEventType.attackStarted:
          if (actor != null) {
            cues.add(
              _BattleMotionCue(
                actor,
                FighterMotion.attack,
                actionPose: actor == BattleActor.player
                    ? switch (event.action) {
                        BattleAction.heavy => HeroActionPose.strongAttack,
                        BattleAction.bow => HeroActionPose.bowDraw,
                        _ => null,
                      }
                    : null,
              ),
            );
          }
        case BattleEventType.attackHit:
        case BattleEventType.hazardHit:
          if (event.type == BattleEventType.attackHit &&
              actor == BattleActor.player &&
              event.action == BattleAction.bow) {
            cues.add(
              _BattleMotionCue(
                actor!,
                FighterMotion.attack,
                actionPose: HeroActionPose.bowRelease,
              ),
            );
          }
          if (target != null) {
            cues.add(
              _BattleMotionCue(
                target,
                FighterMotion.hit,
                actionPose: target == BattleActor.player
                    ? HeroActionPose.stagger
                    : null,
              ),
            );
          }
        case BattleEventType.attackMiss:
          if (actor == BattleActor.player && event.action == BattleAction.bow) {
            cues.add(
              _BattleMotionCue(
                actor!,
                FighterMotion.attack,
                actionPose: HeroActionPose.bowRelease,
              ),
            );
          }
          if (target != null) {
            cues.add(
              _BattleMotionCue(
                target,
                FighterMotion.dodge,
                actionPose: target == BattleActor.player
                    ? HeroActionPose.dodge
                    : null,
              ),
            );
          }
        case BattleEventType.guardRaised:
        case BattleEventType.shieldRaised:
          if (actor != null) {
            cues.add(_BattleMotionCue(actor, FighterMotion.guard));
          }
        case BattleEventType.spellCast:
          if (actor != null) {
            cues.add(
              _BattleMotionCue(
                actor,
                FighterMotion.spell,
                actionPose: actor == BattleActor.player
                    ? HeroActionPose.spell
                    : null,
              ),
            );
          }
        case BattleEventType.statusApplied:
          if (target != null) {
            cues.add(_BattleMotionCue(target, FighterMotion.status));
          }
        case BattleEventType.healed:
        case BattleEventType.resourceRestored:
          break;
        case BattleEventType.rangeChanged:
          if (actor != null) {
            cues.add(_BattleMotionCue(actor, FighterMotion.move));
          }
        case BattleEventType.phaseChanged:
          if (actor != null) {
            cues.add(_BattleMotionCue(actor, FighterMotion.phase));
          }
        case BattleEventType.battleWon:
          cues.add(_BattleMotionCue(BattleActor.player, FighterMotion.victory));
          cues.add(
            _BattleMotionCue(BattleActor.opponent, FighterMotion.defeat),
          );
        case BattleEventType.battleLost:
          cues.add(
            _BattleMotionCue(
              BattleActor.player,
              FighterMotion.defeat,
              actionPose: HeroActionPose.defeat,
            ),
          );
          cues.add(
            _BattleMotionCue(BattleActor.opponent, FighterMotion.victory),
          );
        case BattleEventType.turnStarted:
        case BattleEventType.spellTelegraphed:
        case BattleEventType.statusRemoved:
        case BattleEventType.damageTaken:
        case BattleEventType.hazardWarned:
        case BattleEventType.hazardAvoided:
        case BattleEventType.turnEnded:
          break;
      }
    }

    for (final cue in cues) {
      if (!mounted) return;
      setState(() {
        final pulse = _BattleMotionPulse(
          cue.motion,
          ++_motionSequence,
          cue.actionPose,
        );
        if (cue.actor == BattleActor.player) {
          _playerMotion = pulse;
        } else {
          _opponentMotion = pulse;
        }
      });
      await Future<void>.delayed(
        scaledBattleAnimationDuration(
          const Duration(milliseconds: 190),
          widget.controller.save.battleAnimationSpeed,
        ),
      );
    }
  }

  Future<void> _showResultWhenDone() async {
    final engine = widget.controller.battle;
    if (engine == null || !engine.snapshot.done || _resultShown || !mounted) {
      return;
    }
    _resultShown = true;
    _working = true;
    final previousLevel = widget.controller.save.level;
    final previousStatPoints = widget.controller.save.unspentStatPoints;
    final encounter = widget.controller.activeEncounter!;
    final contract = widget.controller.activeContract;
    final previousGold = widget.controller.save.gold;
    final previousXp = widget.controller.save.xp;
    final matchWasCompleted = widget.controller.save.completedMatches.contains(
      encounter.key,
    );
    final contractWasCompleted =
        contract != null &&
        widget.controller.save.completedContracts.contains(contract.id);
    BattleResolution? result;
    try {
      result = await widget.controller.resolveBattle();
    } catch (_) {
      if (!mounted) {
        _working = false;
        _resultShown = false;
        return;
      }
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GamePalette.panel,
          icon: const Icon(Icons.save_outlined, color: GamePalette.rust),
          title: Text(gameText(context, 'ui.error.saveTitle')),
          content: Text(gameText(context, 'ui.result.saveFailed')),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(gameText(context, 'ui.common.retry')),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _working = false;
      _resultShown = false;
      if (retry == true) await _showResultWhenDone();
      return;
    }
    if (result == null || !mounted) {
      _working = false;
      _resultShown = false;
      return;
    }
    final BattleResolution battleResult = result;
    final goldAwarded = widget.controller.save.gold - previousGold;
    final xpAwarded = widget.controller.save.xp - previousXp;
    final statPointsEarned =
        widget.controller.save.unspentStatPoints - previousStatPoints;
    final audio = GameAudioScope.maybeOf(context);
    if (battleResult.won && audio != null) {
      unawaited(audio.playUiCue(contract == null ? 'reward' : 'contract'));
      if (widget.controller.save.level > previousLevel) {
        unawaited(audio.playUiCue('level_up'));
      }
    }
    final complete = contract == null
        ? (battleResult.won &&
              widget.controller.save.completedMatches.contains(encounter.key))
        : widget.controller.save.completedContracts.contains(contract.id);
    final rewardText = contract != null
        ? goldAwarded > 0
              ? gameText(context, 'ui.result.contractReward', {
                  'reward': goldAwarded,
                })
              : contractWasCompleted
              ? gameText(context, 'ui.result.replayNoReward')
              : gameText(context, 'ui.result.contractFailed')
        : battleResult.won
        ? encounter.kind == EncounterKind.postgame
              ? gameText(context, 'ui.result.postgameNoReward')
              : goldAwarded == 0 && xpAwarded == 0
              ? gameText(context, 'ui.result.replayNoReward')
              : gameText(context, 'ui.result.encounterPayout', {
                  'gold': goldAwarded,
                  'xp': xpAwarded,
                })
        : goldAwarded > 0
        ? gameText(context, 'ui.result.lossSupportAdded')
        : matchWasCompleted
        ? gameText(context, 'ui.result.replayNoReward')
        : gameText(context, 'ui.result.lossSupport');
    final campaignScore =
        contract == null &&
        encounter.id >= 1 &&
        encounter.id <= 32 &&
        encounter.kind != EncounterKind.postgame;
    final bestAudienceScore = campaignScore
        ? widget.controller.save.audienceBestScores[encounter.key]
        : null;
    final localizations = GameLocalizations.of(context);
    final isEnglish = localizations.isEnglish;
    final chapterTitle = gameText(
      context,
      'ui.campaign.chapterTitle.${encounter.chapter}',
    );
    final crowdHeading = isEnglish ? 'Crowd reaction' : 'Seyirci tepkisi';
    final crowdReaction = audienceCrowdReactionText(
      won: battleResult.won,
      isEnglish: isEnglish,
      chapterTitle: chapterTitle,
    );
    final crowdColor = battleResult.won ? GamePalette.teal : GamePalette.rust;
    if (!mounted) return;
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GamePalette.panel,
        icon: Icon(
          battleResult.won ? Icons.emoji_events : Icons.refresh,
          color: battleResult.won ? GamePalette.gold : GamePalette.rust,
          size: 34,
        ),
        title: Text(
          gameText(
            context,
            battleResult.won ? 'ui.result.victory' : 'ui.result.defeat',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameText(context, 'ui.result.encounterTurns', {
                  'encounter': _encounterName(context, encounter),
                  'turns': battleResult.turns,
                }),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Semantics(
                container: true,
                liveRegion: true,
                label: '$crowdHeading. $crowdReaction',
                child: ExcludeSemantics(
                  child: GamePanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    borderColor: crowdColor.withValues(alpha: .7),
                    child: Row(
                      children: [
                        AudienceChapterEmblem(
                          chapter: encounter.chapter,
                          size: 54,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crowdHeading,
                                style: TextStyle(
                                  color: crowdColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                crowdReaction,
                                style: const TextStyle(
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                rewardText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GamePalette.muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              if (widget.controller.save.level > previousLevel) ...[
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ValuePill(
                      icon: Icons.arrow_upward,
                      value: gameText(context, 'ui.fighter.level', {
                        'level': widget.controller.save.level,
                      }),
                    ),
                    if (statPointsEarned > 0)
                      ValuePill(
                        icon: Icons.add_circle_outline,
                        value: '+${gameText(context, 'ui.campaign.points', {
                          'count': statPointsEarned,
                        })}',
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 13),
              GamePanel(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizedHeading(context, 'ui.audience.report'),
                            style: const TextStyle(
                              color: GamePalette.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Text(
                          '${battleResult.audienceReport.score} / 3',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    if (campaignScore) ...[
                      const SizedBox(height: 3),
                      Text(
                        gameText(context, 'ui.audience.bestScore', {
                          'score': bestAudienceScore ?? 0,
                        }),
                        style: const TextStyle(
                          color: GamePalette.muted,
                          fontSize: 10,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 3),
                      Text(
                        gameText(context, 'ui.audience.notCampaign'),
                        style: TextStyle(color: GamePalette.muted, fontSize: 9),
                      ),
                    ],
                    const SizedBox(height: 8),
                    for (final rule in battleResult.audienceReport.rules)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Semantics(
                          container: true,
                          checked: rule.completed,
                          label: gameText(context, rule.message.id),
                          child: ExcludeSemantics(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GameGlyph(
                                  audienceGlyphForMessageId(rule.message.id),
                                  size: 14,
                                  color: rule.completed
                                      ? GamePalette.teal
                                      : GamePalette.muted,
                                  selected: rule.completed,
                                  excludeFromSemantics: true,
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  rule.completed
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: rule.completed
                                      ? GamePalette.teal
                                      : GamePalette.muted,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    gameText(context, rule.message.id),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (battleResult.won && encounter.id == 32)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    gameText(context, 'ui.result.epilogueUnlocked'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: GamePalette.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (!battleResult.won || !complete)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(gameText(context, 'ui.common.retry')),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              gameText(
                context,
                battleResult.won
                    ? 'ui.result.returnLeague'
                    : 'ui.result.leaveDuel',
              ),
            ),
          ),
        ],
      ),
    );
    if (mounted &&
        battleResult.won &&
        contract == null &&
        widget.controller.pendingIntermissionDecision != null) {
      await _showIntermissionChoice(context, widget.controller);
    }
    _working = false;
    if (!mounted) return;
    if (retry == true) {
      _resultShown = false;
      if (contract != null) {
        await widget.controller.startContract(contract.id);
      } else if (encounter.kind == EncounterKind.postgame) {
        await widget.controller.startChampionsRoad(encounter.id - 32);
      } else {
        await widget.controller.startEncounter(encounter.id);
      }
      if (audio != null) {
        final activeEncounter = widget.controller.activeEncounter;
        if (activeEncounter != null) audio.enterBattle(activeEncounter);
      }
      setState(() {});
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _leave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(gameText(dialogContext, 'ui.battle.leaveTitle')),
        content: Text(gameText(dialogContext, 'ui.battle.leaveBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(gameText(dialogContext, 'ui.common.continue')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(gameText(dialogContext, 'ui.common.leave')),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  Widget _buildBriefing(
    GameController controller,
    Encounter encounter,
    ArenaInfo arena,
  ) {
    final contract = controller.activeContract;
    final reward = contract != null
        ? gameText(context, 'ui.battle.contractReward', {
            'reward': contract.reward,
          })
        : encounter.kind == EncounterKind.postgame
        ? gameText(context, 'ui.battle.noPostgameReward')
        : gameText(context, 'ui.battle.encounterReward', {
            'gold': encounter.gold,
            'xp': encounter.xp,
          });
    final story = _encounterContent(context, encounter, 'story');
    final mood = localizedContent(context, 'arena', arena.id, 'mood');
    final briefingText = story.isEmpty
        ? gameText(context, 'ui.battle.briefingFallback', {'mood': mood})
        : gameText(context, 'ui.battle.briefingEncounter', {
            'story': story,
            'mood': mood,
          });
    final audienceMessages = audienceRuleMessages(encounter);
    return Scaffold(
      body: GameBackdrop(
        image: arena.art,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Row(
                    children: [
                      _labelledIconButton(
                        label: gameText(context, 'ui.common.back'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icons.arrow_back,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        localizedHeading(context, 'ui.battle.briefing'),
                        style: TextStyle(
                          color: GamePalette.gold,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 230,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(arena.art, fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x11101719), Color(0xEE101719)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            bottom: 16,
                            right: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  GameLocalizations.of(context)
                                      .uppercase(_arenaName(context, arena.id)),
                                  style: const TextStyle(
                                    color: GamePalette.gold,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _encounterName(context, encounter),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${_encounterArchetype(context, encounter)} · ${gameText(context, 'ui.encounter.level', {'level': encounter.level})}',
                                  style: const TextStyle(
                                    color: GamePalette.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 9,
                            bottom: 8,
                            child: FighterArt(
                              seed: encounter.id,
                              name: '',
                              family: encounter.weaponFamily.name,
                              portraitAsset: characterArtForEncounter(
                                encounter.id,
                              ),
                              atlasAsset: rivalAtlasForEncounter(encounter.id)
                                  ?.asset,
                              atlasIndex: rivalAtlasForEncounter(encounter.id)
                                  ?.index,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GamePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeading(
                          localizedHeading(context, 'ui.battle.arenaState'),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          briefingText,
                          style: const TextStyle(
                            color: GamePalette.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium_outlined,
                              color: GamePalette.gold,
                              size: 18,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                gameText(context, 'ui.battle.firstWinReward', {
                                  'reward': reward,
                                }),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GamePanel(
                    borderColor: GamePalette.gold.withValues(alpha: .6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeading(
                          localizedHeading(context, 'ui.audience.conditions'),
                        ),
                        const SizedBox(height: 9),
                        for (
                          var index = 0;
                          index < audienceMessages.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: chapterColor(encounter.chapter)
                                    .withValues(alpha: .18),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: chapterColor(encounter.chapter),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  gameText(context, audienceMessages[index].id),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          gameText(context, 'ui.battle.audienceHelp'),
                          style: TextStyle(
                            color: GamePalette.muted,
                            fontSize: 10,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GameButton(
                    label: gameText(context, 'ui.battle.start'),
                    icon: Icons.sports_martial_arts,
                    audioCue: 'battle_start',
                    onPressed: () => setState(() => _started = true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final engine = controller.battle;
    final encounter = controller.activeEncounter;
    if (engine == null || encounter == null) {
      return Scaffold(
        body: Center(child: Text(gameText(context, 'ui.battle.notFound'))),
      );
    }
    final state = engine.snapshot;
    final effectEvent = state.events.reversed
        .where(_battleEventHasVisualEffect)
        .firstOrNull;
    final arena = getArena(encounter.arenaId);
    if (!_started) return _buildBriefing(controller, encounter, arena);
    final playerStatus = engine.player.statuses.keys.firstOrNull?.name ?? '';
    final enemyStatus = engine.opponent.statuses.keys.firstOrNull?.name ?? '';
    return Scaffold(
      body: GameBackdrop(
        image: arena.art,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
                children: [
                  if (controller.lastError != null)
                    GamePanel(
                      color: const Color(0xD94A2823),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: GamePalette.rust,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gameText(
                                context,
                                controller.battleCheckpointWritePending
                                    ? 'ui.error.checkpointSavePending'
                                    : 'ui.error.saveFailed',
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          if (controller.battleCheckpointWritePending)
                            TextButton(
                              onPressed: () => unawaited(
                                controller.persistActiveBattleCheckpoint(),
                              ),
                              child: Text(gameText(context, 'ui.common.retry')),
                            ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      _labelledIconButton(
                        label: gameText(context, 'ui.battle.leave'),
                        onPressed: _working ? null : _leave,
                        icon: Icons.close,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _encounterName(context, encounter),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              '${_arenaName(context, arena.id)} · ${gameText(context, switch (encounter.kind) {
                                EncounterKind.champion => 'ui.battle.kind.champion',
                                EncounterKind.intermediateFinal => 'ui.battle.kind.intermediateFinal',
                                EncounterKind.elite => 'ui.battle.kind.elite',
                                _ => 'ui.battle.kind.league',
                              })}',
                              style: const TextStyle(
                                color: GamePalette.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ValuePill(
                        icon: Icons.filter_1,
                        value: gameText(context, 'ui.battle.turnShort', {
                          'turn': engine.metrics.turn + 1,
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GamePanel(
                    color: const Color(0xD9172021),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _heroDisplayName(
                                      context,
                                      controller.save.heroName,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ResourceBar(
                                    label: gameText(
                                      context,
                                      'ui.resource.health',
                                    ),
                                    value: engine.player.health,
                                    max: engine.player.maxHealth,
                                    color: GamePalette.health,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 6),
                                  ResourceBar(
                                    label: gameText(
                                      context,
                                      'ui.resource.effort',
                                    ),
                                    value: engine.player.effort,
                                    max: engine.player.maxEffort,
                                    color: GamePalette.effort,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 6),
                                  ResourceBar(
                                    label: gameText(
                                      context,
                                      'ui.resource.mana',
                                    ),
                                    value: engine.player.mana,
                                    max: engine.player.maxMana,
                                    color: GamePalette.mana,
                                    compact: true,
                                  ),
                                  if (engine.player.statuses.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        for (final entry
                                            in engine.player.statuses.entries)
                                          CombatStatusBadge(
                                            status: entry.key,
                                            stacks: entry.value,
                                            remainingTurns:
                                                _statusRemainingTurns(
                                                  engine,
                                                  engine.player,
                                                  entry.key,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _encounterName(context, encounter),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ResourceBar(
                                    label: gameText(
                                      context,
                                      'ui.resource.health',
                                    ),
                                    value: engine.opponent.health,
                                    max: engine.opponent.maxHealth,
                                    color: GamePalette.health,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 6),
                                  ResourceBar(
                                    label: gameText(
                                      context,
                                      'ui.resource.effort',
                                    ),
                                    value: engine.opponent.effort,
                                    max: engine.opponent.maxEffort,
                                    color: GamePalette.effort,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 6),
                                  ResourceBar(
                                    label: gameText(
                                      context,
                                      'ui.resource.mana',
                                    ),
                                    value: engine.opponent.mana,
                                    max: engine.opponent.maxMana,
                                    color: GamePalette.mana,
                                    compact: true,
                                  ),
                                  if (engine.opponent.statuses.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        for (final entry
                                            in engine.opponent.statuses.entries)
                                          CombatStatusBadge(
                                            status: entry.key,
                                            stacks: entry.value,
                                            remainingTurns:
                                                _statusRemainingTurns(
                                                  engine,
                                                  engine.opponent,
                                                  entry.key,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 228,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(arena.art, fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x22101719), Color(0xBB101719)],
                                stops: [0, 1],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: ArenaFinalPhaseLighting(
                              arenaId: arena.id,
                              isFinalPhase:
                                  encounter.phaseCount > 1 &&
                                  state.phase >= encounter.phaseCount,
                            ),
                          ),
                          if (arena.propAtlas != null) ...[
                            Positioned(
                              left: 2,
                              bottom: 0,
                              width: 78,
                              height: 52,
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: .86,
                                  child: ArenaPropSprite(
                                    atlas: arena.propAtlas!,
                                    index: encounter.id % 4,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 0,
                              width: 78,
                              height: 52,
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: .86,
                                  child: ArenaPropSprite(
                                    atlas: arena.propAtlas!,
                                    index: (encounter.id + 2) % 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Positioned.fill(
                            child: BattleImpactEffect(
                              sequence: effectEvent?.sequence ?? 0,
                              frame: battleEffectFrameForEvent(effectEvent),
                              alignment:
                                  (effectEvent?.target ?? effectEvent?.actor) ==
                                      BattleActor.opponent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              reducedMotion:
                                  controller.save.reducedMotion ||
                                  controller.save.skipBattleAnimations,
                              animationSpeed:
                                  controller.save.battleAnimationSpeed,
                              arenaId: arena.id,
                              weaponFamily:
                                  effectEvent?.action == BattleAction.bow
                                  ? 'bow'
                                  : effectEvent?.actor == BattleActor.player
                                  ? _familyName(controller.save.weaponId)
                                  : encounter.weaponFamily.name,
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 2,
                            bottom: 2,
                            child: FighterArt(
                              seed: _originIndex(controller.save.appearance),
                              name: _heroDisplayName(
                                context,
                                controller.save.heroName,
                              ),
                              isPlayer: true,
                              family: _familyName(controller.save.weaponId),
                              origin: controller.save.appearance,
                              status: playerStatus,
                              portraitAsset: heroArtForAppearance(
                                controller.save.appearance,
                              ),
                              customization: HeroAppearanceSelection(
                                bodyProportionId:
                                    controller.save.bodyProportionId,
                              ),
                              gear: EquippedGearAppearance.fromMap(
                                controller.save.equippedItems,
                              ),
                              motionAtlasAsset:
                                  'assets/art/characters/hero_battle_atlas.png',
                              actionAtlasAsset: 'assets/art/characters/hero_battle_actions.png',
                              actionPose: _playerMotion?.actionPose,
                              motion:
                                  _playerMotion?.motion ?? FighterMotion.idle,
                              motionKey: _playerMotion?.sequence ?? 0,
                              reducedMotion:
                                  controller.save.reducedMotion ||
                                  controller.save.skipBattleAnimations,
                              animationSpeed:
                                  controller.save.battleAnimationSpeed,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 2,
                            bottom: 2,
                            child: FighterArt(
                              seed: encounter.id,
                              name: _encounterName(context, encounter),
                              family: encounter.weaponFamily.name,
                              status: enemyStatus,
                              portraitAsset: characterArtForEncounter(
                                encounter.id,
                              ),
                              atlasAsset: rivalAtlasForEncounter(encounter.id)
                                  ?.asset,
                              atlasIndex: rivalAtlasForEncounter(encounter.id)
                                  ?.index,
                              motionAtlasAsset:
                                  rivalMotionAtlasAssetForEncounter(
                                    encounter.id,
                                  ),
                              motion:
                                  _opponentMotion?.motion ?? FighterMotion.idle,
                              motionKey: _opponentMotion?.sequence ?? 0,
                              reducedMotion:
                                  controller.save.reducedMotion ||
                                  controller.save.skipBattleAnimations,
                              animationSpeed:
                                  controller.save.battleAnimationSpeed,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 10,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xE6101719),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: GamePalette.gold.withValues(
                                      alpha: .65,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  gameText(context, 'ui.battle.distancePhase', {
                                    'distance': GameLocalizations.of(context)
                                        .uppercase(
                                          gameText(
                                            context,
                                            'label.range.${state.distance.name}',
                                          ),
                                        ),
                                    'phase': state.phase,
                                    'phases': encounter.phaseCount,
                                  }),
                                  style: const TextStyle(
                                    color: GamePalette.gold,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: .6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GamePanel(
                    color: const Color(0xD9172021),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              color: GamePalette.rust,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizedHeading(
                                      context,
                                      'ui.battle.opponentIntent',
                                    ),
                                    style: const TextStyle(
                                      color: GamePalette.gold,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Text(
                                    _battleMessageText(
                                      context,
                                      state.intentMessage,
                                      encounter,
                                      _heroDisplayName(
                                        context,
                                        controller.save.heroName,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (state.telegraphedHazard) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: GamePalette.rust),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: GamePalette.gold,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizedHeading(
                                        context,
                                        'ui.battle.arenaHazard',
                                      ),
                                      style: const TextStyle(
                                        color: GamePalette.gold,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    Text(
                                      gameText(
                                        context,
                                        'ui.battle.hazardCountdown',
                                        {
                                          'turns':
                                              state
                                                  .hazardWarningTurnsRemaining ??
                                              1,
                                        },
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionHeading(
                    localizedHeading(context, 'ui.battle.chooseAction'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in [
                        BattleAction.quick,
                        BattleAction.heavy,
                        BattleAction.guard,
                        BattleAction.sweep,
                      ])
                        _BattleActionTile(
                          engine: engine,
                          action: action,
                          onTap: _working ? null : () => _act(action),
                        ),
                      if (engine.player.ammo > 0)
                        _BattleActionTile(
                          engine: engine,
                          action: BattleAction.bow,
                          onTap: _working ? null : () => _act(BattleAction.bow),
                          badge: gameText(context, 'ui.battle.ammo', {
                            'count': engine.player.ammo,
                          }),
                        ),
                      _BattleActionTile(
                        engine: engine,
                        action: BattleAction.closeDistance,
                        onTap: _working
                            ? null
                            : () => _act(BattleAction.closeDistance),
                      ),
                      _BattleActionTile(
                        engine: engine,
                        action: BattleAction.openDistance,
                        onTap: _working
                            ? null
                            : () => _act(BattleAction.openDistance),
                      ),
                      _BattleActionTile(
                        engine: engine,
                        action: BattleAction.shoreStep,
                        onTap: _working
                            ? null
                            : () => _act(BattleAction.shoreStep),
                      ),
                      for (final spell in spells.where(
                        (spell) => controller.save.ownedItems.contains(
                          'spell_${spell.action.name}',
                        ),
                      ))
                        _BattleActionTile(
                          engine: engine,
                          action: spell.action,
                          onTap: _working ? null : () => _act(spell.action),
                          spell: true,
                        ),
                      if (controller.save.healingSalves > 0)
                        _BattleActionTile(
                          engine: engine,
                          action: BattleAction.salve,
                          onTap: _working
                              ? null
                              : () => _act(BattleAction.salve),
                          badge: '×${controller.save.healingSalves}',
                        ),
                      if (controller.save.effortTonics > 0)
                        _BattleActionTile(
                          engine: engine,
                          action: BattleAction.tonic,
                          onTap: _working
                              ? null
                              : () => _act(BattleAction.tonic),
                          badge: '×${controller.save.effortTonics}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GamePanel(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xD9172021),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeading(
                          localizedHeading(context, 'ui.battle.combatLog'),
                        ),
                        const SizedBox(height: 6),
                        for (final entry
                            in state.messages.reversed
                                .take(4)
                                .toList()
                                .reversed)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              gameText(context, 'ui.battle.logEntry', {
                                'entry': _battleMessageText(
                                  context,
                                  entry,
                                  encounter,
                                  _heroDisplayName(
                                    context,
                                    controller.save.heroName,
                                  ),
                                ),
                              }),
                              style: const TextStyle(
                                color: GamePalette.muted,
                                fontSize: 10,
                                height: 1.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    gameText(context, 'ui.battle.turnHint', {
                      'turn': engine.metrics.turn + 1,
                    }),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BattleActionTile extends StatelessWidget {
  const _BattleActionTile({
    required this.engine,
    required this.action,
    required this.onTap,
    this.badge,
    this.spell = false,
  });
  final BattleEngine engine;
  final BattleAction action;
  final VoidCallback? onTap;
  final String? badge;
  final bool spell;
  @override
  Widget build(BuildContext context) {
    final preview = engine.preview(action);
    final isEnabled = preview.canUse && onTap != null;
    final media = MediaQuery.of(context);
    final availableWidth = media.size.width.clamp(0.0, 760.0) - 28;
    final textScale = media.textScaler.scale(14) / 14;
    final fitsTwo = textScale < 1.35 && availableWidth >= 288;
    final tileWidth = fitsTwo
        ? ((availableWidth - 8) / 2).clamp(138.0, 360.0)
        : availableWidth;
    final actionName = gameText(context, 'label.action.${action.name}');
    final costText = gameText(context, preview.costMessage.id, {
      ...preview.costMessage.arguments,
    });
    final statsText = preview.hitChance > 0
        ? '${preview.hitChance}% · ~${preview.estimatedDamage}'
        : null;
    final badgeText = (badge != null && badge!.isNotEmpty) ? badge : null;
    final semanticParts = <String>[
      actionName,
      costText,
      ?statsText,
      ?badgeText,
    ];
    final semanticLabel = semanticParts.join(', ');

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: tileWidth,
        maxWidth: tileWidth,
        minHeight: 73,
      ),
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: semanticLabel,
        onTap: isEnabled ? onTap : null,
        excludeSemantics: true,
        child: Material(
          color: isEnabled
              ? (spell ? const Color(0xE1243041) : const Color(0xE1242D2F))
              : const Color(0xD9151C1E),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            excludeFromSemantics: true,
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          actionName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isEnabled
                                ? GamePalette.parchment
                                : GamePalette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          badge!,
                          style: TextStyle(
                            color: isEnabled
                                ? GamePalette.gold
                                : GamePalette.muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          costText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isEnabled
                                ? GamePalette.muted
                                : GamePalette.muted.withValues(alpha: .6),
                            fontSize: 9,
                          ),
                        ),
                      ),
                      if (statsText != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          statsText,
                          style: TextStyle(
                            color: isEnabled
                                ? (preview.hitChance >= 70
                                    ? GamePalette.teal
                                    : GamePalette.gold)
                                : GamePalette.muted,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
typedef BattleActionTile = _BattleActionTile;

String _localizedShopError(BuildContext context, String message) {
  const exactMessages = <String, String>{
    'Önce dövüşçünü oluştur.': 'ui.shop.error.noHero',
    'Bu katalog henüz açılmadı.': 'ui.shop.error.catalogLocked',
    'Bu eşya zaten envanterinde.': 'ui.shop.error.alreadyOwned',
    'Yeterli Sikke yok.': 'ui.shop.error.notEnoughCoins',
    'Bu eşya dükkân kataloğunda bulunamadı.': 'ui.shop.error.unknownItem',
    'Eşya envanterinde değil.': 'ui.shop.error.notOwned',
    'Kuşanılmış eşya satılamaz.': 'ui.shop.error.cannotSellEquipped',
    'Bu yetenek zaten öğrenildi.': 'ui.shop.error.alreadyLearned',
    'Devre katalogu henüz açılmadı.': 'ui.shop.error.spellCatalogLocked',
    'Bu sarf eşyasından en fazla 3 tane taşıyabilirsin.':
        'ui.shop.error.consumableLimit',
  };
  final key = exactMessages[message];
  if (key != null) return gameText(context, key);

  final level = RegExp(r'^Bu eşya için seviye (\d+) gerekli\.$')
      .firstMatch(message);
  if (level != null) {
    return gameText(context, 'ui.shop.error.level', {
      'level': int.parse(level.group(1)!),
    });
  }

  final attribute = RegExp(r'^Bu eşya için (.+) (\d+) gerekli\.$')
      .firstMatch(message);
  if (attribute != null) {
    final statKey = switch (attribute.group(1)) {
      'Kuvvet' => 'might',
      'Çeviklik' => 'agility',
      'İsabet' => 'precision',
      'Canlılık' => 'vitality',
      'Dayanıklılık' => 'stamina',
      'Gard' || 'Savunma' => 'guard',
      'Kondisyon' => 'stamina',
      'Büyü' => 'arcana',
      _ => null,
    };
    if (statKey != null) {
      return gameText(context, 'ui.shop.error.minimumAttribute', {
        'attribute': gameText(context, 'label.stat.$statKey'),
        'value': int.parse(attribute.group(2)!),
      });
    }
  }

  if (message.startsWith('Kayıt yazılamadı:')) {
    return gameText(context, 'ui.shop.error.saveFailed');
  }
  return message;
}

Future<void> _runShopOperation(
  BuildContext context,
  GameController controller,
  Future<String?> Function() operation,
) async {
  String? result;
  try {
    result = await operation();
  } on Object catch (error) {
    result = controller.lastError ?? error.toString();
  }
  if (!context.mounted || result == null) return;
  final canRetry = result.startsWith('Kayıt yazılamadı:');
  _showMessage(
    context,
    _localizedShopError(context, result),
    actionLabel: canRetry ? gameText(context, 'ui.common.retry') : null,
    onAction: canRetry
        ? () => unawaited(_runShopOperation(context, controller, operation))
        : null,
  );
}

Future<void> _runCampaignReset(
  BuildContext context,
  GameController controller,
) async {
  try {
    await controller.resetCampaign();
  } on Object {
    if (!context.mounted) return;
    _showMessage(
      context,
      gameText(context, 'ui.settings.resetSaveFailed'),
      actionLabel: gameText(context, 'ui.common.retry'),
      onAction: () => unawaited(_runCampaignReset(context, controller)),
    );
  }
}

void _showMessage(
  BuildContext context,
  String text, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: actionLabel == null ? 2 : 8),
      action: actionLabel == null || onAction == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction),
    ),
  );
}

Widget _labelledIconButton({
  required String label,
  required IconData icon,
  required VoidCallback? onPressed,
}) => Semantics(
  container: true,
  explicitChildNodes: true,
  label: label,
  button: true,
  enabled: onPressed != null,
  onTap: onPressed,
  child: ExcludeSemantics(
    child: IconButton(tooltip: label, onPressed: onPressed, icon: Icon(icon)),
  ),
);
