import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/core/domain/story_filters.dart';
import 'package:utah_view/core/domain/story_index.dart';

import '../support/fixtures.dart';

Story story(String id, String region, {String date = '2026-05-25'}) =>
    Story(id: id, title: id, region: region, date: date);

void main() {
  final stories = [
    story('eu-1', 'Europe'),
    story('global-1', 'Global'),
    story('utah-1', 'The Utah Lens'),
    story('am-1', 'The Americas'),
    story('eu-2', 'Europe'),
    story('analysis-1', 'Analysis'),
    story('lower', 'europe'),
    story('blank', ''),
  ];

  group('category filter (must match theutahview.com)', () {
    test('a plain category matches only its exact region', () {
      final europe = storiesForCategory(
        stories,
        const NavCategory(text: 'Europe'),
      );
      expect(europe.map((s) => s.id), ['eu-1', 'eu-2']);
    });

    test('a plain category does not pull in Global or The Utah Lens', () {
      final americas = storiesForCategory(
        stories,
        const NavCategory(text: 'The Americas'),
      );
      expect(americas.map((s) => s.id), ['am-1']);
    });

    test('a section matches its own region plus Global and The Utah Lens', () {
      final analysis = storiesForCategory(
        stories,
        const NavCategory(text: 'Analysis', section: true),
      );
      expect(analysis.map((s) => s.id), ['global-1', 'utah-1', 'analysis-1']);
    });

    test('a section with no stories of its own still lists the catch-alls', () {
      final data = storiesForCategory(
        stories,
        const NavCategory(text: 'Data', section: true),
      );
      expect(data.map((s) => s.id), ['global-1', 'utah-1']);
    });

    test('matching is exact and case-sensitive, like the website', () {
      expect(
        storyMatchesCategory(stories[6], const NavCategory(text: 'Europe')),
        isFalse,
      );
      expect(
        storyMatchesCategory(stories[0], const NavCategory(text: 'Europe ')),
        isFalse,
      );
    });

    test('stories without a region never match', () {
      for (final category in NavCategory.fallback) {
        expect(storyMatchesCategory(stories.last, category), isFalse);
      }
    });

    test('input order is preserved', () {
      final reversed = storiesForCategory(
        stories.reversed,
        const NavCategory(text: 'Europe'),
      );
      expect(reversed.map((s) => s.id), ['eu-2', 'eu-1']);
    });

    test('fallback navigation mirrors the website', () {
      expect(NavCategory.fallback.map((c) => c.text), [
        'The Americas',
        'Europe',
        'Asia-Pacific',
        'Middle East',
        'Africa',
        'Analysis',
        'Opinion',
        'Data',
      ]);
      expect(NavCategory.fallback.where((c) => c.section).map((c) => c.text), [
        'Analysis',
        'Opinion',
        'Data',
      ]);
    });

    test('live data: region categories agree with the API region filter', () {
      final live = parseStoryList(fixture('stories.json'));
      for (final category in NavCategory.fallback.where((c) => !c.section)) {
        final filtered = storiesForCategory(live, category);
        expect(
          filtered.every((s) => s.region == category.text),
          isTrue,
          reason: category.text,
        );
        expect(
          filtered.length,
          live.where((s) => s.region == category.text).length,
        );
      }
      final analysis = storiesForCategory(
        live,
        const NavCategory(text: 'Analysis', section: true),
      );
      expect(
        analysis.every(
          (s) =>
              s.region == 'Analysis' ||
              sectionCatchAllRegions.contains(s.region),
        ),
        isTrue,
      );
    });
  });

  group('archive', () {
    test('sorts newest first, keeps API order for ties, undated last', () {
      final sorted = archiveStories([
        story('a', 'Europe', date: '2026-05-25'),
        story('b', 'Europe', date: ''),
        story('c', 'Europe', date: '2026-07-22'),
        story('d', 'Europe', date: '2026-05-25'),
        story('e', 'Europe', date: '2026-06-05'),
      ]);
      expect(sorted.map((s) => s.id), ['c', 'e', 'a', 'd', 'b']);
    });
  });

  group('StoryIndex', () {
    test('skips unpublished and repeated ids, keeping order', () {
      final index = StoryIndex(stories);
      final resolved = index.resolve(['am-1', 'draft', 'eu-1', 'am-1', '']);
      expect(resolved.map((s) => s.id), ['am-1', 'eu-1']);
      expect(index['draft'], isNull);
      expect(index[null], isNull);
    });
  });

  group('more from this issue', () {
    final issue = [
      story('jul-1', 'Europe', date: '2026-07-22'),
      story('may-1', 'Africa', date: '2026-05-26'),
      story('jul-2', 'Asia-Pacific', date: '2026-07-23'),
      story('may-2', 'Europe', date: '2026-05-25'),
      story('jul-3', 'Middle East', date: '2026-07-01'),
    ];

    test('prefers the same monthly issue and never repeats the article', () {
      final more = moreFromThisIssue(
        storyId: 'jul-1',
        storyDate: '2026-07-22',
        stories: issue,
      );
      expect(more.map((s) => s.id), ['jul-2', 'jul-3', 'may-1']);
    });

    test('fills from the front page, then the newest stories', () {
      final more = moreFromThisIssue(
        storyId: 'may-2',
        storyDate: '2026-05-25',
        stories: issue,
        layout: const LayoutConfig(heroLead: 'jul-3', featured: ['may-2']),
      );
      expect(more.map((s) => s.id), ['may-1', 'jul-3', 'jul-1']);
    });

    test('copes with a missing date and tiny catalogs', () {
      expect(
        moreFromThisIssue(
          storyId: 'x',
          storyDate: '',
          stories: issue,
        ).map((s) => s.id),
        ['jul-1', 'may-1', 'jul-2'],
      );
      expect(
        moreFromThisIssue(storyId: 'jul-1', storyDate: '', stories: [issue[0]]),
        isEmpty,
      );
    });
  });
}
