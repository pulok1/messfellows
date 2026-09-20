/// Domain model for a mess (household/group). Plain Dart, independent of
/// the database implementation — see section 27/48 of the product spec —
/// so the UI and calculation engine never import Drift types directly.
class Mess {
  final String id;
  final String name;
  final String currencyCode;
  final String currencySymbol;
  final bool trackBreakfast;
  final bool trackLunch;
  final bool trackDinner;

  /// When the mess rules last changed; null if none were ever saved.
  final DateTime? rulesUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Mess({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.currencySymbol,
    this.trackBreakfast = true,
    this.trackLunch = true,
    this.trackDinner = true,
    this.rulesUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Mess copyWith({
    String? name,
    String? currencyCode,
    String? currencySymbol,
    bool? trackBreakfast,
    bool? trackLunch,
    bool? trackDinner,
    DateTime? updatedAt,
  }) {
    return Mess(
      id: id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      trackBreakfast: trackBreakfast ?? this.trackBreakfast,
      trackLunch: trackLunch ?? this.trackLunch,
      trackDinner: trackDinner ?? this.trackDinner,
      rulesUpdatedAt: rulesUpdatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
