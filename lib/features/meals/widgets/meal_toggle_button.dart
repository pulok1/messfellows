import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';

/// A single large, tappable meal toggle (Breakfast/Lunch/Dinner). Tapping
/// flips it between off and one meal — no confirmation dialog, per section
/// 15's "avoid unnecessary confirmation dialogs" and "make meal-off easy".
/// Long-pressing opens a count picker for an extra/guest meal in this slot,
/// shown as a small badge once [count] is above 1.
///
/// The toggle squishes slightly while pressed, cross-fades its colors when
/// flipped, and pops the extra-meal badge in and out, with a light haptic
/// tick on each tap so the change registers without looking.
///
/// Passing null for [onTap] locks the toggle (e.g. its month is closed): it
/// still shows the recorded count, dimmed, but can't be changed.
class MealToggleButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MealToggleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MealToggleButton> createState() => _MealToggleButtonState();
}

class _MealToggleButtonState extends State<MealToggleButton> {
  bool _pressed = false;

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = widget.count;
    final isOn = count > 0;
    final enabled = widget.onTap != null;
    final background = isOn
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foreground = isOn
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final short = AppMotion.of(context, AppMotion.short);

    final l10n = AppLocalizations.of(context);
    final stateLabel = switch (count) {
      0 => l10n.mealStateOff,
      1 => l10n.mealStateEaten,
      _ => l10n.mealsCount(count),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.mealSemanticsLabel(widget.label, stateLabel),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.55,
        duration: short,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: short,
          curve: AppMotion.emphasized,
          child: InkWell(
            onTap: enabled ? _handleTap : null,
            onLongPress: widget.onLongPress,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            child: AnimatedContainer(
              duration: short,
              curve: AppMotion.emphasized,
              constraints: const BoxConstraints(minHeight: 56, minWidth: 72),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: foreground),
                    duration: short,
                    builder: (context, color, _) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, color: color, size: 20),
                        const SizedBox(height: 2),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: AnimatedSwitcher(
                      duration: short,
                      switchInCurve: AppMotion.pop,
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: count > 1
                          ? _CountBadge(key: ValueKey(count), count: count)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.surface, width: 1.5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: colorScheme.onTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
