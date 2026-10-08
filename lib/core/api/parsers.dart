import 'dart:convert';

import 'models/json_converters.dart';
import 'models/models.dart';

/// Response-envelope parsers. Each accepts the decoded JSON body and either
/// returns a model or throws [FormatException] when the payload is unusable.
///
/// Individual malformed items inside a list are skipped rather than failing
/// the whole response.

/// `{ stories: [...] }` → stories with an id, de-duplicated, in API order.
List<Story> parseStoryList(Object? json) {
  final raw = asJsonMap(json)?['stories'] ?? json;
  if (raw is! List) {
    throw const FormatException('Expected a "stories" array');
  }
  final seen = <String>{};
  return [
    for (final story in parseObjectList(raw, Story.fromJson))
      if (story.id.isNotEmpty && seen.add(story.id)) story,
  ];
}

/// `{ id, title, ..., body }`.
StoryDetail parseStoryDetail(Object? json) {
  final root = asJsonMap(json);
  final map = asJsonMap(root?['story']) ?? root;
  if (map == null) throw const FormatException('Expected a story object');
  final story = StoryDetail.fromJson(map);
  if (story.id.isEmpty) throw const FormatException('Story has no id');
  return story;
}

/// `{ value: {...} }`. Tolerates `value` stored as a JSON string.
LayoutConfig parseLayoutConfig(Object? json) =>
    LayoutConfig.fromJson(_configValue(json));

/// `{ value: {...} }`. Tolerates `value` stored as a JSON string.
SiteConfig parseSiteConfig(Object? json) =>
    SiteConfig.fromJson(_configValue(json));

/// `{ pages: [...] }` → pages with a slug.
List<SitePageSummary> parsePageList(Object? json) {
  final raw = asJsonMap(json)?['pages'] ?? json;
  if (raw is! List) throw const FormatException('Expected a "pages" array');
  return [
    for (final page in parseObjectList(raw, SitePageSummary.fromJson))
      if (page.slug.isNotEmpty) page,
  ];
}

/// `{ slug, title, subtitle, body }`.
SitePage parseSitePage(Object? json) {
  final map = asJsonMap(json);
  if (map == null) throw const FormatException('Expected a page object');
  return SitePage.fromJson(map);
}

Map<String, dynamic> _configValue(Object? json) {
  final root = asJsonMap(json);
  if (root == null) throw const FormatException('Expected a config object');
  var value = root.containsKey('value') ? root['value'] : root;
  if (value is String && value.trim().startsWith('{')) {
    value = jsonDecode(value);
  }
  return asJsonMap(value) ?? const {};
}
