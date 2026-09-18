import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';

/// A single large, tappable meal toggle (Breakfast/Lunch/Dinner). Tapping
/// flips it between off and one meal — no confirmation dialog, per section
/// 15's "avoid unnecessary confirmation dialogs" and "make meal-off easy".
/// Long-pressing opens a count picker for an extra/guest meal in this slot,
/// shown as a small badge once [count] is above 1.
class MealToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MealToggleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = count > 0;
    final background = isOn
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foreground = isOn
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    final l10n = AppLocalizations.of(context);
    final stateLabel = switch (count) {
      0 => l10n.mealStateOff,
      1 => l10n.mealStateEaten,
      _ => l10n.mealsCount(count),
    };

    return Semantics(
      button: true,
      label: l10n.mealSemanticsLabel(label, stateLabel),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        child: Container(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: foreground, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (count > 1)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
