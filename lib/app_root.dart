import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/mess_provider.dart';

/// Decides between onboarding and the main app shell based on whether a
/// mess has been created yet (section 42) — there is no login screen to
/// gate this, just local state.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(currentMessProvider);

    return messAsync.when(
      data: (mess) => mess == null ? const OnboardingScreen() : HomeShell(mess: mess),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
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
