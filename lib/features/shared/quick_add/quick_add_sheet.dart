import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../bazar/add_edit_expense_dialog.dart';
import '../../payments/add_edit_payment_screen.dart';

/// The core Quick Add UX (section 13): one tap from anywhere in the app to
/// Meal / Bazar / Payment. "Meal" hands off to the Meals tab (already the
/// fastest possible flow — tap-to-toggle, see MealsScreen) rather than a
/// form, since the whole point is that meal-off should take no more than a
/// couple of taps.
Future<void> showQuickAddSheet(
  BuildContext context, {
  required String messId,
  required VoidCallback onSelectMeal,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.quickAddTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              _QuickAddOption(
                icon: Icons.restaurant,
                label: l10n.quickAddMealLabel,
                subtitle: l10n.quickAddMealSubtitle,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelectMeal();
                },
              ),
              _QuickAddOption(
                icon: Icons.shopping_basket_outlined,
                label: l10n.navBazar,
                subtitle: l10n.quickAddBazarSubtitle,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await showAddEditExpenseDialog(context, messId: messId);
                },
              ),
              _QuickAddOption(
                icon: Icons.payments_outlined,
                label: l10n.quickAddPaymentLabel,
                subtitle: l10n.quickAddPaymentSubtitle,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditPaymentScreen(messId: messId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuickAddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAddOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Icon(icon),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }
}
