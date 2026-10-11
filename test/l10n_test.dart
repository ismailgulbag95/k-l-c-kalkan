import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all shipped player-facing content has paired TR/EN messages', () {
    final requiredKeys = <String>{};
    for (final arena in arenas) {
      requiredKeys
        ..add('content.arena.${arena.id}.name')
        ..add('content.arena.${arena.id}.mood');
    }
    for (final stat in Stat.values) {
      requiredKeys
        ..add('label.stat.${stat.name}')
        ..add('ui.statHelp.${stat.name}');
    }
    for (final encounter in mainEncounters) {
      final key = encounter.key;
      requiredKeys
        ..add('content.encounter.$key.name')
        ..add('content.archetype.${encounter.archetype}');
      if (encounter.story.isNotEmpty) {
        requiredKeys.add('content.encounter.$key.story');
      }
      if (encounter.hazard.isNotEmpty) {
        requiredKeys.add('content.encounter.$key.hazard');
      }
    }
    for (final contract in contracts) {
      requiredKeys
        ..add('content.contract.${contract.id}.title')
        ..add('content.contract.${contract.id}.description');
    }
    for (final item in shopItems) {
      requiredKeys
        ..add('content.item.${item.id}.name')
        ..add('content.item.${item.id}.description');
    }
    for (final spell in spells) {
      requiredKeys.add('content.spell.${spell.action.name}.description');
    }
    for (final id in [
      'front_1',
      'front_2',
      'front_3',
      'duel_1',
      'duel_2',
      'duel_3',
      'seal_1',
      'seal_2',
      'seal_3',
    ]) {
      requiredKeys
        ..add('content.mastery.$id.name')
        ..add('content.mastery.$id.path')
        ..add('content.mastery.$id.description');
    }
    for (var stage = 1; stage <= 8; stage++) {
      requiredKeys.add('content.postgame.$stage.name');
    }
    for (final tactic in TaughtTactic.values) {
      requiredKeys.add('content.tactic.${tactic.name}');
    }

    for (final key in requiredKeys) {
      final message = gameMessages[key];
      expect(message, isNotNull, reason: 'Missing message: $key');
      expect(message!.turkish, isNotEmpty, reason: 'Empty Turkish: $key');
      expect(message.english, isNotEmpty, reason: 'Empty English: $key');
      expect(message.description, isNotEmpty, reason: 'Missing context: $key');
    }
  });

  test('message placeholders match and named English plurals format', () {
    final placeholder = RegExp(r'\{([A-Za-z][A-Za-z0-9_]*)');
    for (final entry in gameMessages.entries) {
      final turkish = placeholder
          .allMatches(entry.value.turkish)
          .map((match) => match.group(1))
          .toSet();
      final english = placeholder
          .allMatches(entry.value.english)
          .map((match) => match.group(1))
          .toSet();
      expect(english, turkish, reason: 'Placeholder mismatch: ${entry.key}');
    }

    final english = const GameLocalizations('en');
    final turkish = const GameLocalizations('tr');
    expect(english.text('ui.points.remaining', {'count': 1}), '1 point');
    expect(english.text('ui.points.remaining', {'count': 3}), '3 points');
    expect(turkish.text('ui.points.remaining', {'count': 3}), '3 puan');
    expect(english.text('missing.message'), 'missing.message');
  });

  test('battle presentation IDs are covered and legacy logs stay aligned', () {
    final requiredBattleKeys = <String>{
      'battle.audience.tactics',
      'battle.audience.answerAttack',
      'battle.audience.avoidHazard',
      'battle.audience.changeRange',
      'battle.intent.hazard',
      'battle.log.encounterIntro',
      'battle.log.arenaRule',
      'battle.log.guard',
      'battle.log.hazardApproaching',
      'battle.log.closeDistance',
      'battle.log.openDistance',
      'battle.log.salve',
      'battle.log.tonic',
      'battle.log.tideWard',
      'battle.log.saltCleanse',
      'battle.log.swiftBreeze',
      'battle.log.shoreStep',
      'battle.log.miss',
      'battle.log.ashBurstHit',
      'battle.log.hit',
      'battle.log.stagger',
      'battle.log.bleed',
      'battle.log.statusResisted',
      'battle.log.statusImmune',
      'battle.log.shieldAbsorb',
      'battle.log.damageOverTime',
      'battle.log.spellTelegraph',
      'battle.log.hazardAvoided',
      'battle.log.hazardDamage',
      'battle.log.phaseChange',
      'battle.log.phaseTactics',
      'battle.log.opponentRangeChange',
      'battle.log.victory',
      'battle.log.defeat',
      'battle.preview.cost.bow',
      'battle.preview.cost.mana',
      'battle.preview.cost.free',
      'battle.preview.cost.effort',
      'battle.preview.note.bowPenalty',
      'battle.preview.note.sweepArmor',
      'battle.preview.note.guard',
      'ui.encounter.immunity',
      'label.element.ember',
      'label.element.tide',
      'label.element.wind',
    };
    for (final action in BattleAction.values) {
      requiredBattleKeys.add('battle.intent.${action.name}');
    }
    for (final key in requiredBattleKeys) {
      expect(gameMessages.containsKey(key), isTrue, reason: 'Missing $key');
    }

    final engine = BattleEngine(
      save: const GameSave(),
      encounter: getEncounter(1),
      seed: 17,
    );
    expect(engine.snapshot.messages, hasLength(engine.snapshot.log.length));
    expect(engine.snapshot.messages.first.id, 'battle.log.encounterIntro');
    for (final action in BattleAction.values) {
      final preview = engine.preview(action);
      expect(gameMessages.containsKey(preview.costMessage.id), isTrue);
      if (preview.noteMessage case final message?) {
        expect(gameMessages.containsKey(message.id), isTrue);
      }
    }
    expect(
      audienceRuleMessages(getEncounter(1))
          .every((message) => gameMessages.containsKey(message.id)),
      isTrue,
    );
    engine.perform(BattleAction.quick);
    expect(engine.snapshot.messages, hasLength(engine.snapshot.log.length));
  });

  testWidgets('language choice updates the app and persists across reload', (
    tester,
  ) async {
    final storage = MemorySaveStorage();
    final controller = GameController(storage: storage);
    await controller.initialize();
    await tester.pumpWidget(GameRoot(controller: controller));
    await tester.pumpAndSettle();

    expect(controller.save.language, 'tr');
    expect(find.text('Dövüşçünü oluştur'), findsOneWidget);
    await controller.updateSettings(language: 'en');
    await tester.pumpAndSettle();
    expect(find.text('Create your fighter'), findsOneWidget);
    expect(controller.save.language, 'en');
    expect(storage.value?.language, 'en');

    final relaunched = GameController(storage: storage);
    await relaunched.initialize();
    expect(relaunched.save.language, 'en');
    relaunched.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('fighter preview reflects origin and hides failed options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GameController(storage: MemorySaveStorage());
    await controller.initialize();
    await tester.pumpWidget(
      GameLocaleScope(
        languageCode: 'tr',
        child: MaterialApp(home: CharacterCreator(controller: controller)),
      ),
    );

    final portrait = find.byType(FighterArt);
    expect(tester.widget<FighterArt>(portrait).origin, 'Kıyı');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ocak'));
    await tester.pumpAndSettle();
    expect(tester.widget<FighterArt>(portrait).origin, 'Ocak');
    for (final removedOption in [
      'Saç',
      'Saç biçimi',
      'Sakal',
      'Ten tonu',
      'Ten rengi',
      'Yüz kılı',
      'Renk vurgusu',
      'Ana renk vurgusu',
      'İkincil renk vurgusu',
    ]) {
      expect(find.text(removedOption), findsNothing, reason: removedOption);
    }
    expect(
      find.byKey(const ValueKey('creator.facialHair.facial_hair_00')),
      findsNothing,
    );
    expect(find.text('İsabet'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('English battle briefing and combat log use typed translations', (
    tester,
  ) async {
    final controller = GameController(storage: MemorySaveStorage());
    await controller.initialize();
    await controller.createHero(
      name: 'Test fighter',
      stats: const Stats(
        might: 4,
        agility: 4,
        vitality: 4,
        guard: 2,
        stamina: 2,
        arcana: 2,
      ),
    );
    await controller.startEncounter(1, seed: 17);
    await tester.pumpWidget(
      GameLocaleScope(
        languageCode: 'en',
        child: MaterialApp(home: BattlePage(controller: controller)),
      ),
    );

    expect(find.text('DUEL BRIEFING'), findsOneWidget);
    expect(find.text('ARENA CONDITIONS'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Start duel'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start duel'));
    await tester.pumpAndSettle();

    expect(find.text('CHOOSE YOUR ACTION'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('COMBAT LOG'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('COMBAT LOG'), findsOneWidget);
    expect(
      find.text('·  Pier Bruiser enters the arena. Rival: striker.'),
      findsOneWidget,
    );
    controller.dispose();
  });
}
