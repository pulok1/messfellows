import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../providers/sync_providers.dart';
import '../../sync/sync_engine.dart';
import 'auth_error_message.dart';

bool _isOpen = false;

/// Asks which copy wins when a device that already has a mess signs in to
/// an account that also has one. Can't be dismissed without an answer —
/// signing out is the way to back out.
Future<void> showSyncChoiceDialog(BuildContext context, WidgetRef ref) async {
  if (_isOpen) return;
  _isOpen = true;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final choice = await showDialog<LinkChoice?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.sync_problem_outlined),
        title: Text(l10n.syncChoiceTitle),
        content: Text(l10n.syncChoiceMessage),
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cloudSignOut),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(LinkChoice.keepDevice),
            child: Text(l10n.syncChoiceKeepDevice),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(LinkChoice.keepCloud),
            child: Text(l10n.syncChoiceKeepCloud),
          ),
        ],
      ),
    );
    if (choice == null) {
      await ref.read(cloudAuthServiceProvider)?.signOut();
      return;
    }
    await ref.read(syncEngineProvider)?.resolve(choice);
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(content: Text(authErrorMessage(l10n, e))),
    );
  } finally {
    _isOpen = false;
  }
}
