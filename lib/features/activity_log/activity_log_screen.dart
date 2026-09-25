import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/activity_log_entry.dart';
import '../../models/activity_type.dart';
import '../../providers/activity_log_providers.dart';
import '../../providers/member_providers.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';
import '../shared/widgets/section_header.dart';

enum _Filter { all, bazar, payments, members, rules, settlement }

const _bazarTypes = {
  ActivityType.bazarAdded,
  ActivityType.bazarEdited,
  ActivityType.bazarDeleted,
  ActivityType.bazarRestored,
  ActivityType.bazarPurged,
};
const _paymentTypes = {
  ActivityType.paymentAdded,
  ActivityType.paymentEdited,
  ActivityType.paymentDeleted,
  ActivityType.paymentRestored,
  ActivityType.paymentPurged,
};
const _memberTypes = {
  ActivityType.memberAdded,
  ActivityType.memberArchived,
  ActivityType.memberReactivated,
};
const _ruleTypes = {
  ActivityType.ruleAdded,
  ActivityType.rulesBulkAdded,
  ActivityType.ruleUpdated,
  ActivityType.ruleDeleted,
};
const _settlementTypes = {ActivityType.monthClosed, ActivityType.monthReopened};

/// A permanent, filterable history of meaningful changes across the mess —
/// bazar and payment entries, members, rules, month close/reopen. Routine
/// meal-slot taps are deliberately excluded (see ActivityType's doc
/// comment) so the log stays a signal, not a firehose.
class ActivityLogScreen extends ConsumerStatefulWidget {
  final String messId;

  const ActivityLogScreen({super.key, required this.messId});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  _Filter _filter = _Filter.all;

  bool _matches(ActivityType type) {
    return switch (_filter) {
      _Filter.all => true,
      _Filter.bazar => _bazarTypes.contains(type),
      _Filter.payments => _paymentTypes.contains(type),
      _Filter.members => _memberTypes.contains(type),
      _Filter.rules => _ruleTypes.contains(type),
      _Filter.settlement => _settlementTypes.contains(type),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logAsync = ref.watch(activityLogProvider(widget.messId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: l10n.activityLogTitle),
            _FilterRow(filter: _filter, onChanged: (f) => setState(() => _filter = f)),
            Expanded(
              child: logAsync.when(
                data: (entries) => _buildList(context, l10n, entries),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.couldntLoadActivityLog)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<ActivityLogEntry> entries,
  ) {
    final filtered = entries.where((e) => _matches(e.type)).toList();
    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: l10n.activityLogEmptyTitle,
        message: l10n.activityLogEmptyMessage,
      );
    }

    final children = <Widget>[];
    DateTime? lastDay;
    for (final entry in filtered) {
      final day = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      if (lastDay == null || day != lastDay) {
        if (lastDay != null) children.add(const SizedBox(height: AppSpacing.sm));
        children.add(
          SectionHeader(_dayLabel(context, l10n, day), padding: _sectionPadding),
        );
        lastDay = day;
      }
      children.add(_ActivityTile(messId: widget.messId, entry: entry));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: children,
    );
  }

  String _dayLabel(BuildContext context, AppLocalizations l10n, DateTime day) {
    final today = DateTime.now();
    final diff = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(day).inDays;
    if (diff == 0) return l10n.todayLabel;
    if (diff == 1) return l10n.yesterdayLabel;
    return formatFullDate(context, day);
  }
}

const _sectionPadding = EdgeInsets.fromLTRB(AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.xs);

class _FilterRow extends StatelessWidget {
  final _Filter filter;
  final ValueChanged<_Filter> onChanged;

  const _FilterRow({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(_Filter, String)>[
      (_Filter.all, l10n.allChip),
      (_Filter.bazar, l10n.navBazar),
      (_Filter.payments, l10n.paymentsLabel),
      (_Filter.members, l10n.membersLabel),
      (_Filter.rules, l10n.activityFilterRules),
      (_Filter.settlement, l10n.settlementLabel),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          for (final (value, label) in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(label),
                selected: filter == value,
                onSelected: (_) => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  final String messId;
  final ActivityLogEntry entry;

  const _ActivityTile({required this.messId, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final members = ref.watch(allMembersProvider(messId)).value ?? const [];
    final member = entry.memberId == null
        ? null
        : members.firstWhereOrNull((m) => m.id == entry.memberId);

    final (icon, tone) = _iconAndTone(entry.type);
    final color = switch (tone) {
      _Tone.positive => colorScheme.primary,
      _Tone.neutral => colorScheme.onSurfaceVariant,
      _Tone.destructive => colorScheme.error,
    };

    final title = _title(l10n, entry);
    final subtitleParts = <String>[
      if (member != null) member.name,
      if (entry.type == ActivityType.monthClosed ||
          entry.type == ActivityType.monthReopened)
        formatMonthYear(context, entry.year!, entry.month!)
      else if (entry.detail != null && entry.detail!.isNotEmpty)
        entry.detail!,
      formatTimeOfDay(context, entry.createdAt),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(icon, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: entry.amount == null
            ? null
            : Text(
                entry.amount!.format(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  String _title(AppLocalizations l10n, ActivityLogEntry entry) {
    return switch (entry.type) {
      ActivityType.bazarAdded => l10n.activityBazarAdded,
      ActivityType.bazarEdited => l10n.activityBazarEdited,
      ActivityType.bazarDeleted => l10n.activityBazarDeleted,
      ActivityType.bazarRestored => l10n.activityBazarRestored,
      ActivityType.bazarPurged => l10n.activityBazarPurged,
      ActivityType.paymentAdded => l10n.activityPaymentAdded,
      ActivityType.paymentEdited => l10n.activityPaymentEdited,
      ActivityType.paymentDeleted => l10n.activityPaymentDeleted,
      ActivityType.paymentRestored => l10n.activityPaymentRestored,
      ActivityType.paymentPurged => l10n.activityPaymentPurged,
      ActivityType.memberAdded => l10n.activityMemberAdded,
      ActivityType.memberArchived => l10n.activityMemberArchived,
      ActivityType.memberReactivated => l10n.activityMemberReactivated,
      ActivityType.ruleAdded => l10n.activityRuleAdded,
      ActivityType.rulesBulkAdded => l10n.activityRulesBulkAdded(entry.count ?? 0),
      ActivityType.ruleUpdated => l10n.activityRuleUpdated,
      ActivityType.ruleDeleted => l10n.activityRuleDeleted,
      ActivityType.monthClosed => l10n.activityMonthClosed,
      ActivityType.monthReopened => l10n.activityMonthReopened,
    };
  }

  (IconData, _Tone) _iconAndTone(ActivityType type) {
    return switch (type) {
      ActivityType.bazarAdded ||
      ActivityType.paymentAdded ||
      ActivityType.ruleAdded ||
      ActivityType.rulesBulkAdded ||
      ActivityType.memberAdded => (Icons.add_circle_outline, _Tone.positive),
      ActivityType.bazarEdited ||
      ActivityType.paymentEdited ||
      ActivityType.ruleUpdated => (Icons.edit_outlined, _Tone.neutral),
      ActivityType.bazarDeleted ||
      ActivityType.paymentDeleted ||
      ActivityType.ruleDeleted => (Icons.delete_outline, _Tone.destructive),
      ActivityType.bazarRestored ||
      ActivityType.paymentRestored ||
      ActivityType.memberReactivated => (
        Icons.restore_outlined,
        _Tone.positive,
      ),
      ActivityType.bazarPurged ||
      ActivityType.paymentPurged => (
        Icons.delete_forever_outlined,
        _Tone.destructive,
      ),
      ActivityType.memberArchived => (Icons.archive_outlined, _Tone.neutral),
      ActivityType.monthClosed => (Icons.lock_outline, _Tone.positive),
      ActivityType.monthReopened => (Icons.lock_open_outlined, _Tone.neutral),
    };
  }
}

enum _Tone { positive, neutral, destructive }
