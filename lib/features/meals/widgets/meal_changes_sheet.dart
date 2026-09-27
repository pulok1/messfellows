import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/localized_date.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/activity_log_entry.dart';
import '../../../models/meal_slot.dart';

/// Lists every change made to one member's meals on [date] after that day
/// had passed — what changed, why, and when — so anyone can see exactly
/// how a past day's numbers came to be.
Future<void> showMealChangesSheet(
  BuildContext context, {
  required String memberName,
  required DateTime date,
  required List<ActivityLogEntry> changes,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text(
                l10n.mealChangesTitle(
                  memberName,
                  formatShortDate(sheetContext, date),
                ),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final change in changes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_calendar_outlined),
                  title: Text(
                    l10n.mealChangeLine(
                      _slotLabel(l10n, change.mealSlot),
                      change.previousCount ?? 0,
                      change.count ?? 0,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    [
                      if (change.detail != null) change.detail!,
                      l10n.mealChangedAt(
                        '${formatShortDate(sheetContext, change.createdAt)}, '
                        '${formatTimeOfDay(sheetContext, change.createdAt)}',
                      ),
                    ].join('\n'),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

String _slotLabel(AppLocalizations l10n, MealSlot? slot) => switch (slot) {
  MealSlot.breakfast => l10n.breakfastLabel,
  MealSlot.lunch => l10n.lunchLabel,
  MealSlot.dinner || null => l10n.dinnerLabel,
};
