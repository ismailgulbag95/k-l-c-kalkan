import 'package:flutter/material.dart';

/// Paints a held weapon behind the player body so the sprite's hand stays on
/// top of the hilt or haft. The shapes intentionally use the game's dark iron,
/// brass, and worn wood palette and scale with the body atlas crop.
class HeroWeaponArt {
  const HeroWeaponArt._();

  static const supportedFamilies = <String>{
    'shortSword',
    'maul',
    'spear',
    'bow',
  };

  static void paint(Canvas canvas, Rect body, String family) {
    if (body.isEmpty) return;
    final weaponFamily = supportedFamilies.contains(family)
        ? family
        : 'shortSword';
    final scale = (body.width / 78).clamp(.65, 2.5).toDouble();
    Offset at(double x, double y) => Offset(
      body.left + body.width * x,
      body.top + body.height * y,
    );

    final outline = Paint()
      ..color = const Color(0xFF151718)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final haft = Paint()
      ..color = const Color(0xFF5A3923)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2 * scale
      ..strokeCap = StrokeCap.round;
    final haftHighlight = Paint()
      ..color = const Color(0xFFC18B4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05 * scale
      ..strokeCap = StrokeCap.round;
    final steel = Paint()..color = const Color(0xFFC1C6C2);
    final steelHighlight = Paint()
      ..color = const Color(0xFFECE2CE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15 * scale
      ..strokeCap = StrokeCap.round;
    final brass = Paint()..color = const Color(0xFFD6AD68);

    switch (weaponFamily) {
      case 'maul':
        _paintMaul(canvas, at, outline, haft, haftHighlight, scale);
        break;
      case 'spear':
        _paintSpear(canvas, at, outline, haft, haftHighlight, steel, scale);
        break;
      case 'bow':
        _paintBow(canvas, at, outline, haftHighlight, steelHighlight, scale);
        break;
      case 'shortSword':
        _paintShortSword(
          canvas,
          at,
          outline,
          steel,
          steelHighlight,
          brass,
          scale,
        );
        break;
    }
  }

  static void _paintShortSword(
    Canvas canvas,
    Offset Function(double x, double y) at,
    Paint outline,
    Paint steel,
    Paint steelHighlight,
    Paint brass,
    double scale,
  ) {
    final blade = Path()
      ..moveTo(at(.075, .555).dx, at(.075, .555).dy)
      ..lineTo(at(-.13, .84).dx, at(-.13, .84).dy)
      ..lineTo(at(.025, .595).dx, at(.025, .595).dy)
      ..close();
    canvas.drawPath(blade, steel);
    canvas.drawPath(blade, outline);
    canvas.drawLine(at(.063, .565), at(-.108, .803), steelHighlight);
    canvas.drawLine(at(.035, .60), at(.092, .53), outline);
    canvas.drawLine(
      at(.008, .585),
      at(.105, .646),
      Paint()
        ..color = const Color(0xFF6E4427)
        ..strokeWidth = 4.6 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      at(.008, .585),
      at(.105, .646),
      Paint()
        ..color = brass.color
        ..strokeWidth = 1.6 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(at(.095, .53), 2.1 * scale, brass);
  }

  static void _paintMaul(
    Canvas canvas,
    Offset Function(double x, double y) at,
    Paint outline,
    Paint haft,
    Paint highlight,
    double scale,
  ) {
    final grip = at(.075, .54);
    final haftEnd = at(-.035, .80);
    canvas.drawLine(grip, haftEnd, outline);
    canvas.drawLine(grip, haftEnd, haft);
    canvas.drawLine(at(.067, .56), at(-.025, .77), highlight);
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: at(-.043, .78),
        width: 24 * scale,
        height: 15 * scale,
      ),
      Radius.circular(3 * scale),
    );
    canvas.drawRRect(head, Paint()..color = const Color(0xFF899294));
    canvas.drawRRect(head, outline);
    canvas.drawLine(
      at(-.17, .765),
      at(.08, .765),
      Paint()
        ..color = const Color(0xFFD6AD68)
        ..strokeWidth = 1.2 * scale,
    );
    canvas.drawLine(
      at(-.08, .72),
      at(-.08, .84),
      Paint()
        ..color = const Color(0xFF576467)
        ..strokeWidth = 1.3 * scale,
    );
  }

  static void _paintSpear(
    Canvas canvas,
    Offset Function(double x, double y) at,
    Paint outline,
    Paint haft,
    Paint highlight,
    Paint steel,
    double scale,
  ) {
    final tipBase = at(.055, .115);
    final butt = at(.065, .93);
    canvas.drawLine(butt, tipBase, outline);
    canvas.drawLine(butt, tipBase, haft);
    canvas.drawLine(at(.07, .78), at(.06, .20), highlight);
    final spearHead = Path()
      ..moveTo(at(.055, .015).dx, at(.055, .015).dy)
      ..lineTo(at(.105, .13).dx, at(.105, .13).dy)
      ..lineTo(at(.058, .19).dx, at(.058, .19).dy)
      ..lineTo(at(.012, .13).dx, at(.012, .13).dy)
      ..close();
    canvas.drawPath(spearHead, steel);
    canvas.drawPath(spearHead, outline);
    canvas.drawLine(
      at(.058, .04),
      at(.058, .17),
      Paint()
        ..color = const Color(0xFFD6AD68)
        ..strokeWidth = 1.1 * scale,
    );
    canvas.drawLine(
      at(.04, .20),
      at(.075, .20),
      Paint()
        ..color = const Color(0xFFB96F50)
        ..strokeWidth = 2.6 * scale,
    );
  }

  static void _paintBow(
    Canvas canvas,
    Offset Function(double x, double y) at,
    Paint outline,
    Paint highlight,
    Paint stringPaint,
    double scale,
  ) {
    final top = at(.075, .205);
    final grip = at(.075, .52);
    final bottom = at(.075, .82);
    final bow = Path()
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(at(-.16, .51).dx, at(-.16, .51).dy, bottom.dx, bottom.dy);
    canvas.drawPath(
      bow,
      Paint()
        ..color = outline.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.8 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      bow,
      Paint()
        ..color = const Color(0xFF8F6337)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      bow,
      Paint()
        ..color = const Color(0xFFE0B36C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.05 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(top, bottom, stringPaint);
    canvas.drawLine(
      at(.046, .49),
      at(.103, .55),
      Paint()
        ..color = const Color(0xFF6A4730)
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(grip, at(.09, .54), outline);
  }
}
