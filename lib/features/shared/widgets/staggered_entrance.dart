import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// Fades and lifts [child] into place the first time it's built, delayed by
/// its [index] so a list of these settles in one after another rather than
/// all at once. Later rebuilds (e.g. a balance changing) don't replay it.
class StaggeredEntrance extends StatelessWidget {
  final int index;
  final Widget child;

  /// How much later each successive item starts; capped so long lists
  /// don't keep the bottom rows waiting.
  static const _step = Duration(milliseconds: 60);
  static const _maxStaggered = 8;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = _step * index.clamp(0, _maxStaggered);
    final total = AppMotion.of(context, AppMotion.long + delay);
    if (total == Duration.zero) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.emphasized,
      ),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16),
          child: child,
        ),
      ),
    );
  }
}
