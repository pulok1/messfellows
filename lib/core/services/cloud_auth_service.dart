import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Email + password accounts for cloud sync. Signing in or out only flips
/// the session; lib/providers/sync_providers.dart reacts to that and starts
/// or stops syncing.
class CloudAuthService {
  final GoTrueClient _auth;

  CloudAuthService(this._auth);

  /// Where Google sends the user back to on Android — matches the
  /// intent-filter in AndroidManifest.xml and must be listed under the
  /// project's Redirect URLs (see supabase/README.md).
  static const mobileRedirect = 'com.pulok.messfellows://login-callback';

  /// Opens Google's sign-in page. Covers both sign-in and sign-up: a new
  /// Google account simply becomes a new user. Returns as soon as the page
  /// opens — the session arrives later, when Google redirects back, through
  /// the auth state stream.
  Future<void> signInWithGoogle() async {
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      // On the web app, come back to the page we're on.
      redirectTo: kIsWeb
          ? '${Uri.base.origin}${Uri.base.path}'
          : mobileRedirect,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  /// Returns false when the project requires email confirmation, so there
  /// is no session yet and the user has to confirm, then sign in.
  Future<bool> signUp(String email, String password) async {
    final response = await _auth.signUp(email: email, password: password);
    return response.session != null;
  }

  /// Emails a one-time code (the project's "Reset password" email template
  /// must include `{{ .Token }}` — see supabase/README.md). A code instead of
  /// a link, so no deep-link setup is needed.
  Future<void> sendPasswordResetCode(String email) =>
      _auth.resetPasswordForEmail(email);

  /// Verifies the emailed code (which signs the user in) and sets the new
  /// password.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _auth.verifyOTP(email: email, token: code, type: OtpType.recovery);
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _auth.signOut();
}
