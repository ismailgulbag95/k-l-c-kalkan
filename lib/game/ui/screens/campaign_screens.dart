part of '../screens.dart';

class CampaignPage extends StatelessWidget {
  const CampaignPage({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.campaignComplete
        ? null
        : controller.nextEncounter;
    final pendingStoryEvidence = controller.pendingStoryEvidence;
    final pendingDecision = controller.pendingIntermissionDecision;
    final arena = getArena(current?.arenaId ?? 'halka');
    final completed = controller.save.completedMatches
        .where(
          (key) =>
              int.tryParse(key.substring(1)) != null &&
              int.parse(key.substring(1)) <= 32,
        )
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  gameText(context, 'ui.campaign.greeting', {
                    'name': _heroDisplayName(context, controller.save.heroName),
                  }),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.campaignComplete
                      ? gameText(context, 'ui.campaign.championTitle')
                      : gameText(context, 'ui.campaign.nextDuel'),
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                if (pendingStoryEvidence != null) ...[
                  GamePanel(
                    borderColor: GamePalette.rust.withValues(alpha: .8),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        StoryEvidenceCardArt(
                          frame: pendingStoryEvidence.frame,
                          size: 72,
                          semanticLabel:
                              '${gameText(context, pendingStoryEvidence.titleKey)}. ${gameText(context, pendingStoryEvidence.bodyKey)}',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gameText(context, 'ui.story.evidence.pending'),
                                style: const TextStyle(
                                  color: GamePalette.rust,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gameText(
                                  context,
                                  pendingStoryEvidence.titleKey,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GameButton(
                                label: gameText(
                                  context,
                                  'ui.story.evidence.open',
                                ),
                                icon: Icons.article_outlined,
                                onPressed: () => _showStoryEvidence(
                                  context,
                                  controller,
                                  pendingStoryEvidence,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (pendingDecision != null) ...[
                  GamePanel(
                    borderColor: GamePalette.gold.withValues(alpha: .7),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _intermissionArt(
                            context,
                            pendingDecision,
                            height: 136,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              color: GamePalette.gold,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                gameText(context, 'ui.intermission.pending'),
                                style: const TextStyle(
                                  color: GamePalette.gold,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          gameText(context, 'ui.intermission.body', {
                            'encounter': pendingDecision.afterEncounterId,
                          }),
                          style: const TextStyle(
                            color: GamePalette.muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GameButton(
                          label: gameText(context, 'ui.intermission.heading'),
                          icon: Icons.tune,
                          onPressed: () =>
                              _showIntermissionChoice(context, controller),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 250,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(arena.art, fit: BoxFit.cover),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x33101719), Color(0xEE101719)],
                              stops: [0, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: chapterColor(current?.chapter ?? 4),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              gameText(context, 'ui.campaign.chapter', {
                                'chapter': current?.chapter ?? 4,
                                'arena': GameLocalizations.of(context)
                                    .uppercase(_arenaName(context, arena.id)),
                              }),
                              style: const TextStyle(
                                color: GamePalette.ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      current == null
                                          ? gameText(
                                              context,
                                              'ui.campaign.complete',
                                            )
                                          : _encounterName(context, current),
                                      style: const TextStyle(
                                        color: GamePalette.parchment,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      current == null
                                          ? gameText(
                                              context,
                                              'ui.campaign.championsRoadUnlocked',
                                            )
                                          : '${gameText(context, switch (current.kind) {
                                              EncounterKind.champion => 'ui.encounter.kind.champion',
                                              EncounterKind.elite => 'ui.encounter.kind.elite',
                                              EncounterKind.intermediateFinal => 'ui.encounter.kind.intermediateFinal',
                                              _ => 'ui.encounter.kind.main',
                                            })}  ·  ${gameText(context, 'ui.campaign.reward', {'gold': current.gold})}',
                                      style: const TextStyle(
                                        color: GamePalette.parchment,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (current?.story.isNotEmpty ?? false) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        _encounterContent(
                                          context,
                                          current!,
                                          'story',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: GamePalette.muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (current != null)
                                SizedBox(
                                  width: constraints.maxWidth < 360 ? 96 : 120,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.bottomRight,
                                    child: FighterArt(
                                      seed: 3,
                                      name: '',
                                      isPlayer: false,
                                      family: 'spear',
                                      portraitAsset: characterArtForEncounter(
                                        current.id,
                                      ),
                                      atlasAsset: rivalAtlasForEncounter(
                                        current.id,
                                      )?.asset,
                                      atlasIndex: rivalAtlasForEncounter(
                                        current.id,
                                      )?.index,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (current == null) ...[
                  GamePanel(
                    borderColor: GamePalette.gold.withValues(alpha: .7),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_stories,
                              color: GamePalette.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              gameText(context, 'ui.campaign.epilogueHeading'),
                              style: const TextStyle(
                                color: GamePalette.gold,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          gameText(context, 'ui.campaign.epilogueBody'),
                          style: const TextStyle(
                            color: GamePalette.parchment,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gameText(context, 'ui.campaign.postgameIntro'),
                          style: TextStyle(
                            color: GamePalette.muted,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                GamePanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gameText(context, 'ui.campaign.progress', {
                                'completed': completed,
                              }),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${(completed / 32 * 100).round()}%',
                            style: const TextStyle(
                              color: GamePalette.gold,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completed / 32,
                          minHeight: 8,
                          color: GamePalette.gold,
                          backgroundColor: GamePalette.panelLight,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gameText(context, 'ui.campaign.levelXp', {
                                'level': controller.save.level,
                                'xp': _xpToNext(controller.save),
                              }),
                              style: const TextStyle(
                                color: GamePalette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          ValuePill(
                            icon: Icons.auto_awesome,
                            value: gameText(context, 'ui.campaign.points', {
                              'count': controller.save.unspentStatPoints,
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (current != null)
                  GameButton(
                    label: gameText(context, 'ui.campaign.enterDuel'),
                    icon: Icons.sports_martial_arts,
                    onPressed: () => _openBattle(
                      context,
                      controller,
                      () => controller.startEncounter(current.id),
                    ),
                  ),
                if (current == null)
                  GameButton(
                    label: gameText(context, 'ui.campaign.championsRoad'),
                    icon: Icons.emoji_events,
                    onPressed: () => _openBattle(
                      context,
                      controller,
                      () => controller.startChampionsRoad(
                        (controller.save.championsRunBest + 1).clamp(1, 8),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SectionHeading(
                        localizedHeading(context, 'ui.campaign.map'),
                      ),
                    ),
                    Text(
                      gameText(context, 'ui.campaign.nextKey', {
                        'key':
                            current?.key ??
                            gameText(context, 'ui.campaign.endKey'),
                      }),
                      style: const TextStyle(
                        color: GamePalette.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final chapter in [1, 2, 3, 4]) ...[
                  _ChapterHeader(
                    chapter: chapter,
                    completed: controller.save.completedMatches.where((key) {
                      final id = int.tryParse(key.substring(1));
                      return id != null &&
                          id <= 32 &&
                          ((id - 1) ~/ 8 + 1) == chapter;
                    }).length,
                  ),
                  _AudienceChapterScore(
                    controller: controller,
                    chapter: chapter,
                  ),
                  for (final encounter in mainEncounters.where(
                    (entry) => entry.chapter == chapter,
                  ))
                    EncounterTile(controller: controller, encounter: encounter),
                  const SizedBox(height: 10),
                ],
                if (controller.campaignComplete) ...[
                  SectionHeading(
                    localizedHeading(context, 'ui.campaign.masteryTrials'),
                  ),
                  const SizedBox(height: 8),
                  for (var stage = 1; stage <= 8; stage++)
                    ListTile(
                      leading: Icon(
                        stage <= controller.save.championsRunBest
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: GamePalette.gold,
                      ),
                      title: Text(
                        gameText(context, 'ui.campaign.trial', {
                          'stage': stage,
                        }),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        localizedContent(context, 'postgame', '$stage', 'name'),
                        style: const TextStyle(
                          color: GamePalette.muted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: stage <= controller.save.championsRunBest + 1
                          ? () => _openBattle(
                              context,
                              controller,
                              () => controller.startChampionsRoad(stage),
                            )
                          : null,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

int _xpToNext(GameSave save) {
  if (save.level >= 20) return 0;
  final nextLevel = save.level + 1;
  final threshold = (nextLevel - 1) * (120 + 9 * (nextLevel - 2));
  return threshold - save.xp;
}

String _arenaName(BuildContext context, String arenaId) =>
    localizedContent(context, 'arena', arenaId, 'name');

String _heroDisplayName(BuildContext context, String heroName) =>
    heroName == 'Kıyı Dövüşçüsü'
    ? gameText(context, 'ui.hero.defaultName')
    : heroName;

int _baseEncounterId(int id) {
  if (id <= 32) return id;
  const variants = [6, 14, 8, 16, 22, 24, 30, 32];
  final stage = id - 32;
  return stage >= 1 && stage <= variants.length ? variants[stage - 1] : id;
}

String _encounterName(BuildContext context, Encounter encounter) {
  if (encounter.kind == EncounterKind.postgame && encounter.id == 40) {
    return gameText(context, 'content.postgame.8.name');
  }
  final name = localizedContent(
    context,
    'encounter',
    'M${_baseEncounterId(encounter.id).toString().padLeft(2, '0')}',
    'name',
  );
  return encounter.kind == EncounterKind.postgame
      ? '$name · ${gameText(context, 'ui.encounter.masterySuffix')}'
      : name;
}

String _encounterContent(
  BuildContext context,
  Encounter encounter,
  String field,
) {
  final key =
      'content.encounter.M${_baseEncounterId(encounter.id).toString().padLeft(2, '0')}.$field';
  final translation = gameText(context, key);
  return translation == key
      ? (field == 'story' ? encounter.story : encounter.hazard)
      : translation;
}

String _encounterArchetype(BuildContext context, Encounter encounter) =>
    gameText(context, 'content.archetype.${encounter.archetype}');

String _battleMessageText(
  BuildContext context,
  BattleMessage message,
  Encounter encounter,
  String playerName,
) {
  final arguments = <String, Object?>{};
  for (final entry in message.arguments.entries) {
    final value = entry.value;
    arguments[entry.key] = switch (value) {
      BattleActor.player => playerName,
      BattleActor.opponent => _encounterName(context, encounter),
      BattleAction action => gameText(context, 'label.action.${action.name}'),
      RangeBand range => gameText(context, 'label.range.${range.name}'),
      StatusKind status => gameText(context, 'label.status.${status.name}'),
      CombatElement element => gameText(
        context,
        'label.element.${element.name}',
      ),
      List<Object?> tactics when entry.key == 'tactics' =>
        tactics
            .whereType<TaughtTactic>()
            .map((tactic) => gameText(context, 'content.tactic.${tactic.name}'))
            .join(' · '),
      String text when entry.key == 'archetype' => gameText(
        context,
        'content.archetype.$text',
      ),
      String _ when entry.key == 'hazard' => _encounterContent(
        context,
        encounter,
        'hazard',
      ),
      _ => value,
    };
  }
  return gameText(context, message.id, arguments);
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter, required this.completed});
  final int chapter;
  final int completed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 5),
    child: Row(
      children: [
        Container(
          width: 6,
          height: 30,
          decoration: BoxDecoration(
            color: chapterColor(chapter),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameText(context, 'ui.campaign.chapterHeading', {
                  'chapter': chapter,
                  'title': gameText(
                    context,
                    'ui.campaign.chapterTitle.$chapter',
                  ),
                }),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              Text(
                gameText(context, 'ui.campaign.encountersComplete', {
                  'completed': completed,
                }),
                style: const TextStyle(color: GamePalette.muted, fontSize: 10),
              ),
            ],
          ),
        ),
        Icon(
          Icons.keyboard_double_arrow_down,
          color: GamePalette.muted,
          size: 17,
        ),
      ],
    ),
  );
}

@visibleForTesting
String audienceCrowdReactionText({
  required bool won,
  required bool isEnglish,
  required String chapterTitle,
}) {
  if (isEnglish) {
    return won
        ? 'The $chapterTitle crowd erupts for your victory!'
        : 'The $chapterTitle crowd falls silent after your defeat.';
  }
  return won
      ? '$chapterTitle tribünleri zaferinle coştu!'
      : '$chapterTitle tribünleri yenilginden sonra sessizliğe gömüldü.';
}

class _AudienceChapterScore extends StatelessWidget {
  const _AudienceChapterScore({
    required this.controller,
    required this.chapter,
  });
  final GameController controller;
  final int chapter;

  @override
  Widget build(BuildContext context) {
    final score = controller.audienceScoreForChapter(chapter);
    final unlocked = controller.hasAudienceCrest(chapter);
    final chapterTitle = gameText(context, 'ui.campaign.chapterTitle.$chapter');
    final isEnglish = GameLocalizations.of(context).isEnglish;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GamePanel(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        child: Row(
          children: [
            AudienceChapterEmblem(
              chapter: chapter,
              size: 42,
              semanticLabel: isEnglish
                  ? '$chapterTitle crest'
                  : '$chapterTitle arması',
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameText(
                      context,
                      unlocked
                          ? 'ui.audience.crestUnlocked'
                          : 'ui.audience.scoreTitle',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    unlocked
                        ? gameText(context, 'ui.audience.cosmeticReward')
                        : gameText(context, 'ui.audience.crestThreshold'),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$score / 24',
              style: TextStyle(
                color: unlocked ? chapterColor(chapter) : GamePalette.gold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EncounterTile extends StatelessWidget {
  const EncounterTile({
    super.key,
    required this.controller,
    required this.encounter,
  });
  final GameController controller;
  final Encounter encounter;

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.isEncounterUnlocked(encounter.id);
    final completed = controller.save.completedMatches.contains(encounter.key);
    final icon = completed
        ? Icons.check_circle
        : !unlocked
        ? Icons.lock_outline
        : encounter.kind == EncounterKind.champion ||
              encounter.kind == EncounterKind.intermediateFinal
        ? Icons.emoji_events
        : encounter.kind == EncounterKind.elite
        ? Icons.shield
        : Icons.sports_martial_arts;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: unlocked ? GamePalette.panel : const Color(0xFF171E20),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: unlocked
              ? () => _openBattle(
                  context,
                  controller,
                  () => controller.startEncounter(encounter.id),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: chapterColor(encounter.chapter)
                        .withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: completed
                        ? GamePalette.teal
                        : chapterColor(encounter.chapter),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${encounter.id.toString().padLeft(2, '0')}  ${_encounterName(context, encounter)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: unlocked
                              ? GamePalette.parchment
                              : GamePalette.muted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_encounterArchetype(context, encounter)}  ·  ${gameText(context, 'ui.encounter.level', {'level': encounter.level})}  ·  ${gameText(context, switch (encounter.kind) {
                          EncounterKind.champion => 'ui.encounter.shortChampion',
                          EncounterKind.intermediateFinal => 'ui.encounter.shortIntermediateFinal',
                          EncounterKind.elite => 'ui.encounter.shortElite',
                          _ => 'ui.encounter.shortDuel',
                        })}',
                        style: const TextStyle(
                          color: GamePalette.muted,
                          fontSize: 10,
                        ),
                      ),
                      if (encounter.elementalImmunities.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          '${gameText(context, 'ui.encounter.immunity')}: ${encounter.elementalImmunities.map((element) => gameText(context, 'label.element.${element.name}')).join(' · ')}',
                          style: const TextStyle(
                            color: GamePalette.gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  completed
                      ? gameText(context, 'ui.encounter.complete')
                      : '${encounter.gold} ◈',
                  style: TextStyle(
                    color: completed ? GamePalette.teal : GamePalette.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

