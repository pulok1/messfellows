import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/rule.dart';
import '../../models/rule_category.dart';
import '../../providers/repository_providers.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'rule_category_ui.dart';

/// Shows the add/edit rule dialog. Resolves to `true` if a save or delete
/// happened, `false`/`null` if cancelled.
Future<bool?> showAddEditRuleDialog(
  BuildContext context, {
  required String messId,
  Rule? existing,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AddEditRuleDialog(messId: messId, existing: existing),
  );
}

/// Add-or-edit form for a mess rule, as a popup like the bazar entry form.
class AddEditRuleDialog extends ConsumerStatefulWidget {
  final String messId;
  final Rule? existing;

  const AddEditRuleDialog({super.key, required this.messId, this.existing});

  @override
  ConsumerState<AddEditRuleDialog> createState() => _AddEditRuleDialogState();
}

class _AddEditRuleDialogState extends ConsumerState<AddEditRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late RuleCategory _category;
  late bool _isImportant;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _detailsController = TextEditingController(text: existing?.details ?? '');
    _category = existing?.category ?? RuleCategory.other;
    _isImportant = existing?.isImportant ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(ruleRepositoryProvider);
      final title = _titleController.text;
      final details = _detailsController.text;
      if (_isEditing) {
        await repo.updateRule(
          widget.existing!.copyWith(
            title: title,
            details: details,
            clearDetails: details.trim().isEmpty,
            category: _category,
            isImportant: _isImportant,
          ),
        );
      } else {
        await repo.addRule(
          messId: widget.messId,
          title: title,
          details: details,
          category: _category,
          isImportant: _isImportant,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).couldntSaveRule)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructiveAction(
      context,
      title: l10n.deleteRuleConfirmTitle,
      message: l10n.deleteRuleConfirmMessage,
    );
    if (!confirmed) return;
    await ref.read(ruleRepositoryProvider).deleteRule(widget.existing!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(_isEditing ? l10n.editRuleTitle : l10n.addRuleTitle),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(120)],
                  decoration: InputDecoration(labelText: l10n.ruleTitleLabel),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.ruleTitleValidator
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _detailsController,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: l10n.ruleDetailsLabel),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.ruleCategoryLabel,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final category in RuleCategory.values)
                      ChoiceChip(
                        avatar: Icon(category.icon, size: 18),
                        label: Text(category.label(l10n)),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.ruleImportantLabel),
                  subtitle: Text(l10n.ruleImportantHint),
                  value: _isImportant,
                  onChanged: (value) => setState(() => _isImportant = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _isSaving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(l10n.delete),
          )
        else
          const SizedBox.shrink(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            const SizedBox(width: AppSpacing.xs),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? l10n.saveChanges : l10n.add),
            ),
          ],
        ),
      ],
    );
  }
}
