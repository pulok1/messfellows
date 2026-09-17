import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../core/utils/money.dart';
import '../../l10n/gen/app_localizations.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseChooseWhoPaid)),
      );
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
          SnackBar(content: Text(AppLocalizations.of(context).couldntSaveBazarEntry)),
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
      title: l10n.deleteBazarEntryConfirmTitle,
      message: l10n.removeFromMonthlyCalcMessage,
    );
    if (!confirmed) return;
    await ref
        .read(expenseRepositoryProvider)
        .deleteExpense(widget.existing!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final membersAsync = ref.watch(activeMembersProvider(widget.messId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: _isEditing ? l10n.editBazarTitle : l10n.addBazarTitle,
              actions: [
                if (_isEditing)
                  HeaderIconButton(
                    icon: Icons.delete_outline,
                    tooltip: l10n.deleteTooltip,
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
    final l10n = AppLocalizations.of(context);
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
                decoration: InputDecoration(labelText: l10n.dateLabel),
                child: Text(formatShortDate(context, _date)),
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
                labelText: l10n.amountLabel,
                prefixText: '${AppConstants.defaultCurrencySymbol} ',
              ),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) {
                  return l10n.enterValidAmount;
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
              error: (_, _) => Text(l10n.couldntLoadMembers),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: l10n.categoryLabel),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.enterCategoryValidator
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AppConstants.expenseCategoryKeys
                  .map(
                    (key) => ActionChip(
                      label: Text(_categoryLabel(l10n, key)),
                      onPressed: () => setState(
                        () => _categoryController.text = _categoryLabel(l10n, key),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: l10n.noteOptionalLabel),
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
                  : Text(_isEditing ? l10n.saveChanges : l10n.addBazarTitle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps a category key (see [AppConstants.expenseCategoryKeys]) to its
/// localized chip label.
String _categoryLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'grocery' => l10n.categoryGrocery,
    'vegetables' => l10n.categoryVegetables,
    'fish' => l10n.categoryFish,
    'meat' => l10n.categoryMeat,
    'eggDairy' => l10n.categoryEggDairy,
    'spices' => l10n.categorySpices,
    'gas' => l10n.categoryGas,
    'utensils' => l10n.categoryUtensils,
    _ => l10n.categoryOther,
  };
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
      decoration: InputDecoration(labelText: AppLocalizations.of(context).paidByLabel),
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
