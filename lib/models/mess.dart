/// Domain model for a mess (household/group). Plain Dart, independent of
/// the database implementation — see section 27/48 of the product spec —
/// so the UI and calculation engine never import Drift types directly.
class Mess {
  final String id;
  final String name;
  final String currencyCode;
  final String currencySymbol;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Mess({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.currencySymbol,
    required this.createdAt,
    required this.updatedAt,
  });

  Mess copyWith({
    String? name,
    String? currencyCode,
    String? currencySymbol,
    DateTime? updatedAt,
  }) {
    return Mess(
      id: id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
