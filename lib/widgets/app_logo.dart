import 'package:flutter/material.dart';

/// Small mascot mark used in the app UI (not the launcher icon).
///
/// Drawn programmatically so it can follow the current theme colors.
class FeedMeLogo extends StatelessWidget {
  final double size;

  const FeedMeLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CustomPaint(
      size: Size.square(size),
      painter: _FeedMeLogoPainter(
        primary: scheme.primary,
        secondary: scheme.secondary,
        outline: scheme.onSurface.withValues(alpha: 0.85),
      ),
    );
  }
}

class FeedMeWordmark extends StatelessWidget {
  final double iconSize;

  /// "feed" uses theme.primary and "me" uses theme.secondary.
  const FeedMeWordmark({super.key, this.iconSize = 22});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FeedMeLogo(size: iconSize),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'feed', style: style?.copyWith(color: scheme.primary)),
              TextSpan(text: 'me', style: style?.copyWith(color: scheme.secondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedMeLogoPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color outline;

  const _FeedMeLogoPainter({
    required this.primary,
    required this.secondary,
    required this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = size.shortestSide;
    final stroke = s * 0.09;

    final domeCenter = Offset(w * 0.5, h * 0.52);
    final domeRadius = s * 0.36;

    final domePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromCircle(center: domeCenter, radius: domeRadius));

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = outline;

    // Dome arc
    canvas.drawArc(
      Rect.fromCircle(center: domeCenter, radius: domeRadius),
      3.141592653589793,
      3.141592653589793,
      false,
      domePaint,
    );

    // Base line
    canvas.drawLine(
      Offset(domeCenter.dx - domeRadius, domeCenter.dy),
      Offset(domeCenter.dx + domeRadius, domeCenter.dy),
      basePaint,
    );

    // "Hair" stripes
    final stripePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round
      ..color = outline;

    for (final t in [-0.35, -0.15, 0.05, 0.25]) {
      final x = domeCenter.dx + domeRadius * t;
      final y1 = domeCenter.dy - domeRadius * 0.55;
      final y2 = domeCenter.dy - domeRadius * 0.15;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), stripePaint);
    }

    // Eyes
    final eyePaint = Paint()..color = outline;
    canvas.drawCircle(
      Offset(domeCenter.dx - domeRadius * 0.28, domeCenter.dy - domeRadius * 0.12),
      s * 0.035,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(domeCenter.dx + domeRadius * 0.28, domeCenter.dy - domeRadius * 0.12),
      s * 0.035,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FeedMeLogoPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.outline != outline;
  }
}
