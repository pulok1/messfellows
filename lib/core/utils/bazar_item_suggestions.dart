/// Splits a bazar-list entry's free text into individual item names, e.g.
/// "Rice, Fish\nOil" -> ["Rice", "Fish", "Oil"].
List<String> splitBazarItems(String text) {
  return text
      .split(RegExp(r'[,\n;]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

/// Ranks the items bought most often across [recentLists] (each a raw
/// bazar-list string from a past entry), most frequent first — the
/// "frequently bought" chips offered when adding a new entry.
///
/// Items are deduplicated case-insensitively but shown in whichever casing
/// they were first entered with.
List<String> topBazarItems(List<String> recentLists, {int limit = 8}) {
  final counts = <String, int>{};
  final display = <String, String>{};
  for (final list in recentLists) {
    for (final item in splitBazarItems(list)) {
      final key = item.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
      display.putIfAbsent(key, () => item);
    }
  }
  final keys = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : display[a]!.compareTo(display[b]!);
    });
  return keys.take(limit).map((key) => display[key]!).toList();
}
