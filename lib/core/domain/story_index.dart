import '../api/models/models.dart';

/// Looks stories up by id. Layout ids that point at unpublished or deleted
/// stories resolve to nothing, so callers never need to null-check.
class StoryIndex {
  StoryIndex(List<Story> stories)
    : stories = List.unmodifiable(stories),
      _byId = {for (final s in stories) s.id: s};

  /// Every published story, in API order (newest first).
  final List<Story> stories;
  final Map<String, Story> _byId;

  /// The story with [id], or null if it isn't published.
  Story? operator [](String? id) => id == null || id.isEmpty ? null : _byId[id];

  /// Resolves [ids] in order, silently skipping unknown and repeated ids.
  List<Story> resolve(Iterable<String> ids) {
    final seen = <String>{};
    return [
      for (final id in ids)
        if (_byId[id] case final story? when seen.add(id)) story,
    ];
  }
}
