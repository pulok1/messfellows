import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_log_entry.dart';
import 'params.dart';
import 'repository_providers.dart';

final activityLogProvider =
    StreamProvider.family<List<ActivityLogEntry>, String>((ref, messId) {
      return ref.watch(activityLogRepositoryProvider).watchLog(messId);
    });

/// Logged changes to one day's meals made after that day had passed — the
/// history behind a meal row's "Edited later" tag.
final mealChangesForDateProvider =
    StreamProvider.family<List<ActivityLogEntry>, DateParams>((ref, params) {
      return ref
          .watch(activityLogRepositoryProvider)
          .watchMealChangesForDate(params.messId, params.date);
    });
