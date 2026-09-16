import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';
import 'repository_providers.dart';

/// Active members only — what meal/bazar/payment entry screens list.
final activeMembersProvider = StreamProvider.family<List<Member>, String>((ref, messId) {
  return ref.watch(memberRepositoryProvider).watchActiveMembers(messId);
});

/// Active and archived members — needed so a month a now-archived member
/// was part of can still resolve their name in reports.
final allMembersProvider = StreamProvider.family<List<Member>, String>((ref, messId) {
  return ref.watch(memberRepositoryProvider).watchAllMembers(messId);
});
