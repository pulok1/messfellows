import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_logo.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/mess.dart';
import '../../providers/backup_provider.dart';
import '../../providers/expense_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/mess_provider.dart';
import '../../providers/payment_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/theme_mode_provider.dart';
import '../members/members_screen.dart';
import '../recycle_bin/recycle_bin_screen.dart';
import '../rules/rules_screen.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/page_header_card.dart';
import '../shared/widgets/section_header.dart';

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

  // widget.mess is a one-time snapshot from whoever pushed this route —
  // it never updates after that. Reading the live value from
  // currentMessProvider instead means a toggle can't be built on top of an
  // already-stale copy and silently undo an earlier change.
  Mess get _mess => ref.read(currentMessProvider).value ?? widget.mess;

  Future<void> _renameMess() async {
    final l10n = AppLocalizations.of(context);
    final mess = _mess;
    final controller = TextEditingController(text: mess.name);
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
    if (newName == null || newName.isEmpty || newName == mess.name) {
      return;
    }
    await ref.read(messRepositoryProvider).updateMess(mess.copyWith(name: newName));
  }

  int _recycleBinCount(WidgetRef ref, String messId) {
    final deletedExpenses = ref.watch(deletedExpensesProvider(messId)).value ?? const [];
    final deletedPayments = ref.watch(deletedPaymentsProvider(messId)).value ?? const [];
    return deletedExpenses.length + deletedPayments.length;
  }

  Future<void> _setMealTracking({
    bool? trackBreakfast,
    bool? trackLunch,
    bool? trackDinner,
  }) async {
    final updated = _mess.copyWith(
      trackBreakfast: trackBreakfast,
      trackLunch: trackLunch,
      trackDinner: trackDinner,
    );
    if (!updated.trackBreakfast && !updated.trackLunch && !updated.trackDinner) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).atLeastOneMealRequired)),
      );
      return;
    }
    await ref.read(messRepositoryProvider).updateMess(updated);
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

  Future<void> _pickThemeMode() async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(themeModeProvider);
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.themeLabel),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeLight),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeDark),
                  value: ThemeMode.dark,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeSystem),
                  value: ThemeMode.system,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked != null && picked != current) {
      await ref.read(themeModeProvider.notifier).setThemeMode(picked);
    }
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
    ThemeMode.system => l10n.themeSystem,
  };

  IconData _themeModeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };

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

  static const _sectionHeaderPadding = EdgeInsets.fromLTRB(
    AppSpacing.xs,
    0,
    AppSpacing.xs,
    AppSpacing.sm,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mess = ref.watch(currentMessProvider).value ?? widget.mess;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: l10n.settingsTitle),
            Expanded(
              child: AbsorbPointer(
                absorbing: _isBusy,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  children: [
                    if (_isBusy) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    SectionHeader(
                      l10n.messSectionHeader,
                      padding: _sectionHeaderPadding,
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_outlined),
                            title: Text(l10n.messNameLabel),
                            subtitle: Text(mess.name),
                            onTap: _renameMess,
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.currency_exchange),
                            title: Text(l10n.currencyListTile),
                            subtitle: Text(
                              '${mess.currencySymbol} ${mess.currencyCode}',
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.group_outlined),
                            title: Text(l10n.membersLabel),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    MembersScreen(messId: mess.id),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.gavel_outlined),
                            title: Text(l10n.rulesTitle),
                            subtitle: Text(l10n.rulesSettingsSubtitle),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RulesScreen(messId: mess.id),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
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
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: Icon(
                              _themeModeIcon(ref.watch(themeModeProvider)),
                            ),
                            title: Text(l10n.themeLabel),
                            subtitle: Text(
                              _themeModeLabel(l10n, ref.watch(themeModeProvider)),
                            ),
                            onTap: _pickThemeMode,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(
                      l10n.mealsSectionHeader,
                      padding: _sectionHeaderPadding,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xs,
                        0,
                        AppSpacing.xs,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.mealsSectionExplain,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.wb_twilight),
                            title: Text(l10n.breakfastLabel),
                            value: mess.trackBreakfast,
                            onChanged: (value) =>
                                _setMealTracking(trackBreakfast: value),
                          ),
                          const Divider(height: 1, indent: 56),
                          SwitchListTile(
                            secondary: const Icon(Icons.wb_sunny_outlined),
                            title: Text(l10n.lunchLabel),
                            value: mess.trackLunch,
                            onChanged: (value) =>
                                _setMealTracking(trackLunch: value),
                          ),
                          const Divider(height: 1, indent: 56),
                          SwitchListTile(
                            secondary: const Icon(Icons.nightlight_outlined),
                            title: Text(l10n.dinnerLabel),
                            value: mess.trackDinner,
                            onChanged: (value) =>
                                _setMealTracking(trackDinner: value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(
                      l10n.localDataSectionHeader,
                      padding: _sectionHeaderPadding,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xs,
                        0,
                        AppSpacing.xs,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.localDataExplain,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.upload_outlined),
                            title: Text(l10n.exportDataTitle),
                            subtitle: Text(l10n.exportDataSubtitle),
                            onTap: _exportData,
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.download_outlined),
                            title: Text(l10n.importDataTitle),
                            subtitle: Text(l10n.importDataSubtitle),
                            onTap: _importData,
                          ),
                          const Divider(height: 1, indent: 56),
                          Builder(
                            builder: (context) {
                              final count = _recycleBinCount(ref, mess.id);
                              return ListTile(
                                leading: const Icon(
                                  Icons.restore_from_trash_outlined,
                                ),
                                title: Text(l10n.recycleBinTitle),
                                subtitle: Text(l10n.recycleBinSubtitle),
                                trailing: count == 0
                                    ? null
                                    : CircleAvatar(
                                        radius: 11,
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                        child: Text(
                                          '$count',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onError,
                                          ),
                                        ),
                                      ),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecycleBinScreen(messId: mess.id),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 56),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(
                      l10n.aboutSectionHeader,
                      padding: _sectionHeaderPadding,
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.chipRadius,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                            ),
                          ),
                          child: Center(
                            child: AppLogoMark(
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        title: const Text(AppConstants.appName),
                        subtitle: Text(l10n.aboutVersionSubtitle),
                      ),
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
