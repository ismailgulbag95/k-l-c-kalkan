import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../data/content.dart';
import '../data/intermission_decisions.dart';
import '../data/story_evidence.dart';
import '../domain/battle_engine.dart';
import '../domain/game_controller.dart';
import '../domain/models.dart';
import '../l10n/game_localizations.dart';
import 'contract_art.dart';
import 'audio_service.dart';
import 'audience_emblems.dart';
import 'design.dart';
import 'game_glyphs.dart';
import 'rival_motion_assets.dart';

class GameRoot extends StatefulWidget {
  const GameRoot({super.key, this.controller});
  final GameController? controller;

  @override
  State<GameRoot> createState() => _GameRootState();
}

class _GameRootState extends State<GameRoot> with WidgetsBindingObserver {
  late final GameController controller;
  final GameAudioService audio = GameAudioService();
  late final GameAudioNavigatorObserver audioObserver =
      GameAudioNavigatorObserver(audio);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = widget.controller ?? (GameController()..initialize());
    controller.addListener(_syncAudioFromController);
    _syncAudioFromController();
  }

  void _syncAudioFromController() {
    if (!controller.ready) return;
    audio.syncHome(
      save: controller.save,
      chapter: controller.campaignComplete
          ? 4
          : controller.nextEncounter.chapter,
      campaignComplete: controller.campaignComplete,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    audio.handleLifecycle(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      unawaited(controller.persistActiveBattleCheckpoint());
    } else if (state == AppLifecycleState.resumed &&
        controller.battleCheckpointWritePending) {
      unawaited(controller.persistActiveBattleCheckpoint());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_syncAudioFromController);
    unawaited(audio.dispose());
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      if (!controller.ready) {
        return MaterialApp(
          theme: buildGameTheme(),
          home: const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: GamePalette.gold),
            ),
          ),
        );
      }
      return GameLocaleScope(
        languageCode: controller.save.language == 'en' ? 'en' : 'tr',
        child: GameAudioScope(
          service: audio,
          child: MaterialApp(
            title: 'Kül Çemberi',
            debugShowCheckedModeBanner: false,
            locale: Locale(controller.save.language == 'en' ? 'en' : 'tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: buildGameTheme(),
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final systemScale = media.textScaler.scale(14) / 14;
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(
                    systemScale * controller.save.textScale,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            navigatorObservers: [audioObserver],
            home: controller.save.hasHero
                ? GameHub(controller: controller)
                : GameTitle(controller: controller),
          ),
        ),
      );
    },
  );
}

class GameTitle extends StatelessWidget {
  const GameTitle({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GameBackdrop(
      image: arenas.first.art,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 4),
                  const Text(
                    'KÜL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GamePalette.parchment,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  Text(
                    'ÇEMBERİ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GamePalette.gold,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gameText(context, 'ui.title.tagline'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GamePalette.parchment,
                      fontSize: 16,
                    ),
                  ),
                  if (controller.schemaMigrationPending) ...[
                    const SizedBox(height: 14),
                    _SchemaMigrationNotice(controller: controller),
                  ],
                  const Spacer(flex: 3),
                  GamePanel(
                    color: const Color(0xD8172021),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeading(
                          localizedHeading(context, 'ui.title.panel.heading'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gameText(context, 'ui.title.panel.body'),
                          style: const TextStyle(
                            color: GamePalette.parchment,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GameButton(
                    label: gameText(context, 'ui.title.createFighter'),
                    icon: Icons.sports_martial_arts,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CharacterCreator(controller: controller),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    gameText(context, 'ui.title.footer'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GamePalette.muted, fontSize: 11),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CharacterCreator extends StatefulWidget {
  const CharacterCreator({super.key, required this.controller});
  final GameController controller;

  @override
  State<CharacterCreator> createState() => _CharacterCreatorState();
}

class _CharacterCreatorState extends State<CharacterCreator> {
  final _name = TextEditingController();
  var stats = const Stats();
  int remaining = 6;
  String origin = 'Kıyı';
  String bodyProportionId = 'body_01';

  HeroAppearanceSelection get _appearanceSelection =>
      HeroAppearanceSelection(bodyProportionId: bodyProportionId);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _adjust(Stat stat, int delta) {
    if (delta > 0 && (remaining == 0 || stats[stat] >= 5)) return;
    if (delta < 0 && stats[stat] <= 2) return;
    setState(() {
      stats = stats.withStat(stat, stats[stat] + delta);
      remaining -= delta;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(gameText(context, 'ui.creator.title')),
      leading: _labelledIconButton(
        label: gameText(context, 'ui.common.back'),
        onPressed: () => Navigator.pop(context),
        icon: Icons.arrow_back,
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            children: [
              GamePanel(
                child: Row(
                  children: [
                    SizedBox(
                      width: 132,
                      child: FighterArt(
                        seed: 1,
                        name: gameText(context, 'ui.creator.newFighter'),
                        isPlayer: true,
                        origin: origin,
                        portraitAsset: heroArtForAppearance(origin),
                        customization: _appearanceSelection,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameText(context, 'ui.creator.heading'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            gameText(context, 'ui.creator.body'),
                            style: TextStyle(
                              color: GamePalette.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: gameText(context, 'ui.creator.name'),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 12),
              SectionHeading(
                localizedHeading(context, 'ui.creator.appearance'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final choice in ['Kıyı', 'Ocak', 'Fırtına', 'Taç'])
                    ChoiceChip(
                      avatar: SizedBox(
                        width: 25,
                        height: 38,
                        child: HeroAppearanceOptionPreview(
                          kind: HeroAppearanceOptionKind.body,
                          optionId: 'body_02',
                          origin: choice,
                        ),
                      ),
                      label: Text(
                        gameText(context, switch (choice) {
                          'Kıyı' => 'ui.origin.coast',
                          'Ocak' => 'ui.origin.forge',
                          'Fırtına' => 'ui.origin.storm',
                          _ => 'ui.origin.crown',
                        }),
                      ),
                      selected: origin == choice,
                      onSelected: (_) => setState(() => origin = choice),
                      selectedColor: GamePalette.gold,
                      labelStyle: TextStyle(
                        color: origin == choice
                            ? GamePalette.ink
                            : GamePalette.parchment,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              GamePanel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SectionHeading(
                            localizedHeading(context, 'ui.creator.stats'),
                          ),
                        ),
                        ValuePill(
                          icon: Icons.add_circle_outline,
                          value: gameText(context, 'ui.points.remaining', {
                            'count': remaining,
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final stat in Stat.values)
                      _StatEditor(
                        stat: stat,
                        value: stats[stat],
                        onMinus: () => _adjust(stat, -1),
                        onPlus: () => _adjust(stat, 1),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCustomizationControls(context),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GameButton(
            label: gameText(context, 'ui.creator.joinLeague'),
            icon: Icons.arrow_forward,
            enabled: remaining == 0,
            onPressed: remaining == 0
                ? () async {
                    try {
                      await widget.controller.createHero(
                        name: _name.text,
                        stats: stats,
                        appearance: origin,
                        bodyProportionId: bodyProportionId,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } on Object catch (error) {
                      if (context.mounted) _showMessage(context, '$error');
                    }
                  }
                : null,
          ),
        ),
      ),
    ),
  );

  Widget _buildCustomizationControls(BuildContext context) {
    final isEnglish = GameLocalizations.of(context).isEnglish;
    final labelStyle = TextStyle(
      color: GamePalette.parchment,
      fontWeight: FontWeight.w700,
    );

    Widget selectorTitle(String turkish, String english) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(isEnglish ? english : turkish, style: labelStyle),
    );

    Widget accessibleChoice({
      required String group,
      required String groupLabel,
      required String optionId,
      required int index,
      required bool selected,
      required Widget chip,
      required VoidCallback onSelected,
    }) {
      final option = gameText(context, 'ui.appearance.option', {
        'group': groupLabel,
        'count': index + 1,
      });
      return Semantics(
        key: ValueKey('creator.$group.$optionId'),
        label: option,
        selected: selected,
        button: true,
        onTap: onSelected,
        child: ExcludeSemantics(child: chip),
      );
    }

    Widget imageChoice({
      required String group,
      required String groupLabel,
      required String id,
      required bool selected,
      required HeroAppearanceOptionKind kind,
      required int displayIndex,
      required double previewHeight,
      required ValueChanged<bool> onSelected,
    }) => accessibleChoice(
      group: group,
      groupLabel: groupLabel,
      optionId: id,
      index: displayIndex,
      selected: selected,
      onSelected: () => onSelected(true),
      chip: ChoiceChip(
        avatar: SizedBox(
          width: 42,
          height: previewHeight,
          child: HeroAppearanceOptionPreview(
            kind: kind,
            optionId: id,
            origin: origin,
          ),
        ),
        label: Text('${displayIndex + 1}'),
        selected: selected,
        onSelected: onSelected,
        selectedColor: GamePalette.gold,
        labelStyle: TextStyle(
          color: selected ? GamePalette.ink : GamePalette.parchment,
          fontWeight: FontWeight.w800,
        ),
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      ),
    );

    return GamePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          selectorTitle('Yapı', 'Build'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in heroBodyProportionIds.asMap().entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: imageChoice(
                      group: 'body',
                      groupLabel: gameText(context, 'ui.appearance.build'),
                      id: entry.value,
                      selected: bodyProportionId == entry.value,
                      kind: HeroAppearanceOptionKind.body,
                      displayIndex: entry.key,
                      previewHeight: 48,
                      onSelected: (_) =>
                          setState(() => bodyProportionId = entry.value),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatEditor extends StatelessWidget {
  const _StatEditor({
    required this.stat,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final Stat stat;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameText(context, 'label.stat.${stat.name}'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                gameText(context, 'ui.statHelp.${stat.name}'),
                style: const TextStyle(color: GamePalette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: value > 2 ? onMinus : null,
          icon: const Icon(Icons.remove, size: 18),
          tooltip: gameText(context, 'ui.common.decrease'),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GamePalette.gold,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < 5 ? onPlus : null,
          icon: const Icon(Icons.add, size: 18),
          tooltip: gameText(context, 'ui.common.increase'),
        ),
      ],
    ),
  );
}

class GameHub extends StatefulWidget {
  const GameHub({super.key, required this.controller});
  final GameController controller;

  @override
  State<GameHub> createState() => _GameHubState();
}

class _GameHubState extends State<GameHub> {
  int selected = 0;
  late final pages = [
    CampaignPage(controller: widget.controller),
    FighterPage(controller: widget.controller),
    ShopPage(controller: widget.controller),
    ChallengesPage(controller: widget.controller),
    SettingsPage(controller: widget.controller),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller.restoredBattleFromSave) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.controller.consumeRestoredBattleFlag()) return;
        unawaited(
          _openBattle(
            context,
            widget.controller,
            () {},
            resumeFromCheckpoint: true,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          GameGlyph(
            GameGlyphKind.guard,
            color: GamePalette.gold,
            size: 22,
            excludeFromSemantics: true,
          ),
          SizedBox(width: 9),
          Text(
            'KÜL ÇEMBERİ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Center(
            child: ValuePill(
              icon: Icons.monetization_on_outlined,
              value: '${widget.controller.save.gold}',
            ),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          if (widget.controller.schemaMigrationPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _SchemaMigrationNotice(controller: widget.controller),
            ),
          Expanded(
            child: IndexedStack(index: selected, children: pages),
          ),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) => setState(() => selected = index),
      backgroundColor: GamePalette.panel,
      indicatorColor: GamePalette.gold.withValues(alpha: .18),
      destinations: [
        NavigationDestination(
          icon: const GameGlyph(
            GameGlyphKind.campaign,
            excludeFromSemantics: true,
          ),
          selectedIcon: const GameGlyph(
            GameGlyphKind.campaign,
            selected: true,
            excludeFromSemantics: true,
          ),
          label: gameText(context, 'ui.nav.league'),
        ),
        NavigationDestination(
          icon: const GameGlyph(
            GameGlyphKind.fighter,
            excludeFromSemantics: true,
          ),
          selectedIcon: const GameGlyph(
            GameGlyphKind.fighter,
            selected: true,
            excludeFromSemantics: true,
          ),
          label: gameText(context, 'ui.nav.fighter'),
        ),
        NavigationDestination(
          icon: const GameGlyph(GameGlyphKind.shop, excludeFromSemantics: true),
          selectedIcon: const GameGlyph(
            GameGlyphKind.shop,
            selected: true,
            excludeFromSemantics: true,
          ),
          label: gameText(context, 'ui.nav.shop'),
        ),
        NavigationDestination(
          icon: const GameGlyph(
            GameGlyphKind.champions,
            excludeFromSemantics: true,
          ),
          selectedIcon: const GameGlyph(
            GameGlyphKind.champions,
            selected: true,
            excludeFromSemantics: true,
          ),
          label: gameText(context, 'ui.nav.contracts'),
        ),
        NavigationDestination(
          icon: const GameGlyph(
            GameGlyphKind.settings,
            excludeFromSemantics: true,
          ),
          selectedIcon: const GameGlyph(
            GameGlyphKind.settings,
            selected: true,
            excludeFromSemantics: true,
          ),
          label: gameText(context, 'ui.nav.settings'),
        ),
      ],
    ),
  );
}

class _SchemaMigrationNotice extends StatelessWidget {
  const _SchemaMigrationNotice({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) => GamePanel(
    color: GamePalette.panelLight,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    child: Row(
      children: [
        const Icon(Icons.save_outlined, color: GamePalette.gold, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            gameText(context, 'ui.error.schemaMigrationPending'),
            style: const TextStyle(fontSize: 11, height: 1.25),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => unawaited(controller.retrySchemaMigration()),
          child: Text(gameText(context, 'ui.common.retry')),
        ),
      ],
    ),
  );
}

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
                                  width: 12,
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

class FighterPage extends StatelessWidget {
  const FighterPage({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final save = controller.save;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          _heroDisplayName(context, save.heroName),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        Text(
          gameText(context, 'ui.fighter.heading'),
          style: const TextStyle(color: GamePalette.muted),
        ),
        const SizedBox(height: 16),
        GamePanel(
          child: Row(
            children: [
              SizedBox(
                width: 128,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final currentSave = controller.save;
                    return FighterArt(
                      seed: _originIndex(currentSave.appearance),
                      name: _heroDisplayName(context, currentSave.heroName),
                      isPlayer: true,
                      origin: currentSave.appearance,
                      family: _familyName(currentSave.weaponId),
                      portraitAsset: heroArtForAppearance(
                        currentSave.appearance,
                      ),
                      customization: HeroAppearanceSelection(
                        bodyProportionId: currentSave.bodyProportionId,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameText(context, 'ui.fighter.level', {
                        'level': save.level,
                      }),
                      style: const TextStyle(
                        color: GamePalette.gold,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ResourceBar(
                      label: gameText(context, 'ui.resource.health'),
                      value: save.health,
                      max: save.health,
                      color: GamePalette.health,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    ResourceBar(
                      label: gameText(context, 'ui.resource.effort'),
                      value: save.effort,
                      max: save.effort,
                      color: GamePalette.effort,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    ResourceBar(
                      label: gameText(context, 'ui.resource.mana'),
                      value: save.mana,
                      max: save.mana,
                      color: GamePalette.mana,
                      compact: true,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ValuePill(
                          icon: Icons.monetization_on,
                          value: '${save.gold}',
                        ),
                        ValuePill(
                          icon: Icons.add_circle,
                          value: gameText(context, 'ui.campaign.points', {
                            'count': save.unspentStatPoints,
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GameButton(
          label: gameText(context, 'ui.appearance.edit'),
          icon: Icons.face_retouching_natural,
          secondary: true,
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => AppearanceEditorPage(controller: controller),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (save.rebirthCredits > 0)
          GamePanel(
            padding: const EdgeInsets.all(12),
            borderColor: GamePalette.gold,
            child: Row(
              children: [
                const Icon(Icons.restart_alt, color: GamePalette.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    gameText(context, 'ui.fighter.redistribution', {
                      'count': save.rebirthCredits,
                    }),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(
                          gameText(context, 'ui.fighter.resetStats.title'),
                        ),
                        content: Text(
                          gameText(context, 'ui.fighter.resetStats.body'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: Text(gameText(context, 'ui.common.cancel')),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(gameText(context, 'ui.common.reset')),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) await controller.redistributeStats();
                  },
                  child: Text(gameText(context, 'ui.common.use')),
                ),
              ],
            ),
          ),
        if (save.rebirthCredits > 0) const SizedBox(height: 12),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeading(
                      localizedHeading(context, 'ui.creator.stats'),
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.fighter.pointsToSpend', {
                      'count': save.unspentStatPoints,
                    }),
                    style: const TextStyle(
                      color: GamePalette.gold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final stat in Stat.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          gameText(context, 'label.stat.${stat.name}'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _StatPips(value: save.stats[stat]),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${save.stats[stat]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: GamePalette.gold,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: gameText(context, 'ui.fighter.spendPoint'),
                        onPressed:
                            save.unspentStatPoints > 0 && save.stats[stat] < 20
                            ? () => controller.spendStat(stat)
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeading(
                      localizedHeading(context, 'ui.fighter.equipment'),
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.fighter.inventoryCount', {
                      'count': save.ownedItems
                          .where((id) => !id.startsWith('spell_'))
                          .length,
                    }),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final slot in const [
                'weapon',
                'bow',
                'head',
                'body',
                'boots',
                'talisman',
              ])
                _GearSlot(controller: controller, slot: slot),
              const Divider(height: 22),
              Row(
                children: [
                  const GameGlyph(
                    GameGlyphKind.supply,
                    size: 17,
                    color: GamePalette.gold,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gameText(context, 'ui.fighter.salveCount', {
                      'count': save.healingSalves,
                    }),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    gameText(context, 'ui.fighter.tonicCount', {
                      'count': save.effortTonics,
                    }),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                gameText(context, 'ui.fighter.learnedSpells', {
                  'count': save.ownedItems
                      .where((id) => id.startsWith('spell_'))
                      .length,
                }),
                style: const TextStyle(color: GamePalette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeading(
                      localizedHeading(context, 'ui.fighter.masteryTree'),
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.fighter.masteryPoints', {
                      'count': save.unspentMasteryPoints,
                    }),
                    style: const TextStyle(
                      color: GamePalette.gold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final mastery in _masteryList)
                _MasteryTile(controller: controller, item: mastery),
            ],
          ),
        ),
      ],
    );
  }
}

class AppearanceEditorPage extends StatefulWidget {
  const AppearanceEditorPage({super.key, required this.controller});

  final GameController controller;

  @override
  State<AppearanceEditorPage> createState() => _AppearanceEditorPageState();
}

class _AppearanceEditorPageState extends State<AppearanceEditorPage> {
  late String _bodyProportionId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final save = widget.controller.save;
    _bodyProportionId = save.bodyProportionId;
  }

  Future<void> _selectAppearance({required String bodyProportionId}) async {
    if (_saving) return;
    if (bodyProportionId == _bodyProportionId) return;

    setState(() {
      _bodyProportionId = bodyProportionId;
      _saving = true;
    });
    try {
      final updated = await widget.controller.updateHeroAppearance(
        bodyProportionId: bodyProportionId,
      );
      if (!updated && mounted) {
        _showMessage(context, gameText(context, 'ui.appearance.saveFailed'));
      }
    } on Object {
      if (mounted) {
        _showMessage(context, gameText(context, 'ui.appearance.saveFailed'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _optionChip({
    required BuildContext context,
    required String group,
    required String groupLabel,
    required String optionId,
    required int index,
    required bool selected,
    required Widget avatar,
    required ValueChanged<String> onSelected,
  }) {
    final optionSemanticLabel = gameText(context, 'ui.appearance.option', {
      'group': groupLabel,
      'count': index + 1,
    });
    return Semantics(
      label: optionSemanticLabel,
      selected: selected,
      button: true,
      enabled: !_saving,
      onTap: _saving ? null : () => onSelected(optionId),
      child: ExcludeSemantics(
        child: ChoiceChip(
          key: ValueKey('appearance.$group.$optionId'),
          avatar: avatar,
          label: Text('${index + 1}'),
          selected: selected,
          onSelected: _saving ? null : (_) => onSelected(optionId),
          selectedColor: GamePalette.gold,
          labelStyle: TextStyle(
            color: selected ? GamePalette.ink : GamePalette.parchment,
            fontWeight: FontWeight.w800,
          ),
          visualDensity: VisualDensity.standard,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        ),
      ),
    );
  }

  Widget _bodyOptions(BuildContext context) {
    final groupLabel = gameText(context, 'ui.appearance.build');
    return _appearanceGroup(
      context,
      title: groupLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final entry in heroBodyProportionIds.asMap().entries)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _optionChip(
                  context: context,
                  group: 'body',
                  groupLabel: groupLabel,
                  optionId: entry.value,
                  index: entry.key,
                  selected: _bodyProportionId == entry.value,
                  avatar: SizedBox(
                    width: 42,
                    height: 48,
                    child: HeroAppearanceOptionPreview(
                      kind: HeroAppearanceOptionKind.body,
                      optionId: entry.value,
                      origin: widget.controller.save.appearance,
                    ),
                  ),
                  onSelected: (id) => _selectAppearance(bodyProportionId: id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _appearanceGroup(
    BuildContext context, {
    required String title,
    required Widget child,
  }) => GamePanel(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SectionHeading(title), const SizedBox(height: 10), child],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final save = widget.controller.save;
    final appearance = HeroAppearanceSelection(
      bodyProportionId: _bodyProportionId,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(gameText(context, 'ui.appearance.title')),
        leading: _labelledIconButton(
          label: gameText(context, 'ui.common.back'),
          onPressed: () => Navigator.pop(context),
          icon: Icons.arrow_back,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                GamePanel(
                  child: Column(
                    children: [
                      SizedBox(
                        key: const ValueKey('appearance.preview'),
                        width: 180,
                        height: 190,
                        child: FighterArt(
                          seed: _originIndex(save.appearance),
                          name: _heroDisplayName(context, save.heroName),
                          isPlayer: true,
                          origin: save.appearance,
                          family: _familyName(save.weaponId),
                          portraitAsset: heroArtForAppearance(save.appearance),
                          customization: appearance,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gameText(context, 'ui.appearance.description'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GamePalette.muted,
                          height: 1.4,
                        ),
                      ),
                      if (_saving) ...[
                        const SizedBox(height: 12),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GamePalette.gold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _bodyOptions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPips extends StatelessWidget {
  const _StatPips({required this.value});
  final int value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < 10; i++)
        Container(
          width: 5,
          height: 13,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: i < value ? GamePalette.gold : GamePalette.panelLight,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
    ],
  );
}

class _GearSlot extends StatelessWidget {
  const _GearSlot({required this.controller, required this.slot});
  final GameController controller;
  final String slot;

  @override
  Widget build(BuildContext context) {
    final save = controller.save;
    final id = save.equippedItems[slot];
    final item = shopItems.where((entry) => entry.id == id).firstOrNull;
    final owned = save.ownedItems
        .map(
          (ownedId) =>
              shopItems.where((entry) => entry.id == ownedId).firstOrNull,
        )
        .whereType<ShopItem>()
        .where((entry) => entry.category == slot)
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameText(context, switch (slot) {
                    'weapon' => 'ui.gear.melee',
                    'bow' => 'ui.gear.ranged',
                    'head' => 'ui.gear.head',
                    'body' => 'ui.gear.body',
                    'boots' => 'ui.gear.boots',
                    _ => 'ui.gear.talisman',
                  }),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  item == null
                      ? gameText(context, 'ui.gear.starting')
                      : localizedContent(context, 'item', item.id, 'name'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (owned.length > 1)
            DropdownButton<String>(
              value: id,
              dropdownColor: GamePalette.panel,
              underline: const SizedBox(),
              items: [
                for (final entry in owned)
                  DropdownMenuItem(
                    value: entry.id,
                    child: Text(
                      localizedContent(context, 'item', entry.id, 'name'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
              onChanged: (next) {
                if (next != null) {
                  unawaited(
                    _runShopOperation(
                      context,
                      controller,
                      () => controller.equip(next),
                    ),
                  );
                }
              },
            )
          else
            Text(
              item == null
                  ? '—'
                  : '+${item.weaponPower > 0 ? item.weaponPower : item.armor}',
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _Mastery {
  const _Mastery(this.id);
  final String id;
}

const _masteryList = <_Mastery>[
  _Mastery('front_1'),
  _Mastery('front_2'),
  _Mastery('front_3'),
  _Mastery('duel_1'),
  _Mastery('duel_2'),
  _Mastery('duel_3'),
  _Mastery('seal_1'),
  _Mastery('seal_2'),
  _Mastery('seal_3'),
];

class _MasteryTile extends StatelessWidget {
  const _MasteryTile({required this.controller, required this.item});
  final GameController controller;
  final _Mastery item;
  @override
  Widget build(BuildContext context) {
    final unlocked = controller.save.masteries.contains(item.id);
    final tier = int.parse(item.id.substring(item.id.length - 1));
    final previous =
        tier == 1 ||
        controller.save.masteries.contains(
          '${item.id.substring(0, item.id.length - 1)}${tier - 1}',
        );
    final canUnlock = previous && controller.save.unspentMasteryPoints > 0;
    final unlockLabel = gameText(context, 'ui.mastery.unlock', {
      'name': localizedContent(context, 'mastery', item.id, 'name'),
    });
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        unlocked
            ? Icons.verified
            : previous
            ? Icons.lock_open
            : Icons.lock_outline,
        color: unlocked ? GamePalette.teal : GamePalette.gold,
        size: 20,
      ),
      title: Text(
        localizedContent(context, 'mastery', item.id, 'name'),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: unlocked ? GamePalette.teal : GamePalette.parchment,
        ),
      ),
      subtitle: Text(
        '${localizedContent(context, 'mastery', item.id, 'path')} · ${localizedContent(context, 'mastery', item.id, 'description')}',
        style: const TextStyle(color: GamePalette.muted, fontSize: 10),
      ),
      trailing: unlocked
          ? const Icon(Icons.check, color: GamePalette.teal)
          : _labelledIconButton(
              label: unlockLabel,
              onPressed: canUnlock
                  ? () => controller.unlockMastery(item.id)
                  : null,
              icon: Icons.add_circle_outline,
            ),
    );
  }
}

String _familyName(String? itemId) {
  final item = shopItems.where((entry) => entry.id == itemId).firstOrNull;
  return item?.family?.name ?? 'shortSword';
}

int _originIndex(String appearance) =>
    const {'Kıyı': 0, 'Ocak': 1, 'Fırtına': 2, 'Taç': 3}[appearance] ?? 0;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, required this.controller});
  final GameController controller;
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final visibleItems = shopItems
        .where(
          (item) =>
              item.act <= controller.unlockedAct &&
              (filter == 'all' ||
                  (filter == 'weapon' &&
                      ['weapon', 'bow'].contains(item.category)) ||
                  (filter == 'armor' &&
                      ['head', 'body', 'boots'].contains(item.category)) ||
                  (filter == 'talisman' && item.category == 'talisman')),
        )
        .toList();
    final ownedGear = shopItems
        .where(
          (item) =>
              controller.save.ownedItems.contains(item.id) &&
              (filter == 'all' ||
                  (filter == 'weapon' &&
                      ['weapon', 'bow'].contains(item.category)) ||
                  (filter == 'armor' &&
                      ['head', 'body', 'boots'].contains(item.category)) ||
                  (filter == 'talisman' && item.category == 'talisman')),
        )
        .toList();
    final showSpells = filter == 'all' || filter == 'magic';
    final showConsumables = filter == 'all' || filter == 'supplies';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          gameText(context, 'ui.shop.title'),
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          gameText(context, 'ui.shop.catalog', {'act': controller.unlockedAct}),
          style: const TextStyle(color: GamePalette.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final choice in [
                'all',
                'weapon',
                'armor',
                'talisman',
                'magic',
                'supplies',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                    label: Text(gameText(context, 'ui.filter.$choice')),
                    selected: filter == choice,
                    onSelected: (_) => setState(() => filter = choice),
                    selectedColor: GamePalette.gold,
                    labelStyle: TextStyle(
                      color: filter == choice
                          ? GamePalette.ink
                          : GamePalette.parchment,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems)
          _ShopItemCard(controller: controller, item: item),
        if (ownedGear.isNotEmpty) ...[
          const SizedBox(height: 10),
          SectionHeading(localizedHeading(context, 'ui.shop.resaleTitle')),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              gameText(context, 'ui.shop.resaleInfo'),
              style: const TextStyle(color: GamePalette.muted, fontSize: 11),
            ),
          ),
          for (final item in ownedGear)
            _OwnedGearSaleCard(controller: controller, item: item),
        ],
        if (showSpells) ...[
          const SizedBox(height: 10),
          SectionHeading(localizedHeading(context, 'ui.shop.learnableSkills')),
          for (final spell in spells)
            _SpellCard(controller: controller, spell: spell),
        ],
        if (showConsumables) ...[
          const SizedBox(height: 10),
          SectionHeading(localizedHeading(context, 'ui.shop.suppliesBelt')),
          _ConsumableCard(controller: controller, salve: true),
          _ConsumableCard(controller: controller, salve: false),
        ],
      ],
    );
  }
}

class _OwnedGearSaleCard extends StatelessWidget {
  const _OwnedGearSaleCard({required this.controller, required this.item});
  final GameController controller;
  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    final equipped = controller.save.equippedItems[item.category] == item.id;
    final equipmentFrame = shopEquipmentAtlasFrame(item);
    final resalePrice = item.price ~/ 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: Center(
                child: equipmentFrame != null
                    ? EquipmentAtlasSprite(frame: equipmentFrame, size: 34)
                    : ItemAtlasIcon(frame: shopItemIconFrame(item), size: 30),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedContent(context, 'item', item.id, 'name'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.resalePrice', {
                      'price': resalePrice,
                    }),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 76,
              child: FilledButton(
                onPressed: equipped
                    ? null
                    : () async {
                        final error = await controller.sellItem(item.id);
                        if (!context.mounted) return;
                        _showMessage(
                          context,
                          error == null
                              ? gameText(context, 'ui.shop.saleSuccess', {
                                  'price': resalePrice,
                                })
                              : gameText(context, 'ui.shop.saleRejected'),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: GamePalette.panelLight,
                  foregroundColor: GamePalette.parchment,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  equipped
                      ? gameText(context, 'ui.shop.saleEquipped')
                      : gameText(context, 'ui.shop.sell'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({required this.controller, required this.item});
  final GameController controller;
  final ShopItem item;
  @override
  Widget build(BuildContext context) {
    final save = controller.save;
    final equipmentFrame = shopEquipmentAtlasFrame(item);
    final owned = save.ownedItems.contains(item.id);
    final equipped = save.equippedItems[item.category] == item.id;
    final meetsMinimumAttribute =
        item.minAttribute == null ||
        save.stats[item.minAttribute!] >= item.minAttributeValue;
    final minimumAttributeText = item.minAttribute == null
        ? null
        : gameText(context, 'ui.shop.minimumAttribute', {
            'attribute': gameText(
              context,
              'label.stat.${item.minAttribute!.name}',
            ),
            'value': item.minAttributeValue,
          });
    final canBuy =
        !owned &&
        save.gold >= item.price &&
        save.level >= item.level &&
        meetsMinimumAttribute;
    final badge = switch (item.category) {
      'weapon' => gameText(context, 'label.family.${item.family!.name}'),
      'bow' => gameText(context, 'ui.shop.bow'),
      'head' => gameText(context, 'ui.gear.head'),
      'body' => gameText(context, 'ui.gear.body'),
      'boots' => gameText(context, 'ui.gear.boots'),
      _ => gameText(context, 'ui.gear.talisman'),
    };
    final power = item.weaponPower > 0
        ? gameText(context, 'ui.shop.power', {'power': item.weaponPower})
        : gameText(context, 'ui.shop.armorValue', {'armor': item.armor});
    final statusResistance = item.statusResistance > 0
        ? gameText(context, 'ui.shop.statusResistance', {
            'value': item.statusResistance,
          })
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: GamePalette.gold.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: equipmentFrame != null
                    ? EquipmentAtlasSprite(frame: equipmentFrame, size: 38)
                    : ItemAtlasIcon(frame: shopItemIconFrame(item), size: 32),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizedContent(context, 'item', item.id, 'name'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        GameLocalizations.of(context).uppercase(badge),
                        style: const TextStyle(
                          color: GamePalette.gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${localizedContent(context, 'item', item.id, 'description')}  ·  $power',
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                  if (statusResistance != null)
                    Text(
                      statusResistance,
                      style: const TextStyle(
                        color: GamePalette.teal,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  if (minimumAttributeText != null)
                    Text(
                      minimumAttributeText,
                      style: TextStyle(
                        color: meetsMinimumAttribute
                            ? GamePalette.teal
                            : GamePalette.rust,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    gameText(context, 'ui.shop.itemLevelPrice', {
                      'level': item.level,
                      'price': item.price,
                    }),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 74,
              child: FilledButton(
                onPressed: equipped
                    ? null
                    : owned
                    ? meetsMinimumAttribute
                          ? () {
                              unawaited(
                                _runShopOperation(
                                  context,
                                  controller,
                                  () => controller.equip(item.id),
                                ),
                              );
                            }
                          : null
                    : canBuy
                    ? () => unawaited(
                        _runShopOperation(
                          context,
                          controller,
                          () => controller.buyItem(item),
                        ),
                      )
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: owned
                      ? GamePalette.panelLight
                      : GamePalette.gold,
                  foregroundColor: owned
                      ? GamePalette.parchment
                      : GamePalette.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  equipped
                      ? gameText(context, 'ui.shop.equipped')
                      : owned
                      ? gameText(context, 'ui.shop.equip')
                      : gameText(context, 'ui.shop.buy'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpellCard extends StatelessWidget {
  const _SpellCard({required this.controller, required this.spell});
  final GameController controller;
  final SpellInfo spell;
  @override
  Widget build(BuildContext context) {
    final id = 'spell_${spell.action.name}';
    final known = controller.save.ownedItems.contains(id);
    final act =
        spell.action == BattleAction.emberSpear ||
            spell.action == BattleAction.ashBurst
        ? 1
        : spell.action == BattleAction.tideWard ||
              spell.action == BattleAction.saltCleanse
        ? 2
        : 3;
    const price = [140, 340, 700];
    final cost = price[act - 1];
    final unlocked =
        act <= controller.unlockedAct && controller.save.gold >= cost;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            SizedBox(
              width: 43,
              height: 43,
              child: Center(
                child: ItemAtlasIcon(
                  frame: spellIconFrame(spell.action),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameText(context, 'label.action.${spell.action.name}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.spellCost', {
                      'description': localizedContent(
                        context,
                        'spell',
                        spell.action.name,
                        'description',
                      ),
                      'cost': spell.cost,
                    }),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.actPrice', {
                      'act': act,
                      'cost': cost,
                    }),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 74,
              child: FilledButton(
                onPressed: known || !unlocked
                    ? null
                    : () {
                        unawaited(
                          _runShopOperation(
                            context,
                            controller,
                            () => controller.buySpell(spell.action),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: known
                      ? GamePalette.panelLight
                      : GamePalette.gold,
                  foregroundColor: known
                      ? GamePalette.parchment
                      : GamePalette.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  known
                      ? gameText(context, 'ui.shop.learned')
                      : gameText(context, 'ui.shop.learn'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumableCard extends StatelessWidget {
  const _ConsumableCard({required this.controller, required this.salve});
  final GameController controller;
  final bool salve;
  @override
  Widget build(BuildContext context) {
    final count = salve
        ? controller.save.healingSalves
        : controller.save.effortTonics;
    final price = getConsumablePrice(controller.unlockedAct, salve: salve);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            SizedBox(
              width: 43,
              height: 43,
              child: Center(
                child: ItemAtlasIcon(frame: salve ? 14 : 15, size: 36),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameText(
                      context,
                      salve ? 'ui.shop.healingSalve' : 'ui.shop.effortTonic',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    salve
                        ? gameText(context, 'ui.shop.salveDescription')
                        : gameText(context, 'ui.shop.tonicDescription'),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.inventoryPrice', {
                      'count': count,
                      'price': price,
                    }),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 76,
              child: FilledButton(
                onPressed: count >= 3 || controller.save.gold < price
                    ? null
                    : () {
                        unawaited(
                          _runShopOperation(
                            context,
                            controller,
                            () => controller.buyConsumable(salve: salve),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: GamePalette.gold,
                  foregroundColor: GamePalette.ink,
                ),
                child: Text(
                  gameText(context, 'ui.shop.purchase'),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    children: [
      Text(
        gameText(context, 'ui.challenge.title'),
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        gameText(context, 'ui.challenge.intro'),
        style: const TextStyle(color: GamePalette.muted, fontSize: 12),
      ),
      const SizedBox(height: 16),
      for (var chapter = 1; chapter <= 4; chapter++) ...[
        _ChapterHeader(
          chapter: chapter,
          completed: controller.save.completedContracts
              .where((id) => id.startsWith('C$chapter-'))
              .length,
        ),
        for (final contract in contracts.where(
          (entry) => entry.id.startsWith('C$chapter-'),
        ))
          _ContractTile(controller: controller, contract: contract),
        const SizedBox(height: 10),
      ],
      if (controller.campaignComplete) ...[
        const SizedBox(height: 8),
        GamePanel(
          borderColor: GamePalette.gold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                localizedHeading(context, 'ui.campaign.championsRoad'),
              ),
              const SizedBox(height: 8),
              Text(
                gameText(context, 'ui.challenge.championsRoadIntro'),
                style: TextStyle(color: GamePalette.muted, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gameText(context, 'ui.challenge.completeCount', {
                        'completed': controller.save.championsRunBest,
                      }),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const GameGlyph(
                    GameGlyphKind.champions,
                    color: GamePalette.gold,
                    size: 20,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GameButton(
                label: controller.save.championsRunBest >= 8
                    ? gameText(context, 'ui.challenge.replaySeries')
                    : gameText(context, 'ui.challenge.nextTrial', {
                        'stage': controller.save.championsRunBest + 1,
                      }),
                icon: Icons.sports_martial_arts,
                onPressed: () => _openBattle(
                  context,
                  controller,
                  () => controller.startChampionsRoad(
                    controller.save.championsRunBest >= 8
                        ? 1
                        : controller.save.championsRunBest + 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ] else
        GamePanel(
          child: Text(
            gameText(context, 'ui.challenge.locked'),
            style: TextStyle(color: GamePalette.muted),
          ),
        ),
    ],
  );
}

class _ContractTile extends StatelessWidget {
  const _ContractTile({required this.controller, required this.contract});
  final GameController controller;
  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.isEncounterUnlocked(contract.targetId);
    final completed = controller.save.completedContracts.contains(contract.id);
    final target = getEncounter(contract.targetId);
    final title = localizedContent(context, 'contract', contract.id, 'title');
    final artAsset = contractArtAssetForId(contract.id);

    Widget artworkFallback() => const ColoredBox(
      color: GamePalette.panelLight,
      child: Center(
        child: GameGlyph(
          GameGlyphKind.fighter,
          color: GamePalette.gold,
          size: 24,
          excludeFromSemantics: true,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artSize = (constraints.maxWidth * 0.2)
                .clamp(58.0, 76.0)
                .toDouble();
            final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

            return Row(
              children: [
                SizedBox.square(
                  dimension: artSize,
                  child: Semantics(
                    image: true,
                    label: title,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: artAsset == null
                          ? artworkFallback()
                          : Image.asset(
                              artAsset,
                              fit: BoxFit.cover,
                              cacheWidth: (artSize * devicePixelRatio).round(),
                              excludeFromSemantics: true,
                              frameBuilder: (context, child, frame, _) =>
                                  frame == null ? artworkFallback() : child,
                              errorBuilder: (context, error, stackTrace) =>
                                  artworkFallback(),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  completed
                      ? Icons.task_alt
                      : unlocked
                      ? Icons.assignment_outlined
                      : Icons.lock_outline,
                  color: completed ? GamePalette.teal : GamePalette.gold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${contract.id} · ${_encounterName(context, target)}',
                        style: const TextStyle(
                          color: GamePalette.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizedContent(
                          context,
                          'contract',
                          contract.id,
                          'description',
                        ),
                        style: const TextStyle(
                          color: GamePalette.muted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gameText(context, 'ui.contract.reward', {
                          'reward': contract.reward,
                        }),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: gameText(
                    context,
                    completed ? 'ui.contract.replay' : 'ui.contract.enter',
                  ),
                  onPressed: unlocked
                      ? () => _openBattle(
                          context,
                          controller,
                          () => controller.startContract(contract.id),
                        )
                      : null,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});
  final GameController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _musicVolume;
  late double _sfxVolume;
  bool _editingMusic = false;
  bool _editingSfx = false;

  @override
  void initState() {
    super.initState();
    _readSavedVolumes();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _readSavedVolumes();
    }
  }

  void _readSavedVolumes() {
    _musicVolume = widget.controller.save.musicVolume;
    _sfxVolume = widget.controller.save.sfxVolume;
  }

  void _handleControllerChanged() {
    if (!_editingMusic) _musicVolume = widget.controller.save.musicVolume;
    if (!_editingSfx) _sfxVolume = widget.controller.save.sfxVolume;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  Widget _volumeSlider(
    BuildContext context, {
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: GamePalette.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      Slider(
        value: value,
        min: 0,
        max: 1,
        divisions: 20,
        label: '${(value * 100).round()}%',
        activeColor: GamePalette.gold,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final save = controller.save;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          gameText(context, 'ui.settings.title'),
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.sfx')),
                subtitle: Text(
                  gameText(context, 'ui.settings.sfxDescription'),
                  style: TextStyle(color: GamePalette.muted, fontSize: 11),
                ),
                value: save.sfxEnabled,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(sfxEnabled: value),
              ),
              const Divider(),
              _volumeSlider(
                context,
                title: gameText(context, 'ui.settings.musicVolume'),
                value: _musicVolume,
                onChanged: (value) {
                  _editingMusic = true;
                  setState(() => _musicVolume = value);
                  GameAudioScope.maybeOf(context)?.setMusicVolume(value);
                },
                onChangeEnd: (value) {
                  _editingMusic = false;
                  unawaited(controller.updateSettings(musicVolume: value));
                },
              ),
              const Divider(),
              _volumeSlider(
                context,
                title: gameText(context, 'ui.settings.sfxVolume'),
                value: _sfxVolume,
                onChanged: (value) {
                  _editingSfx = true;
                  setState(() => _sfxVolume = value);
                  GameAudioScope.maybeOf(context)?.setSfxVolume(value);
                },
                onChangeEnd: (value) {
                  _editingSfx = false;
                  unawaited(controller.updateSettings(sfxVolume: value));
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.vibration')),
                subtitle: Text(
                  gameText(context, 'ui.settings.vibrationDescription'),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 11,
                  ),
                ),
                value: save.vibrationEnabled,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(vibrationEnabled: value),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.reduceMotion')),
                subtitle: Text(
                  gameText(context, 'ui.settings.reduceMotionDescription'),
                  style: TextStyle(color: GamePalette.muted, fontSize: 11),
                ),
                value: save.reducedMotion,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(reducedMotion: value),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.textScale')),
                subtitle: Text('${(save.textScale * 100).round()}%'),
              ),
              Wrap(
                spacing: 7,
                runSpacing: 4,
                children: [
                  for (final scale in const [1.0, 1.25, 1.5, 1.75, 2.0])
                    ChoiceChip(
                      label: Text('${(scale * 100).round()}%'),
                      selected: (save.textScale - scale).abs() < .01,
                      onSelected: (_) =>
                          controller.updateSettings(textScale: scale),
                      selectedColor: GamePalette.gold,
                    ),
                ],
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.battleSpeed')),
                subtitle: Text(
                  '${save.battleAnimationSpeed.toStringAsFixed(save.battleAnimationSpeed == 1 ? 0 : 1)}×',
                ),
              ),
              Wrap(
                spacing: 7,
                runSpacing: 4,
                children: [
                  for (final speed in const [1.0, 1.5, 2.0])
                    ChoiceChip(
                      label: Text(
                        '${speed.toStringAsFixed(speed == 1 ? 0 : 1)}×',
                      ),
                      selected: (save.battleAnimationSpeed - speed).abs() < .01,
                      onSelected: (_) => controller.updateSettings(
                        battleAnimationSpeed: speed,
                      ),
                      selectedColor: GamePalette.gold,
                    ),
                ],
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  gameText(context, 'ui.settings.skipBattleAnimations'),
                ),
                subtitle: Text(
                  gameText(
                    context,
                    'ui.settings.skipBattleAnimationsDescription',
                  ),
                  style: TextStyle(color: GamePalette.muted, fontSize: 11),
                ),
                value: save.skipBattleAnimations,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(skipBattleAnimations: value),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.language')),
                subtitle: Text(
                  save.language == 'tr'
                      ? gameText(context, 'ui.settings.turkish')
                      : gameText(context, 'ui.settings.english'),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 11,
                  ),
                ),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'tr', label: Text('TR')),
                    ButtonSegment(value: 'en', label: Text('EN')),
                  ],
                  selected: {save.language},
                  onSelectionChanged: (value) =>
                      controller.updateSettings(language: value.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                localizedHeading(context, 'ui.settings.campaignSave'),
              ),
              const SizedBox(height: 7),
              Text(
                gameText(context, 'ui.settings.campaignSummary', {
                  'name': _heroDisplayName(context, save.heroName),
                  'level': save.level,
                  'count': save.completedMatches
                      .where(
                        (id) => !id.startsWith('M3') && !id.startsWith('M4'),
                      )
                      .length,
                }),
                style: const TextStyle(color: GamePalette.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GameButton(
                label: gameText(context, 'ui.settings.resetCampaign'),
                icon: Icons.delete_outline,
                secondary: true,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        gameText(context, 'ui.settings.deleteSaveTitle'),
                      ),
                      content: Text(
                        gameText(context, 'ui.settings.deleteSaveBody'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(gameText(context, 'ui.common.cancel')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(gameText(context, 'ui.common.reset')),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await _runCampaignReset(context, controller);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(localizedHeading(context, 'ui.settings.about')),
              SizedBox(height: 9),
              Text(
                gameText(context, 'ui.settings.aboutBody'),
                style: TextStyle(
                  color: GamePalette.muted,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _openBattle(
  BuildContext context,
  GameController controller,
  FutureOr<void> Function() begin, {
  bool resumeFromCheckpoint = false,
}) async {
  if (!resumeFromCheckpoint) {
    try {
      await begin();
    } on Object catch (error) {
      if (!context.mounted) return;
      if (!error.toString().startsWith('Kayıt yazılamadı:')) {
        _showMessage(context, error.toString());
        return;
      }
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GamePalette.panel,
          icon: const Icon(Icons.save_outlined, color: GamePalette.rust),
          title: Text(gameText(dialogContext, 'ui.error.saveTitle')),
          content: Text(gameText(dialogContext, 'ui.error.saveFailed')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(gameText(dialogContext, 'ui.common.cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(gameText(dialogContext, 'ui.common.retry')),
            ),
          ],
        ),
      );
      if (retry == true && context.mounted) {
        await _openBattle(context, controller, begin);
      }
      return;
    }
  }
  if (!context.mounted) return;
  final audio = GameAudioScope.maybeOf(context);
  final encounter = controller.activeEncounter;
  if (encounter != null) audio?.enterBattle(encounter);
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BattlePage(
          controller: controller,
          resumeFromCheckpoint: resumeFromCheckpoint,
        ),
      ),
    );
  } finally {
    if (audio != null) {
      audio.leaveBattle(
        save: controller.save,
        chapter: controller.campaignComplete
            ? 4
            : controller.nextEncounter.chapter,
        campaignComplete: controller.campaignComplete,
      );
    }
  }
}

Future<void> _showIntermissionChoice(
  BuildContext context,
  GameController controller,
) async {
  final decision = controller.pendingIntermissionDecision;
  if (decision == null) return;
  final chapter = ((decision.afterEncounterId - 1) ~/ 8) + 1;
  final audio = GameAudioScope.maybeOf(context);
  if (audio != null) unawaited(audio.playIntermissionStinger(chapter));

  final availableStats = Stat.values
      .where((stat) => controller.save.stats[stat] < 20)
      .toList();
  Stat? selectedStat = availableStats.isEmpty ? null : availableStats.first;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        backgroundColor: GamePalette.panel,
        icon: const Icon(Icons.campaign_outlined, color: GamePalette.gold),
        title: Text(
          gameText(dialogContext, 'ui.intermission.heading'),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _intermissionArt(context, decision, height: 150),
              ),
              const SizedBox(height: 12),
              Text(
                gameText(dialogContext, 'ui.intermission.body', {
                  'encounter': decision.afterEncounterId,
                }),
                textAlign: TextAlign.center,
              ),
              if (availableStats.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<Stat>(
                  initialValue: selectedStat,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: gameText(
                      dialogContext,
                      'ui.intermission.chooseStat',
                    ),
                  ),
                  items: availableStats
                      .map(
                        (stat) => DropdownMenuItem(
                          value: stat,
                          child: Text(
                            gameText(dialogContext, 'label.stat.${stat.name}'),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (stat) => setDialogState(() {
                    selectedStat = stat;
                  }),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: selectedStat == null
                      ? null
                      : () async {
                          final chosen = await controller
                              .chooseIntermissionReward(
                                decision.id,
                                reward: IntermissionReward.training,
                                stat: selectedStat,
                              );
                          if (chosen && dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  icon: const Icon(Icons.fitness_center),
                  label: Text(
                    gameText(dialogContext, 'ui.intermission.training', {
                      'stat': selectedStat == null
                          ? ''
                          : gameText(
                              dialogContext,
                              'label.stat.${selectedStat!.name}',
                            ),
                    }),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final chosen = await controller.chooseIntermissionReward(
                    decision.id,
                    reward: IntermissionReward.sponsorship,
                  );
                  if (chosen && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                icon: const Icon(Icons.monetization_on_outlined),
                label: Text(
                  gameText(dialogContext, 'ui.intermission.sponsorship', {
                    'gold': decision.sponsorshipGold,
                  }),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(gameText(dialogContext, 'ui.intermission.later')),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showStoryEvidence(
  BuildContext context,
  GameController controller,
  StoryEvidenceEntry evidence,
) async {
  final title = gameText(context, evidence.titleKey);
  final body = gameText(context, evidence.bodyKey);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: GamePalette.panel,
      icon: const Icon(Icons.find_in_page_outlined, color: GamePalette.rust),
      title: Text(title, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GamePalette.panelLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: StoryEvidenceCardArt(
                frame: evidence.frame,
                size: 220,
                semanticLabel: '$title. $body',
              ),
            ),
            const SizedBox(height: 14),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await controller.markStoryEvidenceSeen(evidence.id);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(gameText(dialogContext, 'ui.story.evidence.close')),
        ),
      ],
    ),
  );
}

Widget _intermissionArt(
  BuildContext context,
  IntermissionDecision decision, {
  required double height,
}) => SizedBox(
  height: height,
  width: double.infinity,
  child: Image.asset(
    decision.art,
    fit: BoxFit.cover,
    cacheWidth: 900,
    semanticLabel: gameText(context, 'ui.intermission.artDescription', {
      'encounter': decision.afterEncounterId,
    }),
    errorBuilder: (context, error, stackTrace) => const ColoredBox(
      color: GamePalette.panelLight,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: GamePalette.muted,
        ),
      ),
    ),
  ),
);

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
    if (engine == null || !engine.snapshot.done || _resultShown || !mounted)
      return;
    _resultShown = true;
    _working = true;
    final previousLevel = widget.controller.save.level;
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
    if (engine == null || encounter == null)
      return Scaffold(
        body: Center(child: Text(gameText(context, 'ui.battle.notFound'))),
      );
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
    final width = (MediaQuery.sizeOf(context).width - 44) / 2;
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

    return SizedBox(
      width: width.clamp(145, 340),
      height: 73,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: semanticLabel,
        onTap: isEnabled ? onTap : null,
        excludeSemantics: true,
        child: Material(
          color: preview.canUse
              ? (spell ? const Color(0xE1243041) : const Color(0xE1242D2F))
              : const Color(0xD9151C1E),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            excludeFromSemantics: true,
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          actionName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: preview.canUse
                                ? GamePalette.parchment
                                : GamePalette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Text(
                          badge!,
                          style: const TextStyle(
                            color: GamePalette.gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          costText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: GamePalette.muted,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      if (statsText != null)
                        Text(
                          statsText,
                          style: TextStyle(
                            color: preview.hitChance >= 70
                                ? GamePalette.teal
                                : GamePalette.gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
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
