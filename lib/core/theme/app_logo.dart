import 'package:flutter/material.dart';

/// The Mess Fellows brand mark: a shared bowl with two rising steam wisps —
/// the bowl stands for the shared meal a "mess" is built around, the two
/// wisps stand for the fellows sharing it. Custom-drawn rather than a
/// borrowed Material icon so the app (and its exported app icon, see
/// `tool/generate_app_icon_test.dart`) has its own mark.
///
/// Used wherever the app shows its own icon: the dashboard header, the
/// onboarding hero, and the settings About row.
class AppLogoMark extends StatelessWidget {
  final double size;
  final Color color;

  const AppLogoMark({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AppLogoPainter(color),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  final Color color;

  _AppLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bowlTop = h * 0.54;
    final bowlBottom = h * 0.88;
    final bowlLeft = w * 0.08;
    final bowlRight = w * 0.92;

    final bodyFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bowlPath = Path()
      ..moveTo(bowlLeft, bowlTop)
      ..quadraticBezierTo(bowlLeft, bowlBottom, w * 0.5, bowlBottom)
      ..quadraticBezierTo(bowlRight, bowlBottom, bowlRight, bowlTop)
      ..close();
    canvas.drawPath(bowlPath, bodyFill);

    final rimFill = Paint()..color = color.withValues(alpha: 0.62);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, bowlTop),
        width: bowlRight - bowlLeft,
        height: h * 0.11,
      ),
      rimFill,
    );

    _drawSteam(
      canvas,
      color,
      base: Offset(w * 0.38, h * 0.50),
      height: h * 0.42,
      sway: w * 0.075,
    );
    _drawSteam(
      canvas,
      color,
      base: Offset(w * 0.62, h * 0.50),
      height: h * 0.36,
      sway: -w * 0.075,
    );
  }

  void _drawSteam(
    Canvas canvas,
    Color color, {
    required Offset base,
    required double height,
    required double sway,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.16
      ..strokeCap = StrokeCap.round;

    // A single gentle bend reads as a soft wisp of steam; the double-S
    // curve tried earlier looked more like a curly cord than steam.
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + sway,
        base.dy - height * 0.55,
        base.dx,
        base.dy - height,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AppLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
