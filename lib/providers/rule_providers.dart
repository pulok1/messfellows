import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rule.dart';
import 'repository_providers.dart';

final rulesProvider = StreamProvider.family<List<Rule>, String>((ref, messId) {
  return ref.watch(ruleRepositoryProvider).watchRules(messId);
});
