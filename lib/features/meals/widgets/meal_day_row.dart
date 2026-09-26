import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/member.dart';
import 'meal_toggle_button.dart';

/// One member's row on the daily meal tracker: name plus three
/// independently-tappable meal toggles. Tap flips a slot off/on; long-press
/// opens a count picker for an extra/guest meal (2 or more) in that slot.
class MealDayRow extends StatelessWidget {
  final Member member;
  final int breakfast;
  final int lunch;
  final int dinner;
  final bool showBreakfast;
  final bool showLunch;
  final bool showDinner;

  /// False when [member]'s day can't be changed (its month is closed):
  /// the counts still show, but taps and long-presses do nothing.
  final bool enabled;
  final ValueChanged<int> onBreakfastChanged;
  final ValueChanged<int> onLunchChanged;
  final ValueChanged<int> onDinnerChanged;

  const MealDayRow({
    super.key,
    required this.member,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.showBreakfast = true,
    this.showLunch = true,
    this.showDinner = true,
    this.enabled = true,
    required this.onBreakfastChanged,
    required this.onLunchChanged,
    required this.onDinnerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(children: _buildSlots(context, l10n)),
          ],
        ),
      ),
    );
  }

  /// One [MealToggleButton] per slot this mess tracks, separated by gaps —
  /// built as a list rather than a fixed 3-wide Row so a mess that only
  /// tracks lunch & dinner doesn't show an empty breakfast button.
  List<Widget> _buildSlots(BuildContext context, AppLocalizations l10n) {
    final slots = <Widget>[];

    void addSlot(Widget button) {
      if (slots.isNotEmpty) slots.add(const SizedBox(width: AppSpacing.sm));
      slots.add(Expanded(child: button));
    }

    if (showBreakfast) {
      addSlot(
        MealToggleButton(
          icon: Icons.wb_twilight,
          label: l10n.breakfastLabel,
          count: breakfast,
          onTap: enabled
              ? () => onBreakfastChanged(breakfast > 0 ? 0 : 1)
              : null,
          onLongPress: enabled
              ? () => _showMealCountDialog(
                  context,
                  label: l10n.breakfastLabel,
                  current: breakfast,
                  onChanged: onBreakfastChanged,
                )
              : null,
        ),
      );
    }
    if (showLunch) {
      addSlot(
        MealToggleButton(
          icon: Icons.wb_sunny_outlined,
          label: l10n.lunchLabel,
          count: lunch,
          onTap: enabled ? () => onLunchChanged(lunch > 0 ? 0 : 1) : null,
          onLongPress: enabled
              ? () => _showMealCountDialog(
                  context,
                  label: l10n.lunchLabel,
                  current: lunch,
                  onChanged: onLunchChanged,
                )
              : null,
        ),
      );
    }
    if (showDinner) {
      addSlot(
        MealToggleButton(
          icon: Icons.nightlight_outlined,
          label: l10n.dinnerLabel,
          count: dinner,
          onTap: enabled ? () => onDinnerChanged(dinner > 0 ? 0 : 1) : null,
          onLongPress: enabled
              ? () => _showMealCountDialog(
                  context,
                  label: l10n.dinnerLabel,
                  current: dinner,
                  onChanged: onDinnerChanged,
                )
              : null,
        ),
      );
    }

    return slots;
  }
}

const _maxMealCount = 9;

Future<void> _showMealCountDialog(
  BuildContext context, {
  required String label,
  required int current,
  required ValueChanged<int> onChanged,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<int>(
    context: context,
    builder: (context) {
      var count = current;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.mealCountDialogTitle(label)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.mealCountDialogHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: count > 0 ? () => setState(() => count--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: count < _maxMealCount
                        ? () => setState(() => count++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(count),
              child: Text(l10n.save),
            ),
          ],
        ),
      );
    },
  );
  if (result != null && result != current) onChanged(result);
}
