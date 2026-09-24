import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// Text showing a number that counts up from zero on first appearance and
/// glides to each new value afterwards, so a changed total is noticed
/// instead of silently swapped. [format] turns the in-between value into
/// display text (money, a plain count, ...).
class CountUpText extends StatelessWidget {
  final num value;
  final String Function(double value) format;
  final TextStyle? style;

  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AppMotion.of(context, AppMotion.long),
      curve: AppMotion.emphasized,
      builder: (context, current, _) => Text(format(current), style: style),
    );
  }
}
