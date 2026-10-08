// Fetches every public endpoint on the live API and parses it with the app's
// own models and parsers, then reports anything the app would have to skip.
//
//   dart run tool/verify_api.dart            # read-only checks
//   dart run tool/verify_api.dart --fixtures # also refresh test/fixtures
//
// Never calls /api/subscribe or /api/unsubscribe (they write to the list).
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:utah_view/core/api/api_client.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/news_repository.dart';
import 'package:utah_view/core/domain/story_filters.dart';
import 'package:utah_view/core/domain/story_index.dart';
import 'package:utah_view/core/storage/key_value_store.dart';

Future<void> main(List<String> args) async {
  final writeFixtures = args.contains('--fixtures');
  final dio = Dio();
  // Desktop runs honor HTTP(S)_PROXY like curl does; the app itself doesn't
  // need this on devices.
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () =>
        HttpClient()..findProxy = HttpClient.findProxyFromEnvironment,
  );
  final api = ApiClient(
    dio: dio..options.baseUrl = 'https://api.theutahview.com',
  );
  final repo = NewsRepository(api: api, cache: MemoryKeyValueStore());
  final problems = <String>[];
  final notes = <String>[];

  Future<T?> check<T>(String label, Future<T> Function() run) async {
    try {
      final value = await run();
      print('  ok   $label');
      return value;
    } on Object catch (e) {
      problems.add('$label: $e');
      print('  FAIL $label: $e');
      return null;
    }
  }

  print('Endpoints');
  final stories =
      await check(
        'GET /api/stories',
        () => repo.fetch(NewsRepository.stories),
      ) ??
      [];
  final layout = await check(
    'GET /api/config/layout',
    () => repo.fetch(NewsRepository.layout),
  );
  final site = await check(
    'GET /api/config/site',
    () => repo.fetch(NewsRepository.site),
  );
  final pages =
      await check('GET /api/pages', () => repo.fetch(NewsRepository.pages)) ??
      [];
  await check('GET /api/stories?region=Europe', () async {
    final json = await api.getJson('/api/stories', query: {'region': 'Europe'});
    final regional = repo.cachedOrParse(json);
    if (regional.any((s) => s.region != 'Europe')) {
      throw StateError('region filter returned other regions');
    }
    return regional;
  });

  print('\nStories (${stories.length})');
  final index = StoryIndex(stories);
  final regions = <String, int>{};
  for (final s in stories) {
    regions[s.region] = (regions[s.region] ?? 0) + 1;
  }
  print('  regions: $regions');
  final badReadTime = stories.where((s) => s.readTimeLabel == null).toList();
  for (final s in badReadTime) {
    notes.add(
      'read_time "${s.readTime}" on "${s.id}" is not a duration; byline omits it',
    );
  }
  final badDates = stories.where(
    (s) => s.displayDate == s.date && s.date.isNotEmpty,
  );
  for (final s in badDates) {
    notes.add('date "${s.date}" on "${s.id}" is not YYYY-MM-DD');
  }

  var detailOk = 0;
  final details = <String, Object?>{};
  for (final s in stories) {
    try {
      final json = await api.getJson(
        '/api/stories/${Uri.encodeComponent(s.id)}',
      );
      final detail = NewsRepository.story(s.id).parse(json);
      if (detail.id != s.id) throw StateError('id mismatch ${detail.id}');
      if (detail.body.trim().isEmpty) {
        notes.add('story "${s.id}" has an empty body');
      }
      details[s.id] = json;
      detailOk++;
    } on Object catch (e) {
      problems.add('GET /api/stories/${s.id}: $e');
    }
  }
  print('  ok   $detailOk/${stories.length} story bodies parsed');
  final tags = <String>{};
  for (final json in details.values) {
    final body = (json as Map)['body'];
    if (body is String) {
      tags.addAll(
        RegExp(r'<([a-zA-Z0-9]+)')
            .allMatches(body)
            .map((m) => m[1]!.toLowerCase()),
      );
    }
  }
  print('  HTML tags used in bodies: ${tags.toList()..sort()}');

  if (layout != null) {
    print('\nLayout');
    void slot(String name, Iterable<String> ids) {
      final missing = ids
          .where((id) => id.isNotEmpty && index[id] == null)
          .toList();
      final resolved = index.resolve(ids).length;
      print(
        '  ${name.padRight(16)} ${ids.where((i) => i.isNotEmpty).length} ids → $resolved published',
      );
      for (final id in missing) {
        notes.add(
          'layout.$name references "$id", which is not published (skipped)',
        );
      }
    }

    slot('hero_lead', [layout.heroLead]);
    slot('hero_secondary', [layout.heroSecondary]);
    slot('hero_center', [layout.heroCenter]);
    slot('hero_right', layout.heroRight);
    slot('editorial', layout.editorial);
    slot('regions', layout.orderedRegions.map((e) => e.value));
    slot('featured', layout.featured);
    slot('sidebar_utah', layout.sidebarUtah);
    slot('sidebar_data', layout.sidebarData);
    print('  hero_image: ${layout.heroImageUrl ?? '(none)'}');
    print('  ticker: ${layout.ticker.length} chars');
  }

  if (site != null) {
    print('\nSite config');
    print(
      '  nav_categories: ${site.navCategories == null ? 'missing → using fallback' : '${site.navCategories!.length} configured'}',
    );
    for (final c in site.effectiveNavCategories) {
      final count = storiesForCategory(stories, c).length;
      print(
        '    ${c.text.padRight(14)} ${c.section ? 'section' : 'region '}  $count stories',
      );
    }
    print(
      '  subscribe: "${site.subscribeOverline}" / "${site.subscribeHeading}"',
    );
    print('  footer columns: ${site.footerCols.length}');
  }

  print('\nPages (${pages.length})');
  final pageJson = <String, Object?>{};
  for (final p in pages) {
    try {
      final json = await api.getJson(
        '/api/pages/${Uri.encodeComponent(p.slug)}',
      );
      final page = NewsRepository.page(p.slug).parse(json);
      pageJson[p.slug] = json;
      print('  ok   ${p.slug} (${page.body.length} chars)');
    } on ApiException catch (e) {
      notes.add(
        'page "${p.slug}" is listed but GET /api/pages/{slug} fails (${e.kind.name}); the app shows "not available"',
      );
      print('  skip ${p.slug}: ${e.kind.name}');
    }
  }

  if (writeFixtures) {
    const dir = 'test/fixtures';
    Directory(dir).createSync(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    Future<void> save(String name, Object? json) =>
        File('$dir/$name').writeAsString('${encoder.convert(json)}\n');
    await save('stories.json', await api.getJson('/api/stories'));
    await save('layout.json', await api.getJson('/api/config/layout'));
    await save('site.json', await api.getJson('/api/config/site'));
    await save('pages.json', await api.getJson('/api/pages'));
    final leadId = layout?.heroLead ?? stories.first.id;
    await save('story_detail.json', details[leadId]);
    if (pageJson['our-mission'] != null) {
      await save('page_our_mission.json', pageJson['our-mission']);
    }
    print('\nWrote fixtures to $dir');
  }

  print('\nNotes (${notes.length})');
  for (final n in notes) {
    print('  - $n');
  }
  print(
    '\n${problems.isEmpty ? 'PASS' : 'FAIL'}: ${problems.length} problem(s)',
  );
  for (final p in problems) {
    print('  ! $p');
  }
  exit(problems.isEmpty ? 0 : 1);
}

extension on NewsRepository {
  List<Story> cachedOrParse(Object? json) => NewsRepository.stories.parse(json);
}
