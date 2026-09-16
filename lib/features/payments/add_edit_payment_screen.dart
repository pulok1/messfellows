import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/money.dart';
import '../../models/member.dart';
import '../../models/payment.dart';
import '../../providers/member_providers.dart';
import '../../providers/repository_providers.dart';
import '../shared/widgets/confirm_dialog.dart';

/// Add-or-edit form for a member payment/contribution (section 17).
class AddEditPaymentScreen extends ConsumerStatefulWidget {
  final String messId;
  final Payment? existing;

  /// Preselects the member — used when opened from a member's detail page.
  final String? initialMemberId;

  const AddEditPaymentScreen({
    super.key,
    required this.messId,
    this.existing,
    this.initialMemberId,
  });

  @override
  ConsumerState<AddEditPaymentScreen> createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends ConsumerState<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _memberId;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _date = existing?.date ?? DateTime.now();
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.major.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _memberId = existing?.memberId ?? widget.initialMemberId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_memberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please choose a member.')));
      return;
    }

    setState(() => _isSaving = true);
    final amount = Money.fromMajor(double.parse(_amountController.text.trim()));
    final note = _noteController.text.trim();

    try {
      final repo = ref.read(paymentRepositoryProvider);
      if (_isEditing) {
        await repo.updatePayment(
          widget.existing!.copyWith(
            date: _date,
            memberId: _memberId,
            amount: amount,
            note: note,
            clearNote: note.isEmpty,
          ),
        );
      } else {
        await repo.addPayment(
          messId: widget.messId,
          date: _date,
          memberId: _memberId!,
          amount: amount,
          note: note.isEmpty ? null : note,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save this payment. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete this payment?',
      message: 'This will remove it from the monthly calculation.',
    );
    if (!confirmed) return;
    await ref.read(paymentRepositoryProvider).deletePayment(widget.existing!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(activeMembersProvider(widget.messId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Payment' : 'Add Payment'),
        actions: [
          if (_isEditing)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(_formatDate(_date)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                membersAsync.when(
                  data: (members) => _MemberField(
                    members: members,
                    selectedId: _memberId,
                    onChanged: (id) => setState(() => _memberId = id),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text("Couldn't load members."),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${AppConstants.defaultCurrencySymbol} ',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Add Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberField extends StatelessWidget {
  final List<Member> members;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _MemberField({required this.members, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: members.any((m) => m.id == selectedId) ? selectedId : null,
      decoration: const InputDecoration(labelText: 'Member'),
      items: members
          .map((member) => DropdownMenuItem(value: member.id, child: Text(member.name)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
