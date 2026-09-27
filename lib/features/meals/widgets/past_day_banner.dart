import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/localized_date.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Shown on a day that has passed. While [reason] is null the day's meals
/// are locked and this explains why, with an Edit button that asks for a
/// reason first. Once unlocked it shows the reason every change will be
/// logged with, and a Done button to lock the day again.
class PastDayBanner extends StatelessWidget {
  final DateTime date;
  final String? reason;
  final ValueChanged<String> onUnlock;
  final VoidCallback onLock;

  const PastDayBanner({
    super.key,
    required this.date,
    required this.reason,
    required this.onUnlock,
    required this.onLock,
  });

  Future<void> _askForReason(BuildContext context) async {
    final entered = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(date: date),
    );
    if (entered != null && entered.trim().isNotEmpty) onUnlock(entered);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final editing = reason != null;
    final background = editing
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.secondaryContainer;
    final foreground = editing
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        children: [
          Icon(
            editing ? Icons.edit_calendar_outlined : Icons.history,
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              editing
                  ? l10n.pastDayEditingBanner(reason!)
                  : l10n.pastDayLockedBanner,
              style: theme.textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
          TextButton(
            onPressed: editing ? onLock : () => _askForReason(context),
            style: TextButton.styleFrom(foregroundColor: foreground),
            child: Text(
              editing ? l10n.doneEditingAction : l10n.editPastDayAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  final DateTime date;

  const _ReasonDialog({required this.date});

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quickReasons = [
      l10n.reasonForgotToMark,
      l10n.reasonMarkedByMistake,
      l10n.reasonGuestMeal,
    ];
    final hasReason = _controller.text.trim().isNotEmpty;

    return AlertDialog(
      title: Text(
        l10n.pastDayReasonTitle(formatShortDate(context, widget.date)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pastDayReasonExplain,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.pastDayReasonHint),
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final quick in quickReasons)
                  ActionChip(
                    label: Text(quick),
                    onPressed: () => _controller
                      ..text = quick
                      ..selection = TextSelection.collapsed(
                        offset: quick.length,
                      ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: hasReason
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: Text(l10n.startEditingAction),
        ),
      ],
    );
  }
}
