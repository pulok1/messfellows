/// App-wide constants that aren't tied to a specific feature.
class AppConstants {
  AppConstants._();

  static const String appName = 'Mess Fellows';
  static const String databaseFileName = 'mess_fellows';

  /// Bumped whenever the JSON backup format changes shape; import rejects
  /// files from a newer version than this app understands.
  static const int backupFormatVersion = 2;

  static const String defaultCurrencySymbol = '৳';
  static const String defaultCurrencyCode = 'BDT';
}
