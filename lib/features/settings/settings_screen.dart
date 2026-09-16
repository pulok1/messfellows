import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/mess.dart';
import '../../providers/backup_provider.dart';
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
    final controller = TextEditingController(text: widget.mess.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mess name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
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
      _showError("Couldn't export your data. Please try again.");
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importData() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty || files.single.path == null) return;
    if (!mounted) return;

    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Replace all local data?',
      message:
          'Importing this backup will permanently replace every mess, member, meal, bazar, '
          'payment and settlement currently on this device. This cannot be undone.',
      confirmLabel: 'Replace Data',
    );
    if (!confirmed) return;

    setState(() => _isBusy = true);
    try {
      final file = File(files.single.path!);
      final json = await file.readAsString();
      await ref.read(backupServiceProvider).importFromJson(json);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup imported successfully.')),
        );
      }
    } on ImportException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError("Couldn't import this backup. Please try again.");
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete all local data?',
      message:
          'This permanently deletes your mess, members, meals, bazar, payments and settlements '
          'from this device. Export a backup first if you want to keep a copy.',
      confirmLabel: 'Delete Everything',
    );
    if (!confirmed) return;

    setState(() => _isBusy = true);
    try {
      await ref.read(messRepositoryProvider).deleteAllData();
      // AppRoot watches currentMessProvider and will drop back to
      // onboarding automatically once the mess row is gone.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      _showError("Couldn't delete your data. Please try again.");
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeaderCard(title: 'Settings'),
            Expanded(
              child: AbsorbPointer(
                absorbing: _isBusy,
                child: ListView(
                  children: [
                    if (_isBusy) const LinearProgressIndicator(),
                    _SectionHeader('Mess'),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Mess name'),
                      subtitle: Text(widget.mess.name),
                      onTap: _renameMess,
                    ),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: const Text('Currency'),
                      subtitle: Text(
                        '${widget.mess.currencySymbol} ${widget.mess.currencyCode}',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('Members'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MembersScreen(messId: widget.mess.id),
                        ),
                      ),
                    ),
                    const Divider(),
                    _SectionHeader('Local Data'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'Your data lives only on this device — there is no cloud backup yet. '
                        'Export a copy regularly, especially before switching phones.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      leading: const Icon(Icons.upload_outlined),
                      title: const Text('Export data'),
                      subtitle: const Text(
                        'Save a backup file you can share or store',
                      ),
                      onTap: _exportData,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Import data'),
                      subtitle: const Text(
                        'Replace local data from a backup file',
                      ),
                      onTap: _importData,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        'Delete all local data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onTap: _deleteAllData,
                    ),
                    const Divider(),
                    _SectionHeader('About'),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text(AppConstants.appName),
                      subtitle: Text(
                        'Version 1.0.0 · Local-first, no account required',
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
