import '../core/utils/money.dart';

/// A bazar/food (or other mess supply) purchase paid for by one member on
/// behalf of the group.
class Expense {
  final String id;
  final String messId;
  final DateTime date;
  final Money amount;
  final String paidByMemberId;
  final String bazarList;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Expense({
    required this.id,
    required this.messId,
    required this.date,
    required this.amount,
    required this.paidByMemberId,
    required this.bazarList,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Expense copyWith({
    DateTime? date,
    Money? amount,
    String? paidByMemberId,
    String? bazarList,
    String? note,
    bool clearNote = false,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id,
      messId: messId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      bazarList: bazarList ?? this.bazarList,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
    );
  }
}
