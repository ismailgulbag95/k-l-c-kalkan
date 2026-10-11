part of '../screens.dart';

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
            child: Semantics(
              label: gameText(context, 'ui.shop.resalePrice', {
                'price': widget.controller.save.gold,
              }),
              excludeSemantics: true,
              child: ValuePill(
                icon: Icons.monetization_on_outlined,
                value: '${widget.controller.save.gold}',
              ),
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

