import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/core/domain/story_index.dart';
import 'package:utah_view/features/home/home_feed.dart';

import '../support/fixtures.dart';

void main() {
  final index = StoryIndex(parseStoryList(fixture('stories.json')));
  final layout = parseLayoutConfig(fixture('layout.json'));

  test('live layout resolves every slot', () {
    final feed = HomeFeed.build(index, layout);
    expect(feed.lead?.id, layout.heroLead);
    expect(feed.leadImageUrl, layout.heroImageUrl);
    expect(feed.ticker, layout.ticker);
    expect(feed.topStories.map((s) => s.id), [
      layout.heroSecondary,
      layout.heroCenter,
    ]);
    expect(feed.fromThisIssue, hasLength(layout.heroRight.length));
    expect(feed.editorial, hasLength(layout.editorial.length));
    expect(feed.regions.map((r) => r.$1), LayoutConfig.regionOrder);
    expect(feed.featured, hasLength(layout.featured.length));
    expect(feed.utahLens, hasLength(layout.sidebarUtah.length));
    expect(feed.dataBrief, isEmpty);
    expect(feed.latest, isEmpty);
  });

  test('unpublished ids are skipped silently', () {
    final feed = HomeFeed.build(
      index,
      layout.copyWith(
        editorial: ['draft-1', ...layout.editorial, 'draft-2'],
        regions: {...layout.regions, 'Europe': 'unpublished-draft'},
        featured: ['nope'],
      ),
    );
    expect(feed.editorial, hasLength(layout.editorial.length));
    expect(feed.regions.map((r) => r.$1), isNot(contains('Europe')));
    expect(feed.featured, isEmpty);
  });

  test(
    'an unpublished lead promotes the next placed story, without its photo',
    () {
      final feed = HomeFeed.build(
        index,
        layout.copyWith(heroLead: 'not-yet-published'),
      );
      expect(feed.lead?.id, layout.heroSecondary);
      expect(feed.leadImageUrl, isNull);
      expect(feed.topStories.map((s) => s.id), [layout.heroCenter]);
    },
  );

  test('no layout falls back to newest-first', () {
    final feed = HomeFeed.build(index, null);
    expect(feed.lead, index.stories.first);
    expect(feed.latest, isNotEmpty);
    expect(feed.latest.first, index.stories[1]);
    expect(feed.featured, isEmpty);
  });

  test('an empty catalog yields an empty front page', () {
    expect(HomeFeed.build(StoryIndex(const []), layout).lead, isNull);
    expect(HomeFeed.build(StoryIndex(const []), null).lead, isNull);
  });
}
