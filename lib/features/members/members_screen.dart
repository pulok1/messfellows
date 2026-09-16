import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/member.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../../providers/repository_providers.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';
import 'add_edit_member_screen.dart';
import 'member_detail_screen.dart';

/// Member management (section 19): active members with this month's meal
/// count, plus an archived section for people who've left — kept, not
/// deleted, so their historical records stay valid.
class MembersScreen extends ConsumerWidget {
  final String messId;

  const MembersScreen({super.key, required this.messId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final allMembersAsync = ref.watch(allMembersProvider(messId));
    final calculation = ref.watch(
      monthCalculationProvider((
        messId: messId,
        year: now.year,
        month: now.month,
      )),
    );
    final mealCountByMember = {
      for (final balance in calculation.memberBalances)
        balance.memberId: balance.mealCount,
    };

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditMemberScreen(messId: messId),
          ),
        ),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add Member'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const PageHeaderCard(title: 'Members'),
            Expanded(
              child: allMembersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return EmptyState(
                      icon: Icons.group_outlined,
                      title: 'No members yet',
                      message: 'Add the people in your mess to start tracking meals and bazar.',
                      actionLabel: 'Add Member',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditMemberScreen(messId: messId),
                        ),
                      ),
                    );
                  }

                  final active = members.where((m) => m.isActive).toList();
                  final archived = members.where((m) => !m.isActive).toList();

                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      for (final member in active)
                        _MemberTile(
                          member: member,
                          mealCount: mealCountByMember[member.id] ?? 0,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MemberDetailScreen(
                                messId: messId,
                                memberId: member.id,
                              ),
                            ),
                          ),
                        ),
                      if (archived.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'Archived',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ),
                        for (final member in archived)
                          _MemberTile(
                            member: member,
                            mealCount: mealCountByMember[member.id] ?? 0,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MemberDetailScreen(
                                  messId: messId,
                                  memberId: member.id,
                                ),
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) =>
                    const Center(child: Text("Couldn't load members.")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  final Member member;
  final int mealCount;
  final VoidCallback onTap;

  const _MemberTile({
    required this.member,
    required this.mealCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: member.isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(member.name.isEmpty ? '?' : member.name[0].toUpperCase()),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          member.isActive ? '$mealCount meals this month' : 'Archived',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (member.isActive)
              const PopupMenuItem(value: 'archive', child: Text('Archive'))
            else
              const PopupMenuItem(
                value: 'reactivate',
                child: Text('Reactivate'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    switch (action) {
      case 'edit':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AddEditMemberScreen(messId: member.messId, existing: member),
          ),
        );
      case 'archive':
        final confirmed = await confirmDestructiveAction(
          context,
          title: 'Archive ${member.name}?',
          message: 'They will no longer appear in meal/bazar/payment entry, but their history is kept.',
          confirmLabel: 'Archive',
        );
        if (confirmed) {
          await ref.read(memberRepositoryProvider).archiveMember(member.id);
        }
      case 'reactivate':
        await ref.read(memberRepositoryProvider).reactivateMember(member.id);
    }
  }
}
