import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/member.dart';
import '../../providers/repository_providers.dart';
import '../shared/widgets/page_header_card.dart';

/// Add-or-edit form for a member (section 19). Deliberately short — just
/// name and an optional phone number — since the manager needs to add
/// several people quickly when first setting up the mess.
class AddEditMemberScreen extends ConsumerStatefulWidget {
  final String messId;
  final Member? existing;

  const AddEditMemberScreen({super.key, required this.messId, this.existing});

  @override
  ConsumerState<AddEditMemberScreen> createState() =>
      _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends ConsumerState<AddEditMemberScreen> {
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: _isEditing ? 'Edit Member' : 'Add Member'),
            Expanded(child: _buildForm(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
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
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Add another after saving'),
                value: _addAnother,
                onChanged: (value) => setState(() => _addAnother = value),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
