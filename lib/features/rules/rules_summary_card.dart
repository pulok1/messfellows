import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/mess_provider.dart';
import '../../providers/rule_providers.dart';
import 'rules_screen.dart';

/// A glanceable Dashboard entry point to the mess rules: how many there are,
/// how many are important, and when they last changed. Prompts the manager
/// to set rules up when there are none yet.
class RulesSummaryCard extends ConsumerWidget {
  final String messId;

  const RulesSummaryCard({super.key, required this.messId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final rules = ref.watch(rulesProvider(messId)).value;
    // Nothing useful to show while loading or if the read failed; the card
    // is a shortcut, not something worth an error state on the Dashboard.
    if (rules == null) return const SizedBox.shrink();

    final updatedAt = ref.watch(currentMessProvider).value?.rulesUpdatedAt;
    final importantCount = rules.where((r) => r.isImportant).length;
    final isEmpty = rules.isEmpty;

    final title = isEmpty ? l10n.rulesSummaryEmptyTitle : l10n.rulesTitle;
    final subtitle = isEmpty
        ? l10n.rulesSummaryEmptyMessage
        : [
            l10n.rulesSummaryCount(rules.length),
            if (importantCount > 0) l10n.rulesSummaryImportant(importantCount),
          ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RulesScreen(messId: messId)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Icon(
                  Icons.gavel_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!isEmpty && updatedAt != null)
                      Text(
                        l10n.rulesLastUpdated(formatShortDate(context, updatedAt)),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
