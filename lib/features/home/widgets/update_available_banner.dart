import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/update_check_provider.dart';

/// A dismissible strip above the bottom-nav tabs announcing a newer build
/// is on GitHub — see UpdateCheckerService for why the app has to check
/// this itself. Tapping it (or "Update") opens the APK download in the
/// browser; nothing here installs anything automatically.
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
                onTap: () => _openDownload(updateInfo.downloadUrl),
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
                        onPressed: () => _openDownload(updateInfo.downloadUrl),
                        child: Text(l10n.updateNowAction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: colorScheme.onPrimaryContainer,
                        tooltip: l10n.updateDismissTooltip,
                        onPressed: () => ref.read(updateAvailableProvider.notifier).dismiss(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _openDownload(String url) {
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
