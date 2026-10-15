import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/cloud_auth_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/sync_providers.dart';
import 'auth_error_message.dart';

enum _Mode { signIn, signUp, reset }

/// Sign in / create account / reset password for cloud sync. Pops itself
/// once signed in — from there the sync engine takes over (see
/// syncEngineProvider), and AppRoot asks which data to keep if needed.
class CloudAccountScreen extends ConsumerStatefulWidget {
  const CloudAccountScreen({super.key});

  @override
  ConsumerState<CloudAccountScreen> createState() =>
      _CloudAccountScreenState();
}

class _CloudAccountScreenState extends ConsumerState<CloudAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  _Mode _mode = _Mode.signIn;
  bool _codeSent = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  CloudAuthService get _auth => ref.read(cloudAuthServiceProvider)!;

  void _setMode(_Mode mode) => setState(() {
    _mode = mode;
    _codeSent = false;
    _error = null;
    _info = null;
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      switch (_mode) {
        case _Mode.signIn:
          await _auth.signIn(email, _password.text);
          if (mounted) Navigator.of(context).pop();
        case _Mode.signUp:
          final signedIn = await _auth.signUp(email, _password.text);
          if (signedIn) {
            if (mounted) Navigator.of(context).pop();
          } else {
            _mode = _Mode.signIn;
            _info = l10n.accountCheckEmail;
          }
        case _Mode.reset when !_codeSent:
          await _auth.sendPasswordResetCode(email);
          _codeSent = true;
          _info = l10n.accountCodeSent(email);
        case _Mode.reset:
          await _auth.resetPassword(
            email: email,
            code: _code.text.trim(),
            newPassword: _password.text,
          );
          if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      _error = authErrorMessage(l10n, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      _error = authErrorMessage(l10n, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Google sign-in finishes in the browser and comes back through the
    // auth stream, not through _google() — close as soon as it lands.
    ref.listen(signedInUserIdProvider, (previous, next) {
      if (previous == null && next != null && mounted) {
        Navigator.of(context).maybePop();
      }
    });
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resetting = _mode == _Mode.reset;
    final needsPassword = !resetting || _codeSent;

    final submitLabel = switch (_mode) {
      _Mode.signIn => l10n.accountSignInTab,
      _Mode.signUp => l10n.accountCreateTab,
      _Mode.reset => _codeSent ? l10n.accountSetPassword : l10n.accountSendCode,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(resetting ? l10n.accountResetTitle : l10n.accountScreenTitle),
        leading: resetting
            ? BackButton(onPressed: () => _setMode(_Mode.signIn))
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        resetting
                            ? Icons.lock_reset_outlined
                            : Icons.cloud_sync_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        resetting
                            ? l10n.accountResetExplain
                            : l10n.cloudSyncExplain,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (!resetting) ...[
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _google,
                            icon: const _GoogleMark(),
                            label: Text(
                              l10n.accountContinueWithGoogle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                l10n.accountOrUseEmail,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SegmentedButton<_Mode>(
                          segments: [
                            ButtonSegment(
                              value: _Mode.signIn,
                              label: Text(l10n.accountSignInTab),
                            ),
                            ButtonSegment(
                              value: _Mode.signUp,
                              label: Text(l10n.accountCreateTab),
                            ),
                          ],
                          selected: {_mode},
                          showSelectedIcon: false,
                          onSelectionChanged: _busy
                              ? null
                              : (selection) => _setMode(selection.single),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      TextFormField(
                        controller: _email,
                        enabled: !(resetting && _codeSent),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountEmailLabel,
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
                              ? null
                              : l10n.accountEmailValidator;
                        },
                      ),
                      if (resetting && _codeSent) ...[
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _code,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.accountCodeLabel,
                            prefixIcon: const Icon(Icons.pin_outlined),
                          ),
                          validator: (value) =>
                              (value?.trim().length ?? 0) >= 6
                              ? null
                              : l10n.authErrorBadCode,
                        ),
                      ],
                      if (needsPassword) ...[
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: [
                            _mode == _Mode.signIn
                                ? AutofillHints.password
                                : AutofillHints.newPassword,
                          ],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _busy ? null : _submit(),
                          decoration: InputDecoration(
                            labelText: resetting
                                ? l10n.accountNewPasswordLabel
                                : l10n.accountPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (value) => (value?.length ?? 0) >= 6
                              ? null
                              : l10n.accountPasswordValidator,
                        ),
                      ],
                      if (_error != null || _info != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _error ?? _info!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: _error != null
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: _busy
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  submitLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      if (_mode == _Mode.signIn) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _setMode(_Mode.reset),
                          child: Text(l10n.accountForgotPassword),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A plain "G" in Google's blue, standing in for the logo so no image
/// asset is needed.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
