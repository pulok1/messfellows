import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../providers/rule_providers.dart';
import 'rule_category_ui.dart';
import 'rule_templates.dart';

/// Shows the suggested-rules picker. Adds the chosen templates as ordinary
/// rules in one go and confirms with a snackbar.
Future<void> showRuleTemplatesSheet(
  BuildContext context, {
  required String messId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => RuleTemplatesSheet(messId: messId),
  );
}

class RuleTemplatesSheet extends ConsumerStatefulWidget {
  final String messId;

  const RuleTemplatesSheet({super.key, required this.messId});

  @override
  ConsumerState<RuleTemplatesSheet> createState() => _RuleTemplatesSheetState();
}

class _RuleTemplatesSheetState extends ConsumerState<RuleTemplatesSheet> {
  final _selected = <String>{};
  bool _isSaving = false;

  String _normalize(String title) => title.trim().toLowerCase();

  Future<void> _addSelected(List<RuleTemplate> chosen) async {
    if (_isSaving || chosen.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);

    try {
      await ref
          .read(ruleRepositoryProvider)
          .addRules(widget.messId, [
            for (final t in chosen)
              (
                title: t.title,
                details: t.details,
                category: t.category,
                isImportant: t.isImportant,
              ),
          ]);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.rulesAddedSnackbar(chosen.length))),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.couldntSaveRule)));
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final existingTitles = {
      for (final rule in ref.watch(rulesProvider(widget.messId)).value ?? [])
        _normalize(rule.title),
    };
    final templates = ruleTemplates(l10n);
    final available = [
      for (final t in templates)
        if (!existingTitles.contains(_normalize(t.title))) t,
    ];
    // Drop selections whose template just got added elsewhere.
    _selected.removeWhere((key) => !available.any((t) => t.key == key));
    final chosen = [
      for (final t in available)
        if (_selected.contains(t.key)) t,
    ];
    final allSelected = available.isNotEmpty && chosen.length == available.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suggestedRulesTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.suggestedRulesSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (available.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() {
                    if (allSelected) {
                      _selected.clear();
                    } else {
                      _selected
                        ..clear()
                        ..addAll(available.map((t) => t.key));
                    }
                  }),
                  child: Text(
                    allSelected ? l10n.clearSelectionLabel : l10n.selectAllLabel,
                  ),
                ),
            ],
          ),
        ),
        Flexible(
          child: available.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.allSuggestionsAdded,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  children: [
                    for (final t in available)
                      CheckboxListTile(
                        value: _selected.contains(t.key),
                        onChanged: _isSaving
                            ? null
                            : (checked) => setState(() {
                                if (checked ?? false) {
                                  _selected.add(t.key);
                                } else {
                                  _selected.remove(t.key);
                                }
                              }),
                        controlAffinity: ListTileControlAffinity.leading,
                        secondary: Icon(
                          t.category.icon,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          t.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(t.details),
                      ),
                  ],
                ),
        ),
        if (available.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: chosen.isEmpty || _isSaving
                    ? null
                    : () => _addSelected(chosen),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.addSelectedRules(chosen.length)),
              ),
            ),
          ),
      ],
    );
  }
}
