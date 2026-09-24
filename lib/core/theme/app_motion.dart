import 'package:flutter/widgets.dart';

/// Shared animation timings and curves, so motion feels the same across the
/// app. Every duration goes through [AppMotion.of], which collapses it to
/// zero when the system "reduce motion" / "remove animations" setting is on.
abstract final class AppMotion {
  /// Small state changes: a toggle flipping, a press bounce.
  static const short = Duration(milliseconds: 180);

  /// Content changes: tab fades, numbers counting up.
  static const medium = Duration(milliseconds: 320);

  /// Larger reveals: list items settling in on first load.
  static const long = Duration(milliseconds: 520);

  static const emphasized = Curves.easeOutCubic;
  static const pop = Curves.easeOutBack;

  /// [duration], or [Duration.zero] if the user asked for reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
          ? Duration.zero
          : duration;
}
