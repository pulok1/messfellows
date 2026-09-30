import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/utils/bazar_item_suggestions.dart';

void main() {
  group('splitBazarItems', () {
    test('splits on commas, semicolons and newlines, trimming blanks', () {
      expect(splitBazarItems('Rice, Fish\nOil; Salt ,, '), [
        'Rice',
        'Fish',
        'Oil',
        'Salt',
      ]);
    });

    test('empty text yields no items', () {
      expect(splitBazarItems('   '), isEmpty);
    });
  });

  group('topBazarItems', () {
    test('ranks items by how often they recur, most frequent first', () {
      final ranked = topBazarItems([
        'Rice, Fish, Oil',
        'Rice, Vegetables',
        'Rice, Fish',
      ]);

      expect(ranked, ['Rice', 'Fish', 'Oil', 'Vegetables']);
    });

    test('dedupes case-insensitively, keeping the first-seen casing', () {
      final ranked = topBazarItems(['rice', 'Rice', 'RICE, Fish']);

      expect(ranked, ['rice', 'Fish']);
    });

    test('caps the result at limit', () {
      final ranked = topBazarItems([
        'A, B, C, D, E',
      ], limit: 3);

      expect(ranked, hasLength(3));
    });
  });
}
