import 'package:collection/collection.dart';

import '../api/models/models.dart';

/// Regions that every *section* category also includes. Mirrors the
/// website's filter so the app and site always list the same stories.
const sectionCatchAllRegions = {'Global', 'The Utah Lens'};

/// The category rule shared with theutahview.com:
///
/// * a `section` category matches its own name, "Global" and "The Utah Lens";
/// * any other category matches only stories whose region is exactly its name.
bool storyMatchesCategory(Story story, NavCategory category) {
  if (story.region == category.text) return true;
  return category.section && sectionCatchAllRegions.contains(story.region);
}

/// Stories in [category], keeping the input order.
List<Story> storiesForCategory(Iterable<Story> stories, NavCategory category) =>
    [
      for (final s in stories)
        if (storyMatchesCategory(s, category)) s,
    ];

/// Every story, newest first by `date`. Stories with the same date keep
/// their API order, and stories without a date go last.
List<Story> archiveStories(Iterable<Story> stories) {
  final sorted = stories.toList();
  mergeSort<Story>(sorted, compare: (a, b) => b.date.compareTo(a.date));
  return sorted;
}

/// Picks up to [count] stories for "More from this issue" under an article.
///
/// Preference order: other stories from the same monthly issue (same
/// `YYYY-MM` as the article), then stories on the current front page, then
/// the newest stories. Never returns the article itself or duplicates.
List<Story> moreFromThisIssue({
  required String storyId,
  required String storyDate,
  required List<Story> stories,
  LayoutConfig? layout,
  int count = 3,
}) {
  final month = storyDate.length >= 7 ? storyDate.substring(0, 7) : null;
  final byId = {for (final s in stories) s.id: s};
  final candidates = <Story>[
    if (month != null) ...stories.where((s) => s.date.startsWith(month)),
    for (final id in layout?.referencedIds ?? const <String>[]) ?byId[id],
    ...stories,
  ];
  final seen = <String>{storyId};
  return candidates.where((s) => seen.add(s.id)).take(count).toList();
}
