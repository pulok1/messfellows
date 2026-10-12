import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/account/sync_choice_dialog.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/mess_provider.dart';
import 'providers/sync_providers.dart';
import 'sync/sync_engine.dart';

/// Decides between onboarding and the main app shell based on whether a
/// mess has been created yet (section 42) — there is no login screen to
/// gate this, just local state. A mess pulled down by cloud sync flips it
/// the same way.
///
/// Also keeps the sync engine alive for as long as someone is signed in,
/// and asks which data to keep when a sign-in finds a mess on both sides.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(currentMessProvider);
    ref.watch(syncEngineProvider);
    ref.listen(syncStatusProvider, (previous, next) {
      final phase = next.value?.phase;
      if (phase == SyncPhase.needsChoice &&
          previous?.value?.phase != SyncPhase.needsChoice) {
        showSyncChoiceDialog(context, ref);
      }
    });

    return messAsync.when(
      data: (mess) =>
          mess == null ? const OnboardingScreen() : HomeShell(mess: mess),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Couldn't load your mess data.\n$error",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
