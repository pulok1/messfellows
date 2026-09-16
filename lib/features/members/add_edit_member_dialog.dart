import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/member.dart';
import '../../providers/repository_providers.dart';

/// Shows the add/edit member dialog. Resolves to `true` if a save
/// happened, `false`/`null` if cancelled.
Future<bool?> showAddEditMemberDialog(
  BuildContext context, {
  required String messId,
  Member? existing,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AddEditMemberDialog(messId: messId, existing: existing),
  );
}

/// Add-or-edit form for a member (section 19), as a compact popup rather
/// than a full page. Adding people — especially several in a row during
/// first-time setup — is quick and frequent enough that a dialog keeps the
/// manager in context instead of navigating away and back each time.
class AddEditMemberDialog extends ConsumerStatefulWidget {
  final String messId;
  final Member? existing;

  const AddEditMemberDialog({super.key, required this.messId, this.existing});

  @override
  ConsumerState<AddEditMemberDialog> createState() =>
      _AddEditMemberDialogState();
}

class _AddEditMemberDialogState extends ConsumerState<AddEditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;
  bool _addAnother = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.existing?.phone ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      final repo = ref.read(memberRepositoryProvider);
      if (_isEditing) {
        await repo.updateMember(
          widget.existing!.copyWith(
            name: name,
            phone: phone,
            clearPhone: phone.isEmpty,
          ),
        );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        await repo.addMember(
          messId: widget.messId,
          name: name,
          phone: phone.isEmpty ? null : phone,
        );
        if (_addAnother) {
          _nameController.clear();
          _phoneController.clear();
          setState(() {});
        } else if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't save this member. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Member' : 'Add Member'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
              onFieldSubmitted: (_) => _save(),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Add another after saving'),
                value: _addAnother,
                onChanged: (value) => setState(() => _addAnother = value),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
