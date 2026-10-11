import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControllableSaveStorage implements SaveStorage {
  _ControllableSaveStorage([GameSave? initial])
    : _inner = MemorySaveStorage()..value = initial;

  final MemorySaveStorage _inner;
  Completer<void>? writeCompleter;

  GameSave? get value => _inner.value;

  @override
  Future<GameSave?> read() => _inner.read();

  @override
  Future<void> write(GameSave save) async {
    final completer = writeCompleter;
    if (completer != null) {
      await completer.future;
    }
    await _inner.write(save);
  }

  @override
  Future<void> clear() => _inner.clear();
}

void main() {
  void setupTestView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildEditor({
    required GameController controller,
    required String languageCode,
  }) {
    return GameLocaleScope(
      languageCode: languageCode,
      child: MaterialApp(
        theme: buildGameTheme(),
        home: AppearanceEditorPage(controller: controller),
      ),
    );
  }

  group('Appearance editor option chip accessibility semantics', () {
    testWidgets(
      'exposes single button semantics with Turkish localized labels, selected state, and tap action',
      (tester) async {
        setupTestView(tester);
        final handle = tester.ensureSemantics();

        const initialSave = GameSave(
          hasHero: true,
          heroName: 'Kül Savaşçısı',
          headOptionId: 'head_01',
          skinToneId: 'skin_01',
          bodyProportionId: 'body_01',
          facialHairId: 'facial_hair_00',
          language: 'tr',
        );
        final storage = MemorySaveStorage()..value = initialSave;
        final controller = GameController(storage: storage);
        await controller.initialize();

        try {
          await tester.pumpWidget(
            buildEditor(controller: controller, languageCode: 'tr'),
          );
          await tester.pumpAndSettle();

          // 1. Build option 1 (selected)
          final body1Finder = find.bySemanticsLabel('Yapı, seçenek 1');
          expect(body1Finder, findsOneWidget);
          final body1Node = tester.getSemantics(body1Finder);
          final body1Data = body1Node.getSemanticsData();
          expect(body1Data.label, 'Yapı, seçenek 1');
          expect(body1Data.flagsCollection.isButton, isTrue);
          expect(body1Data.flagsCollection.isSelected, Tristate.isTrue);
          expect(body1Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(body1Data.hasAction(SemanticsAction.tap), isTrue);
          expect(body1Node.childrenCount, 0);

          // 2. Build option 2 (unselected)
          final body2Finder = find.bySemanticsLabel('Yapı, seçenek 2');
          expect(body2Finder, findsOneWidget);
          final body2Node = tester.getSemantics(body2Finder);
          final body2Data = body2Node.getSemanticsData();
          expect(body2Data.label, 'Yapı, seçenek 2');
          expect(body2Data.flagsCollection.isButton, isTrue);
          expect(body2Data.flagsCollection.isSelected, Tristate.isFalse);
          expect(body2Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(body2Data.hasAction(SemanticsAction.tap), isTrue);
          expect(body2Node.childrenCount, 0);

          expect(find.bySemanticsLabel(RegExp(r'Yüz kılı')), findsNothing);
          expect(find.bySemanticsLabel(RegExp(r'renk vurgusu')), findsNothing);
          expect(find.bySemanticsLabel(RegExp(r'Saç ve başlık')), findsNothing);
          expect(find.bySemanticsLabel(RegExp(r'Ten tonu')), findsNothing);
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );

    testWidgets(
      'exposes single button semantics with English localized labels, selected state, and tap action',
      (tester) async {
        setupTestView(tester);
        final handle = tester.ensureSemantics();

        const initialSave = GameSave(
          hasHero: true,
          heroName: 'Coast Fighter',
          headOptionId: 'head_01',
          skinToneId: 'skin_01',
          bodyProportionId: 'body_01',
          facialHairId: 'facial_hair_00',
          language: 'en',
        );
        final storage = MemorySaveStorage()..value = initialSave;
        final controller = GameController(storage: storage);
        await controller.initialize();

        try {
          await tester.pumpWidget(
            buildEditor(controller: controller, languageCode: 'en'),
          );
          await tester.pumpAndSettle();

          // 1. Build option 1 (selected)
          final body1Finder = find.bySemanticsLabel('Build, option 1');
          expect(body1Finder, findsOneWidget);
          final body1Node = tester.getSemantics(body1Finder);
          final body1Data = body1Node.getSemanticsData();
          expect(body1Data.label, 'Build, option 1');
          expect(body1Data.flagsCollection.isButton, isTrue);
          expect(body1Data.flagsCollection.isSelected, Tristate.isTrue);
          expect(body1Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(body1Data.hasAction(SemanticsAction.tap), isTrue);
          expect(body1Node.childrenCount, 0);

          // 2. Build option 2 (unselected)
          final body2Finder = find.bySemanticsLabel('Build, option 2');
          expect(body2Finder, findsOneWidget);
          final body2Node = tester.getSemantics(body2Finder);
          final body2Data = body2Node.getSemanticsData();
          expect(body2Data.label, 'Build, option 2');
          expect(body2Data.flagsCollection.isButton, isTrue);
          expect(body2Data.flagsCollection.isSelected, Tristate.isFalse);
          expect(body2Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(body2Data.hasAction(SemanticsAction.tap), isTrue);
          expect(body2Node.childrenCount, 0);

          expect(find.bySemanticsLabel(RegExp(r'Facial hair')), findsNothing);
          expect(find.bySemanticsLabel(RegExp(r'color accent')), findsNothing);
          expect(
            find.bySemanticsLabel(RegExp(r'Hair and headwear')),
            findsNothing,
          );
          expect(find.bySemanticsLabel(RegExp(r'Skin tone')), findsNothing);
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );

    testWidgets(
      'updates option selection and persisted appearance when invoking semantic tap action',
      (tester) async {
        setupTestView(tester);
        final handle = tester.ensureSemantics();

        const initialSave = GameSave(
          hasHero: true,
          heroName: 'Kül Savaşçısı',
          headOptionId: 'head_01',
          skinToneId: 'skin_01',
          bodyProportionId: 'body_01',
          facialHairId: 'facial_hair_00',
          language: 'tr',
        );
        final storage = MemorySaveStorage()..value = initialSave;
        final controller = GameController(storage: storage);
        await controller.initialize();

        try {
          await tester.pumpWidget(
            buildEditor(controller: controller, languageCode: 'tr'),
          );
          await tester.pumpAndSettle();

          final body1Finder = find.bySemanticsLabel('Yapı, seçenek 1');
          final body2Finder = find.bySemanticsLabel('Yapı, seçenek 2');

          expect(
            tester
                .getSemantics(body1Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
          expect(
            tester
                .getSemantics(body2Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );

          // Perform semantic tap on option 2
          tester.semantics.performAction(
            find.semantics.byLabel('Yapı, seçenek 2'),
            SemanticsAction.tap,
          );
          await tester.pumpAndSettle();

          // Verify controller and storage persisted selection
          expect(controller.save.bodyProportionId, 'body_02');
          expect(storage.value?.bodyProportionId, 'body_02');

          // Verify updated semantic state
          expect(
            tester
                .getSemantics(body1Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );
          expect(
            tester
                .getSemantics(body2Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );

          expect(controller.save.facialHairId, 'facial_hair_00');
          expect(storage.value?.facialHairId, 'facial_hair_00');
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );

    testWidgets(
      'disables semantic button and strips tap action while saving is in progress',
      (tester) async {
        setupTestView(tester);
        final handle = tester.ensureSemantics();

        const initialSave = GameSave(
          hasHero: true,
          heroName: 'Kül Savaşçısı',
          headOptionId: 'head_01',
          skinToneId: 'skin_01',
          bodyProportionId: 'body_01',
          facialHairId: 'facial_hair_00',
          language: 'tr',
        );
        final storage = _ControllableSaveStorage(initialSave);
        final controller = GameController(storage: storage);
        await controller.initialize();

        try {
          await tester.pumpWidget(
            buildEditor(controller: controller, languageCode: 'tr'),
          );
          await tester.pumpAndSettle();

          final writeGate = Completer<void>();
          storage.writeCompleter = writeGate;

          final targetFinder = find.bySemanticsLabel('Yapı, seçenek 2');
          // Invoke semantic tap to trigger asynchronous save
          tester.semantics.performAction(
            find.semantics.byLabel('Yapı, seçenek 2'),
            SemanticsAction.tap,
          );
          // Pump one frame to apply setState(() => _saving = true)
          await tester.pump();

          // While saving is pending, semantic nodes must be disabled without tap action
          final savingTargetData = tester
              .getSemantics(targetFinder)
              .getSemanticsData();
          expect(savingTargetData.flagsCollection.isButton, isTrue);
          expect(savingTargetData.flagsCollection.isEnabled, Tristate.isFalse);
          expect(savingTargetData.hasAction(SemanticsAction.tap), isFalse);

          final otherFinder = find.bySemanticsLabel('Yapı, seçenek 1');
          final otherData = tester.getSemantics(otherFinder).getSemanticsData();
          expect(otherData.flagsCollection.isButton, isTrue);
          expect(otherData.flagsCollection.isEnabled, Tristate.isFalse);
          expect(otherData.hasAction(SemanticsAction.tap), isFalse);

          // Resume save completion
          writeGate.complete();
          await tester.pumpAndSettle();

          // Once saving is settled, node is re-enabled, has tap action, and is selected
          final settledData = tester
              .getSemantics(targetFinder)
              .getSemanticsData();
          expect(settledData.flagsCollection.isButton, isTrue);
          expect(settledData.flagsCollection.isEnabled, Tristate.isTrue);
          expect(settledData.hasAction(SemanticsAction.tap), isTrue);
          expect(settledData.flagsCollection.isSelected, Tristate.isTrue);
          expect(controller.save.bodyProportionId, 'body_02');
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );
  });
}
