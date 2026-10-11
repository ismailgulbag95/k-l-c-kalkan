import 'package:ash_circuit/game/ui/audience_emblems.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crowd reaction reflects the result in Turkish and English', () {
    expect(
      audienceCrowdReactionText(
        won: true,
        isEnglish: false,
        chapterTitle: 'Kor Devresi',
      ),
      'Kor Devresi tribünleri zaferinle coştu!',
    );
    expect(
      audienceCrowdReactionText(
        won: false,
        isEnglish: false,
        chapterTitle: 'Kor Devresi',
      ),
      'Kor Devresi tribünleri yenilginden sonra sessizliğe gömüldü.',
    );
    expect(
      audienceCrowdReactionText(
        won: true,
        isEnglish: true,
        chapterTitle: 'Ember Circuit',
      ),
      'The Ember Circuit crowd erupts for your victory!',
    );
    expect(
      audienceCrowdReactionText(
        won: false,
        isEnglish: true,
        chapterTitle: 'Ember Circuit',
      ),
      'The Ember Circuit crowd falls silent after your defeat.',
    );
  });

  group('Audience chapter heraldry atlas', () {
    test('maps acts to stable 2×2 cells in reading order', () {
      expect(
        AudienceHeraldryCell.forChapter(1),
        AudienceHeraldryCell.chapterOne,
      );
      expect(
        AudienceHeraldryCell.forChapter(2),
        AudienceHeraldryCell.chapterTwo,
      );
      expect(
        AudienceHeraldryCell.forChapter(3),
        AudienceHeraldryCell.chapterThree,
      );
      expect(
        AudienceHeraldryCell.forChapter(4),
        AudienceHeraldryCell.chapterFour,
      );
      expect(
        [
          for (var chapter = 1; chapter <= 4; chapter++)
            AudienceHeraldryCell.forChapter(chapter).alignment,
        ],
        const [
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
          Alignment.bottomRight,
        ],
      );
    });

    test('out-of-range chapter IDs resolve safely to the last cell', () {
      expect(
        AudienceHeraldryCell.forChapter(0),
        AudienceHeraldryCell.chapterFour,
      );
      expect(
        AudienceHeraldryCell.forChapter(99),
        AudienceHeraldryCell.chapterFour,
      );
    });

    testWidgets('emblem keeps its size and exposes its localized label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AudienceChapterEmblem(
                  chapter: 2,
                  size: 52,
                  semanticLabel: 'Fırtına ve Gelgit arması',
                ),
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(AudienceChapterEmblem)),
          const Size(52, 52),
        );
        expect(
          find.bySemanticsLabel('Fırtına ve Gelgit arması'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  });

  testWidgets('arena color wash is present only in the final phase', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 100,
          height: 100,
          child: ArenaFinalPhaseLighting(
            arenaId: 'kor_ocagi',
            isFinalPhase: false,
          ),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsNothing);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 100,
          height: 100,
          child: ArenaFinalPhaseLighting(
            arenaId: 'kor_ocagi',
            isFinalPhase: true,
          ),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsOneWidget);
  });
}
