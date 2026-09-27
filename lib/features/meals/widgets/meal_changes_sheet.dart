import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/localized_date.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/activity_log_entry.dart';
import '../meal_slot_ui.dart';

/// Lists meal changes made after their day had passed — what changed, why,
/// and when — so anyone can see exactly how a past day's numbers came to
/// be. Pass [memberNames] when [changes] span several members/days, to
/// label each change with its day and member.
Future<void> showMealChangesSheet(
  BuildContext context, {
  required String title,
  required List<ActivityLogEntry> changes,
  Map<String, String>? memberNames,
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
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final change in changes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_calendar_outlined),
                  title: Text(
                    [
                      if (memberNames != null) ...[
                        formatDayMonth(sheetContext, change.mealDate!),
                        ?memberNames[change.memberId],
                      ],
                      l10n.mealChangeLine(
                        mealSlotLabel(l10n, change.mealSlot!),
                        change.previousCount ?? 0,
                        change.count ?? 0,
                      ),
                    ].join(' · '),
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
