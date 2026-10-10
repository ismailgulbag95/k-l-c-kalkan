import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/models.dart';
import '../l10n/game_localizations.dart';
import 'design.dart';

/// Distinct custom glyph identifiers for the Kül Çemberi UI.
enum GameGlyphKind {
  campaign,
  arena,
  fighter,
  shop,
  champions,
  settings,
  coin,
  health,
  stamina,
  weapon,
  armor,
  guard,
  magic,
  supply,
  statusStagger,
  statusBleed,
  statusBurn,
  statusBrokenGuard,
  audienceTactics,
  audienceAnswerAttack,
  audienceAvoidHazard,
  audienceChangeRange,
}

/// Resolves a stable default semantic label for [kind], using localized game
/// strings when available and falling back to clean static labels.
String defaultGlyphSemanticLabel(BuildContext? context, GameGlyphKind kind) {
  if (context != null) {
    try {
      final key = switch (kind) {
        GameGlyphKind.campaign || GameGlyphKind.arena => 'ui.nav.league',
        GameGlyphKind.fighter => 'ui.nav.fighter',
        GameGlyphKind.shop => 'ui.nav.shop',
        GameGlyphKind.champions => 'ui.nav.contracts',
        GameGlyphKind.settings => 'ui.nav.settings',
        GameGlyphKind.health => 'ui.resource.health',
        GameGlyphKind.stamina => 'ui.resource.effort',
        GameGlyphKind.magic => 'ui.resource.mana',
        GameGlyphKind.weapon => 'ui.filter.weapon',
        GameGlyphKind.armor => 'ui.filter.armor',
        GameGlyphKind.guard => 'label.stat.guard',
        GameGlyphKind.supply => 'ui.filter.supplies',
        GameGlyphKind.coin => null,
        GameGlyphKind.statusStagger => 'label.status.stagger',
        GameGlyphKind.statusBleed => 'label.status.bleed',
        GameGlyphKind.statusBurn => 'label.status.burn',
        GameGlyphKind.statusBrokenGuard => 'label.status.brokenGuard',
        GameGlyphKind.audienceTactics => 'battle.audience.tactics',
        GameGlyphKind.audienceAnswerAttack => 'battle.audience.answerAttack',
        GameGlyphKind.audienceAvoidHazard => 'battle.audience.avoidHazard',
        GameGlyphKind.audienceChangeRange => 'battle.audience.changeRange',
      };
      if (key != null) {
        return gameText(context, key);
      }
    } catch (_) {
      // Fallback below if context lacks localization resources.
    }
  }

  return switch (kind) {
    GameGlyphKind.campaign => 'Lig',
    GameGlyphKind.arena => 'Arena',
    GameGlyphKind.fighter => 'Dövüşçü',
    GameGlyphKind.shop => 'Dükkân',
    GameGlyphKind.champions => 'Sözleşme',
    GameGlyphKind.settings => 'Ayarlar',
    GameGlyphKind.coin => 'Altın',
    GameGlyphKind.health => 'SAĞLIK',
    GameGlyphKind.stamina => 'EFOR',
    GameGlyphKind.weapon => 'Silah',
    GameGlyphKind.armor => 'Zırh',
    GameGlyphKind.guard => 'Savunma',
    GameGlyphKind.magic => 'MANA',
    GameGlyphKind.supply => 'Sarf',
    GameGlyphKind.statusStagger => 'Sendeleme',
    GameGlyphKind.statusBleed => 'Kanama',
    GameGlyphKind.statusBurn => 'Yanma',
    GameGlyphKind.statusBrokenGuard => 'Kırık gard',
    GameGlyphKind.audienceTactics => 'En az iki farklı taktik yaklaşım kullan',
    GameGlyphKind.audienceAnswerAttack =>
      'Gösterilen saldırı niyetine gardla karşılık ver',
    GameGlyphKind.audienceAvoidHazard =>
      'Arena tehlikesinden hasar almadan çık',
    GameGlyphKind.audienceChangeRange => 'Mesafeyi en az bir kez değiştir',
  };
}

/// Maps a [StatusKind] to its corresponding [GameGlyphKind].
GameGlyphKind glyphForStatusKind(
  StatusKind? status, {
  GameGlyphKind fallback = GameGlyphKind.statusStagger,
}) {
  return switch (status) {
    StatusKind.stagger => GameGlyphKind.statusStagger,
    StatusKind.bleed => GameGlyphKind.statusBleed,
    StatusKind.burn => GameGlyphKind.statusBurn,
    StatusKind.brokenGuard => GameGlyphKind.statusBrokenGuard,
    null => fallback,
  };
}

/// Maps a status enum name or identifier string to its corresponding [GameGlyphKind].
GameGlyphKind glyphForStatusId(
  String? id, {
  GameGlyphKind fallback = GameGlyphKind.statusStagger,
}) {
  return switch (id) {
    'stagger' || 'label.status.stagger' => GameGlyphKind.statusStagger,
    'bleed' || 'label.status.bleed' => GameGlyphKind.statusBleed,
    'burn' || 'label.status.burn' => GameGlyphKind.statusBurn,
    'brokenGuard' ||
    'label.status.brokenGuard' => GameGlyphKind.statusBrokenGuard,
    _ => fallback,
  };
}

/// Generic status-to-glyph resolver accepting either a [StatusKind] or a [String].
GameGlyphKind glyphForStatus(
  Object? status, {
  GameGlyphKind fallback = GameGlyphKind.statusStagger,
}) {
  if (status is StatusKind) {
    return glyphForStatusKind(status, fallback: fallback);
  }
  if (status is String) {
    return glyphForStatusId(status, fallback: fallback);
  }
  return fallback;
}

/// Returns the specific audience glyph if [id] is known, or null if unknown.
GameGlyphKind? tryAudienceGlyphForMessageId(String? id) {
  return switch (id) {
    'battle.audience.tactics' => GameGlyphKind.audienceTactics,
    'battle.audience.answerAttack' => GameGlyphKind.audienceAnswerAttack,
    'battle.audience.avoidHazard' => GameGlyphKind.audienceAvoidHazard,
    'battle.audience.changeRange' => GameGlyphKind.audienceChangeRange,
    _ => null,
  };
}

/// Maps an audience criterion message ID to its corresponding [GameGlyphKind].
///
/// Returns [fallback] (defaults to [GameGlyphKind.arena]) for unknown message IDs.
GameGlyphKind audienceGlyphForMessageId(
  String? id, {
  GameGlyphKind fallback = GameGlyphKind.arena,
}) => tryAudienceGlyphForMessageId(id) ?? fallback;

/// Alias for [audienceGlyphForMessageId] for callers resolving by rule ID.
GameGlyphKind glyphForAudienceRule(
  String? messageId, {
  GameGlyphKind fallback = GameGlyphKind.arena,
}) => audienceGlyphForMessageId(messageId, fallback: fallback);

/// A focused, original vector glyph drawn with [CustomPainter].
///
/// Adheres to the Kül Çemberi line weight, color palette, and high-contrast
/// readability. Supports selection states and screen-reader semantics.
class GameGlyph extends StatelessWidget {
  const GameGlyph(
    this.kind, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 1.8,
    this.selected = false,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final GameGlyphKind kind;
  final double? size;
  final Color? color;
  final double strokeWidth;
  final bool selected;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = size ?? iconTheme.size ?? 24.0;
    final effectiveColor = color ?? iconTheme.color ?? GamePalette.parchment;

    final glyphCanvas = SizedBox.square(
      dimension: effectiveSize,
      child: CustomPaint(
        size: Size.square(effectiveSize),
        painter: _GameGlyphPainter(
          kind: kind,
          color: effectiveColor,
          strokeWidth: strokeWidth,
          selected: selected,
        ),
      ),
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: glyphCanvas);
    }

    final effectiveLabel =
        semanticLabel ?? defaultGlyphSemanticLabel(context, kind);
    if (effectiveLabel.isEmpty) {
      return ExcludeSemantics(child: glyphCanvas);
    }

    return Semantics(
      label: effectiveLabel,
      container: true,
      child: glyphCanvas,
    );
  }
}

class _GameGlyphPainter extends CustomPainter {
  const _GameGlyphPainter({
    required this.kind,
    required this.color,
    required this.strokeWidth,
    required this.selected,
  });

  final GameGlyphKind kind;
  final Color color;
  final double strokeWidth;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final scale = math.min(size.width, size.height) / 24.0;
    canvas.scale(scale, scale);
    canvas.translate(-12, -12);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: selected ? 0.32 : 0.08)
      ..style = PaintingStyle.fill;

    switch (kind) {
      case GameGlyphKind.campaign:
        _paintCampaign(canvas, strokePaint, fillPaint);
      case GameGlyphKind.arena:
        _paintArena(canvas, strokePaint, fillPaint);
      case GameGlyphKind.fighter:
        _paintFighter(canvas, strokePaint, fillPaint);
      case GameGlyphKind.shop:
        _paintShop(canvas, strokePaint, fillPaint);
      case GameGlyphKind.champions:
        _paintChampions(canvas, strokePaint, fillPaint);
      case GameGlyphKind.settings:
        _paintSettings(canvas, strokePaint, fillPaint);
      case GameGlyphKind.coin:
        _paintCoin(canvas, strokePaint, fillPaint);
      case GameGlyphKind.health:
        _paintHealth(canvas, strokePaint, fillPaint);
      case GameGlyphKind.stamina:
        _paintStamina(canvas, strokePaint, fillPaint);
      case GameGlyphKind.weapon:
        _paintWeapon(canvas, strokePaint, fillPaint);
      case GameGlyphKind.armor:
        _paintArmor(canvas, strokePaint, fillPaint);
      case GameGlyphKind.guard:
        _paintGuard(canvas, strokePaint, fillPaint);
      case GameGlyphKind.magic:
        _paintMagic(canvas, strokePaint, fillPaint);
      case GameGlyphKind.supply:
        _paintSupply(canvas, strokePaint, fillPaint);
      case GameGlyphKind.statusStagger:
        _paintStatusStagger(canvas, strokePaint, fillPaint);
      case GameGlyphKind.statusBleed:
        _paintStatusBleed(canvas, strokePaint, fillPaint);
      case GameGlyphKind.statusBurn:
        _paintStatusBurn(canvas, strokePaint, fillPaint);
      case GameGlyphKind.statusBrokenGuard:
        _paintStatusBrokenGuard(canvas, strokePaint, fillPaint);
      case GameGlyphKind.audienceTactics:
        _paintAudienceTactics(canvas, strokePaint, fillPaint);
      case GameGlyphKind.audienceAnswerAttack:
        _paintAudienceAnswerAttack(canvas, strokePaint, fillPaint);
      case GameGlyphKind.audienceAvoidHazard:
        _paintAudienceAvoidHazard(canvas, strokePaint, fillPaint);
      case GameGlyphKind.audienceChangeRange:
        _paintAudienceChangeRange(canvas, strokePaint, fillPaint);
    }

    canvas.restore();
  }

  void _paintCampaign(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawLine(const Offset(2.5, 21), const Offset(21.5, 21), stroke);

    final arch = Path()
      ..moveTo(4.5, 21)
      ..lineTo(4.5, 10.5)
      ..cubicTo(4.5, 5.0, 8.0, 3.0, 12.0, 3.0)
      ..cubicTo(16.0, 3.0, 19.5, 5.0, 19.5, 10.5)
      ..lineTo(19.5, 21);
    canvas.drawPath(arch, stroke);

    final portal = Path()
      ..moveTo(7.5, 21)
      ..lineTo(7.5, 12.0)
      ..cubicTo(7.5, 8.5, 9.5, 6.5, 12.0, 6.5)
      ..cubicTo(14.5, 6.5, 16.5, 8.5, 16.5, 12.0)
      ..lineTo(16.5, 21)
      ..close();

    if (selected) {
      canvas.drawPath(portal, fill);
    }
    canvas.drawPath(portal, stroke);

    final keystone = Path()
      ..moveTo(10.5, 2.5)
      ..lineTo(13.5, 2.5)
      ..lineTo(12.8, 6.5)
      ..lineTo(11.2, 6.5)
      ..close();
    canvas.drawPath(keystone, selected ? fill : stroke);

    canvas.drawCircle(const Offset(12, 12), 1.8, stroke);
  }

  void _paintArena(Canvas canvas, Paint stroke, Paint fill) {
    final outerRect = Rect.fromCenter(
      center: const Offset(12, 12),
      width: 18,
      height: 14,
    );
    final innerRect = Rect.fromCenter(
      center: const Offset(12, 12),
      width: 10,
      height: 7,
    );

    if (selected) {
      canvas.drawOval(outerRect, fill);
    }
    canvas.drawOval(outerRect, stroke);
    canvas.drawOval(innerRect, stroke);

    canvas.drawLine(const Offset(12, 3), const Offset(12, 5), stroke);
    canvas.drawLine(const Offset(12, 19), const Offset(12, 21), stroke);
    canvas.drawLine(const Offset(1.5, 12), const Offset(3, 12), stroke);
    canvas.drawLine(const Offset(21, 12), const Offset(22.5, 12), stroke);

    canvas.drawLine(const Offset(10, 10.5), const Offset(14, 13.5), stroke);
    canvas.drawLine(const Offset(14, 10.5), const Offset(10, 13.5), stroke);
  }

  void _paintFighter(Canvas canvas, Paint stroke, Paint fill) {
    final plume = Path()
      ..moveTo(12, 2)
      ..lineTo(9.5, 6)
      ..lineTo(14.5, 6)
      ..close();
    canvas.drawPath(plume, fill);
    canvas.drawPath(plume, stroke);

    final helmet = Path()
      ..moveTo(5.5, 11.5)
      ..cubicTo(5.5, 5.5, 18.5, 5.5, 18.5, 11.5)
      ..lineTo(17.5, 18.5)
      ..lineTo(13.5, 21.5)
      ..lineTo(10.5, 21.5)
      ..lineTo(6.5, 18.5)
      ..close();

    if (selected) {
      canvas.drawPath(helmet, fill);
    }
    canvas.drawPath(helmet, stroke);

    canvas.drawLine(const Offset(7.5, 12), const Offset(16.5, 12), stroke);
    canvas.drawLine(const Offset(12, 12), const Offset(12, 18.5), stroke);
  }

  void _paintShop(Canvas canvas, Paint stroke, Paint fill) {
    final canopy = Path()
      ..moveTo(3, 9.5)
      ..lineTo(12, 3.5)
      ..lineTo(21, 9.5)
      ..close();

    if (selected) {
      canvas.drawPath(canopy, fill);
    }
    canvas.drawPath(canopy, stroke);

    final fringe = Path()
      ..moveTo(3, 9.5)
      ..quadraticBezierTo(6, 12, 9, 9.5)
      ..quadraticBezierTo(12, 12, 15, 9.5)
      ..quadraticBezierTo(18, 12, 21, 9.5);
    canvas.drawPath(fringe, stroke);

    canvas.drawLine(const Offset(4.5, 15.5), const Offset(19.5, 15.5), stroke);
    canvas.drawLine(const Offset(6, 15.5), const Offset(6, 21), stroke);
    canvas.drawLine(const Offset(18, 15.5), const Offset(18, 21), stroke);

    canvas.drawCircle(const Offset(12, 12.5), 1.6, stroke);
  }

  void _paintChampions(Canvas canvas, Paint stroke, Paint fill) {
    final bowl = Path()
      ..moveTo(6, 5)
      ..lineTo(18, 5)
      ..cubicTo(18, 12.5, 15, 15, 12, 15)
      ..cubicTo(9, 15, 6, 12.5, 6, 5)
      ..close();

    if (selected) {
      canvas.drawPath(bowl, fill);
    }
    canvas.drawPath(bowl, stroke);

    final leftHandle = Path()
      ..moveTo(6, 7)
      ..cubicTo(2.5, 7.5, 2.5, 11.5, 7.5, 12.5);
    canvas.drawPath(leftHandle, stroke);

    final rightHandle = Path()
      ..moveTo(18, 7)
      ..cubicTo(21.5, 7.5, 21.5, 11.5, 16.5, 12.5);
    canvas.drawPath(rightHandle, stroke);

    canvas.drawLine(const Offset(12, 15), const Offset(12, 18.5), stroke);
    canvas.drawLine(const Offset(9, 18.5), const Offset(15, 18.5), stroke);
    canvas.drawLine(const Offset(6.5, 21), const Offset(17.5, 21), stroke);

    final star = Path()
      ..moveTo(12, 7.5)
      ..lineTo(13.2, 9.5)
      ..lineTo(12, 11.5)
      ..lineTo(10.8, 9.5)
      ..close();
    canvas.drawPath(star, stroke);
  }

  void _paintSettings(Canvas canvas, Paint stroke, Paint fill) {
    const center = Offset(12, 12);
    const outerR = 9.2;
    const innerR = 6.8;
    const hubR = 3.0;

    final gear = Path();
    const teeth = 6;
    const step = (math.pi * 2) / teeth;
    const toothWidth = step * 0.28;

    for (int i = 0; i < teeth; i++) {
      final a = i * step;
      final a1 = a - toothWidth;
      final a2 = a + toothWidth;
      final a3 = a + step * 0.5 - toothWidth;

      if (i == 0) {
        gear.moveTo(
          center.dx + innerR * math.cos(a1),
          center.dy + innerR * math.sin(a1),
        );
      } else {
        gear.lineTo(
          center.dx + innerR * math.cos(a1),
          center.dy + innerR * math.sin(a1),
        );
      }
      gear.lineTo(
        center.dx + outerR * math.cos(a1),
        center.dy + outerR * math.sin(a1),
      );
      gear.lineTo(
        center.dx + outerR * math.cos(a2),
        center.dy + outerR * math.sin(a2),
      );
      gear.lineTo(
        center.dx + innerR * math.cos(a2),
        center.dy + innerR * math.sin(a2),
      );
      gear.lineTo(
        center.dx + innerR * math.cos(a3),
        center.dy + innerR * math.sin(a3),
      );
    }
    gear.close();

    if (selected) {
      canvas.drawPath(gear, fill);
    }
    canvas.drawPath(gear, stroke);
    canvas.drawCircle(center, hubR, stroke);
  }

  void _paintCoin(Canvas canvas, Paint stroke, Paint fill) {
    const center = Offset(12, 12);
    if (selected) {
      canvas.drawCircle(center, 8.5, fill);
    }
    canvas.drawCircle(center, 8.5, stroke);
    canvas.drawCircle(center, 6.5, stroke);

    final diamond = Path()
      ..moveTo(12, 7.5)
      ..lineTo(16.5, 12)
      ..lineTo(12, 16.5)
      ..lineTo(7.5, 12)
      ..close();
    canvas.drawPath(diamond, stroke);
    canvas.drawCircle(center, 1.2, stroke);
  }

  void _paintHealth(Canvas canvas, Paint stroke, Paint fill) {
    final heart = Path()
      ..moveTo(12, 7.5)
      ..cubicTo(11, 4.2, 6.5, 3.8, 4.5, 6.8)
      ..cubicTo(2.8, 9.5, 4.0, 12.8, 7.5, 16.0)
      ..lineTo(12, 20.5)
      ..lineTo(16.5, 16.0)
      ..cubicTo(20.0, 12.8, 21.2, 9.5, 19.5, 6.8)
      ..cubicTo(17.5, 3.8, 13, 4.2, 12, 7.5)
      ..close();

    if (selected) {
      canvas.drawPath(heart, fill);
    }
    canvas.drawPath(heart, stroke);

    canvas.drawLine(const Offset(9.5, 11), const Offset(14.5, 11), stroke);
    canvas.drawLine(const Offset(12, 8.5), const Offset(12, 13.5), stroke);
  }

  void _paintStamina(Canvas canvas, Paint stroke, Paint fill) {
    final bolt = Path()
      ..moveTo(13.5, 2.5)
      ..lineTo(6.5, 12.0)
      ..lineTo(12.0, 12.0)
      ..lineTo(9.5, 21.5)
      ..lineTo(17.5, 10.5)
      ..lineTo(12.0, 10.5)
      ..close();

    if (selected) {
      canvas.drawPath(bolt, fill);
    }
    canvas.drawPath(bolt, stroke);
  }

  void _paintWeapon(Canvas canvas, Paint stroke, Paint fill) {
    // Sword 1 (top-left to bottom-right)
    canvas.drawLine(const Offset(4.5, 4.5), const Offset(16.5, 16.5), stroke);
    canvas.drawLine(const Offset(14.5, 18.0), const Offset(18.0, 14.5), stroke);
    canvas.drawCircle(const Offset(19.0, 19.0), 1.2, stroke);

    // Sword 2 (top-right to bottom-left)
    canvas.drawLine(const Offset(19.5, 4.5), const Offset(7.5, 16.5), stroke);
    canvas.drawLine(const Offset(6.0, 14.5), const Offset(9.5, 18.0), stroke);
    canvas.drawCircle(const Offset(5.0, 19.0), 1.2, stroke);

    // Blade tip accents
    canvas.drawLine(const Offset(4.5, 4.5), const Offset(4.5, 7.0), stroke);
    canvas.drawLine(const Offset(4.5, 4.5), const Offset(7.0, 4.5), stroke);
    canvas.drawLine(const Offset(19.5, 4.5), const Offset(19.5, 7.0), stroke);
    canvas.drawLine(const Offset(19.5, 4.5), const Offset(17.0, 4.5), stroke);

    final crossDiamond = Path()
      ..moveTo(12, 10.5)
      ..lineTo(13.5, 12)
      ..lineTo(12, 13.5)
      ..lineTo(10.5, 12)
      ..close();
    canvas.drawPath(crossDiamond, selected ? fill : stroke);
  }

  void _paintArmor(Canvas canvas, Paint stroke, Paint fill) {
    final cuirass = Path()
      ..moveTo(9, 4.5)
      ..lineTo(4.5, 7.5)
      ..cubicTo(4.5, 13, 6, 17, 7, 20.5)
      ..quadraticBezierTo(12, 19.5, 17, 20.5)
      ..cubicTo(18, 17, 19.5, 13, 19.5, 7.5)
      ..lineTo(15, 4.5)
      ..quadraticBezierTo(12, 6.5, 9, 4.5)
      ..close();

    if (selected) {
      canvas.drawPath(cuirass, fill);
    }
    canvas.drawPath(cuirass, stroke);

    canvas.drawLine(const Offset(12, 6.5), const Offset(12, 18.5), stroke);
    final chestLine = Path()
      ..moveTo(7.5, 11)
      ..quadraticBezierTo(12, 13, 16.5, 11);
    canvas.drawPath(chestLine, stroke);
  }

  void _paintGuard(Canvas canvas, Paint stroke, Paint fill) {
    final shield = Path()
      ..moveTo(5, 4.5)
      ..lineTo(19, 4.5)
      ..lineTo(19, 12.0)
      ..cubicTo(19, 17.5, 15, 20.5, 12, 21.5)
      ..cubicTo(9, 20.5, 5, 17.5, 5, 12.0)
      ..close();

    if (selected) {
      canvas.drawPath(shield, fill);
    }
    canvas.drawPath(shield, stroke);

    canvas.drawLine(const Offset(12, 4.5), const Offset(12, 21), stroke);
    canvas.drawCircle(const Offset(12, 11.5), 2.4, stroke);
  }

  void _paintMagic(Canvas canvas, Paint stroke, Paint fill) {
    final star = Path()
      ..moveTo(12, 2.5)
      ..lineTo(13.8, 10.2)
      ..lineTo(21.5, 12)
      ..lineTo(13.8, 13.8)
      ..lineTo(12, 21.5)
      ..lineTo(10.2, 13.8)
      ..lineTo(2.5, 12)
      ..lineTo(10.2, 10.2)
      ..close();

    if (selected) {
      canvas.drawPath(star, fill);
    }
    canvas.drawPath(star, stroke);

    canvas.drawLine(const Offset(6.5, 6.5), const Offset(8, 8), stroke);
    canvas.drawLine(const Offset(17.5, 6.5), const Offset(16, 8), stroke);
    canvas.drawLine(const Offset(17.5, 17.5), const Offset(16, 16), stroke);
    canvas.drawLine(const Offset(6.5, 17.5), const Offset(8, 16), stroke);

    canvas.drawCircle(const Offset(12, 12), 1.8, stroke);
  }

  void _paintSupply(Canvas canvas, Paint stroke, Paint fill) {
    final handle = Path()
      ..moveTo(9, 7.5)
      ..cubicTo(9, 4, 15, 4, 15, 7.5);
    canvas.drawPath(handle, stroke);

    final body = RRect.fromRectAndRadius(
      const Rect.fromLTRB(5, 7.5, 19, 21),
      const Radius.circular(3.5),
    );

    if (selected) {
      canvas.drawRRect(body, fill);
    }
    canvas.drawRRect(body, stroke);

    final flap = Path()
      ..moveTo(5, 10)
      ..lineTo(12, 14.5)
      ..lineTo(19, 10);
    canvas.drawPath(flap, stroke);

    canvas.drawLine(const Offset(12, 7.5), const Offset(12, 19.5), stroke);

    final buckle = Rect.fromCenter(
      center: const Offset(12, 14.5),
      width: 3.5,
      height: 3.5,
    );
    canvas.drawRect(buckle, stroke);
  }

  void _paintStatusStagger(Canvas canvas, Paint stroke, Paint fill) {
    // Central impact diamond / dazed spark
    final star = Path()
      ..moveTo(12, 7)
      ..lineTo(13.8, 10.2)
      ..lineTo(17, 12)
      ..lineTo(13.8, 13.8)
      ..lineTo(12, 17)
      ..lineTo(10.2, 13.8)
      ..lineTo(7, 12)
      ..lineTo(10.2, 10.2)
      ..close();
    if (selected) {
      canvas.drawPath(star, fill);
    }
    canvas.drawPath(star, stroke);

    // Orbiting dizzy / dazed arcs
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12, 12), radius: 8.5),
      -math.pi * 0.85,
      math.pi * 0.65,
      false,
      stroke,
    );
    canvas.drawCircle(const Offset(18.5, 7.5), 1.3, stroke);

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12, 12), radius: 8.5),
      math.pi * 0.15,
      math.pi * 0.65,
      false,
      stroke,
    );
    canvas.drawCircle(const Offset(5.5, 16.5), 1.3, stroke);

    // Concussive shock accents
    canvas.drawLine(const Offset(5, 7), const Offset(7.5, 8.5), stroke);
    canvas.drawLine(const Offset(19, 17), const Offset(16.5, 15.5), stroke);
  }

  void _paintStatusBleed(Canvas canvas, Paint stroke, Paint fill) {
    // Primary blood droplet
    final drop = Path()
      ..moveTo(12, 3.5)
      ..cubicTo(12, 3.5, 5.5, 11.5, 5.5, 15.5)
      ..cubicTo(5.5, 19.5, 8.4, 21.5, 12, 21.5)
      ..cubicTo(15.6, 21.5, 18.5, 19.5, 18.5, 15.5)
      ..cubicTo(18.5, 11.5, 12, 3.5, 12, 3.5)
      ..close();

    if (selected) {
      canvas.drawPath(drop, fill);
    }
    canvas.drawPath(drop, stroke);

    // Curved blood slit / specular reflection
    final slit = Path()
      ..moveTo(9, 13)
      ..cubicTo(8.5, 15.5, 10, 18.5, 12, 19);
    canvas.drawPath(slit, stroke);

    // Trailing dripping droplet
    canvas.drawCircle(const Offset(18, 7.5), 1.5, stroke);
  }

  void _paintStatusBurn(Canvas canvas, Paint stroke, Paint fill) {
    // Outer flame silhouette
    final flame = Path()
      ..moveTo(12, 2.5)
      ..cubicTo(13.5, 5.5, 16.5, 7.5, 16.5, 10.5)
      ..cubicTo(16.5, 12.0, 15.5, 13.0, 14.5, 13.5)
      ..cubicTo(17.5, 14.5, 19.0, 17.0, 18.5, 19.5)
      ..cubicTo(18.0, 21.5, 15.5, 22.5, 12, 22.5)
      ..cubicTo(8.5, 22.5, 5.5, 21.0, 5.5, 18.0)
      ..cubicTo(5.5, 15.0, 8.0, 13.0, 9.5, 10.5)
      ..cubicTo(10.5, 9.0, 10.5, 6.5, 12, 2.5)
      ..close();

    if (selected) {
      canvas.drawPath(flame, fill);
    }
    canvas.drawPath(flame, stroke);

    // Inner ember core
    final inner = Path()
      ..moveTo(12, 11)
      ..cubicTo(14, 13, 14.5, 15, 14.5, 17)
      ..cubicTo(14.5, 19.5, 13.2, 20.5, 12, 20.5)
      ..cubicTo(10.8, 20.5, 9.5, 19.5, 9.5, 17)
      ..cubicTo(9.5, 14.5, 11, 13, 12, 11)
      ..close();
    canvas.drawPath(inner, stroke);

    // Floating spark
    canvas.drawCircle(const Offset(7, 6.5), 1.1, stroke);
  }

  void _paintStatusBrokenGuard(Canvas canvas, Paint stroke, Paint fill) {
    // Fractured shield split into two jagged halves
    final leftHalf = Path()
      ..moveTo(5, 4.5)
      ..lineTo(10.5, 4.5)
      ..lineTo(13, 8.5)
      ..lineTo(9.5, 12.5)
      ..lineTo(13.5, 16.5)
      ..lineTo(11, 21.2)
      ..cubicTo(8.5, 20.2, 5, 17.5, 5, 12.0)
      ..close();

    final rightHalf = Path()
      ..moveTo(13.5, 4.5)
      ..lineTo(19, 4.5)
      ..lineTo(19, 12.0)
      ..cubicTo(19, 17.5, 15.5, 20.2, 13, 21.2)
      ..lineTo(15.5, 16.5)
      ..lineTo(11.5, 12.5)
      ..lineTo(15, 8.5)
      ..lineTo(12.5, 4.5)
      ..close();

    if (selected) {
      canvas.drawPath(leftHalf, fill);
      canvas.drawPath(rightHalf, fill);
    }
    canvas.drawPath(leftHalf, stroke);
    canvas.drawPath(rightHalf, stroke);

    // Impact crack shards
    canvas.drawLine(const Offset(16.5, 9.5), const Offset(18.5, 7.5), stroke);
    canvas.drawLine(const Offset(6, 14), const Offset(8, 16), stroke);
  }

  void _paintAudienceTactics(Canvas canvas, Paint stroke, Paint fill) {
    const pivot = Offset(12, 19.5);
    if (selected) {
      canvas.drawCircle(pivot, 2.0, fill);
    }
    canvas.drawCircle(pivot, 2.0, stroke);

    // Center direct tactical arrow
    canvas.drawLine(const Offset(12, 17.5), const Offset(12, 4.5), stroke);
    final topHead = Path()
      ..moveTo(9.5, 7.5)
      ..lineTo(12, 3.5)
      ..lineTo(14.5, 7.5);
    canvas.drawPath(topHead, stroke);

    // Left diverging tactical route
    final leftPath = Path()
      ..moveTo(10.5, 18)
      ..cubicTo(7, 16, 5.5, 12, 5.5, 7.5);
    canvas.drawPath(leftPath, stroke);
    final leftHead = Path()
      ..moveTo(3.5, 10)
      ..lineTo(5.5, 6.5)
      ..lineTo(8.5, 9);
    canvas.drawPath(leftHead, stroke);

    // Right diverging tactical route
    final rightPath = Path()
      ..moveTo(13.5, 18)
      ..cubicTo(17, 16, 18.5, 12, 18.5, 7.5);
    canvas.drawPath(rightPath, stroke);
    final rightHead = Path()
      ..moveTo(15.5, 9)
      ..lineTo(18.5, 6.5)
      ..lineTo(20.5, 10);
    canvas.drawPath(rightHead, stroke);
  }

  void _paintAudienceAnswerAttack(Canvas canvas, Paint stroke, Paint fill) {
    // Incoming attack blade/spear thrust from top-left
    canvas.drawLine(const Offset(3.5, 3.5), const Offset(11, 11), stroke);
    canvas.drawLine(const Offset(4, 7), const Offset(7, 4), stroke);
    final bladeTip = Path()
      ..moveTo(9, 12.5)
      ..lineTo(12, 12)
      ..lineTo(12.5, 9);
    canvas.drawPath(bladeTip, stroke);

    // Defensive ward / parrying shield arc
    final ward = Path()
      ..moveTo(10.5, 20)
      ..cubicTo(14.5, 19, 19, 14.5, 20, 10.5)
      ..lineTo(17.5, 8)
      ..cubicTo(16.5, 12, 12, 16.5, 8, 17.5)
      ..close();
    if (selected) {
      canvas.drawPath(ward, fill);
    }
    canvas.drawPath(ward, stroke);

    // Parry deflection sparks
    canvas.drawLine(const Offset(11.5, 8.5), const Offset(11.5, 6), stroke);
    canvas.drawLine(const Offset(15, 12), const Offset(17.5, 12), stroke);
    canvas.drawLine(const Offset(8.5, 11.5), const Offset(6, 11.5), stroke);
    canvas.drawCircle(const Offset(12, 12), 1.2, stroke);
  }

  void _paintAudienceAvoidHazard(Canvas canvas, Paint stroke, Paint fill) {
    // Floor baseline
    canvas.drawLine(const Offset(3, 21), const Offset(21, 21), stroke);

    // Arena hazard spikes
    final spikes = Path()
      ..moveTo(3.5, 21)
      ..lineTo(6.5, 15.5)
      ..lineTo(9.5, 21)
      ..lineTo(12.5, 14)
      ..lineTo(15.5, 21)
      ..lineTo(18.5, 16)
      ..lineTo(20.5, 21);
    canvas.drawPath(spikes, stroke);

    // Overhead evasion leap arc
    final leap = Path()
      ..moveTo(3.5, 14)
      ..cubicTo(6, 4, 18, 4, 20.5, 14);
    if (selected) {
      final leapFill = Path.from(leap)
        ..lineTo(3.5, 14)
        ..close();
      canvas.drawPath(leapFill, fill);
    }
    canvas.drawPath(leap, stroke);

    // Evasion arrow / agile landing
    final landingArrow = Path()
      ..moveTo(17.5, 12.5)
      ..lineTo(20.5, 14)
      ..lineTo(19.5, 10);
    canvas.drawPath(landingArrow, stroke);
    canvas.drawCircle(const Offset(12, 6.5), 1.4, stroke);
  }

  void _paintAudienceChangeRange(Canvas canvas, Paint stroke, Paint fill) {
    // Range axis line
    canvas.drawLine(const Offset(3.5, 12), const Offset(20.5, 12), stroke);

    // Left range arrow (close distance)
    final leftArrow = Path()
      ..moveTo(6.5, 8.5)
      ..lineTo(3.0, 12)
      ..lineTo(6.5, 15.5);
    canvas.drawPath(leftArrow, stroke);

    // Right range arrow (open distance)
    final rightArrow = Path()
      ..moveTo(17.5, 8.5)
      ..lineTo(21.0, 12)
      ..lineTo(17.5, 15.5);
    canvas.drawPath(rightArrow, stroke);

    // Distance band marker posts: Close, Medium, Far
    canvas.drawLine(const Offset(8, 8), const Offset(8, 16), stroke);
    canvas.drawLine(const Offset(12, 5.5), const Offset(12, 18.5), stroke);
    canvas.drawLine(const Offset(16, 8), const Offset(16, 16), stroke);

    // Range transition arc
    final shiftArc = Path()
      ..moveTo(8, 8)
      ..cubicTo(8, 4.5, 16, 4.5, 16, 8);
    canvas.drawPath(shiftArc, stroke);

    if (selected) {
      canvas.drawCircle(const Offset(12, 12), 2.5, fill);
    }
    canvas.drawCircle(const Offset(12, 12), 1.8, stroke);
  }

  @override
  bool shouldRepaint(covariant _GameGlyphPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.selected != selected;
}
