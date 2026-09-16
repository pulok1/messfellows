import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/money.dart';
import '../../models/expense.dart';
import '../../models/member.dart';
import '../../providers/member_providers.dart';
import '../../providers/repository_providers.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/page_header_card.dart';

/// Add-or-edit form for a bazar/expense entry (section 16). Date defaults
/// to today and the amount field opens the numeric keypad, per the UX spec.
class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final String messId;
  final Expense? existing;

  const AddEditExpenseScreen({super.key, required this.messId, this.existing});

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  String? _paidByMemberId;
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
    _categoryController = TextEditingController(text: existing?.category ?? '');
    _noteController = TextEditingController(text: existing?.note ?? '');
    _paidByMemberId = existing?.paidByMemberId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
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
    if (_paidByMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please choose who paid.')));
      return;
    }

    setState(() => _isSaving = true);
    final amount = Money.fromMajor(double.parse(_amountController.text.trim()));
    final category = _categoryController.text.trim();
    final note = _noteController.text.trim();

    try {
      final repo = ref.read(expenseRepositoryProvider);
      if (_isEditing) {
        await repo.updateExpense(
          widget.existing!.copyWith(
            date: _date,
            amount: amount,
            paidByMemberId: _paidByMemberId,
            category: category,
            note: note,
            clearNote: note.isEmpty,
          ),
        );
      } else {
        await repo.addExpense(
          messId: widget.messId,
          date: _date,
          amount: amount,
          paidByMemberId: _paidByMemberId!,
          category: category,
          note: note.isEmpty ? null : note,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't save this bazar entry. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete this bazar entry?',
      message: 'This will remove it from the monthly calculation.',
    );
    if (!confirmed) return;
    await ref
        .read(expenseRepositoryProvider)
        .deleteExpense(widget.existing!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(activeMembersProvider(widget.messId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: _isEditing ? 'Edit Bazar' : 'Add Bazar',
              actions: [
                if (_isEditing)
                  HeaderIconButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete',
                    onPressed: _delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            Expanded(child: _buildForm(membersAsync)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AsyncValue<List<Member>> membersAsync) {
    return SingleChildScrollView(
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
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${AppConstants.defaultCurrencySymbol} ',
              ),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            membersAsync.when(
              data: (members) => _PaidByField(
                members: members,
                selectedId: _paidByMemberId,
                onChanged: (id) => setState(() => _paidByMemberId = id),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text("Couldn't load members."),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter a category'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AppConstants.expenseCategories
                  .map(
                    (category) => ActionChip(
                      label: Text(category),
                      onPressed: () =>
                          setState(() => _categoryController.text = category),
                    ),
                  )
                  .toList(),
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
                  : Text(_isEditing ? 'Save Changes' : 'Add Bazar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaidByField extends StatelessWidget {
  final List<Member> members;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _PaidByField({
    required this.members,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: members.any((m) => m.id == selectedId) ? selectedId : null,
      decoration: const InputDecoration(labelText: 'Paid by'),
      items: members
          .map(
            (member) =>
                DropdownMenuItem(value: member.id, child: Text(member.name)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
