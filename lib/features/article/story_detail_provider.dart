import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models/models.dart';
import '../../core/api/news_repository.dart';
import '../../core/api/providers.dart';
import '../saved/saved_stories.dart';

/// One full story. Cached like every endpoint, and also readable from the
/// reader's bookmarks, so saved stories open offline even if the response
/// cache was cleared.
class StoryDetailNotifier extends CachedEndpointNotifier<StoryDetail> {
  StoryDetailNotifier(this.id);

  final String id;

  @override
  Endpoint<StoryDetail> get endpoint => NewsRepository.story(id);

  @override
  StoryDetail? offlineFallback() =>
      ref.read(savedStoriesProvider.notifier).detail(id);

  @override
  void onFetched(StoryDetail value) {
    unawaited(ref.read(savedStoriesProvider.notifier).updateIfSaved(value));
  }
}

final storyDetailProvider = AsyncNotifierProvider.autoDispose
    .family<StoryDetailNotifier, StoryDetail, String>(
      StoryDetailNotifier.new,
      retry: apiRetry,
    );
