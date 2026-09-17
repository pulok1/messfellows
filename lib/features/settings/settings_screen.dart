import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/mess.dart';
import '../../providers/backup_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/repository_providers.dart';
import '../members/members_screen.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/page_header_card.dart';

/// Settings (section 41): mess name, a link to member management, local
/// backup export/import, and full data deletion. There is deliberately no
/// account/login section here — see section 40.
class SettingsScreen extends ConsumerStatefulWidget {
  final Mess mess;

  const SettingsScreen({super.key, required this.mess});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBusy = false;

  Future<void> _renameMess() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: widget.mess.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.messNameLabel),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == widget.mess.name) {
      return;
    }
    await ref
        .read(messRepositoryProvider)
        .updateMess(widget.mess.copyWith(name: newName));
  }

  Future<void> _pickLanguage() async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeProvider);
    final picked = await showDialog<Locale>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.languageLabel),
        children: [
          RadioGroup<Locale>(
            groupValue: current,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              children: [
                RadioListTile<Locale>(
                  title: Text(l10n.languageEnglish),
                  value: const Locale('en'),
                ),
                RadioListTile<Locale>(
                  title: Text(l10n.languageBangla),
                  value: const Locale('bn'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked != null && picked != current) {
      await ref.read(localeProvider.notifier).setLocale(picked);
    }
  }

  Future<void> _exportData() async {
    setState(() => _isBusy = true);
    try {
      final json = await ref.read(backupServiceProvider).exportToJson();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File(
        '${directory.path}/mess_fellows_backup_$timestamp.json',
      );
      await file.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Mess Fellows backup'),
      );
    } catch (_) {
      if (mounted) _showError(AppLocalizations.of(context).couldntExportData);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importData() async {
    final l10n = AppLocalizations.of(context);
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty || files.single.path == null) return;
    if (!mounted) return;

    final confirmed = await confirmDestructiveAction(
      context,
      title: l10n.replaceAllDataConfirmTitle,
      message: l10n.replaceAllDataConfirmMessage,
      confirmLabel: l10n.replaceDataButton,
    );
    if (!confirmed) return;

    setState(() => _isBusy = true);
    try {
      final file = File(files.single.path!);
      final json = await file.readAsString();
      await ref.read(backupServiceProvider).importFromJson(json);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupImportedSnackbar)),
        );
      }
    } on ImportException catch (e) {
      _showError(_importErrorMessage(l10n, e.reason));
    } catch (_) {
      _showError(l10n.couldntImportBackup);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _importErrorMessage(AppLocalizations l10n, ImportFailureReason reason) {
    return switch (reason) {
      ImportFailureReason.malformed => l10n.invalidBackupFile,
      ImportFailureReason.unsupportedVersion => l10n.backupTooNew,
      ImportFailureReason.missingMessData => l10n.backupMissingMessData,
      ImportFailureReason.unreadable => l10n.backupUnreadable,
    };
  }

  Future<void> _deleteAllData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructiveAction(
      context,
      title: l10n.deleteAllDataConfirmTitle,
      message: l10n.deleteAllDataConfirmMessage,
      confirmLabel: l10n.deleteEverythingButton,
    );
    if (!confirmed) return;

    setState(() => _isBusy = true);
    try {
      await ref.read(messRepositoryProvider).deleteAllData();
      // AppRoot watches currentMessProvider and will drop back to
      // onboarding automatically once the mess row is gone.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      _showError(l10n.couldntDeleteData);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: l10n.settingsTitle),
            Expanded(
              child: AbsorbPointer(
                absorbing: _isBusy,
                child: ListView(
                  children: [
                    if (_isBusy) const LinearProgressIndicator(),
                    _SectionHeader(l10n.messSectionHeader),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.messNameLabel),
                      subtitle: Text(widget.mess.name),
                      onTap: _renameMess,
                    ),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: Text(l10n.currencyListTile),
                      subtitle: Text(
                        '${widget.mess.currencySymbol} ${widget.mess.currencyCode}',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: Text(l10n.membersLabel),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MembersScreen(messId: widget.mess.id),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text(l10n.languageLabel),
                      subtitle: Text(
                        ref.watch(localeProvider).languageCode == 'bn'
                            ? l10n.languageBangla
                            : l10n.languageEnglish,
                      ),
                      onTap: _pickLanguage,
                    ),
                    const Divider(),
                    _SectionHeader(l10n.localDataSectionHeader),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(l10n.localDataExplain),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      leading: const Icon(Icons.upload_outlined),
                      title: Text(l10n.exportDataTitle),
                      subtitle: Text(l10n.exportDataSubtitle),
                      onTap: _exportData,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(l10n.importDataTitle),
                      subtitle: Text(l10n.importDataSubtitle),
                      onTap: _importData,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        l10n.deleteAllDataTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onTap: _deleteAllData,
                    ),
                    const Divider(),
                    _SectionHeader(l10n.aboutSectionHeader),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text(AppConstants.appName),
                      subtitle: Text(l10n.aboutVersionSubtitle),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
