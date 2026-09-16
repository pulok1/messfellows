import '../core/utils/money.dart';

/// A member's contribution of money into the mess.
class Payment {
  final String id;
  final String messId;
  final DateTime date;
  final String memberId;
  final Money amount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.messId,
    required this.date,
    required this.memberId,
    required this.amount,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Payment copyWith({
    DateTime? date,
    String? memberId,
    Money? amount,
    String? note,
    bool clearNote = false,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id,
      messId: messId,
      date: date ?? this.date,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
