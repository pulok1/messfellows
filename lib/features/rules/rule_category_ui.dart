import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/rule_category.dart';

/// Presentation details for [RuleCategory], kept out of the domain model so
/// lib/models stays free of Flutter and l10n imports.
extension RuleCategoryUi on RuleCategory {
  IconData get icon => switch (this) {
    RuleCategory.meals => Icons.restaurant_outlined,
    RuleCategory.bazar => Icons.shopping_basket_outlined,
    RuleCategory.payments => Icons.payments_outlined,
    RuleCategory.guests => Icons.people_outline,
    RuleCategory.cleanliness => Icons.cleaning_services_outlined,
    RuleCategory.quietHours => Icons.bedtime_outlined,
    RuleCategory.other => Icons.rule_outlined,
  };

  String label(AppLocalizations l10n) => switch (this) {
    RuleCategory.meals => l10n.ruleCategoryMeals,
    RuleCategory.bazar => l10n.ruleCategoryBazar,
    RuleCategory.payments => l10n.ruleCategoryPayments,
    RuleCategory.guests => l10n.ruleCategoryGuests,
    RuleCategory.cleanliness => l10n.ruleCategoryCleanliness,
    RuleCategory.quietHours => l10n.ruleCategoryQuietHours,
    RuleCategory.other => l10n.ruleCategoryOther,
  };
}
