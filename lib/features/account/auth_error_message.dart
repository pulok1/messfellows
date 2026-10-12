import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../sync/remote_sync_api.dart';

/// A user-facing message for a failed sign-in/sign-up/reset or sync call.
/// Supabase's own messages are English-only, so the common cases are
/// translated and anything else falls back to the server's text.
String authErrorMessage(AppLocalizations l10n, Object error) {
  if (error is AuthRetryableFetchException ||
      error is SyncOfflineException ||
      error is SocketException ||
      error is http.ClientException ||
      error is TimeoutException) {
    return l10n.authErrorOffline;
  }
  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => l10n.authErrorInvalidCredentials,
      'email_not_confirmed' => l10n.authErrorEmailNotConfirmed,
      'user_already_exists' || 'email_exists' => l10n.authErrorUserExists,
      'weak_password' => l10n.authErrorWeakPassword,
      'over_email_send_rate_limit' ||
      'over_request_rate_limit' => l10n.authErrorRateLimit,
      'otp_expired' || 'otp_disabled' => l10n.authErrorBadCode,
      _ => error.message,
    };
  }
  if (error is PostgrestException) return error.message;
  return error.toString();
}
