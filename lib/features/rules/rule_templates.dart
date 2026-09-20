import '../../l10n/gen/app_localizations.dart';
import '../../models/rule_category.dart';

/// A ready-made rule the manager can add with one tap. The text comes from
/// the ARB files, so it's in the current language; once added it's copied
/// into the database as ordinary, editable rule text.
typedef RuleTemplate = ({
  String key,
  RuleCategory category,
  bool isImportant,
  String title,
  String details,
});

List<RuleTemplate> ruleTemplates(AppLocalizations l10n) => [
  (
    key: 'mealSkip',
    category: RuleCategory.meals,
    isImportant: true,
    title: l10n.tplMealSkipTitle,
    details: l10n.tplMealSkipDetails,
  ),
  (
    key: 'mealGuest',
    category: RuleCategory.meals,
    isImportant: false,
    title: l10n.tplMealGuestTitle,
    details: l10n.tplMealGuestDetails,
  ),
  (
    key: 'bazarRecord',
    category: RuleCategory.bazar,
    isImportant: false,
    title: l10n.tplBazarRecordTitle,
    details: l10n.tplBazarRecordDetails,
  ),
  (
    key: 'bazarList',
    category: RuleCategory.bazar,
    isImportant: false,
    title: l10n.tplBazarListTitle,
    details: l10n.tplBazarListDetails,
  ),
  (
    key: 'payDue',
    category: RuleCategory.payments,
    isImportant: true,
    title: l10n.tplPayDueTitle,
    details: l10n.tplPayDueDetails,
  ),
  (
    key: 'payLeaving',
    category: RuleCategory.payments,
    isImportant: false,
    title: l10n.tplPayLeavingTitle,
    details: l10n.tplPayLeavingDetails,
  ),
  (
    key: 'guestOvernight',
    category: RuleCategory.guests,
    isImportant: false,
    title: l10n.tplGuestOvernightTitle,
    details: l10n.tplGuestOvernightDetails,
  ),
  (
    key: 'cleanAfter',
    category: RuleCategory.cleanliness,
    isImportant: false,
    title: l10n.tplCleanAfterTitle,
    details: l10n.tplCleanAfterDetails,
  ),
  (
    key: 'cleanRoster',
    category: RuleCategory.cleanliness,
    isImportant: false,
    title: l10n.tplCleanRosterTitle,
    details: l10n.tplCleanRosterDetails,
  ),
  (
    key: 'quietHours',
    category: RuleCategory.quietHours,
    isImportant: false,
    title: l10n.tplQuietHoursTitle,
    details: l10n.tplQuietHoursDetails,
  ),
  (
    key: 'saveUtilities',
    category: RuleCategory.other,
    isImportant: false,
    title: l10n.tplSaveUtilitiesTitle,
    details: l10n.tplSaveUtilitiesDetails,
  ),
];
