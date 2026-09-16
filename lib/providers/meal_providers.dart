import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_entry.dart';
import 'params.dart';
import 'repository_providers.dart';

final mealsForDateProvider = StreamProvider.family<List<MealEntry>, DateParams>((ref, params) {
  return ref.watch(mealRepositoryProvider).watchMealsForDate(params.messId, params.date);
});

final mealsForMonthProvider = StreamProvider.family<List<MealEntry>, MonthParams>((ref, params) {
  return ref
      .watch(mealRepositoryProvider)
      .watchMealsForMonth(params.messId, params.year, params.month);
});
