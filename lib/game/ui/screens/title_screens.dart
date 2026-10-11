part of '../screens.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: IntrinsicHeight(
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
                                localizedHeading(
                                  context,
                                  'ui.title.panel.heading',
                                ),
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
                          style: TextStyle(
                            color: GamePalette.muted,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

