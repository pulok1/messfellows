/// App-wide constants that aren't tied to a specific feature.
class AppConstants {
  AppConstants._();

  static const String appName = 'Mess Fellows';
  static const String databaseFileName = 'mess_fellows';

  /// Bumped whenever the JSON backup format changes shape; import rejects
  /// files from a newer version than this app understands.
  static const int backupFormatVersion = 1;

  static const String defaultCurrencySymbol = '৳';
  static const String defaultCurrencyCode = 'BDT';

  /// Suggested category keys for a bazar/expense entry. The field itself is
  /// free text, so a manager can type anything — these just seed quick-pick
  /// chips. Kept as keys (not literal English words) so the chip labels can
  /// be localized; see `AddEditExpenseScreen._categoryLabel`.
  static const List<String> expenseCategoryKeys = [
    'grocery',
    'vegetables',
    'fish',
    'meat',
    'eggDairy',
    'spices',
    'gas',
    'utensils',
    'other',
  ];
}
