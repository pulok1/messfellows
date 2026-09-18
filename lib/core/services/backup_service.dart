import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../models/settlement_status.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

/// Exports/imports the entire local database as a single portable JSON
/// document (section 24). Nothing here ever touches the network — the
/// resulting file is handed to the OS share sheet or picked from local
/// storage, and that's the full extent of "backup" for this local-first
/// MVP.
///
/// Import always replaces the current data wholesale rather than merging,
/// and only after the caller has shown an explicit confirmation — see
/// SettingsScreen — because a partial/smart merge across two independently
/// edited backups is exactly the kind of complexity sections 24/26 say to
/// defer to the future sync phase.
class BackupService {
  final AppDatabase _db;

  const BackupService(this._db);

  Future<String> exportToJson() async {
    final mess = await _db.select(_db.messes).getSingleOrNull();
    if (mess == null) {
      throw const StorageException('No mess to export yet.');
    }

    final members = await _db.select(_db.members).get();
    final mealEntries = await _db.select(_db.mealEntries).get();
    final expenses = await _db.select(_db.expenses).get();
    final payments = await _db.select(_db.payments).get();
    final settlements = await _db.select(_db.monthlySettlements).get();
    final settlementMembers = await _db
        .select(_db.monthlySettlementMembers)
        .get();

    final document = {
      'schemaVersion': AppConstants.backupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'mess': _messToJson(mess),
      'members': members.map(_memberToJson).toList(),
      'mealEntries': mealEntries.map(_mealEntryToJson).toList(),
      'expenses': expenses.map(_expenseToJson).toList(),
      'payments': payments.map(_paymentToJson).toList(),
      'settlements': settlements.map(_settlementToJson).toList(),
      'settlementMembers': settlementMembers
          .map(_settlementMemberToJson)
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(document);
  }

  /// Replaces all local data with the contents of [jsonString]. Throws
  /// [ImportException] if the file is malformed or from an unsupported
  /// schema version, without touching the existing database.
  Future<void> importFromJson(String jsonString) async {
    final Map<String, dynamic> document;
    try {
      document = jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException {
      throw const ImportException(
        ImportFailureReason.malformed,
        'This file is not a valid Mess Fellows backup.',
      );
    }

    final schemaVersion = document['schemaVersion'];
    if (schemaVersion is! int ||
        schemaVersion > AppConstants.backupFormatVersion) {
      throw const ImportException(
        ImportFailureReason.unsupportedVersion,
        'This backup was created by a newer version of the app and cannot be imported.',
      );
    }

    final messJson = document['mess'];
    if (messJson is! Map<String, dynamic>) {
      throw const ImportException(
        ImportFailureReason.missingMessData,
        'This backup file is missing mess data.',
      );
    }

    try {
      await _db.transaction(() async {
        await _db.delete(_db.monthlySettlementMembers).go();
        await _db.delete(_db.monthlySettlements).go();
        await _db.delete(_db.mealEntries).go();
        await _db.delete(_db.expenses).go();
        await _db.delete(_db.payments).go();
        await _db.delete(_db.members).go();
        await _db.delete(_db.messes).go();

        await _db.into(_db.messes).insert(_messFromJson(messJson));

        await _db.batch((batch) {
          batch.insertAll(
            _db.members,
            _listOf(document['members']).map(_memberFromJson),
          );
          batch.insertAll(
            _db.mealEntries,
            _listOf(document['mealEntries']).map(_mealEntryFromJson),
          );
          batch.insertAll(
            _db.expenses,
            _listOf(document['expenses']).map(_expenseFromJson),
          );
          batch.insertAll(
            _db.payments,
            _listOf(document['payments']).map(_paymentFromJson),
          );
          batch.insertAll(
            _db.monthlySettlements,
            _listOf(document['settlements']).map(_settlementFromJson),
          );
          batch.insertAll(
            _db.monthlySettlementMembers,
            _listOf(document['settlementMembers'])
                .map(_settlementMemberFromJson),
          );
        });
      });
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException(
        ImportFailureReason.unreadable,
        "This backup file couldn't be read. Your existing data has not been changed.",
      );
    }
  }

  List<Map<String, dynamic>> _listOf(Object? value) {
    if (value is! List) return const [];
    return value.cast<Map<String, dynamic>>();
  }

  // --- mess ---

  Map<String, dynamic> _messToJson(MessRow row) => {
    'id': row.id,
    'name': row.name,
    'currencyCode': row.currencyCode,
    'currencySymbol': row.currencySymbol,
    'trackBreakfast': row.trackBreakfast,
    'trackLunch': row.trackLunch,
    'trackDinner': row.trackDinner,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  MessesCompanion _messFromJson(Map<String, dynamic> json) =>
      MessesCompanion.insert(
        id: json['id'] as String,
        name: json['name'] as String,
        currencyCode: Value(json['currencyCode'] as String),
        currencySymbol: Value(json['currencySymbol'] as String),
        // Older backups predate these fields; default to true so a
        // restored mess still shows all three meal slots.
        trackBreakfast: Value(json['trackBreakfast'] as bool? ?? true),
        trackLunch: Value(json['trackLunch'] as bool? ?? true),
        trackDinner: Value(json['trackDinner'] as bool? ?? true),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  // --- members ---

  Map<String, dynamic> _memberToJson(MemberRow row) => {
    'id': row.id,
    'messId': row.messId,
    'name': row.name,
    'phone': row.phone,
    'joinedAt': row.joinedAt.toIso8601String(),
    'leftAt': row.leftAt?.toIso8601String(),
    'isActive': row.isActive,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  MembersCompanion _memberFromJson(Map<String, dynamic> json) =>
      MembersCompanion.insert(
        id: json['id'] as String,
        messId: json['messId'] as String,
        name: json['name'] as String,
        phone: Value(json['phone'] as String?),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        leftAt: Value(
          json['leftAt'] == null
              ? null
              : DateTime.parse(json['leftAt'] as String),
        ),
        isActive: Value(json['isActive'] as bool),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  // --- meal entries ---

  Map<String, dynamic> _mealEntryToJson(MealEntryRow row) => {
    'id': row.id,
    'messId': row.messId,
    'memberId': row.memberId,
    'date': row.date.toIso8601String(),
    'breakfast': row.breakfast,
    'lunch': row.lunch,
    'dinner': row.dinner,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  MealEntriesCompanion _mealEntryFromJson(Map<String, dynamic> json) =>
      MealEntriesCompanion.insert(
        id: json['id'] as String,
        messId: json['messId'] as String,
        memberId: json['memberId'] as String,
        date: DateTime.parse(json['date'] as String),
        // Older backups stored these as bool; coerce so they still import.
        breakfast: Value(_mealCount(json['breakfast'])),
        lunch: Value(_mealCount(json['lunch'])),
        dinner: Value(_mealCount(json['dinner'])),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Meal counts were exported as bool before `backupFormatVersion` 3.
  int _mealCount(Object? value) {
    if (value is bool) return value ? 1 : 0;
    if (value is int) return value;
    return 0;
  }

  // --- expenses ---

  Map<String, dynamic> _expenseToJson(ExpenseRow row) => {
    'id': row.id,
    'messId': row.messId,
    'date': row.date.toIso8601String(),
    'amountMinorUnits': row.amountMinorUnits,
    'paidByMemberId': row.paidByMemberId,
    'bazarList': row.bazarList,
    'note': row.note,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  ExpensesCompanion _expenseFromJson(Map<String, dynamic> json) =>
      ExpensesCompanion.insert(
        id: json['id'] as String,
        messId: json['messId'] as String,
        date: DateTime.parse(json['date'] as String),
        amountMinorUnits: json['amountMinorUnits'] as int,
        paidByMemberId: json['paidByMemberId'] as String,
        // Fall back to the old 'category' key so backups exported before
        // the category -> bazarList rename (schemaVersion 1) still import.
        bazarList: (json['bazarList'] ?? json['category'] ?? '') as String,
        note: Value(json['note'] as String?),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  // --- payments ---

  Map<String, dynamic> _paymentToJson(PaymentRow row) => {
    'id': row.id,
    'messId': row.messId,
    'date': row.date.toIso8601String(),
    'memberId': row.memberId,
    'amountMinorUnits': row.amountMinorUnits,
    'note': row.note,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  PaymentsCompanion _paymentFromJson(Map<String, dynamic> json) =>
      PaymentsCompanion.insert(
        id: json['id'] as String,
        messId: json['messId'] as String,
        date: DateTime.parse(json['date'] as String),
        memberId: json['memberId'] as String,
        amountMinorUnits: json['amountMinorUnits'] as int,
        note: Value(json['note'] as String?),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  // --- settlements ---

  Map<String, dynamic> _settlementToJson(MonthlySettlementRow row) => {
    'id': row.id,
    'messId': row.messId,
    'month': row.month,
    'year': row.year,
    'totalExpenseMinorUnits': row.totalExpenseMinorUnits,
    'totalMeals': row.totalMeals,
    'mealRateMinorUnits': row.mealRateMinorUnits,
    'status': row.status.name,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  MonthlySettlementsCompanion _settlementFromJson(Map<String, dynamic> json) =>
      MonthlySettlementsCompanion.insert(
        id: json['id'] as String,
        messId: json['messId'] as String,
        month: json['month'] as int,
        year: json['year'] as int,
        totalExpenseMinorUnits: json['totalExpenseMinorUnits'] as int,
        totalMeals: json['totalMeals'] as int,
        mealRateMinorUnits: json['mealRateMinorUnits'] as int,
        status: Value(SettlementStatus.values.byName(json['status'] as String)),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  // --- settlement members ---

  Map<String, dynamic> _settlementMemberToJson(
    MonthlySettlementMemberRow row,
  ) => {
    'id': row.id,
    'settlementId': row.settlementId,
    'memberId': row.memberId,
    'mealCount': row.mealCount,
    'mealCostMinorUnits': row.mealCostMinorUnits,
    'paidAmountMinorUnits': row.paidAmountMinorUnits,
    'balanceMinorUnits': row.balanceMinorUnits,
    'createdAt': row.createdAt.toIso8601String(),
  };

  MonthlySettlementMembersCompanion _settlementMemberFromJson(
    Map<String, dynamic> json,
  ) => MonthlySettlementMembersCompanion.insert(
    id: json['id'] as String,
    settlementId: json['settlementId'] as String,
    memberId: json['memberId'] as String,
    mealCount: json['mealCount'] as int,
    mealCostMinorUnits: json['mealCostMinorUnits'] as int,
    paidAmountMinorUnits: json['paidAmountMinorUnits'] as int,
    balanceMinorUnits: json['balanceMinorUnits'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
