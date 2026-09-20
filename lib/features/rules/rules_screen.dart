import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/rule.dart';
import '../../models/rule_category.dart';
import '../../providers/mess_provider.dart';
import '../../providers/rule_providers.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/expandable_text.dart';
import '../shared/widgets/page_header_card.dart';
import '../shared/widgets/section_header.dart';
import 'add_edit_rule_dialog.dart';
import 'rule_category_ui.dart';

/// The mess's house rules, grouped by category with important ones first.
/// The manager (whoever holds this device — there are no accounts) adds and
/// edits them here; everyone else reads them on the manager's phone.
class RulesScreen extends ConsumerWidget {
  final String messId;

  const RulesScreen({super.key, required this.messId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rulesAsync = ref.watch(rulesProvider(messId));
    final updatedAt = ref.watch(currentMessProvider).value?.rulesUpdatedAt;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditRuleDialog(context, messId: messId),
        icon: const Icon(Icons.add),
        label: Text(l10n.addRuleButton),
      ),
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: l10n.rulesTitle,
              subtitle: updatedAt == null
                  ? null
                  : l10n.rulesLastUpdated(formatShortDate(context, updatedAt)),
            ),
            Expanded(
              child: rulesAsync.when(
                data: (rules) {
                  if (rules.isEmpty) {
                    return EmptyState(
                      icon: Icons.gavel_outlined,
                      title: l10n.rulesEmptyTitle,
                      message: l10n.rulesEmptyMessage,
                    );
                  }
                  return _RulesList(messId: messId, rules: rules);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.couldntLoadRules)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesList extends StatelessWidget {
  final String messId;
  final List<Rule> rules;

  const _RulesList({required this.messId, required this.rules});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Rules arrive already ordered (category, important first), so a single
    // pass emits a header whenever the category changes. The number is the
    // rule's position across the whole list, so it can be quoted ("rule 7").
    final children = <Widget>[];
    RuleCategory? currentCategory;
    for (final (index, rule) in rules.indexed) {
      if (rule.category != currentCategory) {
        currentCategory = rule.category;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.lg),
            child: _CategoryHeader(category: rule.category, l10n: l10n),
          ),
        );
        children.add(const SizedBox(height: AppSpacing.sm));
      }
      children.add(
        _RuleCard(
          number: index + 1,
          rule: rule,
          onTap: () =>
              showAddEditRuleDialog(context, messId: messId, existing: rule),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        // Clears the extended FAB so the last card is never hidden behind it.
        88,
      ),
      children: children,
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final RuleCategory category;
  final AppLocalizations l10n;

  const _CategoryHeader({required this.category, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          category.icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: SectionHeader(category.label(l10n))),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final int number;
  final Rule rule;
  final VoidCallback onTap;

  const _RuleCard({
    required this.number,
    required this.rule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final details = rule.details;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: rule.isImportant
            ? BorderSide(color: colorScheme.tertiary.withValues(alpha: 0.6))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rule.isImportant
                      ? colorScheme.tertiaryContainer
                      : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: rule.isImportant
                        ? colorScheme.onTertiaryContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (rule.isImportant) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _ImportantBadge(label: l10n.importantBadge),
                    ],
                    if (details != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      ExpandableText(
                        details,
                        maxLines: 3,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportantBadge extends StatelessWidget {
  final String label;

  const _ImportantBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high,
            size: 14,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
