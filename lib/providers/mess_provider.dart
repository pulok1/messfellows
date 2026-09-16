import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mess.dart';
import 'repository_providers.dart';

/// The single local mess, or null before onboarding has created one. A
/// stream so the app automatically moves from onboarding to the dashboard
/// the moment a mess is created — no manual navigation/refresh needed.
final currentMessProvider = StreamProvider<Mess?>((ref) {
  return ref.watch(messRepositoryProvider).watchMess();
});
