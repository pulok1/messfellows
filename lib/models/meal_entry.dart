/// One member's breakfast/lunch/dinner counts for a day, detached from any
/// stored row — the unit bulk writes (and their undo) work in.
typedef MealCounts = ({int breakfast, int lunch, int dinner});

/// A day with nothing eaten — also what a member with no row that day has.
const MealCounts noMeals = (breakfast: 0, lunch: 0, dinner: 0);

/// One member's breakfast/lunch/dinner record for a single calendar day.
class MealEntry {
  final String id;
  final String messId;
  final String memberId;
  final DateTime date;
  final int breakfast;
  final int lunch;
  final int dinner;
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

  /// Total meals eaten this day. Usually 0-3, but a slot can be 2 or more
  /// when an extra/guest meal is recorded under this member.
  int get totalMeals => breakfast + lunch + dinner;

  MealCounts get counts => (breakfast: breakfast, lunch: lunch, dinner: dinner);

  MealEntry copyWith({
    int? breakfast,
    int? lunch,
    int? dinner,
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
