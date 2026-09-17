import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';

/// Shows a standard destructive-action confirmation dialog and returns
/// true only if the user tapped the confirm button. Used for every delete
/// (meal, expense, payment, member archive, data wipe) so confirmation
/// copy/behavior stays consistent app-wide (section 35).
Future<bool> confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
