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

          // 1. Head option 1 (selected)
          final head1Finder = find.bySemanticsLabel('Saç ve başlık, seçenek 1');
          expect(head1Finder, findsOneWidget);
          final head1Node = tester.getSemantics(head1Finder);
          final head1Data = head1Node.getSemanticsData();
          expect(head1Data.label, 'Saç ve başlık, seçenek 1');
          expect(head1Data.flagsCollection.isButton, isTrue);
          expect(head1Data.flagsCollection.isSelected, Tristate.isTrue);
          expect(head1Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(head1Data.hasAction(SemanticsAction.tap), isTrue);
          expect(head1Node.childrenCount, 0);

          // 2. Head option 2 (unselected)
          final head2Finder = find.bySemanticsLabel('Saç ve başlık, seçenek 2');
          expect(head2Finder, findsOneWidget);
          final head2Node = tester.getSemantics(head2Finder);
          final head2Data = head2Node.getSemanticsData();
          expect(head2Data.label, 'Saç ve başlık, seçenek 2');
          expect(head2Data.flagsCollection.isButton, isTrue);
          expect(head2Data.flagsCollection.isSelected, Tristate.isFalse);
          expect(head2Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(head2Data.hasAction(SemanticsAction.tap), isTrue);
          expect(head2Node.childrenCount, 0);

          // 3. Other groups expose correct Turkish group label and single button node
          final skin1Node = tester.getSemantics(
            find.bySemanticsLabel('Ten tonu, seçenek 1'),
          );
          expect(
            skin1Node.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );
          expect(skin1Node.getSemanticsData().flagsCollection.isButton, isTrue);
          expect(
            skin1Node.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isTrue,
          );
          expect(
            skin1Node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(skin1Node.childrenCount, 0);

          final body1Node = tester.getSemantics(
            find.bySemanticsLabel('Yapı, seçenek 1'),
          );
          expect(
            body1Node.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );
          expect(body1Node.getSemanticsData().flagsCollection.isButton, isTrue);
          expect(
            body1Node.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isTrue,
          );
          expect(
            body1Node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(body1Node.childrenCount, 0);

          final facialHair1Node = tester.getSemantics(
            find.bySemanticsLabel('Yüz kılı, seçenek 1'),
          );
          expect(
            facialHair1Node.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );
          expect(
            facialHair1Node.getSemanticsData().flagsCollection.isButton,
            isTrue,
          );
          expect(
            facialHair1Node.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isTrue,
          );
          expect(
            facialHair1Node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(facialHair1Node.childrenCount, 0);
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

          // 1. Head option 1 (selected)
          final head1Finder = find.bySemanticsLabel(
            'Hair and headwear, option 1',
          );
          expect(head1Finder, findsOneWidget);
          final head1Node = tester.getSemantics(head1Finder);
          final head1Data = head1Node.getSemanticsData();
          expect(head1Data.label, 'Hair and headwear, option 1');
          expect(head1Data.flagsCollection.isButton, isTrue);
          expect(head1Data.flagsCollection.isSelected, Tristate.isTrue);
          expect(head1Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(head1Data.hasAction(SemanticsAction.tap), isTrue);
          expect(head1Node.childrenCount, 0);

          // 2. Head option 2 (unselected)
          final head2Finder = find.bySemanticsLabel(
            'Hair and headwear, option 2',
          );
          expect(head2Finder, findsOneWidget);
          final head2Node = tester.getSemantics(head2Finder);
          final head2Data = head2Node.getSemanticsData();
          expect(head2Data.label, 'Hair and headwear, option 2');
          expect(head2Data.flagsCollection.isButton, isTrue);
          expect(head2Data.flagsCollection.isSelected, Tristate.isFalse);
          expect(head2Data.flagsCollection.isEnabled, Tristate.isTrue);
          expect(head2Data.hasAction(SemanticsAction.tap), isTrue);
          expect(head2Node.childrenCount, 0);

          // 3. Other groups expose correct English group label and single button node
          final skin1Node = tester.getSemantics(
            find.bySemanticsLabel('Skin tone, option 1'),
          );
          expect(
            skin1Node.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );
          expect(skin1Node.getSemanticsData().flagsCollection.isButton, isTrue);
          expect(
            skin1Node.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isTrue,
          );
          expect(
            skin1Node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(skin1Node.childrenCount, 0);

          final body1Node = tester.getSemantics(
            find.bySemanticsLabel('Build, option 1'),
          );
          expect(
            body1Node.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );
          expect(body1Node.getSemanticsData().flagsCollection.isButton, isTrue);
          expect(
            body1Node.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isTrue,
          );
          expect(
            body1Node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(body1Node.childrenCount, 0);

          final facialHair1Node = tester.getSemantics(
            find.bySemanticsLabel('Facial hair, option 1'),
          );
          expect(
            facialHair1Node.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );
          expect(
            facialHair1Node.getSemanticsData().flagsCollection.isButton,
            isTrue,
          );
          expect(
            facialHair1Node.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isTrue,
          );
          expect(
            facialHair1Node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(facialHair1Node.childrenCount, 0);
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

          final head1Finder = find.bySemanticsLabel('Saç ve başlık, seçenek 1');
          final head2Finder = find.bySemanticsLabel('Saç ve başlık, seçenek 2');

          expect(
            tester
                .getSemantics(head1Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
          expect(
            tester
                .getSemantics(head2Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );

          // Perform semantic tap on option 2
          tester.semantics.performAction(
            find.semantics.byLabel('Saç ve başlık, seçenek 2'),
            SemanticsAction.tap,
          );
          await tester.pumpAndSettle();

          // Verify controller and storage persisted selection
          expect(controller.save.headOptionId, 'head_02');
          expect(storage.value?.headOptionId, 'head_02');

          // Verify updated semantic state
          expect(
            tester
                .getSemantics(head1Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );
          expect(
            tester
                .getSemantics(head2Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );

          // Next test skin option selection via semantic tap
          final skin1Finder = find.bySemanticsLabel('Ten tonu, seçenek 1');
          final skin2Finder = find.bySemanticsLabel('Ten tonu, seçenek 2');

          expect(
            tester
                .getSemantics(skin1Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
          expect(
            tester
                .getSemantics(skin2Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );

          tester.semantics.performAction(
            find.semantics.byLabel('Ten tonu, seçenek 2'),
            SemanticsAction.tap,
          );
          await tester.pumpAndSettle();

          expect(controller.save.skinToneId, 'skin_02');
          expect(storage.value?.skinToneId, 'skin_02');
          expect(
            tester
                .getSemantics(skin1Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );
          expect(
            tester
                .getSemantics(skin2Finder)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
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

          final targetFinder = find.bySemanticsLabel(
            'Saç ve başlık, seçenek 2',
          );
          // Invoke semantic tap to trigger asynchronous save
          tester.semantics.performAction(
            find.semantics.byLabel('Saç ve başlık, seçenek 2'),
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

          final otherFinder = find.bySemanticsLabel('Saç ve başlık, seçenek 1');
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
          expect(controller.save.headOptionId, 'head_02');
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );
  });
}
