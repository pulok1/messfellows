import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/expense.dart';
import '../../models/payment.dart';
import '../../providers/expense_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/payment_providers.dart';
import '../../providers/repository_providers.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/expandable_text.dart';
import '../shared/widgets/page_header_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/staggered_entrance.dart';

/// Deleted bazar entries and payments (section 35): a delete moves an
/// entry here instead of destroying it outright, so it can be restored or
/// purged for good. Anything left here purges itself automatically after
/// [AppConstants.recycleBinRetentionDays] — see recycle_bin_purge_provider.
///
/// Each tile can be swiped as well as opened via its menu — right to
/// restore, left to delete forever — for anyone who prefers a swipe to a
/// tap-and-pick.
class RecycleBinScreen extends ConsumerWidget {
  final String messId;

  const RecycleBinScreen({super.key, required this.messId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expensesAsync = ref.watch(deletedExpensesProvider(messId));
    final paymentsAsync = ref.watch(deletedPaymentsProvider(messId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: l10n.recycleBinTitle),
            Expanded(
              child: _buildBody(context, ref, l10n, expensesAsync, paymentsAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue<List<Expense>> expensesAsync,
    AsyncValue<List<Payment>> paymentsAsync,
  ) {
    if (expensesAsync.isLoading && paymentsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (expensesAsync.hasError || paymentsAsync.hasError) {
      return Center(child: Text(l10n.couldntLoadRecycleBin));
    }

    final expenses = expensesAsync.value ?? const <Expense>[];
    final payments = paymentsAsync.value ?? const <Payment>[];

    if (expenses.isEmpty && payments.isEmpty) {
      return EmptyState(
        icon: Icons.restore_from_trash_outlined,
        title: l10n.recycleBinEmptyTitle,
        message: l10n.recycleBinEmptyMessage,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            0,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Text(
            l10n.recycleBinExplain(AppConstants.recycleBinRetentionDays),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (expenses.isNotEmpty) ...[
          SectionHeader(l10n.navBazar, padding: _sectionHeaderPadding),
          for (final (i, expense) in expenses.indexed)
            StaggeredEntrance(
              key: ValueKey(expense.id),
              index: i,
              child: _DeletedExpenseTile(messId: messId, expense: expense),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (payments.isNotEmpty) ...[
          SectionHeader(l10n.paymentsLabel, padding: _sectionHeaderPadding),
          for (final (i, payment) in payments.indexed)
            StaggeredEntrance(
              key: ValueKey(payment.id),
              index: expenses.length + i,
              child: _DeletedPaymentTile(messId: messId, payment: payment),
            ),
        ],
      ],
    );
  }
}

const _sectionHeaderPadding = EdgeInsets.fromLTRB(
  AppSpacing.xs,
  0,
  AppSpacing.xs,
  AppSpacing.sm,
);

/// "Deleted 3 days ago · auto-deletes in 27 days" — null-safe: only
/// meaningful once the row actually has a deletedAt (always true here).
String _purgeInfo(BuildContext context, DateTime? deletedAt) {
  final l10n = AppLocalizations.of(context);
  if (deletedAt == null) return '';
  final daysLeft =
      AppConstants.recycleBinRetentionDays -
      DateTime.now().difference(deletedAt).inDays;
  return l10n.deletedAndPurgeInfo(
    formatShortDate(context, deletedAt),
    daysLeft < 0 ? 0 : daysLeft,
  );
}

/// The colored panel revealed behind a tile while it's being swiped.
class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm,
        children: alignment == Alignment.centerLeft
            ? [Icon(icon, color: Colors.white), Text(label, style: textStyle)]
            : [Text(label, style: textStyle), Icon(icon, color: Colors.white)],
      ),
    );
  }
}

class _DeletedExpenseTile extends ConsumerWidget {
  final String messId;
  final Expense expense;

  const _DeletedExpenseTile({required this.messId, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final members = ref.watch(allMembersProvider(messId)).value ?? const [];
    final payer = members.firstWhereOrNull(
      (m) => m.id == expense.paidByMemberId,
    );

    return Dismissible(
      key: ValueKey(expense.id),
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: colorScheme.primary,
        icon: Icons.restore_outlined,
        label: l10n.restoreAction,
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: colorScheme.error,
        icon: Icons.delete_forever_outlined,
        label: l10n.deleteForeverAction,
      ),
      confirmDismiss: (direction) => direction == DismissDirection.startToEnd
          ? _restore(ref)
          : _purge(context, ref),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          title: ExpandableText(
            expense.bazarList,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${payer?.name ?? l10n.unknown} · ${_purgeInfo(context, expense.deletedAt)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expense.amount.format(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              PopupMenuButton<String>(
                onSelected: (action) => action == 'restore'
                    ? _restore(ref)
                    : _purge(context, ref),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'restore', child: Text(l10n.restoreAction)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.deleteForeverAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _restore(WidgetRef ref) async {
    await ref.read(expenseRepositoryProvider).restoreExpense(expense.id);
    HapticFeedback.lightImpact();
    return true;
  }

  Future<bool> _purge(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructiveAction(
      context,
      title: l10n.deleteForeverConfirmTitle,
      message: l10n.deleteForeverConfirmMessage,
      confirmLabel: l10n.deleteForeverAction,
    );
    if (confirmed) {
      await ref.read(expenseRepositoryProvider).permanentlyDeleteExpense(expense.id);
      HapticFeedback.mediumImpact();
    }
    return confirmed;
  }
}

class _DeletedPaymentTile extends ConsumerWidget {
  final String messId;
  final Payment payment;

  const _DeletedPaymentTile({required this.messId, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final members = ref.watch(allMembersProvider(messId)).value ?? const [];
    final member = members.firstWhereOrNull((m) => m.id == payment.memberId);

    return Dismissible(
      key: ValueKey(payment.id),
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: colorScheme.primary,
        icon: Icons.restore_outlined,
        label: l10n.restoreAction,
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: colorScheme.error,
        icon: Icons.delete_forever_outlined,
        label: l10n.deleteForeverAction,
      ),
      confirmDismiss: (direction) => direction == DismissDirection.startToEnd
          ? _restore(ref)
          : _purge(context, ref),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          title: Text(
            member?.name ?? l10n.unknown,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(_purgeInfo(context, payment.deletedAt)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                payment.amount.format(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              PopupMenuButton<String>(
                onSelected: (action) => action == 'restore'
                    ? _restore(ref)
                    : _purge(context, ref),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'restore', child: Text(l10n.restoreAction)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.deleteForeverAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _restore(WidgetRef ref) async {
    await ref.read(paymentRepositoryProvider).restorePayment(payment.id);
    HapticFeedback.lightImpact();
    return true;
  }

  Future<bool> _purge(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructiveAction(
      context,
      title: l10n.deleteForeverConfirmTitle,
      message: l10n.deleteForeverConfirmMessage,
      confirmLabel: l10n.deleteForeverAction,
    );
    if (confirmed) {
      await ref.read(paymentRepositoryProvider).permanentlyDeletePayment(payment.id);
      HapticFeedback.mediumImpact();
    }
    return confirmed;
  }
}
