import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/core/domain/story_index.dart';

import '../support/fixtures.dart';

void main() {
  group('live fixtures', () {
    test('stories list', () {
      final stories = parseStoryList(fixture('stories.json'));
      expect(stories, isNotEmpty);
      expect(stories.every((s) => s.id.isNotEmpty), isTrue);
      expect(stories.map((s) => s.id).toSet().length, stories.length);
      final batanes = stories.firstWhere(
        (s) =>
            s.id ==
            'chinese-academics-begin-questioning-who-owns-the-batanes-isl',
      );
      expect(batanes.author, 'Benjamin Koh');
      expect(batanes.region, 'Asia-Pacific');
      expect(batanes.readTime, '3 min');
      expect(batanes.readTimeLabel, '3 min read');
      expect(batanes.displayDate, 'July 22, 2026');
    });

    test('story detail', () {
      final detail = parseStoryDetail(fixture('story_detail.json'));
      expect(detail.id, isNotEmpty);
      expect(detail.status, 'published');
      expect(detail.body, startsWith('<'));
      expect(detail.toStory().id, detail.id);
      expect(detail.toStory().title, detail.title);
    });

    test('layout: every slot parses and resolves against the stories', () {
      final layout = parseLayoutConfig(fixture('layout.json'));
      final index = StoryIndex(parseStoryList(fixture('stories.json')));
      expect(layout.ticker, isNotEmpty);
      expect(index[layout.heroLead], isNotNull);
      expect(layout.heroRight, hasLength(3));
      expect(index.resolve(layout.heroRight), hasLength(3));
      expect(layout.editorial, isNotEmpty);
      expect(layout.featured, isNotEmpty);
      expect(layout.sidebarData, isEmpty);
      expect(layout.heroImageUrl, startsWith('https://'));
      expect(layout.heroCenterCaption, isEmpty);
      expect(layout.orderedRegions.map((e) => e.key), [
        'The Americas',
        'Europe',
        'Asia-Pacific',
        'Middle East',
        'Africa',
      ]);
    });

    test('site config: missing nav_categories falls back', () {
      final site = parseSiteConfig(fixture('site.json'));
      expect(site.navCategories, isNull);
      expect(site.effectiveNavCategories, NavCategory.fallback);
      expect(site.subscribeOverline, 'Stay briefed');
      expect(site.subscribeHeading, 'Independent analysis, delivered monthly');
      expect(site.copyright, isNotEmpty);
      expect(site.footerCols, isNotEmpty);
      expect(site.footerCols.first.links.first.text, isNotEmpty);
    });

    test('pages list and a page body', () {
      final pages = parsePageList(fixture('pages.json'));
      expect(pages.map((p) => p.slug), contains('our-mission'));
      final mission = parseSitePage(fixture('page_our_mission.json'));
      expect(mission.title, 'Our Mission');
      expect(mission.body, isNotEmpty);
    });
  });

  group('Story: missing, null and wrong-type fields', () {
    test('missing fields default to empty strings', () {
      final s = Story.fromJson({'id': 'abc'});
      expect(s.title, '');
      expect(s.author, '');
      expect(s.region, '');
      expect(s.summary, '');
      expect(s.readTime, '');
      expect(s.date, '');
      expect(s.readTimeLabel, isNull);
      expect(s.displayDate, '');
    });

    test('null values become empty strings', () {
      final s = Story.fromJson({
        'id': 'abc',
        'title': null,
        'read_time': null,
        'date': null,
      });
      expect(s.title, '');
      expect(s.readTime, '');
      expect(s.readTimeLabel, isNull);
    });

    test('numbers are coerced to strings', () {
      final s = Story.fromJson({'id': 42, 'read_time': 4, 'title': 3.0});
      expect(s.id, '42');
      expect(s.readTime, '4');
      expect(s.readTimeLabel, '4 min read');
      expect(s.title, '3');
    });

    test('empty and junk read_time are dropped from the byline', () {
      expect(
        Story.fromJson({'id': 'a', 'read_time': ''}).readTimeLabel,
        isNull,
      );
      expect(
        Story.fromJson({'id': 'a', 'read_time': '  '}).readTimeLabel,
        isNull,
      );
      expect(
        Story.fromJson({'id': 'a', 'read_time': 'Charlie Kirk'}).readTimeLabel,
        isNull,
      );
    });

    test('strings are trimmed', () {
      final s = Story.fromJson({'id': ' abc ', 'region': 'Europe\n'});
      expect(s.id, 'abc');
      expect(s.region, 'Europe');
    });

    test('objects where a string belongs are ignored', () {
      final s = Story.fromJson({
        'id': 'a',
        'title': {'en': 'x'},
        'author': ['x'],
      });
      expect(s.title, '');
      expect(s.author, '');
    });
  });

  group('story list envelope', () {
    test('skips non-objects, blank ids and duplicates', () {
      final stories = parseStoryList({
        'stories': [
          {'id': 'a', 'title': 'A'},
          'not a story',
          null,
          {'title': 'no id'},
          {'id': ''},
          {'id': 'b'},
          {'id': 'a', 'title': 'duplicate'},
        ],
      });
      expect(stories.map((s) => s.id), ['a', 'b']);
      expect(stories.first.title, 'A');
    });

    test('accepts a bare array', () {
      expect(
        parseStoryList([
          {'id': 'a'},
        ]),
        hasLength(1),
      );
    });

    test('rejects a payload without stories', () {
      expect(
        () => parseStoryList({'error': 'Not found'}),
        throwsFormatException,
      );
      expect(() => parseStoryList(null), throwsFormatException);
    });

    test('story detail without an id is rejected', () {
      expect(
        () => parseStoryDetail({'error': 'Not found'}),
        throwsFormatException,
      );
    });
  });

  group('LayoutConfig', () {
    test('an empty value parses to an empty layout', () {
      final layout = parseLayoutConfig({'value': <String, Object?>{}});
      expect(layout, const LayoutConfig());
      expect(layout.heroImageUrl, isNull);
      expect(layout.referencedIds, isEmpty);
    });

    test('null value and null fields are tolerated', () {
      final layout = parseLayoutConfig({
        'value': {
          'ticker': null,
          'hero_right': null,
          'regions': null,
          'featured': [null, 'a', '', 7],
        },
      });
      expect(layout.ticker, '');
      expect(layout.heroRight, isEmpty);
      expect(layout.regions, isEmpty);
      expect(layout.featured, ['a', '7']);
      expect(parseLayoutConfig({'value': null}), const LayoutConfig());
    });

    test('value stored as a JSON string is decoded', () {
      final layout = parseLayoutConfig({
        'value': jsonEncode({
          'hero_lead': 'lead-id',
          'editorial': ['x'],
        }),
      });
      expect(layout.heroLead, 'lead-id');
      expect(layout.editorial, ['x']);
    });

    test('a single id or comma list where an array belongs', () {
      final layout = parseLayoutConfig({
        'value': {'hero_right': 'only-one', 'featured': 'a, b ,c'},
      });
      expect(layout.heroRight, ['only-one']);
      expect(layout.featured, ['a', 'b', 'c']);
    });

    test('regions: website order first, extras after, blanks dropped', () {
      final layout = parseLayoutConfig({
        'value': {
          'regions': {
            'Oceania': 'o',
            'Africa': 'af',
            'Europe': 'eu',
            'Middle East': null,
            'The Americas': '',
          },
        },
      });
      expect(layout.orderedRegions.map((e) => '${e.key}=${e.value}'), [
        'Europe=eu',
        'Africa=af',
        'Oceania=o',
      ]);
    });

    test('ids pointing at unpublished stories are skipped silently', () {
      final layout = parseLayoutConfig({
        'value': {
          'hero_lead': 'draft',
          'hero_right': ['a', 'draft-2', 'b'],
          'regions': {'Europe': 'unpublished'},
        },
      });
      final index = StoryIndex([const Story(id: 'a'), const Story(id: 'b')]);
      expect(index[layout.heroLead], isNull);
      expect(index.resolve(layout.heroRight).map((s) => s.id), ['a', 'b']);
      expect(index.resolve(layout.orderedRegions.map((e) => e.value)), isEmpty);
    });

    test('relative hero_image resolves against the API host', () {
      expect(
        const LayoutConfig(heroImage: '/images/lead.jpg').heroImageUrl,
        'https://api.theutahview.com/images/lead.jpg',
      );
      expect(
        const LayoutConfig(heroImage: 'images/lead.jpg').heroImageUrl,
        'https://api.theutahview.com/images/lead.jpg',
      );
    });
  });

  group('SiteConfig and NavCategory', () {
    test('section flag accepts booleans, strings and numbers', () {
      final site = parseSiteConfig({
        'value': {
          'nav_categories': [
            {'text': 'Europe'},
            {'text': 'Analysis', 'section': true},
            {'text': 'Opinion', 'section': 'true'},
            {'text': 'Data', 'section': 1},
            {'text': 'Africa', 'section': null},
          ],
        },
      });
      expect(site.effectiveNavCategories.map((c) => c.section), [
        false,
        true,
        true,
        true,
        false,
      ]);
    });

    test('bare strings and blank entries in nav_categories', () {
      final site = parseSiteConfig({
        'value': {
          'nav_categories': [
            'Europe',
            {'text': ''},
            42,
            {'text': 'Opinion', 'section': true},
          ],
        },
      });
      expect(site.effectiveNavCategories.map((c) => c.text), [
        'Europe',
        'Opinion',
      ]);
    });

    test('empty nav_categories also falls back', () {
      final site = parseSiteConfig({
        'value': {'nav_categories': <Object?>[]},
      });
      expect(site.effectiveNavCategories, NavCategory.fallback);
    });

    test('subscribe copy defaults match the website', () {
      const site = SiteConfig();
      expect(site.subscribeOverline, 'Stay briefed');
      expect(site.subscribeHeading, 'Independent analysis, delivered monthly');
      expect(site.subscribeDescription, contains('every region'));
    });

    test('malformed footer columns are skipped', () {
      final site = parseSiteConfig({
        'value': {
          'footer_cols': [
            {
              'title': 'Regions',
              'links': [
                {'text': 'Europe', 'url': '?cat=Europe'},
                'bad',
              ],
            },
            'bad column',
          ],
        },
      });
      expect(site.footerCols, hasLength(1));
      expect(site.footerCols.single.links.single.url, '?cat=Europe');
    });
  });

  group('pages', () {
    test('entries without a slug are dropped', () {
      final pages = parsePageList({
        'pages': [
          {'slug': 'contact', 'title': 'Contact'},
          {'title': 'No slug'},
        ],
      });
      expect(pages.map((p) => p.slug), ['contact']);
    });

    test('missing page fields default to empty', () {
      final page = parseSitePage({'slug': 'x'});
      expect(page.title, '');
      expect(page.subtitle, '');
      expect(page.body, '');
    });
  });

  test('StoryDetail round-trips through JSON (used for saved stories)', () {
    final detail = parseStoryDetail(fixture('story_detail.json'));
    final copy = StoryDetail.fromJson(
      jsonDecode(jsonEncode(detail.toJson())) as Map<String, dynamic>,
    );
    expect(copy, detail);
  });
}
