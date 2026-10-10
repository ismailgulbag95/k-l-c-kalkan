import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio_service.dart';

class GamePalette {
  static const ink = Color(0xFF101719);
  static const panel = Color(0xFF192224);
  static const panelLight = Color(0xFF253033);
  static const parchment = Color(0xFFECE2CE);
  static const muted = Color(0xFFB5B9B3);
  static const gold = Color(0xFFD6AD68);
  static const teal = Color(0xFF72B6A8);
  static const rust = Color(0xFFCC7656);
  static const health = Color(0xFFBB6E5F);
  static const effort = Color(0xFFD4A85B);
  static const mana = Color(0xFF7AA5C3);
  static const line = Color(0xFF455052);
}

enum BattleEffectFrame { impact, dust, block, arrow, healing, wind, fire, tide }

const battleEffectsAtlasAsset = 'assets/art/effects/combat_effects_atlas.png';
const battleEffectsAtlasFrames = <Rect>[
  Rect.fromLTWH(0, 0, 443.5, 443.5),
  Rect.fromLTWH(443.5, 0, 443.5, 443.5),
  Rect.fromLTWH(887, 0, 443.5, 443.5),
  Rect.fromLTWH(1330.5, 0, 443.5, 443.5),
  Rect.fromLTWH(0, 443.5, 443.5, 443.5),
  Rect.fromLTWH(443.5, 443.5, 443.5, 443.5),
  Rect.fromLTWH(887, 443.5, 443.5, 443.5),
  Rect.fromLTWH(1330.5, 443.5, 443.5, 443.5),
];

class BattleImpactEffect extends StatelessWidget {
  const BattleImpactEffect({
    super.key,
    required this.sequence,
    required this.alignment,
    required this.reducedMotion,
    this.frame = 0,
  });

  final int sequence;
  final Alignment alignment;
  final bool reducedMotion;
  final int frame;

  @override
  Widget build(BuildContext context) {
    if (sequence <= 0 || reducedMotion) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(sequence),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 440),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) => Opacity(
            opacity: (math.sin(math.pi * progress) * .96).clamp(0, 1),
            child: Transform.scale(scale: .62 + progress * .58, child: child),
          ),
          child: FutureBuilder<ui.Image>(
            future: _AtlasPortrait._decodedImages.putIfAbsent(
              battleEffectsAtlasAsset,
              () => _AtlasPortrait._decode(battleEffectsAtlasAsset),
            ),
            builder: (context, snapshot) => SizedBox.square(
              dimension: 132,
              child: snapshot.data == null
                  ? const SizedBox.shrink()
                  : ExcludeSemantics(
                      child: CustomPaint(
                        painter: _ItemAtlasPainter(
                          snapshot.data!,
                          frame,
                          battleEffectsAtlasFrames,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

String uppercaseTurkish(String text) =>
    text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

ThemeData buildGameTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: GamePalette.ink,
  colorScheme: ColorScheme.fromSeed(
    seedColor: GamePalette.gold,
    brightness: Brightness.dark,
    surface: GamePalette.panel,
  ),
  fontFamily: 'serif',
  textTheme:
      const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: .6,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(height: 1.35),
        bodyMedium: TextStyle(height: 1.3),
      ).apply(
        bodyColor: GamePalette.parchment,
        displayColor: GamePalette.parchment,
      ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: GamePalette.panelLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: GamePalette.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: GamePalette.gold, width: 1.5),
    ),
  ),
  dividerColor: GamePalette.line,
  appBarTheme: const AppBarTheme(
    backgroundColor: GamePalette.ink,
    foregroundColor: GamePalette.parchment,
    centerTitle: false,
  ),
);

class GameBackdrop extends StatelessWidget {
  const GameBackdrop({
    super.key,
    required this.child,
    this.image,
    this.alignment = Alignment.center,
  });
  final Widget child;
  final String? image;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: GamePalette.ink,
      image: image == null
          ? null
          : DecorationImage(
              image: AssetImage(image!),
              fit: BoxFit.cover,
              alignment: alignment,
              colorFilter: const ColorFilter.mode(
                Color(0x990B1113),
                BlendMode.darken,
              ),
            ),
    ),
    child: child,
  );
}

class ArenaPropSprite extends StatelessWidget {
  const ArenaPropSprite({super.key, required this.atlas, required this.index});

  final String atlas;
  final int index;

  @override
  Widget build(BuildContext context) =>
      AtlasCellSprite(atlas: atlas, index: index, columns: 2, rows: 2);
}

class AtlasCellSprite extends StatelessWidget {
  const AtlasCellSprite({
    super.key,
    required this.atlas,
    required this.index,
    required this.columns,
    required this.rows,
  });

  final String atlas;
  final int index;
  final int columns;
  final int rows;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cell = index.clamp(0, columns * rows - 1).toInt();
      final column = cell % columns;
      final row = cell ~/ columns;
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final alignment = Alignment(
        columns == 1 ? 0 : -1 + (2 * column / (columns - 1)),
        rows == 1 ? 0 : -1 + (2 * row / (rows - 1)),
      );
      return ClipRect(
        child: OverflowBox(
          alignment: alignment,
          minWidth: width * columns,
          maxWidth: width * columns,
          minHeight: height * rows,
          maxHeight: height * rows,
          child: Image.asset(
            atlas,
            width: width * columns,
            height: height * rows,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    },
  );
}

class EquipmentAtlasSprite extends StatelessWidget {
  const EquipmentAtlasSprite({super.key, required this.frame, this.size = 36});

  final int frame;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: AtlasCellSprite(
      atlas: 'assets/art/items/armor_equipment_atlas.png',
      index: frame,
      columns: 4,
      rows: 3,
    ),
  );
}

class GamePanel extends StatelessWidget {
  const GamePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = GamePalette.panel,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor ?? GamePalette.line, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          uppercaseTurkish(title),
          style: const TextStyle(
            color: GamePalette.gold,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      ?trailing,
    ],
  );
}

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    this.expand = true,
    this.enabled = true,
    this.audioCue = 'ui_confirm',
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool expand;
  final bool enabled;
  final String? audioCue;

  @override
  Widget build(BuildContext context) {
    void invoke() {
      final audio = GameAudioScope.maybeOf(context);
      if (audio != null && audioCue != null) {
        unawaited(audio.playUiCue(audioCue!));
      }
      onPressed?.call();
    }

    final button = secondary
        ? OutlinedButton.icon(
            onPressed: enabled && onPressed != null ? invoke : null,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: GamePalette.parchment,
              side: const BorderSide(color: GamePalette.line),
              minimumSize: const Size(48, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          )
        : FilledButton.icon(
            onPressed: enabled && onPressed != null ? invoke : null,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
            label: Text(label),
            style: FilledButton.styleFrom(
              backgroundColor: GamePalette.gold,
              foregroundColor: GamePalette.ink,
              disabledBackgroundColor: GamePalette.panelLight,
              disabledForegroundColor: GamePalette.muted,
              minimumSize: const Size(48, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          );
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class ResourceBar extends StatelessWidget {
  const ResourceBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.compact = false,
  });
  final String label;
  final int value;
  final int max;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: GamePalette.muted,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$value/$max',
              style: TextStyle(
                color: GamePalette.parchment,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: compact ? 6 : 8,
            color: color,
            backgroundColor: const Color(0xFF344042),
          ),
        ),
      ],
    );
  }
}

class ValuePill extends StatelessWidget {
  const ValuePill({
    super.key,
    required this.icon,
    required this.value,
    this.color = GamePalette.gold,
  });
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: GamePalette.panelLight,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: GamePalette.line),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

enum FighterMotion {
  idle,
  attack,
  hit,
  dodge,
  guard,
  spell,
  status,
  heal,
  resource,
  move,
  phase,
  victory,
  defeat,
}

enum HeroActionPose {
  strongAttack,
  bowDraw,
  bowRelease,
  dodge,
  consumable,
  stagger,
  spell,
  defeat,
}

/// Maps a named action pose to its zero-based, row-major atlas cell.
int heroActionAtlasFrame(HeroActionPose pose) => switch (pose) {
  HeroActionPose.strongAttack => 0,
  HeroActionPose.bowDraw => 1,
  HeroActionPose.bowRelease => 2,
  HeroActionPose.dodge => 3,
  HeroActionPose.consumable => 4,
  HeroActionPose.stagger => 5,
  HeroActionPose.spell => 6,
  HeroActionPose.defeat => 7,
};

/// Maps battle motion progress to a zero-based, row-major hero atlas cell.
int heroMotionAtlasFrame(FighterMotion motion, double progress) {
  if (motion == FighterMotion.victory) return 5;
  if (motion == FighterMotion.attack && progress < .82) {
    return progress < .34 ? 1 : 2;
  }
  if (progress >= 1) return 0;
  return switch (motion) {
    FighterMotion.hit || FighterMotion.defeat => 3,
    FighterMotion.guard => 4,
    _ => 0,
  };
}

/// Maps champion rival atlases whose final cell is a defeat pose.
int rivalMotionAtlasFrame(FighterMotion motion, double progress) {
  if (motion == FighterMotion.defeat) return 5;
  if (motion == FighterMotion.victory) return 0;
  if (motion == FighterMotion.spell) return progress >= 1 ? 0 : 2;
  return heroMotionAtlasFrame(motion, progress);
}

const gameItemIconAtlasAsset = 'assets/art/items/item_icons.png';
const gameTieredItemIconAtlasAsset = 'assets/art/items/tiered_item_icons.png';
const gameItemIconAtlasFrames = <Rect>[
  Rect.fromLTWH(112, 122, 195, 202),
  Rect.fromLTWH(390, 116, 202, 208),
  Rect.fromLTWH(675, 116, 201, 211),
  Rect.fromLTWH(949, 121, 199, 214),
  Rect.fromLTWH(100, 399, 210, 217),
  Rect.fromLTWH(398, 406, 198, 210),
  Rect.fromLTWH(683, 413, 190, 200),
  Rect.fromLTWH(980, 397, 176, 216),
  Rect.fromLTWH(94, 670, 213, 215),
  Rect.fromLTWH(385, 670, 211, 214),
  Rect.fromLTWH(668, 671, 207, 214),
  Rect.fromLTWH(963, 681, 212, 203),
  Rect.fromLTWH(101, 955, 206, 193),
  Rect.fromLTWH(385, 945, 203, 210),
  Rect.fromLTWH(685, 947, 189, 204),
  Rect.fromLTWH(983, 938, 145, 218),
];

const gameTieredItemIconAtlasFrames = <Rect>[
  Rect.fromLTWH(0, 0, 256, 256),
  Rect.fromLTWH(256, 0, 256, 256),
  Rect.fromLTWH(512, 0, 256, 256),
  Rect.fromLTWH(768, 0, 256, 256),
  Rect.fromLTWH(1024, 0, 256, 256),
  Rect.fromLTWH(1280, 0, 256, 256),
  Rect.fromLTWH(0, 256, 256, 256),
  Rect.fromLTWH(256, 256, 256, 256),
  Rect.fromLTWH(512, 256, 256, 256),
  Rect.fromLTWH(768, 256, 256, 256),
  Rect.fromLTWH(1024, 256, 256, 256),
  Rect.fromLTWH(1280, 256, 256, 256),
  Rect.fromLTWH(0, 512, 256, 256),
  Rect.fromLTWH(256, 512, 256, 256),
  Rect.fromLTWH(512, 512, 256, 256),
  Rect.fromLTWH(768, 512, 256, 256),
  Rect.fromLTWH(1024, 512, 256, 256),
  Rect.fromLTWH(1280, 512, 256, 256),
  Rect.fromLTWH(0, 768, 256, 256),
  Rect.fromLTWH(256, 768, 256, 256),
  Rect.fromLTWH(512, 768, 256, 256),
  Rect.fromLTWH(768, 768, 256, 256),
  Rect.fromLTWH(1024, 768, 256, 256),
  Rect.fromLTWH(1280, 768, 256, 256),
];

class ItemAtlasIcon extends StatelessWidget {
  const ItemAtlasIcon({super.key, required this.frame, this.size = 24});

  final int frame;
  final double size;

  @override
  Widget build(BuildContext context) {
    final usesTieredAtlas = frame >= gameItemIconAtlasFrames.length;
    final asset = usesTieredAtlas
        ? gameTieredItemIconAtlasAsset
        : gameItemIconAtlasAsset;
    final frames = usesTieredAtlas
        ? gameTieredItemIconAtlasFrames
        : gameItemIconAtlasFrames;
    final sourceFrame = usesTieredAtlas
        ? frame - gameItemIconAtlasFrames.length
        : frame;

    return FutureBuilder<ui.Image>(
      future: _AtlasPortrait._decodedImages.putIfAbsent(
        asset,
        () => _AtlasPortrait._decode(asset),
      ),
      builder: (context, snapshot) => SizedBox.square(
        dimension: size,
        child: snapshot.data == null
            ? null
            : CustomPaint(
                painter: _ItemAtlasPainter(snapshot.data!, sourceFrame, frames),
              ),
      ),
    );
  }
}

class _ItemAtlasPainter extends CustomPainter {
  const _ItemAtlasPainter(this.image, this.frame, this.frames);

  final ui.Image image;
  final int frame;
  final List<Rect> frames;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame < 0 || frame >= frames.length) return;
    final source = frames[frame];
    final fit = applyBoxFit(BoxFit.contain, source.size, size);
    final destination = Alignment.center.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_ItemAtlasPainter oldDelegate) =>
      !identical(image, oldDelegate.image) || frame != oldDelegate.frame;
}

const storyEvidenceAtlasAsset = 'assets/art/evidence/evidence_card_atlas.png';
const storyEvidenceAtlasFrames = <Rect>[
  Rect.fromLTWH(0, 0, 627, 627),
  Rect.fromLTWH(627, 0, 627, 627),
  Rect.fromLTWH(0, 627, 627, 627),
  Rect.fromLTWH(627, 627, 627, 627),
];

class StoryEvidenceCardArt extends StatelessWidget {
  const StoryEvidenceCardArt({
    super.key,
    required this.frame,
    required this.semanticLabel,
    this.size = 88,
  });

  final int frame;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image>(
    future: _AtlasPortrait._decodedImages.putIfAbsent(
      storyEvidenceAtlasAsset,
      () => _AtlasPortrait._decode(storyEvidenceAtlasAsset),
    ),
    builder: (context, snapshot) => SizedBox.square(
      dimension: size,
      child: snapshot.data == null
          ? const SizedBox.shrink()
          : Semantics(
              image: true,
              label: semanticLabel,
              child: CustomPaint(
                painter: _ItemAtlasPainter(
                  snapshot.data!,
                  frame,
                  storyEvidenceAtlasFrames,
                ),
              ),
            ),
    ),
  );
}

const heroHeadOptionIds = <String>[
  'head_01',
  'head_02',
  'head_03',
  'head_04',
  'head_05',
  'head_06',
  'head_07',
  'head_08',
];

const heroSkinToneIds = <String>[
  'skin_01',
  'skin_02',
  'skin_03',
  'skin_04',
  'skin_05',
  'skin_06',
  'skin_07',
  'skin_08',
];

const heroBodyProportionIds = <String>['body_01', 'body_02', 'body_03'];

const heroFacialHairIds = <String>[
  'facial_hair_00',
  'facial_hair_01',
  'facial_hair_02',
  'facial_hair_03',
  'facial_hair_04',
];

const heroSkinToneColors = <String, Color>{
  'skin_01': Color(0xFFE8B98F),
  'skin_02': Color(0xFFDCA273),
  'skin_03': Color(0xFFC98558),
  'skin_04': Color(0xFFAD6B48),
  'skin_05': Color(0xFFE6C4AA),
  'skin_06': Color(0xFF965A3E),
  'skin_07': Color(0xFF754733),
  'skin_08': Color(0xFF55352B),
};

int heroHeadOptionIndex(String id) {
  final index = heroHeadOptionIds.indexOf(id);
  return index < 0 ? 0 : index;
}

int heroBodyProportionIndex(String id) {
  final index = heroBodyProportionIds.indexOf(id);
  return index < 0 ? 0 : index;
}

int heroFacialHairIndex(String id) {
  final index = heroFacialHairIds.indexOf(id);
  return index < 0 ? 0 : index;
}

Color heroSkinToneColor(String id) =>
    heroSkinToneColors[id] ?? heroSkinToneColors['skin_01']!;

Rect heroHeadAtlasCell(String id, Size atlasSize) {
  final index = heroHeadOptionIndex(id);
  final cellWidth = atlasSize.width / 4;
  final cellHeight = atlasSize.height / 2;
  return Rect.fromLTWH(
    (index % 4) * cellWidth,
    (index ~/ 4) * cellHeight,
    cellWidth,
    cellHeight,
  );
}

Rect heroBodyAtlasCell(String id, Size atlasSize) {
  final index = heroBodyProportionIndex(id);
  final cellWidth = atlasSize.width / 3;
  return Rect.fromLTWH(index * cellWidth, 0, cellWidth, atlasSize.height);
}

Rect heroFacialHairAtlasCell(String id, Size atlasSize) {
  final index = heroFacialHairIndex(id);
  final cellWidth = atlasSize.width / 3;
  final cellHeight = atlasSize.height / 2;
  return Rect.fromLTWH(
    (index % 3) * cellWidth,
    (index ~/ 3) * cellHeight,
    cellWidth,
    cellHeight,
  );
}

class HeroAppearanceSelection {
  const HeroAppearanceSelection({
    this.headOptionId = 'head_01',
    this.skinToneId = 'skin_01',
    this.bodyProportionId = 'body_01',
    this.facialHairId = 'facial_hair_00',
  });

  final String headOptionId;
  final String skinToneId;
  final String bodyProportionId;
  final String facialHairId;

  bool get isDefault =>
      headOptionId == 'head_01' &&
      skinToneId == 'skin_01' &&
      bodyProportionId == 'body_01' &&
      facialHairId == 'facial_hair_00';
}

bool isKnownHeadGearId(String? id) =>
    id == 'helm_1' || id == 'helm_2' || id == 'helm_3' || id == 'helm_4';

bool isKnownBodyGearId(String? id) =>
    id == 'coat_1' || id == 'coat_2' || id == 'coat_3' || id == 'coat_4';

bool isKnownBootsGearId(String? id) =>
    id == 'boots_1' || id == 'boots_2' || id == 'boots_3' || id == 'boots_4';

bool isKnownGearId(String? id) =>
    isKnownHeadGearId(id) || isKnownBodyGearId(id) || isKnownBootsGearId(id);

class EquippedGearAppearance {
  const EquippedGearAppearance({this.head, this.body, this.boots});

  factory EquippedGearAppearance.fromMap(Map<String, String>? map) {
    if (map == null || map.isEmpty) {
      return const EquippedGearAppearance();
    }
    return EquippedGearAppearance(
      head: map['head'],
      body: map['body'],
      boots: map['boots'],
    );
  }

  final String? head;
  final String? body;
  final String? boots;

  String? get headItemId => head;
  String? get bodyItemId => body;
  String? get bootsItemId => boots;

  bool get isEmpty =>
      (head == null || head!.isEmpty) &&
      (body == null || body!.isEmpty) &&
      (boots == null || boots!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  bool get hasVisibleGear =>
      isKnownHeadGearId(head) ||
      isKnownBodyGearId(body) ||
      isKnownBootsGearId(boots);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquippedGearAppearance &&
          runtimeType == other.runtimeType &&
          head == other.head &&
          body == other.body &&
          boots == other.boots;

  @override
  int get hashCode => Object.hash(head, body, boots);

  @override
  String toString() =>
      'EquippedGearAppearance(head: $head, body: $body, boots: $boots)';
}

enum HeroAppearanceOptionKind { head, body, facialHair }

class HeroAppearanceOptionPreview extends StatelessWidget {
  const HeroAppearanceOptionPreview({
    super.key,
    required this.kind,
    required this.optionId,
  });

  final HeroAppearanceOptionKind kind;
  final String optionId;

  String get _asset => switch (kind) {
    HeroAppearanceOptionKind.head =>
      'assets/art/characters/hero_head_layers.png',
    HeroAppearanceOptionKind.body =>
      'assets/art/characters/hero_body_layers.png',
    HeroAppearanceOptionKind.facialHair =>
      'assets/art/characters/hero_facial_hair_layers.png',
  };

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image>(
    future: _AtlasPortrait._decodedImages.putIfAbsent(
      _asset,
      () => _AtlasPortrait._decode(_asset),
    ),
    builder: (context, snapshot) {
      final image = snapshot.data;
      if (image == null) return const SizedBox.expand();
      return CustomPaint(
        painter: _HeroAppearanceOptionPainter(image, kind, optionId),
      );
    },
  );
}

class _HeroAppearanceOptionPainter extends CustomPainter {
  const _HeroAppearanceOptionPainter(this.image, this.kind, this.optionId);

  final ui.Image image;
  final HeroAppearanceOptionKind kind;
  final String optionId;

  @override
  void paint(Canvas canvas, Size size) {
    final source = switch (kind) {
      HeroAppearanceOptionKind.head => heroHeadAtlasCell(
        optionId,
        Size(image.width.toDouble(), image.height.toDouble()),
      ),
      HeroAppearanceOptionKind.body => heroBodyAtlasCell(
        optionId,
        Size(image.width.toDouble(), image.height.toDouble()),
      ),
      HeroAppearanceOptionKind.facialHair => heroFacialHairAtlasCell(
        optionId,
        Size(image.width.toDouble(), image.height.toDouble()),
      ),
    };
    final fit = applyBoxFit(BoxFit.contain, source.size, size);
    final destination = Alignment.bottomCenter.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_HeroAppearanceOptionPainter oldDelegate) =>
      !identical(image, oldDelegate.image) ||
      kind != oldDelegate.kind ||
      optionId != oldDelegate.optionId;
}

class HeroCustomizationArt extends StatelessWidget {
  const HeroCustomizationArt({
    super.key,
    this.selection = const HeroAppearanceSelection(),
    this.gear = const EquippedGearAppearance(),
  });

  final HeroAppearanceSelection selection;
  final EquippedGearAppearance gear;

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image>(
    future: _AtlasPortrait._decodedImages.putIfAbsent(
      'assets/art/characters/hero_body_layers.png',
      () =>
          _AtlasPortrait._decode('assets/art/characters/hero_body_layers.png'),
    ),
    builder: (context, bodySnapshot) {
      final body = bodySnapshot.data;
      if (body == null) {
        return Image.asset(
          'assets/art/characters/hero_kulak.webp',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.expand(),
        );
      }
      return FutureBuilder<ui.Image>(
        future: _AtlasPortrait._decodedImages.putIfAbsent(
          'assets/art/characters/hero_head_layers.png',
          () => _AtlasPortrait._decode(
            'assets/art/characters/hero_head_layers.png',
          ),
        ),
        builder: (context, headSnapshot) {
          final head = headSnapshot.data;
          if (head == null) {
            return Image.asset(
              'assets/art/characters/hero_kulak.webp',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.expand(),
            );
          }
          return FutureBuilder<ui.Image>(
            future: _AtlasPortrait._decodedImages.putIfAbsent(
              'assets/art/characters/hero_facial_hair_layers.png',
              () => _AtlasPortrait._decode(
                'assets/art/characters/hero_facial_hair_layers.png',
              ),
            ),
            builder: (context, facialHairSnapshot) => CustomPaint(
              painter: _HeroCustomizationPainter(
                body,
                head,
                facialHairSnapshot.data,
                selection,
                gear,
              ),
            ),
          );
        },
      );
    },
  );
}

class _HeroCustomizationPainter extends CustomPainter {
  const _HeroCustomizationPainter(
    this.bodyAtlas,
    this.headAtlas,
    this.facialHairAtlas,
    this.selection,
    this.gear,
  );

  final ui.Image bodyAtlas;
  final ui.Image headAtlas;
  final ui.Image? facialHairAtlas;
  final HeroAppearanceSelection selection;
  final EquippedGearAppearance gear;

  @override
  void paint(Canvas canvas, Size size) {
    final bodySource = heroBodyAtlasCell(
      selection.bodyProportionId,
      Size(bodyAtlas.width.toDouble(), bodyAtlas.height.toDouble()),
    );
    final bodyFit = applyBoxFit(BoxFit.contain, bodySource.size, size);
    final bodyDestination = Alignment.bottomCenter.inscribe(
      bodyFit.destination,
      Offset.zero & size,
    );
    final bodyPaint = Paint()..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(bodyAtlas, bodySource, bodyDestination, bodyPaint);

    if (selection.skinToneId != 'skin_01') {
      final mask = _skinMask(bodyDestination);
      canvas.save();
      canvas.clipPath(mask);
      canvas.drawImageRect(
        bodyAtlas,
        bodySource,
        bodyDestination,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(
            heroSkinToneColor(selection.skinToneId),
            BlendMode.color,
          ),
      );
      canvas.restore();
    }

    if (gear.boots != null) {
      FighterGearPainter.paintBoots(canvas, bodyDestination, gear.boots!);
    }
    if (gear.body != null) {
      FighterGearPainter.paintBody(canvas, bodyDestination, gear.body!);
    }

    final headSource = heroHeadAtlasCell(
      selection.headOptionId,
      Size(headAtlas.width.toDouble(), headAtlas.height.toDouble()),
    );
    final headSize = bodyDestination.width * .43;
    final headDestination = Rect.fromCenter(
      center: Offset(
        bodyDestination.left + bodyDestination.width * .50,
        bodyDestination.top + bodyDestination.height * .09,
      ),
      width: headSize,
      height: headSize,
    );
    canvas.drawImageRect(
      headAtlas,
      headSource,
      headDestination,
      Paint()..filterQuality = FilterQuality.medium,
    );
    final facialHair = facialHairAtlas;
    if (facialHair != null) {
      final facialHairSource = heroFacialHairAtlasCell(
        selection.facialHairId,
        Size(facialHair.width.toDouble(), facialHair.height.toDouble()),
      );
      final faceOpening = Path()
        ..moveTo(
          headDestination.left + headSize * .36,
          headDestination.top + headSize * .34,
        )
        ..quadraticBezierTo(
          headDestination.left + headSize * .57,
          headDestination.top + headSize * .27,
          headDestination.left + headSize * .78,
          headDestination.top + headSize * .39,
        )
        ..lineTo(
          headDestination.left + headSize * .76,
          headDestination.top + headSize * .70,
        )
        ..quadraticBezierTo(
          headDestination.left + headSize * .59,
          headDestination.top + headSize * .88,
          headDestination.left + headSize * .40,
          headDestination.top + headSize * .76,
        )
        ..close();
      canvas.save();
      canvas.clipPath(faceOpening);
      canvas.drawImageRect(
        facialHair,
        facialHairSource,
        headDestination,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }

    if (gear.head != null) {
      FighterGearPainter.paintHead(canvas, headDestination, gear.head!);
    }
  }

  Path _skinMask(Rect rect) {
    double x(double value) => rect.left + rect.width * value;
    double y(double value) => rect.top + rect.height * value;
    final path = Path()
      // Face, ears and the small throat area above the scarf.
      ..addOval(Rect.fromLTRB(x(.405), y(.035), x(.595), y(.155)))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x(.435), y(.135), x(.575), y(.215)),
          Radius.circular(rect.width * .025),
        ),
      )
      // Bare upper arms and small hand openings around the bracers.
      ..moveTo(x(.195), y(.215))
      ..quadraticBezierTo(x(.155), y(.23), x(.16), y(.285))
      ..lineTo(x(.18), y(.365))
      ..quadraticBezierTo(x(.21), y(.39), x(.255), y(.37))
      ..lineTo(x(.27), y(.27))
      ..close()
      ..moveTo(x(.70), y(.22))
      ..quadraticBezierTo(x(.79), y(.22), x(.80), y(.30))
      ..lineTo(x(.78), y(.375))
      ..quadraticBezierTo(x(.75), y(.39), x(.70), y(.37))
      ..close()
      ..addOval(Rect.fromLTRB(x(.105), y(.455), x(.17), y(.505)))
      ..addOval(Rect.fromLTRB(x(.79), y(.455), x(.855), y(.505)))
      // Exposed skin beneath the split armor skirt.
      ..moveTo(x(.365), y(.565))
      ..lineTo(x(.47), y(.565))
      ..lineTo(x(.465), y(.665))
      ..quadraticBezierTo(x(.42), y(.68), x(.375), y(.655))
      ..close()
      ..moveTo(x(.525), y(.565))
      ..lineTo(x(.63), y(.565))
      ..lineTo(x(.625), y(.66))
      ..quadraticBezierTo(x(.575), y(.68), x(.535), y(.655))
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(_HeroCustomizationPainter oldDelegate) =>
      !identical(bodyAtlas, oldDelegate.bodyAtlas) ||
      !identical(headAtlas, oldDelegate.headAtlas) ||
      !identical(facialHairAtlas, oldDelegate.facialHairAtlas) ||
      selection.headOptionId != oldDelegate.selection.headOptionId ||
      selection.skinToneId != oldDelegate.selection.skinToneId ||
      selection.bodyProportionId != oldDelegate.selection.bodyProportionId ||
      selection.facialHairId != oldDelegate.selection.facialHairId ||
      gear != oldDelegate.gear;
}

class FighterGearPainter extends CustomPainter {
  const FighterGearPainter({
    required this.gear,
    this.customBodyDestination,
    this.customHeadDestination,
  });

  final EquippedGearAppearance gear;
  final Rect? customBodyDestination;
  final Rect? customHeadDestination;

  @override
  void paint(Canvas canvas, Size size) {
    if (!gear.hasVisibleGear) return;
    final bodyDestination =
        customBodyDestination ??
        Alignment.bottomCenter.inscribe(
          applyBoxFit(BoxFit.contain, const Size(512, 1024), size).destination,
          Offset.zero & size,
        );
    final headSize = bodyDestination.width * .43;
    final headDestination =
        customHeadDestination ??
        Rect.fromCenter(
          center: Offset(
            bodyDestination.left + bodyDestination.width * .50,
            bodyDestination.top + bodyDestination.height * .09,
          ),
          width: headSize,
          height: headSize,
        );
    paintGear(canvas, bodyDestination, headDestination, gear);
  }

  static void paintGear(
    Canvas canvas,
    Rect bodyDestination,
    Rect headDestination,
    EquippedGearAppearance gear,
  ) {
    if (gear.boots != null) {
      paintBoots(canvas, bodyDestination, gear.boots!);
    }
    if (gear.body != null) {
      paintBody(canvas, bodyDestination, gear.body!);
    }
    if (gear.head != null) {
      paintHead(canvas, headDestination, gear.head!);
    }
  }

  static void paintHead(Canvas canvas, Rect headDestination, String itemId) {
    if (!isKnownHeadGearId(itemId)) return;
    double hx(double v) => headDestination.left + headDestination.width * v;
    double hy(double v) => headDestination.top + headDestination.height * v;
    final scale = math.max(1.0, headDestination.width / 34.0);
    final outline = Paint()
      ..color = const Color(0xFF101719)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (itemId) {
      case 'helm_1':
        final cap = Path()
          ..moveTo(hx(.27), hy(.36))
          ..quadraticBezierTo(hx(.30), hy(.08), hx(.53), hy(.04))
          ..quadraticBezierTo(hx(.77), hy(.08), hx(.79), hy(.37))
          ..quadraticBezierTo(hx(.54), hy(.30), hx(.27), hy(.36))
          ..close();
        canvas.drawPath(cap, Paint()..color = const Color(0xFF38291E));
        canvas.drawPath(cap, outline);

        final band = Path()
          ..moveTo(hx(.25), hy(.36))
          ..quadraticBezierTo(hx(.54), hy(.30), hx(.81), hy(.37))
          ..lineTo(hx(.80), hy(.42))
          ..quadraticBezierTo(hx(.54), hy(.35), hx(.26), hy(.41))
          ..close();
        canvas.drawPath(band, Paint()..color = GamePalette.gold);
        canvas.drawPath(band, outline);

        final rivetPaint = Paint()..color = const Color(0xFFECE2CE);
        canvas.drawCircle(Offset(hx(.36), hy(.36)), 1.1 * scale, rivetPaint);
        canvas.drawCircle(Offset(hx(.53), hy(.33)), 1.1 * scale, rivetPaint);
        canvas.drawCircle(Offset(hx(.70), hy(.36)), 1.1 * scale, rivetPaint);

      case 'helm_2':
        final dome = Path()
          ..moveTo(hx(.24), hy(.38))
          ..quadraticBezierTo(hx(.26), hy(.05), hx(.53), hy(.02))
          ..quadraticBezierTo(hx(.79), hy(.05), hx(.81), hy(.39))
          ..quadraticBezierTo(hx(.54), hy(.31), hx(.24), hy(.38))
          ..close();
        canvas.drawPath(dome, Paint()..color = const Color(0xFFB5843E));
        final facet = Path()
          ..moveTo(hx(.26), hy(.36))
          ..quadraticBezierTo(hx(.28), hy(.08), hx(.53), hy(.03))
          ..lineTo(hx(.53), hy(.32))
          ..quadraticBezierTo(hx(.38), hy(.33), hx(.26), hy(.36))
          ..close();
        canvas.drawPath(facet, Paint()..color = const Color(0xFFDCAE60));
        canvas.drawPath(dome, outline);

        final leftTab = Path()
          ..moveTo(hx(.24), hy(.38))
          ..lineTo(hx(.27), hy(.49))
          ..lineTo(hx(.33), hy(.47))
          ..lineTo(hx(.31), hy(.36))
          ..close();
        final rightTab = Path()
          ..moveTo(hx(.81), hy(.39))
          ..lineTo(hx(.78), hy(.50))
          ..lineTo(hx(.72), hy(.48))
          ..lineTo(hx(.74), hy(.37))
          ..close();
        final tabPaint = Paint()..color = const Color(0xFF9E7030);
        canvas.drawPath(leftTab, tabPaint);
        canvas.drawPath(leftTab, outline);
        canvas.drawPath(rightTab, tabPaint);
        canvas.drawPath(rightTab, outline);

        final nasal = Path()
          ..moveTo(hx(.50), hy(.32))
          ..lineTo(hx(.56), hy(.32))
          ..lineTo(hx(.55), hy(.50))
          ..lineTo(hx(.51), hy(.50))
          ..close();
        canvas.drawPath(nasal, Paint()..color = GamePalette.gold);
        canvas.drawPath(nasal, outline);

      case 'helm_3':
        final steelHelm = Path()
          ..moveTo(hx(.23), hy(.42))
          ..quadraticBezierTo(hx(.24), hy(.04), hx(.53), hy(.01))
          ..quadraticBezierTo(hx(.81), hy(.04), hx(.82), hy(.42))
          ..lineTo(hx(.77), hy(.58))
          ..lineTo(hx(.69), hy(.56))
          ..lineTo(hx(.72), hy(.42))
          ..quadraticBezierTo(hx(.54), hy(.36), hx(.34), hy(.42))
          ..lineTo(hx(.37), hy(.56))
          ..lineTo(hx(.29), hy(.58))
          ..close();
        canvas.drawPath(steelHelm, Paint()..color = const Color(0xFF7E8C90));
        final facet = Path()
          ..moveTo(hx(.24), hy(.40))
          ..quadraticBezierTo(hx(.25), hy(.06), hx(.53), hy(.02))
          ..lineTo(hx(.53), hy(.36))
          ..quadraticBezierTo(hx(.37), hy(.37), hx(.30), hy(.42))
          ..close();
        canvas.drawPath(facet, Paint()..color = const Color(0xFFAAB6B9));
        canvas.drawPath(steelHelm, outline);

        final ridge = RRect.fromRectAndRadius(
          Rect.fromLTRB(hx(.51), hy(-.01), hx(.55), hy(.36)),
          Radius.circular(2 * scale),
        );
        canvas.drawRRect(ridge, Paint()..color = GamePalette.gold);
        canvas.drawRRect(ridge, outline);

      case 'helm_4':
        final fullHelm = Path()
          ..moveTo(hx(.22), hy(.44))
          ..quadraticBezierTo(hx(.23), hy(.04), hx(.53), hy(.01))
          ..quadraticBezierTo(hx(.82), hy(.04), hx(.83), hy(.44))
          ..lineTo(hx(.78), hy(.66))
          ..quadraticBezierTo(hx(.54), hy(.72), hx(.27), hy(.66))
          ..close();
        canvas.drawPath(fullHelm, Paint()..color = const Color(0xFFC0CACD));
        final shadowFacet = Path()
          ..moveTo(hx(.53), hy(.01))
          ..quadraticBezierTo(hx(.82), hy(.04), hx(.83), hy(.44))
          ..lineTo(hx(.78), hy(.66))
          ..quadraticBezierTo(hx(.66), hy(.69), hx(.53), hy(.71))
          ..close();
        canvas.drawPath(shadowFacet, Paint()..color = const Color(0xFF67767A));
        canvas.drawPath(fullHelm, outline);

        final visor = Rect.fromLTWH(
          hx(.32),
          hy(.42),
          headDestination.width * .42,
          headDestination.height * .05,
        );
        canvas.drawRect(visor, Paint()..color = const Color(0xFF101719));
        canvas.drawLine(
          Offset(hx(.32), hy(.42)),
          Offset(hx(.74), hy(.42)),
          Paint()
            ..color = GamePalette.gold
            ..strokeWidth = 1.2 * scale,
        );
        canvas.drawLine(
          Offset(hx(.32), hy(.47)),
          Offset(hx(.74), hy(.47)),
          Paint()
            ..color = GamePalette.gold
            ..strokeWidth = 1.2 * scale,
        );

        final plume = Path()
          ..moveTo(hx(.49), hy(.02))
          ..quadraticBezierTo(hx(.50), hy(-.14), hx(.55), hy(-.15))
          ..quadraticBezierTo(hx(.60), hy(-.12), hx(.58), hy(.03))
          ..close();
        canvas.drawPath(plume, Paint()..color = GamePalette.teal);
        canvas.drawPath(plume, outline);

        final gem = Path()
          ..moveTo(hx(.53), hy(.29))
          ..lineTo(hx(.57), hy(.33))
          ..lineTo(hx(.53), hy(.37))
          ..lineTo(hx(.49), hy(.33))
          ..close();
        canvas.drawPath(gem, Paint()..color = GamePalette.teal);
        canvas.drawPath(gem, outline);
        canvas.drawCircle(
          Offset(hx(.53), hy(.33)),
          1.0 * scale,
          Paint()..color = const Color(0xFFD6F6F0),
        );
    }
  }

  static void paintBody(Canvas canvas, Rect bodyDestination, String itemId) {
    if (!isKnownBodyGearId(itemId)) return;
    double bx(double v) => bodyDestination.left + bodyDestination.width * v;
    double by(double v) => bodyDestination.top + bodyDestination.height * v;
    final scale = math.max(1.0, bodyDestination.width / 78.0);
    final outline = Paint()
      ..color = const Color(0xFF101719)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (itemId) {
      case 'coat_1':
        final vest = Path()
          ..moveTo(bx(.36), by(.22))
          ..quadraticBezierTo(bx(.50), by(.29), bx(.64), by(.22))
          ..lineTo(bx(.74), by(.24))
          ..quadraticBezierTo(bx(.71), by(.36), bx(.69), by(.44))
          ..lineTo(bx(.67), by(.54))
          ..quadraticBezierTo(bx(.50), by(.55), bx(.33), by(.54))
          ..lineTo(bx(.31), by(.44))
          ..quadraticBezierTo(bx(.29), by(.36), bx(.26), by(.24))
          ..close();
        canvas.drawPath(vest, Paint()..color = const Color(0xFF38291E));
        canvas.drawPath(vest, outline);

        final strap = Path()
          ..moveTo(bx(.65), by(.23))
          ..lineTo(bx(.70), by(.24))
          ..lineTo(bx(.36), by(.53))
          ..lineTo(bx(.32), by(.52))
          ..close();
        canvas.drawPath(strap, Paint()..color = const Color(0xFF241A12));
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(bx(.51), by(.37)),
            width: 7 * scale,
            height: 7 * scale,
          ),
          Paint()..color = GamePalette.gold,
        );

        final belt = Rect.fromLTRB(bx(.32), by(.50), bx(.68), by(.54));
        canvas.drawRect(belt, Paint()..color = const Color(0xFF241A12));
        canvas.drawRect(belt, outline);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(bx(.50), by(.52)),
            width: 8 * scale,
            height: 5 * scale,
          ),
          Paint()..color = GamePalette.gold,
        );

      case 'coat_2':
        final vest = Path()
          ..moveTo(bx(.30), by(.22))
          ..lineTo(bx(.70), by(.22))
          ..lineTo(bx(.68), by(.54))
          ..lineTo(bx(.32), by(.54))
          ..close();
        canvas.drawPath(vest, Paint()..color = const Color(0xFF2C2017));

        final leftShoulder = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bx(.18),
            by(.20),
            bodyDestination.width * .14,
            bodyDestination.height * .08,
          ),
          Radius.circular(3 * scale),
        );
        final rightShoulder = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bx(.68),
            by(.20),
            bodyDestination.width * .14,
            bodyDestination.height * .08,
          ),
          Radius.circular(3 * scale),
        );
        final pauldronPaint = Paint()..color = const Color(0xFFB5843E);
        canvas.drawRRect(leftShoulder, pauldronPaint);
        canvas.drawRRect(leftShoulder, outline);
        canvas.drawRRect(rightShoulder, pauldronPaint);
        canvas.drawRRect(rightShoulder, outline);

        final platePaint = Paint()..color = const Color(0xFFC7984E);
        final plateHighlight = Paint()..color = const Color(0xFFE8C27B);
        for (final yTier in [by(.27), by(.35), by(.43)]) {
          for (final xPlate in [bx(.34), bx(.45), bx(.56)]) {
            final plate = RRect.fromRectAndRadius(
              Rect.fromLTWH(
                xPlate,
                yTier,
                bodyDestination.width * .10,
                bodyDestination.height * .06,
              ),
              Radius.circular(2 * scale),
            );
            canvas.drawRRect(plate, platePaint);
            canvas.drawLine(
              Offset(xPlate, yTier),
              Offset(xPlate + bodyDestination.width * .10, yTier),
              plateHighlight,
            );
            canvas.drawRRect(plate, outline);
          }
        }

        final belt = Rect.fromLTRB(bx(.31), by(.49), bx(.69), by(.54));
        canvas.drawRect(belt, Paint()..color = const Color(0xFF241A12));
        canvas.drawRect(belt, outline);
        canvas.drawCircle(
          Offset(bx(.50), by(.515)),
          4 * scale,
          Paint()..color = GamePalette.gold,
        );

      case 'coat_3':
        final leftShoulder = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bx(.16),
            by(.19),
            bodyDestination.width * .15,
            bodyDestination.height * .10,
          ),
          Radius.circular(3 * scale),
        );
        final rightShoulder = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bx(.69),
            by(.19),
            bodyDestination.width * .15,
            bodyDestination.height * .10,
          ),
          Radius.circular(3 * scale),
        );
        final steelPaint = Paint()..color = const Color(0xFF869599);
        canvas.drawRRect(leftShoulder, steelPaint);
        canvas.drawRRect(leftShoulder, outline);
        canvas.drawRRect(rightShoulder, steelPaint);
        canvas.drawRRect(rightShoulder, outline);

        final cuirass = Path()
          ..moveTo(bx(.34), by(.21))
          ..lineTo(bx(.66), by(.21))
          ..lineTo(bx(.70), by(.38))
          ..lineTo(bx(.67), by(.51))
          ..lineTo(bx(.33), by(.51))
          ..lineTo(bx(.30), by(.38))
          ..close();
        canvas.drawPath(cuirass, steelPaint);
        final leftFacet = Path()
          ..moveTo(bx(.34), by(.21))
          ..lineTo(bx(.50), by(.21))
          ..lineTo(bx(.50), by(.51))
          ..lineTo(bx(.33), by(.51))
          ..lineTo(bx(.30), by(.38))
          ..close();
        canvas.drawPath(leftFacet, Paint()..color = const Color(0xFFAAB6B9));
        canvas.drawPath(cuirass, outline);
        canvas.drawLine(
          Offset(bx(.50), by(.21)),
          Offset(bx(.50), by(.51)),
          Paint()
            ..color = GamePalette.gold
            ..strokeWidth = 1.2 * scale,
        );

        final faulds = Path()
          ..moveTo(bx(.31), by(.51))
          ..lineTo(bx(.69), by(.51))
          ..lineTo(bx(.66), by(.60))
          ..lineTo(bx(.51), by(.60))
          ..lineTo(bx(.50), by(.52))
          ..lineTo(bx(.49), by(.60))
          ..lineTo(bx(.34), by(.60))
          ..close();
        canvas.drawPath(faulds, Paint()..color = const Color(0xFF7E8C90));
        canvas.drawPath(faulds, outline);

      case 'coat_4':
        final leftShoulder = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bx(.13),
            by(.18),
            bodyDestination.width * .19,
            bodyDestination.height * .13,
          ),
          Radius.circular(4 * scale),
        );
        final rightShoulder = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bx(.68),
            by(.18),
            bodyDestination.width * .19,
            bodyDestination.height * .13,
          ),
          Radius.circular(4 * scale),
        );
        final polishedSteel = Paint()..color = const Color(0xFFC0CACD);
        canvas.drawRRect(leftShoulder, polishedSteel);
        canvas.drawRRect(
          leftShoulder,
          Paint()
            ..color = GamePalette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4 * scale,
        );
        canvas.drawRRect(rightShoulder, polishedSteel);
        canvas.drawRRect(
          rightShoulder,
          Paint()
            ..color = GamePalette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4 * scale,
        );

        final cuirass = Path()
          ..moveTo(bx(.33), by(.20))
          ..lineTo(bx(.67), by(.20))
          ..lineTo(bx(.71), by(.38))
          ..lineTo(bx(.67), by(.52))
          ..lineTo(bx(.33), by(.52))
          ..lineTo(bx(.29), by(.38))
          ..close();
        canvas.drawPath(cuirass, polishedSteel);
        canvas.drawPath(cuirass, outline);

        canvas.drawCircle(
          Offset(bx(.50), by(.33)),
          5 * scale,
          Paint()..color = GamePalette.gold,
        );
        canvas.drawCircle(
          Offset(bx(.50), by(.33)),
          3.2 * scale,
          Paint()..color = GamePalette.teal,
        );
        canvas.drawCircle(
          Offset(bx(.49), by(.32)),
          1.2 * scale,
          Paint()..color = const Color(0xFFD6F6F0),
        );

        final tieredFaulds = Path()
          ..moveTo(bx(.30), by(.52))
          ..lineTo(bx(.70), by(.52))
          ..lineTo(bx(.67), by(.63))
          ..lineTo(bx(.33), by(.63))
          ..close();
        canvas.drawPath(tieredFaulds, polishedSteel);
        canvas.drawPath(
          tieredFaulds,
          Paint()
            ..color = GamePalette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4 * scale,
        );
    }
  }

  static void paintBoots(Canvas canvas, Rect bodyDestination, String itemId) {
    if (!isKnownBootsGearId(itemId)) return;
    double bx(double v) => bodyDestination.left + bodyDestination.width * v;
    double by(double v) => bodyDestination.top + bodyDestination.height * v;
    final scale = math.max(1.0, bodyDestination.width / 78.0);
    final outline = Paint()
      ..color = const Color(0xFF101719)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (itemId) {
      case 'boots_1':
        final leftBoot = Path()
          ..moveTo(bx(.34), by(.70))
          ..quadraticBezierTo(bx(.41), by(.68), bx(.47), by(.71))
          ..lineTo(bx(.46), by(.89))
          ..lineTo(bx(.46), by(.95))
          ..lineTo(bx(.31), by(.95))
          ..quadraticBezierTo(bx(.30), by(.90), bx(.34), by(.87))
          ..close();
        final rightBoot = Path()
          ..moveTo(bx(.53), by(.71))
          ..quadraticBezierTo(bx(.59), by(.68), bx(.66), by(.70))
          ..lineTo(bx(.66), by(.87))
          ..lineTo(bx(.69), by(.95))
          ..lineTo(bx(.54), by(.95))
          ..lineTo(bx(.54), by(.89))
          ..close();
        final leatherPaint = Paint()..color = const Color(0xFF38291E);
        canvas.drawPath(leftBoot, leatherPaint);
        canvas.drawPath(leftBoot, outline);
        canvas.drawPath(rightBoot, leatherPaint);
        canvas.drawPath(rightBoot, outline);

        final strapPaint = Paint()
          ..color = GamePalette.gold
          ..strokeWidth = 1.2 * scale;
        for (final yStrap in [by(.75), by(.81), by(.87)]) {
          canvas.drawLine(
            Offset(bx(.34), yStrap),
            Offset(bx(.46), yStrap),
            strapPaint,
          );
          canvas.drawLine(
            Offset(bx(.54), yStrap),
            Offset(bx(.66), yStrap),
            strapPaint,
          );
        }

      case 'boots_2':
        final leftBase = Rect.fromLTRB(bx(.33), by(.70), bx(.47), by(.95));
        final rightBase = Rect.fromLTRB(bx(.53), by(.70), bx(.67), by(.95));
        final darkLeather = Paint()..color = const Color(0xFF281D15);
        canvas.drawRect(leftBase, darkLeather);
        canvas.drawRect(rightBase, darkLeather);

        final leftGreave = RRect.fromRectAndRadius(
          Rect.fromLTRB(bx(.35), by(.71), bx(.45), by(.88)),
          Radius.circular(2 * scale),
        );
        final rightGreave = RRect.fromRectAndRadius(
          Rect.fromLTRB(bx(.55), by(.71), bx(.65), by(.88)),
          Radius.circular(2 * scale),
        );
        final bronzePaint = Paint()..color = const Color(0xFFB5843E);
        canvas.drawRRect(leftGreave, bronzePaint);
        canvas.drawRRect(leftGreave, outline);
        canvas.drawRRect(rightGreave, bronzePaint);
        canvas.drawRRect(rightGreave, outline);

        final goldPaint = Paint()..color = GamePalette.gold;
        canvas.drawRect(
          Rect.fromLTRB(bx(.31), by(.91), bx(.42), by(.95)),
          goldPaint,
        );
        canvas.drawRect(
          Rect.fromLTRB(bx(.58), by(.91), bx(.69), by(.95)),
          goldPaint,
        );

      case 'boots_3':
        final steelPaint = Paint()..color = const Color(0xFF869599);
        final leftPoleyn = RRect.fromRectAndRadius(
          Rect.fromLTRB(bx(.34), by(.68), bx(.46), by(.73)),
          Radius.circular(3 * scale),
        );
        final rightPoleyn = RRect.fromRectAndRadius(
          Rect.fromLTRB(bx(.54), by(.68), bx(.66), by(.73)),
          Radius.circular(3 * scale),
        );
        canvas.drawRRect(leftPoleyn, steelPaint);
        canvas.drawRRect(leftPoleyn, outline);
        canvas.drawRRect(rightPoleyn, steelPaint);
        canvas.drawRRect(rightPoleyn, outline);

        final leftGreave = RRect.fromRectAndRadius(
          Rect.fromLTRB(bx(.34), by(.73), bx(.46), by(.88)),
          Radius.circular(2 * scale),
        );
        final rightGreave = RRect.fromRectAndRadius(
          Rect.fromLTRB(bx(.54), by(.73), bx(.66), by(.88)),
          Radius.circular(2 * scale),
        );
        canvas.drawRRect(leftGreave, steelPaint);
        canvas.drawRRect(leftGreave, outline);
        canvas.drawRRect(rightGreave, steelPaint);
        canvas.drawRRect(rightGreave, outline);

        final leftSabaton = Rect.fromLTRB(bx(.30), by(.88), bx(.46), by(.96));
        final rightSabaton = Rect.fromLTRB(bx(.54), by(.88), bx(.70), by(.96));
        final darkSteel = Paint()..color = const Color(0xFF7E8C90);
        canvas.drawRect(leftSabaton, darkSteel);
        canvas.drawRect(leftSabaton, outline);
        canvas.drawRect(rightSabaton, darkSteel);
        canvas.drawRect(rightSabaton, outline);

      case 'boots_4':
        final leftWing = Path()
          ..moveTo(bx(.32), by(.71))
          ..lineTo(bx(.40), by(.66))
          ..lineTo(bx(.48), by(.71))
          ..lineTo(bx(.40), by(.73))
          ..close();
        final rightWing = Path()
          ..moveTo(bx(.52), by(.71))
          ..lineTo(bx(.60), by(.66))
          ..lineTo(bx(.68), by(.71))
          ..lineTo(bx(.60), by(.73))
          ..close();
        final goldPaint = Paint()..color = GamePalette.gold;
        canvas.drawPath(leftWing, goldPaint);
        canvas.drawPath(leftWing, outline);
        canvas.drawPath(rightWing, goldPaint);
        canvas.drawPath(rightWing, outline);

        final tealPaint = Paint()..color = GamePalette.teal;
        canvas.drawCircle(Offset(bx(.40), by(.695)), 2 * scale, tealPaint);
        canvas.drawCircle(Offset(bx(.60), by(.695)), 2 * scale, tealPaint);

        final polishedSteel = Paint()..color = const Color(0xFFC0CACD);
        final leftGreave = Rect.fromLTRB(bx(.34), by(.73), bx(.46), by(.88));
        final rightGreave = Rect.fromLTRB(bx(.54), by(.73), bx(.66), by(.88));
        canvas.drawRect(leftGreave, polishedSteel);
        canvas.drawRect(leftGreave, outline);
        canvas.drawRect(rightGreave, polishedSteel);
        canvas.drawRect(rightGreave, outline);

        final leftSabaton = Rect.fromLTRB(bx(.30), by(.88), bx(.46), by(.96));
        final rightSabaton = Rect.fromLTRB(bx(.54), by(.88), bx(.70), by(.96));
        canvas.drawRect(leftSabaton, polishedSteel);
        canvas.drawRect(
          leftSabaton,
          Paint()
            ..color = GamePalette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3 * scale,
        );
        canvas.drawRect(rightSabaton, polishedSteel);
        canvas.drawRect(
          rightSabaton,
          Paint()
            ..color = GamePalette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3 * scale,
        );
    }
  }

  @override
  bool shouldRepaint(FighterGearPainter oldDelegate) =>
      gear != oldDelegate.gear ||
      customBodyDestination != oldDelegate.customBodyDestination ||
      customHeadDestination != oldDelegate.customHeadDestination;
}

class FighterArt extends StatelessWidget {
  const FighterArt({
    super.key,
    required this.seed,
    required this.name,
    this.isPlayer = false,
    this.family = 'shortSword',
    this.status = '',
    this.portraitAsset,
    this.atlasAsset,
    this.atlasIndex,
    this.motionAtlasAsset,
    this.actionAtlasAsset,
    this.actionPose,
    this.motion = FighterMotion.idle,
    this.motionKey = 0,
    this.reducedMotion = false,
    this.customization,
    this.gear = const EquippedGearAppearance(),
  });
  final int seed;
  final String name;
  final bool isPlayer;
  final String family;
  final String status;
  final String? portraitAsset;
  final String? atlasAsset;
  final int? atlasIndex;
  final String? motionAtlasAsset;
  final String? actionAtlasAsset;
  final HeroActionPose? actionPose;
  final FighterMotion motion;
  final int motionKey;
  final bool reducedMotion;
  final HeroAppearanceSelection? customization;
  final EquippedGearAppearance gear;

  @override
  Widget build(BuildContext context) {
    final fallbackArt = _fallbackArt();
    final usesLayeredAppearance =
        (customization != null && !customization!.isDefault) ||
        gear.hasVisibleGear;
    final fighter = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 126,
          height: 156,
          child: motionAtlasAsset != null && !usesLayeredAppearance
              ? _FighterMotionAtlas(
                  asset: motionAtlasAsset!,
                  isPlayer: isPlayer,
                  actionAsset: actionAtlasAsset,
                  actionIndex: actionPose == null
                      ? null
                      : heroActionAtlasFrame(actionPose!),
                  motion: motion,
                  motionKey: motionKey,
                  reducedMotion: reducedMotion,
                  fallback: fallbackArt,
                )
              : fallbackArt,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xE6101719),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isPlayer ? GamePalette.teal : GamePalette.rust,
            ),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: GamePalette.parchment,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
    if (reducedMotion || motion == FighterMotion.idle || motionKey == 0) {
      return fighter;
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey('$seed:$motionKey'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: fighter,
      builder: (context, progress, child) {
        final pulse = math.sin(math.pi * progress);
        final direction = isPlayer ? 1.0 : -1.0;
        var dx = 0.0;
        var dy = 0.0;
        var angle = 0.0;
        var scale = 1.0;
        switch (motion) {
          case FighterMotion.idle:
            break;
          case FighterMotion.attack:
            dx = direction * 32 * pulse;
            dy = -6 * pulse;
            scale += .035 * pulse;
          case FighterMotion.hit:
            dx = -direction * 7 * math.sin(math.pi * 8 * progress) * pulse;
            dy = -3 * pulse;
            scale -= .045 * pulse;
          case FighterMotion.dodge:
            dx = -direction * 27 * pulse;
            dy = -4 * pulse;
          case FighterMotion.guard:
            dy = -4 * pulse;
            scale += .025 * pulse;
          case FighterMotion.spell:
            angle = direction * .035 * pulse;
            dy = -7 * pulse;
            scale += .06 * pulse;
          case FighterMotion.status:
            dx = 4 * math.sin(math.pi * 6 * progress) * pulse;
          case FighterMotion.heal:
            dy = -12 * pulse;
            scale += .05 * pulse;
          case FighterMotion.resource:
            dy = -8 * pulse;
            scale += .035 * pulse;
          case FighterMotion.move:
            dx = direction * 12 * pulse;
          case FighterMotion.phase:
            dy = -8 * pulse;
            scale += .08 * pulse;
          case FighterMotion.victory:
            dy = -18 * pulse;
            scale += .08 * pulse;
          case FighterMotion.defeat:
            dy = 10 * progress;
            scale -= .07 * progress;
        }
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }

  Widget _fallbackArt() {
    if (customization != null || (isPlayer && gear.hasVisibleGear)) {
      return HeroCustomizationArt(
        selection: customization ?? const HeroAppearanceSelection(),
        gear: gear,
      );
    }
    if (portraitAsset != null) {
      return Image.asset(
        portraitAsset!,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) => CustomPaint(
          painter: _FighterPainter(
            seed: seed,
            isPlayer: isPlayer,
            family: family,
            status: status,
          ),
        ),
      );
    }
    if (atlasAsset != null && atlasIndex != null) {
      return _AtlasPortrait(asset: atlasAsset!, index: atlasIndex!);
    }
    return CustomPaint(
      painter: _FighterPainter(
        seed: seed,
        isPlayer: isPlayer,
        family: family,
        status: status,
      ),
    );
  }
}

class _FighterMotionAtlas extends StatelessWidget {
  const _FighterMotionAtlas({
    required this.asset,
    required this.isPlayer,
    required this.actionAsset,
    required this.actionIndex,
    required this.motion,
    required this.motionKey,
    required this.reducedMotion,
    required this.fallback,
  });

  final String asset;
  final bool isPlayer;
  final String? actionAsset;
  final int? actionIndex;
  final FighterMotion motion;
  final int motionKey;
  final bool reducedMotion;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image>(
    future: _AtlasPortrait._decodedImages.putIfAbsent(
      asset,
      () => _AtlasPortrait._decode(asset),
    ),
    builder: (context, snapshot) {
      final image = snapshot.data;
      if (image == null) {
        return fallback;
      }
      if (reducedMotion || motionKey == 0 || motion == FighterMotion.idle) {
        return CustomPaint(painter: _BattleMotionAtlasPainter(image, 0));
      }
      if (actionAsset != null && actionIndex != null) {
        return FutureBuilder<ui.Image>(
          future: _AtlasPortrait._decodedImages.putIfAbsent(
            actionAsset!,
            () => _AtlasPortrait._decode(actionAsset!),
          ),
          builder: (context, actionSnapshot) {
            final actionImage = actionSnapshot.data;
            if (actionImage == null) {
              return TweenAnimationBuilder<double>(
                key: ValueKey('$asset:$motionKey:${motion.name}'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.linear,
                builder: (context, progress, _) => CustomPaint(
                  painter: _BattleMotionAtlasPainter(
                    image,
                    _motionFrame(progress),
                  ),
                ),
              );
            }
            final isDefeat =
                actionIndex == heroActionAtlasFrame(HeroActionPose.defeat);
            return TweenAnimationBuilder<double>(
              key: ValueKey('$actionAsset:$motionKey:${motion.name}'),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.linear,
              builder: (context, progress, _) => CustomPaint(
                painter: progress < 1 || isDefeat
                    ? _HeroActionAtlasPainter(actionImage, actionIndex!)
                    : _BattleMotionAtlasPainter(image, 0),
              ),
            );
          },
        );
      }
      return TweenAnimationBuilder<double>(
        key: ValueKey('$asset:$motionKey:${motion.name}'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.linear,
        builder: (context, progress, _) => CustomPaint(
          painter: _BattleMotionAtlasPainter(image, _motionFrame(progress)),
        ),
      );
    },
  );

  int _motionFrame(double progress) => isPlayer
      ? heroMotionAtlasFrame(motion, progress)
      : rivalMotionAtlasFrame(motion, progress);
}

class _HeroActionAtlasPainter extends CustomPainter {
  const _HeroActionAtlasPainter(this.image, this.index);

  final ui.Image image;
  final int index;

  static const _rowSplit = 459 / 887;

  @override
  void paint(Canvas canvas, Size size) {
    if (index < 0 || index >= 8) return;
    const columns = 4;
    final cellWidth = image.width / columns;
    final column = index % columns;
    final row = index ~/ columns;
    final rowSplit = image.height * _rowSplit;
    final sourceTop = row == 0 ? 0.0 : rowSplit;
    final sourceHeight = row == 0 ? rowSplit : image.height - rowSplit;
    final source = Rect.fromLTWH(
      column * cellWidth,
      sourceTop,
      cellWidth,
      sourceHeight,
    );
    // The generated top row extends 16 px below the nominal half-height line.
    // Crop at the transparent gap and normalize both rows to the same square.
    final fit = applyBoxFit(BoxFit.contain, Size.square(cellWidth), size);
    final destination = Alignment.bottomCenter.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_HeroActionAtlasPainter oldDelegate) =>
      !identical(image, oldDelegate.image) || index != oldDelegate.index;
}

class _BattleMotionAtlasPainter extends CustomPainter {
  const _BattleMotionAtlasPainter(this.image, this.index);

  final ui.Image image;
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    if (index < 0 || index >= 6) return;
    const columns = 3;
    const rows = 2;
    final cellSize = Size(image.width / columns, image.height / rows);
    final column = index % columns;
    final row = index ~/ columns;
    final source = Rect.fromLTWH(
      column * cellSize.width,
      row * cellSize.height,
      cellSize.width,
      cellSize.height,
    );
    final fit = applyBoxFit(BoxFit.contain, source.size, size);
    final destination = Alignment.bottomCenter.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_BattleMotionAtlasPainter oldDelegate) =>
      !identical(image, oldDelegate.image) || index != oldDelegate.index;
}

class _AtlasPortrait extends StatelessWidget {
  const _AtlasPortrait({required this.asset, required this.index});

  static final Map<String, Future<ui.Image>> _decodedImages = {};

  final String asset;
  final int index;

  static Future<ui.Image> _decode(String asset) async {
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image>(
    future: _decodedImages.putIfAbsent(asset, () => _decode(asset)),
    builder: (context, snapshot) {
      final image = snapshot.data;
      if (image == null) return const SizedBox.shrink();
      return CustomPaint(painter: _AtlasPortraitPainter(image, index));
    },
  );
}

class _AtlasPortraitPainter extends CustomPainter {
  const _AtlasPortraitPainter(this.image, this.index);

  final ui.Image image;
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    if (index < 0 || index >= 8) return;
    const columns = 4;
    final cellSize = Size(image.width / columns, image.height / 2);
    final column = index % columns;
    final row = index ~/ columns;
    final source = Rect.fromLTWH(
      column * cellSize.width,
      row * cellSize.height,
      cellSize.width,
      cellSize.height,
    );
    final fit = applyBoxFit(BoxFit.contain, source.size, size);
    final destination = Alignment.bottomCenter.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_AtlasPortraitPainter oldDelegate) =>
      !identical(image, oldDelegate.image) || index != oldDelegate.index;
}

class _FighterPainter extends CustomPainter {
  _FighterPainter({
    required this.seed,
    required this.isPlayer,
    required this.family,
    required this.status,
  });
  final int seed;
  final bool isPlayer;
  final String family;
  final String status;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = isPlayer
        ? [
            GamePalette.teal,
            GamePalette.rust,
            GamePalette.mana,
            GamePalette.gold,
          ][seed % 4]
        : Color.lerp(GamePalette.rust, GamePalette.gold, (seed % 5) / 5)!;
    final dark = const Color(0xFF182124);
    final outline = Paint()
      ..color = const Color(0xFF0D1214)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = accent;
    final cloth = Paint()..color = Color.lerp(accent, dark, .35)!;
    final metal = Paint()..color = const Color(0xFFD4C7A7);
    final x = size.width / 2;
    final groundY = size.height * .94;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, groundY), width: 75, height: 14),
      Paint()..color = const Color(0x55000000),
    );
    canvas.drawLine(
      Offset(x - 18, size.height * .73),
      Offset(x - 27, groundY - 3),
      outline,
    );
    canvas.drawLine(
      Offset(x + 17, size.height * .73),
      Offset(x + 29, groundY - 3),
      outline,
    );
    canvas.drawLine(
      Offset(x - 18, size.height * .73),
      Offset(x - 27, groundY - 3),
      Paint()
        ..color = dark
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(x + 17, size.height * .73),
      Offset(x + 29, groundY - 3),
      Paint()
        ..color = dark
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );
    final torso = Path()
      ..moveTo(x - 24, size.height * .38)
      ..quadraticBezierTo(x, size.height * .30, x + 24, size.height * .38)
      ..lineTo(x + 21, size.height * .76)
      ..quadraticBezierTo(x, size.height * .83, x - 21, size.height * .76)
      ..close();
    canvas.drawPath(torso, cloth);
    canvas.drawPath(torso, outline);
    canvas.drawLine(
      Offset(x - 21, size.height * .43),
      Offset(x - 35, size.height * .67),
      outline,
    );
    canvas.drawLine(
      Offset(x + 21, size.height * .43),
      Offset(x + 37, size.height * .59),
      outline,
    );
    canvas.drawLine(
      Offset(x - 21, size.height * .43),
      Offset(x - 35, size.height * .67),
      Paint()
        ..color = accent
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(x + 21, size.height * .43),
      Offset(x + 37, size.height * .59),
      Paint()
        ..color = accent
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(x, size.height * .27), 23, fill);
    canvas.drawCircle(Offset(x, size.height * .27), 23, outline);
    final helmet = Path()
      ..moveTo(x - 22, size.height * .29)
      ..quadraticBezierTo(x - 20, size.height * .08, x + 2, size.height * .10)
      ..quadraticBezierTo(x + 23, size.height * .12, x + 22, size.height * .28)
      ..lineTo(x + 12, size.height * .23)
      ..lineTo(x - 8, size.height * .23)
      ..close();
    canvas.drawPath(helmet, Paint()..color = dark);
    canvas.drawPath(helmet, outline);
    canvas.drawLine(
      Offset(x - 9, size.height * .28),
      Offset(x + 8, size.height * .28),
      Paint()
        ..color = GamePalette.gold
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    if (family == 'maul') {
      canvas.drawLine(
        Offset(x + 37, size.height * .59),
        Offset(x + 45, size.height * .26),
        outline,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x + 45, size.height * .23),
          width: 22,
          height: 17,
        ),
        fill,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x + 45, size.height * .23),
          width: 22,
          height: 17,
        ),
        outline,
      );
    } else if (family == 'spear') {
      canvas.drawLine(
        Offset(x + 39, size.height * .68),
        Offset(x + 45, size.height * .04),
        Paint()
          ..color = const Color(0xFFD2C6AA)
          ..strokeWidth = 4,
      );
      final tip = Path()
        ..moveTo(x + 45, size.height * .01)
        ..lineTo(x + 55, size.height * .10)
        ..lineTo(x + 45, size.height * .08)
        ..close();
      canvas.drawPath(tip, metal);
    } else if (family == 'bow') {
      final bow = Path()
        ..moveTo(x + 37, size.height * .29)
        ..quadraticBezierTo(
          x + 71,
          size.height * .46,
          x + 37,
          size.height * .67,
        );
      canvas.drawPath(
        bow,
        Paint()
          ..color = GamePalette.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
      canvas.drawLine(
        Offset(x + 37, size.height * .29),
        Offset(x + 37, size.height * .67),
        Paint()
          ..color = GamePalette.parchment
          ..strokeWidth = 1.5,
      );
    } else {
      canvas.drawLine(
        Offset(x + 40, size.height * .62),
        Offset(x + 54, size.height * .34),
        Paint()
          ..color = GamePalette.parchment
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(x + 52, size.height * .35),
        Offset(x + 61, size.height * .30),
        Paint()
          ..color = GamePalette.gold
          ..strokeWidth = 3,
      );
    }
    if (status.isNotEmpty) {
      canvas.drawCircle(
        Offset(x, 8),
        6,
        Paint()..color = status == 'burn' ? GamePalette.rust : GamePalette.gold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FighterPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.isPlayer != isPlayer ||
      oldDelegate.family != family ||
      oldDelegate.status != status;
}

Color chapterColor(int chapter) => switch (chapter) {
  1 => GamePalette.teal,
  2 => const Color(0xFFE58C4E),
  3 => const Color(0xFF76A6C8),
  _ => GamePalette.gold,
};
