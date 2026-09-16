/// One member's breakfast/lunch/dinner record for a single calendar day.
class MealEntry {
  final String id;
  final String messId;
  final String memberId;
  final DateTime date;
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealEntry({
    required this.id,
    required this.messId,
    required this.memberId,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total meals eaten this day (0-3).
  int get totalMeals => (breakfast ? 1 : 0) + (lunch ? 1 : 0) + (dinner ? 1 : 0);

  MealEntry copyWith({
    bool? breakfast,
    bool? lunch,
    bool? dinner,
    DateTime? updatedAt,
  }) {
    return MealEntry(
      id: id,
      messId: messId,
      memberId: memberId,
      date: date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
