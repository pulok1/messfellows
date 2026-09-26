import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';

/// A per-slot completion summary above the member list — "2/4" marked for
/// each meal, at a glance, without scrolling the whole list. Tapping a chip
/// is the "smart" part: it marks everyone who hasn't eaten yet (leaving
/// anyone already marked, including a guest-meal count above 1, untouched),
/// or clears the whole slot if everyone's already marked — since most days
/// the whole mess eats together, this turns N taps into one.
class MealProgressRow extends StatelessWidget {
  final int totalMembers;
  final int breakfastMarked;
  final int lunchMarked;
  final int dinnerMarked;
  final bool showBreakfast;
  final bool showLunch;
  final bool showDinner;

  /// False when the day can't be changed (its month is closed): the
  /// progress still shows, but tapping a chip does nothing.
  final bool enabled;
  final VoidCallback onToggleBreakfast;
  final VoidCallback onToggleLunch;
  final VoidCallback onToggleDinner;

  const MealProgressRow({
    super.key,
    required this.totalMembers,
    required this.breakfastMarked,
    required this.lunchMarked,
    required this.dinnerMarked,
    this.showBreakfast = true,
    this.showLunch = true,
    this.showDinner = true,
    this.enabled = true,
    required this.onToggleBreakfast,
    required this.onToggleLunch,
    required this.onToggleDinner,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <Widget>[];

    void addChip(Widget chip) {
      if (chips.isNotEmpty) chips.add(const SizedBox(width: AppSpacing.sm));
      chips.add(Expanded(child: chip));
    }

    if (showBreakfast) {
      addChip(
        _ProgressChip(
          icon: Icons.wb_twilight,
          label: l10n.breakfastLabel,
          marked: breakfastMarked,
          total: totalMembers,
          onTap: enabled ? onToggleBreakfast : null,
        ),
      );
    }
    if (showLunch) {
      addChip(
        _ProgressChip(
          icon: Icons.wb_sunny_outlined,
          label: l10n.lunchLabel,
          marked: lunchMarked,
          total: totalMembers,
          onTap: enabled ? onToggleLunch : null,
        ),
      );
    }
    if (showDinner) {
      addChip(
        _ProgressChip(
          icon: Icons.nightlight_outlined,
          label: l10n.dinnerLabel,
          marked: dinnerMarked,
          total: totalMembers,
          onTap: enabled ? onToggleDinner : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(children: chips),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int marked;
  final int total;
  final VoidCallback? onTap;

  const _ProgressChip({
    required this.icon,
    required this.label,
    required this.marked,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final complete = total > 0 && marked == total;
    final background = complete
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = complete
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final short = AppMotion.of(context, AppMotion.short);

    return Semantics(
      button: true,
      label: l10n.mealSemanticsLabel(
        label,
        l10n.mealProgressLabel(label, marked, total),
      ),
      enabled: onTap != null,
      hint: onTap == null
          ? null
          : complete
          ? l10n.clearAllAction
          : l10n.markAllAction,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        child: AnimatedContainer(
          duration: short,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                complete ? Icons.check_circle : icon,
                size: 18,
                color: foreground,
              ),
              const SizedBox(height: 2),
              Text(
                '$marked/$total',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: foreground, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
