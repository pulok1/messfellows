import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/id_generator.dart';
import '../../database/app_database.dart';
import '../../models/member.dart';
import '../member_repository.dart';

class LocalMemberRepository implements MemberRepository {
  final AppDatabase _db;

  LocalMemberRepository(this._db);

  Member _toModel(MemberRow row) => Member(
    id: row.id,
    messId: row.messId,
    name: row.name,
    phone: row.phone,
    joinedAt: row.joinedAt,
    leftAt: row.leftAt,
    isActive: row.isActive,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  @override
  Stream<List<Member>> watchActiveMembers(String messId) {
    final query = _db.select(_db.members)
      ..where((t) => t.messId.equals(messId) & t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<Member>> watchAllMembers(String messId) {
    final query = _db.select(_db.members)
      ..where((t) => t.messId.equals(messId))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<Member?> getMember(String id) async {
    final row = await (_db.select(
      _db.members,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<Member> addMember({
    required String messId,
    required String name,
    String? phone,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Member name cannot be empty.');
    }

    final now = DateTime.now();
    final id = IdGenerator.generate();
    await _db
        .into(_db.members)
        .insert(
          MembersCompanion.insert(
            id: id,
            messId: messId,
            name: name,
            phone: Value(phone),
            joinedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return Member(
      id: id,
      messId: messId,
      name: name,
      phone: phone,
      joinedAt: now,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateMember(Member member) async {
    if (member.name.trim().isEmpty) {
      throw const ValidationException('Member name cannot be empty.');
    }
    await (_db.update(
      _db.members,
    )..where((t) => t.id.equals(member.id))).write(
      MembersCompanion(
        name: Value(member.name),
        phone: Value(member.phone),
        isActive: Value(member.isActive),
        leftAt: Value(member.leftAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> archiveMember(String id) async {
    await (_db.update(_db.members)..where((t) => t.id.equals(id))).write(
      MembersCompanion(
        isActive: const Value(false),
        leftAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> reactivateMember(String id) async {
    await (_db.update(_db.members)..where((t) => t.id.equals(id))).write(
      MembersCompanion(
        isActive: const Value(true),
        leftAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
