/// Domain model for a mess member. Members are archived (see [isActive]),
/// never hard-deleted, so historical meal/expense/payment/settlement
/// records they're referenced by remain valid.
class Member {
  final String id;
  final String messId;
  final String name;
  final String? phone;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Member({
    required this.id,
    required this.messId,
    required this.name,
    this.phone,
    required this.joinedAt,
    this.leftAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Member copyWith({
    String? name,
    String? phone,
    bool clearPhone = false,
    DateTime? leftAt,
    bool clearLeftAt = false,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id,
      messId: messId,
      name: name ?? this.name,
      phone: clearPhone ? null : (phone ?? this.phone),
      joinedAt: joinedAt,
      leftAt: clearLeftAt ? null : (leftAt ?? this.leftAt),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
