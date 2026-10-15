/// Where the optional cloud sync backend lives.
///
/// Defaults to the production project, so every build (including a plain
/// `flutter run`) has cloud sync. A different project can be swapped in at
/// build time with `--dart-define-from-file=supabase.json` (see
/// supabase/README.md); defining both values as empty strings builds an
/// offline-only app with the cloud section hidden.
///
/// The publishable key is safe to commit and ship inside the app: every row
/// is guarded by row-level security on the server, not by keeping this
/// secret.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kppnsbkztvyrnfsepquk.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_s03JQBaKxwXWQ5sZaH7cgQ_GhpCsf4b',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
