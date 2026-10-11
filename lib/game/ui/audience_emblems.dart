import 'package:flutter/material.dart';

import 'design.dart';

/// The four act crests occupy a fixed 2×2 atlas in reading order.
enum AudienceHeraldryCell {
  chapterOne(0, 0),
  chapterTwo(1, 0),
  chapterThree(0, 1),
  chapterFour(1, 1);

  const AudienceHeraldryCell(this.column, this.row);

  final int column;
  final int row;

  Alignment get alignment => Alignment(
    column == 0 ? -1 : 1,
    row == 0 ? -1 : 1,
  );

  static AudienceHeraldryCell forChapter(int chapter) => switch (chapter) {
    1 => chapterOne,
    2 => chapterTwo,
    3 => chapterThree,
    _ => chapterFour,
  };
}

/// Displays one original chapter crest from the transparent 2×2 atlas.
///
/// The per-act symbol remains visible while the atlas is loading or if the
/// asset cannot be decoded, so the UI never flashes an empty placeholder.
class AudienceChapterEmblem extends StatelessWidget {
  const AudienceChapterEmblem({
    super.key,
    required this.chapter,
    this.size = 40,
    this.semanticLabel,
  });

  static const atlasAsset = 'assets/art/arenas/chapter_heraldry_atlas.png';

  final int chapter;
  final double size;
  final String? semanticLabel;

  static IconData _fallbackIcon(int chapter) => switch (chapter) {
    1 => Icons.local_fire_department,
    2 => Icons.water_drop,
    3 => Icons.bolt,
    _ => Icons.emoji_events,
  };

  Widget _fallbackSheet(Color color, AudienceHeraldryCell cell) => SizedBox(
    width: size * 2,
    height: size * 2,
    child: Stack(
      children: [
        Positioned(
          left: cell.column * size,
          top: cell.row * size,
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .16),
              border: Border.all(color: color.withValues(alpha: .7)),
            ),
            child: Center(
              child: Icon(
                _fallbackIcon(chapter),
                size: size * .58,
                color: color,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final color = chapterColor(chapter);
    final cell = AudienceHeraldryCell.forChapter(chapter);
    final pixelExtent = (size * 2 *
            (MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1))
        .round()
        .clamp(32, 512)
        .toInt();
    final emblem = SizedBox.square(
      dimension: size,
      child: ClipRect(
        child: OverflowBox(
          alignment: cell.alignment,
          minWidth: size * 2,
          minHeight: size * 2,
          maxWidth: size * 2,
          maxHeight: size * 2,
          child: Image.asset(
            atlasAsset,
            width: size * 2,
            height: size * 2,
            cacheWidth: pixelExtent,
            cacheHeight: pixelExtent,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return _fallbackSheet(color, cell);
            },
            errorBuilder: (context, error, stackTrace) =>
                _fallbackSheet(color, cell),
          ),
        ),
      ),
    );

    if (semanticLabel == null) return ExcludeSemantics(child: emblem);
    return Semantics(image: true, label: semanticLabel, child: emblem);
  }
}
