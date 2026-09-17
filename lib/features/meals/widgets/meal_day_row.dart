import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/member.dart';
import 'meal_toggle_button.dart';

/// One member's row on the daily meal tracker: name plus three
/// independently-tappable meal toggles.
class MealDayRow extends StatelessWidget {
  final Member member;
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final ValueChanged<bool> onBreakfastChanged;
  final ValueChanged<bool> onLunchChanged;
  final ValueChanged<bool> onDinnerChanged;

  const MealDayRow({
    super.key,
    required this.member,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
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
            Row(
              children: [
                Expanded(
                  child: MealToggleButton(
                    icon: Icons.wb_twilight,
                    label: l10n.breakfastLabel,
                    isOn: breakfast,
                    onTap: () => onBreakfastChanged(!breakfast),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MealToggleButton(
                    icon: Icons.wb_sunny_outlined,
                    label: l10n.lunchLabel,
                    isOn: lunch,
                    onTap: () => onLunchChanged(!lunch),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MealToggleButton(
                    icon: Icons.nightlight_outlined,
                    label: l10n.dinnerLabel,
                    isOn: dinner,
                    onTap: () => onDinnerChanged(!dinner),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
