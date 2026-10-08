import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/models/json_converters.dart';
import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/storage/key_value_store.dart';

/// A bookmarked story. The full body is stored so it reads offline.
@immutable
class SavedStory {
  const SavedStory(this.story, this.savedAt);

  final StoryDetail story;
  final DateTime savedAt;

  Map<String, Object?> toJson() => {
    'saved_at': savedAt.toUtc().toIso8601String(),
    'story': story.toJson(),
  };

  static SavedStory? tryParse(String raw) {
    try {
      final map = asJsonMap(jsonDecode(raw));
      final story = asJsonMap(map?['story']);
      final savedAt = DateTime.tryParse(coerceJsonString(map?['saved_at']));
      if (story == null || savedAt == null) return null;
      final detail = StoryDetail.fromJson(story);
      return detail.id.isEmpty ? null : SavedStory(detail, savedAt.toLocal());
    } on Object {
      return null;
    }
  }
}

/// Bookmarks, newest first. Local only in v1 (no sign-in); Phase 2 syncs
/// them through the reader's Google account.
class SavedStoriesNotifier extends Notifier<List<SavedStory>> {
  KeyValueStore get _store => ref.read(appStoresProvider).savedStories;

  @override
  List<SavedStory> build() {
    final store = _store;
    final saved = [
      for (final key in store.keys)
        if (store.read(key) case final raw?) ?SavedStory.tryParse(raw),
    ]..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return saved;
  }

  bool isSaved(String id) => state.any((s) => s.story.id == id);

  /// The bookmarked copy of [id], if any. Used as the offline fallback.
  StoryDetail? detail(String id) {
    for (final saved in state) {
      if (saved.story.id == id) return saved.story;
    }
    return null;
  }

  Future<void> save(StoryDetail story) async {
    final entry = SavedStory(story, DateTime.now());
    state = [entry, ...state.where((s) => s.story.id != story.id)];
    await _store.write(story.id, jsonEncode(entry.toJson()));
  }

  Future<void> remove(String id) async {
    state = [...state.where((s) => s.story.id != id)];
    await _store.delete(id);
  }

  /// Restores an entry removed by a swipe, keeping its original position.
  Future<void> restore(SavedStory entry) async {
    state = [...state.where((s) => s.story.id != entry.story.id), entry]
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    await _store.write(entry.story.id, jsonEncode(entry.toJson()));
  }

  /// Saves or unsaves [story]; returns true if it is now saved.
  Future<bool> toggle(StoryDetail story) async {
    if (isSaved(story.id)) {
      await remove(story.id);
      return false;
    }
    await save(story);
    return true;
  }

  /// Keeps a bookmarked copy current when a newer version is fetched.
  Future<void> updateIfSaved(StoryDetail fresh) async {
    final index = state.indexWhere((s) => s.story.id == fresh.id);
    if (index == -1 || state[index].story == fresh) return;
    final entry = SavedStory(fresh, state[index].savedAt);
    state = [...state]..[index] = entry;
    await _store.write(fresh.id, jsonEncode(entry.toJson()));
  }
}

final savedStoriesProvider =
    NotifierProvider<SavedStoriesNotifier, List<SavedStory>>(
      SavedStoriesNotifier.new,
    );

/// Whether [id] is bookmarked; rebuilds only when that answer changes.
final isSavedProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(
    savedStoriesProvider.select((l) => l.any((s) => s.story.id == id)),
  ),
);
