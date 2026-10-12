import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/localized_date.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/sync_providers.dart';
import '../../../sync/sync_engine.dart';
import '../../account/auth_error_message.dart';
import '../../account/cloud_account_screen.dart';
import '../../account/sync_choice_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/section_header.dart';

/// Settings' "Cloud backup & sync" block: a sign-in entry point while
/// signed out, then the account, live sync status, "Sync now" and sign-out.
/// Renders nothing in a build without Supabase config.
class CloudSyncSection extends ConsumerWidget {
  final EdgeInsetsGeometry headerPadding;

  const CloudSyncSection({super.key, required this.headerPadding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(supabaseClientProvider) == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authUserProvider).value;
    final status = ref.watch(syncStatusProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.cloudSyncSectionHeader, padding: headerPadding),
        if (user == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              0,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Text(
              l10n.cloudSyncExplain,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: user == null
              ? ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: Text(l10n.cloudSignInTitle),
                  subtitle: Text(l10n.cloudSignInSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CloudAccountScreen(),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ListTile(
                      leading: _statusIcon(colorScheme, status?.phase),
                      title: Text(user.email ?? ''),
                      subtitle: Text(_statusText(context, l10n, status)),
                      trailing: status?.phase == SyncPhase.syncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              tooltip: l10n.cloudSyncNow,
                              icon: const Icon(Icons.sync),
                              onPressed: () =>
                                  ref.read(syncEngineProvider)?.syncNow(),
                            ),
                      onTap: status?.phase == SyncPhase.needsChoice
                          ? () => showSyncChoiceDialog(context, ref)
                          : null,
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.cloudSignOut),
                      onTap: () => _signOut(context, ref),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  static Widget _statusIcon(ColorScheme colors, SyncPhase? phase) =>
      switch (phase) {
        SyncPhase.idle => Icon(Icons.cloud_done_outlined, color: colors.primary),
        SyncPhase.offline => const Icon(Icons.cloud_off_outlined),
        SyncPhase.error ||
        SyncPhase.needsChoice => Icon(Icons.sync_problem, color: colors.error),
        _ => const Icon(Icons.cloud_sync_outlined),
      };

  static String _statusText(
    BuildContext context,
    AppLocalizations l10n,
    SyncStatus? status,
  ) {
    switch (status?.phase) {
      case null || SyncPhase.starting || SyncPhase.syncing:
        return l10n.cloudSyncing;
      case SyncPhase.needsChoice:
        return l10n.cloudNeedsChoiceStatus;
      case SyncPhase.offline:
        return l10n.cloudOfflineStatus;
      case SyncPhase.error:
        return l10n.cloudSyncFailed(authErrorMessage(l10n, status!.error!));
      case SyncPhase.idle:
        if (status!.pending > 0) return l10n.cloudPendingChanges(status.pending);
        final last = status.lastSyncedAt;
        if (last == null) return l10n.cloudNotSyncedYet;
        return l10n.cloudUpToDate(_when(context, last));
    }
  }

  /// "3:40 PM" today, "16 Sep 3:40 PM" otherwise.
  static String _when(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final sameDay =
        now.year == time.year && now.month == time.month && now.day == time.day;
    final clock = formatTimeOfDay(context, time);
    return sameDay ? clock : '${formatDayMonth(context, time)} $clock';
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructiveAction(
      context,
      title: l10n.cloudSignOutConfirmTitle,
      message: l10n.cloudSignOutConfirmMessage,
      confirmLabel: l10n.cloudSignOut,
    );
    if (!confirmed) return;
    await ref.read(cloudAuthServiceProvider)?.signOut();
  }
}
