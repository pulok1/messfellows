/// Where the optional cloud sync backend lives. Both values are baked in at
/// build time (`--dart-define-from-file=supabase.json` locally, repository
/// variables in CI — see supabase/README.md) rather than committed, so a
/// build without them is simply an offline-only app with the cloud section
/// hidden.
///
/// The publishable key (or the legacy anon key) is safe to ship inside the
/// app: every row is guarded by row-level security on the server, not by
/// keeping this secret.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
