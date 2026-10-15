import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/update_check_provider.dart';
import 'update_sheet.dart';

/// A strip above the tabs that stays while a newer build is available —
/// the quiet reminder behind the update popup (see HomeShell). Tapping it
/// (or "Update") reopens the popup; closing it snoozes like "Later".
class UpdateAvailableBanner extends ConsumerWidget {
  const UpdateAvailableBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateInfo = ref.watch(updateAvailableProvider).value;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AnimatedSize(
      duration: AppMotion.of(context, AppMotion.medium),
      curve: AppMotion.emphasized,
      alignment: Alignment.topCenter,
      child: updateInfo == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: colorScheme.primaryContainer,
              child: InkWell(
                onTap: () => showUpdateSheet(context, updateInfo),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.system_update_outlined,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.updateAvailableMessage,
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => showUpdateSheet(context, updateInfo),
                        child: Text(l10n.updateNowAction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: colorScheme.onPrimaryContainer,
                        tooltip: l10n.updateDismissTooltip,
                        onPressed: () =>
                            ref.read(updateAvailableProvider.notifier).snooze(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
