import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_updater.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/app_update_info.dart';
import '../../../providers/update_check_provider.dart';

bool _isOpen = false;

/// The "Update available" popup: version, size, what's new, and a one-tap
/// update — an in-app download straight into Android's installer, or a
/// reload on the web. "Later" (or swiping it away) snoozes this build.
Future<void> showUpdateSheet(BuildContext context, AppUpdateInfo info) async {
  if (_isOpen) return;
  _isOpen = true;
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _UpdateSheet(info: info),
    );
  } finally {
    _isOpen = false;
  }
}

class _UpdateSheet extends ConsumerStatefulWidget {
  final AppUpdateInfo info;

  const _UpdateSheet({required this.info});

  @override
  ConsumerState<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends ConsumerState<_UpdateSheet> {
  UpdateProgress? _progress;
  StreamSubscription<UpdateProgress>? _sub;

  bool get _busy =>
      _progress?.phase == UpdatePhase.downloading ||
      _progress?.phase == UpdatePhase.installing;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _later() {
    ref.read(updateAvailableProvider.notifier).snooze();
    Navigator.of(context).pop();
  }

  void _update() {
    final updater = ref.read(appUpdaterProvider);
    if (kIsWeb) {
      updater.reloadWeb();
      return;
    }
    _sub?.cancel();
    _sub = updater
        .installApk(widget.info)
        .listen((p) => setState(() => _progress = p));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final info = widget.info;
    final size = info.sizeBytes == null
        ? ''
        : ' · ${(info.sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
    final notes = info.notes.isEmpty ? [l10n.updateNoNotes] : info.notes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Icon(
                    Icons.system_update_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.updateSheetTitle,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${l10n.updateVersionLabel(info.version, info.buildNumber)}$size',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.updateWhatsNew,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.35,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final note in notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(note, style: textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _StatusLine(progress: _progress),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _busy ? null : _later,
                    child: Text(l10n.updateLaterAction),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _update,
                      icon: Icon(
                        kIsWeb ? Icons.refresh : Icons.download_rounded,
                      ),
                      label: Text(
                        kIsWeb ? l10n.updateReloadAction : l10n.updateNowAction,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_progress?.phase == UpdatePhase.failed)
              TextButton(
                onPressed: () =>
                    ref.read(appUpdaterProvider).openInBrowser(info),
                child: Text(l10n.updateDownloadInBrowser),
              ),
          ],
        ),
      ),
    );
  }
}

/// Download progress, or what happened, under the notes.
class _StatusLine extends StatelessWidget {
  final UpdateProgress? progress;

  const _StatusLine({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final p = progress;

    if (p == null) {
      return Text(
        kIsWeb ? l10n.updateWebHint : l10n.updateKeepsData,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (p.phase == UpdatePhase.downloading) {
      final fraction = p.fraction ?? 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: fraction == 0 ? null : fraction,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.updateDownloading((fraction * 100).round()),
            style: textTheme.bodySmall,
          ),
        ],
      );
    }
    final (text, color) = switch (p.phase) {
      UpdatePhase.installing => (l10n.updateInstalling, colorScheme.primary),
      UpdatePhase.permissionDenied => (
        l10n.updatePermissionNeeded,
        colorScheme.error,
      ),
      _ => (l10n.updateFailed, colorScheme.error),
    };
    return Text(text, style: textTheme.bodyMedium?.copyWith(color: color));
  }
}
