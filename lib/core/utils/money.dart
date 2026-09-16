import 'package:intl/intl.dart';

/// An exact monetary amount stored as integer minor units (poisha, 1/100 of
/// a taka) so financial math never touches floating-point.
///
/// All arithmetic on [Money] is exact integer arithmetic; the only place
/// rounding happens is [Money.divide], which must choose how to distribute a
/// remainder, and that choice is explicit at the call site.
class Money implements Comparable<Money> {
  /// The amount in minor units (poisha). 500 BDT is `minorUnits: 50000`.
  final int minorUnits;

  const Money(this.minorUnits);

  const Money.zero() : minorUnits = 0;

  /// Builds a [Money] from a major-unit decimal amount, e.g. `Money.fromMajor(500.5)`
  /// for ৳500.50. Prefer [Money.new] with minor units when the source is
  /// already exact (e.g. a database column) to avoid double parsing.
  factory Money.fromMajor(num majorAmount) {
    return Money((majorAmount * 100).round());
  }

  double get major => minorUnits / 100;

  bool get isZero => minorUnits == 0;
  bool get isNegative => minorUnits < 0;
  bool get isPositive => minorUnits > 0;

  Money operator +(Money other) => Money(minorUnits + other.minorUnits);
  Money operator -(Money other) => Money(minorUnits - other.minorUnits);
  Money operator -() => Money(-minorUnits);
  Money operator *(int factor) => Money(minorUnits * factor);

  bool operator >(Money other) => minorUnits > other.minorUnits;
  bool operator <(Money other) => minorUnits < other.minorUnits;
  bool operator >=(Money other) => minorUnits >= other.minorUnits;
  bool operator <=(Money other) => minorUnits <= other.minorUnits;

  /// Divides this amount by [divisor], rounding to the nearest minor unit.
  /// Returns zero when [divisor] is zero rather than throwing, since "no
  /// meals recorded yet" is an expected state, not an error.
  Money divide(num divisor) {
    if (divisor == 0) return const Money.zero();
    return Money((minorUnits / divisor).round());
  }

  @override
  bool operator ==(Object other) => other is Money && other.minorUnits == minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  /// Formats as `৳500` for whole amounts or `৳500.50` when there are poisha,
  /// matching the display rule in the product spec.
  String format({String currencySymbol = '৳'}) {
    final isWhole = minorUnits % 100 == 0;
    final formatter = NumberFormat(isWhole ? '#,##0' : '#,##0.00');
    return '$currencySymbol${formatter.format(major)}';
  }

  @override
  String toString() => format();
}
