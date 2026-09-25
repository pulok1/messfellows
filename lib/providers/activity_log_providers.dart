import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_log_entry.dart';
import 'repository_providers.dart';

final activityLogProvider =
    StreamProvider.family<List<ActivityLogEntry>, String>((ref, messId) {
      return ref.watch(activityLogRepositoryProvider).watchLog(messId);
    });
