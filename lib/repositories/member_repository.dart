import '../models/member.dart';

abstract interface class MemberRepository {
  /// Active members only — what meal/bazar/payment entry screens show.
  Stream<List<Member>> watchActiveMembers(String messId);

  /// Every member including archived ones — needed so historical reports
  /// for a month a now-archived member was part of still resolve names.
  Stream<List<Member>> watchAllMembers(String messId);

  Future<Member?> getMember(String id);

  Future<Member> addMember({
    required String messId,
    required String name,
    String? phone,
  });

  Future<void> updateMember(Member member);

  /// Archives a member (isActive = false, leftAt = now) rather than
  /// deleting, so their historical meal/expense/payment records stay valid.
  Future<void> archiveMember(String id);

  Future<void> reactivateMember(String id);
}
