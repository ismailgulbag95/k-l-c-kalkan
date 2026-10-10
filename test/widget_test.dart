import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('title opens fighter creation and shows the six point budget', (
    tester,
  ) async {
    final controller = GameController(storage: MemorySaveStorage());
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: GameTitle(controller: controller),
      ),
    );

    expect(find.text('KÜL'), findsOneWidget);
    expect(find.text('ÇEMBERİ'), findsOneWidget);
    await tester.tap(find.text('Dövüşçünü oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('Dövüşçü yarat'), findsOneWidget);
    expect(find.text('6 puan'), findsOneWidget);
    expect(find.text('Kuvvet'), findsOneWidget);
    final creatorScroll = find.descendant(
      of: find.byType(CharacterCreator),
      matching: find.byType(Scrollable),
    );
    await tester.drag(creatorScroll.first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Kıyı Ligi’ne katıl'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('settings persist separate audio levels and vibration choice', (
    tester,
  ) async {
    final controller = GameController(storage: MemorySaveStorage());
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: Scaffold(body: SettingsPage(controller: controller)),
      ),
    );

    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.text('Müzik ve arena ambiyansı'), findsOneWidget);
    expect(find.text('Dövüş ve arayüz sesleri'), findsOneWidget);
    await tester.ensureVisible(find.byType(Slider).first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).first, const Offset(70, 0));
    await tester.pumpAndSettle();
    expect(controller.save.musicVolume, isNot(0.65));
    expect(controller.save.sfxVolume, 0.75);

    final vibrationTitle = find.text('Titreşim');
    await tester.ensureVisible(vibrationTitle);
    await tester.tap(vibrationTitle);
    await tester.pumpAndSettle();
    expect(controller.save.vibrationEnabled, isFalse);
    controller.dispose();
  });

  testWidgets(
    'battle begins with a briefing and exposes its score conditions',
    (tester) async {
      final controller = GameController(storage: MemorySaveStorage());
      await controller.initialize();
      await controller.createHero(
        name: 'Kıyı',
        stats: const Stats(
          might: 4,
          agility: 4,
          vitality: 4,
          guard: 2,
          stamina: 2,
          arcana: 2,
        ),
      );
      await controller.startEncounter(1, seed: 33);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: BattlePage(controller: controller),
        ),
      );

      expect(find.text('DÜELLO BRİFİNGİ'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Düelloya başla'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('SEYİRCİ NOTU · 3 AÇIK KOŞUL'), findsOneWidget);
      expect(find.text('Mesafeyi en az bir kez değiştir'), findsOneWidget);
      await tester.tap(find.text('Düelloya başla'));
      await tester.pumpAndSettle();

      expect(find.text('HAMLENİ SEÇ'), findsOneWidget);
      expect(find.text('RAKİBİN NİYETİ'), findsOneWidget);
      controller.dispose();
    },
  );

  testWidgets('hub automatically resumes a checkpoint into the active battle', (
    tester,
  ) async {
    final storage = MemorySaveStorage();
    final controller = GameController(storage: storage);
    await controller.initialize();
    await controller.createHero(
      name: 'Kıyı',
      stats: const Stats(
        might: 4,
        agility: 4,
        vitality: 4,
        guard: 2,
        stamina: 2,
        arcana: 2,
      ),
    );
    await controller.startEncounter(1, seed: 34);
    expect(controller.performAction(BattleAction.guard), isNull);
    await controller.persistActiveBattleCheckpoint();

    final reloaded = GameController(storage: storage);
    await reloaded.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: GameHub(controller: reloaded),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BattlePage), findsOneWidget);
    expect(find.text('HAMLENİ SEÇ'), findsOneWidget);
    expect(find.text('DÜELLO BRİFİNGİ'), findsNothing);
    expect(reloaded.battle?.metrics.turn, 1);
    expect(tester.takeException(), isNull);
    controller.dispose();
    reloaded.dispose();
  });

  testWidgets('battle animates typed beats and ignores taps while resolving', (
    tester,
  ) async {
    final controller = GameController(storage: MemorySaveStorage());
    await controller.initialize();
    await controller.createHero(
      name: 'Kıyı',
      stats: const Stats(
        might: 4,
        agility: 4,
        vitality: 4,
        guard: 2,
        stamina: 2,
        arcana: 2,
      ),
    );
    await controller.startEncounter(1, seed: 33);
    final engine = controller.battle!;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: BattlePage(controller: controller),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Düelloya başla'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Düelloya başla'));
    await tester.pumpAndSettle();

    final quickAction = find.text('Hızlı vuruş').first;
    await tester.scrollUntilVisible(
      quickAction,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(quickAction);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(quickAction);

    expect(engine.metrics.turn, 1);
    await tester.pumpAndSettle();
    expect(engine.metrics.turn, 1);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('fighter motion layer renders and honors reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: Center(
            child: FighterArt(
              seed: 1,
              name: 'Dövüşçü',
              isPlayer: true,
              motion: FighterMotion.attack,
              motionKey: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: Center(
            child: FighterArt(
              seed: 1,
              name: 'Dövüşçü',
              isPlayer: true,
              motion: FighterMotion.attack,
              motionKey: 2,
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending intermission choice can be resumed from campaign', (
    tester,
  ) async {
    final storage = MemorySaveStorage()
      ..value = GameSave(
        hasHero: true,
        completedMatches: {'M01', 'M02', 'M03', 'M04'},
        gold: 10,
      );
    final controller = GameController(storage: storage);
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: Scaffold(body: CampaignPage(controller: controller)),
      ),
    );

    expect(find.text('Ara turnuva kararı bekliyor'), findsOneWidget);
    await tester.tap(find.text('Turnuva arası karar'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Turnuva arası karar'),
      ),
      findsOneWidget,
    );
    expect(find.text('Sponsorluk · +120 Sikke'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sponsorluk · +120 Sikke'),
      120,
      scrollable: find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sponsorluk · +120 Sikke'));
    await tester.pumpAndSettle();
    expect(controller.save.gold, 130);
    expect(controller.save.intermissionChoices['I04'], 'sponsorship');
    expect(controller.pendingIntermissionDecision, isNull);
    controller.dispose();
  });

  testWidgets('pending story evidence can be read and acknowledged', (
    tester,
  ) async {
    final storage = MemorySaveStorage()
      ..value = GameSave(
        hasHero: true,
        completedMatches: {'M01', 'M02', 'M03', 'M04'},
      );
    final controller = GameController(storage: storage);
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: Scaffold(body: CampaignPage(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yeni lig kanıtı'), findsOneWidget);
    await tester.tap(find.text('Kanıtı oku'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Ödül defterindeki tutarsız mühür'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Kayda ekle ve kapat'));
    await tester.pumpAndSettle();
    expect(controller.save.seenStoryEvidence, {'E04'});
    expect(controller.pendingStoryEvidence, isNull);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('each act rival atlas decodes and paints a portrait cell', (
    tester,
  ) async {
    for (final id in [1, 9, 17, 25]) {
      final art = rivalAtlasForEncounter(id)!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FighterArt(
                seed: id,
                name: 'Rakip $id',
                atlasAsset: art.asset,
                atlasIndex: art.index,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsOneWidget, reason: 'match $id');
      expect(tester.takeException(), isNull, reason: 'match $id');
    }
  });

  testWidgets('each Champions Road rival frame decodes and paints', (
    tester,
  ) async {
    for (var stage = 1; stage <= 7; stage++) {
      final encounterId = 32 + stage;
      final art = rivalAtlasForEncounter(encounterId)!;
      expect(art.index, stage - 1);
      expect(art.asset, 'assets/art/rivals/champions_road_atlas.png');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FighterArt(
                seed: encounterId,
                name: 'Ustalık Sınaması $stage',
                atlasAsset: art.asset,
                atlasIndex: art.index,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsOneWidget, reason: 'stage $stage');
      expect(tester.takeException(), isNull, reason: 'stage $stage');
    }
  });

  testWidgets('hero battle atlas decodes and paints combat poses', (
    tester,
  ) async {
    const motions = [
      FighterMotion.idle,
      FighterMotion.attack,
      FighterMotion.hit,
      FighterMotion.guard,
      FighterMotion.victory,
    ];
    for (var index = 0; index < motions.length; index++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FighterArt(
                seed: index,
                name: 'Kıyı Dövüşçüsü',
                isPlayer: true,
                motionAtlasAsset: 'assets/art/characters/hero_battle_atlas.png',
                motion: motions[index],
                motionKey: index + 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(CustomPaint),
        findsAtLeastNWidgets(1),
        reason: motions[index].name,
      );
      expect(tester.takeException(), isNull, reason: motions[index].name);
    }
  });

  testWidgets('saved hero cosmetics remain visible in battle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FighterArt(
              seed: 7,
              name: 'Kıyı Dövüşçüsü',
              isPlayer: true,
              motionAtlasAsset: 'assets/art/characters/hero_battle_atlas.png',
              customization: const HeroAppearanceSelection(
                headOptionId: 'head_04',
                skinToneId: 'skin_07',
                bodyProportionId: 'body_02',
                facialHairId: 'facial_hair_03',
              ),
              motion: FighterMotion.attack,
              motionKey: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HeroCustomizationArt), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('champion rival motion atlas maps the final defeat pose', () {
    expect(rivalMotionAtlasFrame(FighterMotion.idle, 0), 0);
    expect(rivalMotionAtlasFrame(FighterMotion.attack, .2), 1);
    expect(rivalMotionAtlasFrame(FighterMotion.attack, .5), 2);
    expect(rivalMotionAtlasFrame(FighterMotion.hit, .4), 3);
    expect(rivalMotionAtlasFrame(FighterMotion.guard, .4), 4);
    expect(rivalMotionAtlasFrame(FighterMotion.defeat, 1), 5);
    expect(rivalMotionAtlasFrame(FighterMotion.victory, 1), 0);
  });

  testWidgets('chapter champion rival atlases paint all battle states', (
    tester,
  ) async {
    const motions = [
      FighterMotion.idle,
      FighterMotion.attack,
      FighterMotion.hit,
      FighterMotion.guard,
      FighterMotion.spell,
      FighterMotion.defeat,
      FighterMotion.victory,
    ];
    const champions = <Map<String, String>>[
      {
        'name': 'Fener Şampiyonu',
        'portrait': 'assets/art/characters/fener_sampiyonu.webp',
        'atlas': 'assets/art/characters/fener_champion_motion.png',
      },
      {
        'name': 'Pirinç Muhafız',
        'portrait': 'assets/art/characters/pirinc_muhafiz.webp',
        'atlas': 'assets/art/characters/brass_guardian_motion.png',
      },
      {
        'name': 'Gözlemci Başrahip',
        'portrait': 'assets/art/characters/gozlemci_basrahip.webp',
        'atlas': 'assets/art/characters/observatory_priest_motion.png',
      },
      {
        'name': 'Çember Ustası',
        'portrait': 'assets/art/characters/cember_ustasi.webp',
        'atlas': 'assets/art/characters/circle_master_motion.png',
      },
    ];
    for (final champion in champions) {
      for (var index = 0; index < motions.length; index++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: FighterArt(
                  seed: index,
                  name: champion['name']!,
                  portraitAsset: champion['portrait']!,
                  motionAtlasAsset: champion['atlas']!,
                  motion: motions[index],
                  motionKey: index + 1,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
        expect(
          tester.takeException(),
          isNull,
          reason: '${champion['name']} ${motions[index].name}',
        );
      }
    }
  });

  testWidgets('hero action atlas decodes and paints all eight action poses', (
    tester,
  ) async {
    for (final pose in HeroActionPose.values) {
      final motion = switch (pose) {
        HeroActionPose.strongAttack ||
        HeroActionPose.bowDraw ||
        HeroActionPose.bowRelease => FighterMotion.attack,
        HeroActionPose.dodge => FighterMotion.dodge,
        HeroActionPose.consumable => FighterMotion.heal,
        HeroActionPose.stagger => FighterMotion.hit,
        HeroActionPose.spell => FighterMotion.spell,
        HeroActionPose.defeat => FighterMotion.defeat,
      };
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FighterArt(
                seed: pose.index,
                name: 'Kıyı Dövüşçüsü',
                isPlayer: true,
                motionAtlasAsset: 'assets/art/characters/hero_battle_atlas.png',
                actionAtlasAsset:
                    'assets/art/characters/hero_battle_actions.png',
                actionPose: pose,
                motion: motion,
                motionKey: pose.index + 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(CustomPaint),
        findsAtLeastNWidgets(1),
        reason: pose.name,
      );
      expect(tester.takeException(), isNull, reason: pose.name);
    }
  });

  testWidgets('item icon atlas decodes and paints all 16 catalog icons', (
    tester,
  ) async {
    for (var frame = 0; frame < gameItemIconAtlasFrames.length; frame++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: ItemAtlasIcon(frame: frame, size: 44)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsOneWidget, reason: 'frame $frame');
      expect(tester.takeException(), isNull, reason: 'frame $frame');
    }
  });

  testWidgets('arena and equipment atlas cells decode and paint', (
    tester,
  ) async {
    for (final item in shopItems.where(
      (item) => ['head', 'body', 'boots'].contains(item.category),
    )) {
      final row = switch (item.category) {
        'head' => 0,
        'body' => 1,
        'boots' => 2,
        _ => throw StateError('Unexpected equipment item'),
      };
      final tier = int.parse(item.id.split('_').last);
      expect(
        shopEquipmentAtlasFrame(item),
        row * 4 + tier - 1,
        reason: item.id,
      );
    }
    for (final arena in arenas) {
      final atlas = arena.propAtlas;
      expect(atlas, isNotNull, reason: arena.id);
      for (var frame = 0; frame < 4; frame++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 78,
                  height: 52,
                  child: ArenaPropSprite(atlas: atlas!, index: frame),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(Image),
          findsOneWidget,
          reason: '${arena.id}:$frame',
        );
        expect(tester.takeException(), isNull, reason: '${arena.id}:$frame');
      }
    }
    for (var frame = 0; frame < 12; frame++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: EquipmentAtlasSprite(frame: frame)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget, reason: 'equipment:$frame');
      expect(tester.takeException(), isNull, reason: 'equipment:$frame');
    }
  });
}
