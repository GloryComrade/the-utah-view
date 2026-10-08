import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/core/domain/story_filters.dart';
import 'package:utah_view/core/domain/story_search.dart';

import '../support/app_harness.dart';
import '../support/fixtures.dart';
import '../support/test_harness.dart';

Finder get _feed => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .first;

void main() {
  final stories = parseStoryList(fixture('stories.json'));
  final layout = parseLayoutConfig(fixture('layout.json'));
  final lead = stories.firstWhere((s) => s.id == layout.heroLead);

  setUpAll(loadAppFonts);

  group('Home', () {
    testWidgets('renders the front page from cache while offline', (
      tester,
    ) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/home'));
      await settle(tester);

      expect(find.text('BRIEFING'), findsOneWidget);
      expect(find.text(lead.title), findsOneWidget);
      expect(find.text('EVERY REGION · EVERY MONTH'), findsOneWidget);

      for (final heading in [
        'EDITORIAL & OPINION',
        'AROUND THE WORLD',
        'IN THIS ISSUE',
        'THE UTAH LENS',
      ]) {
        await tester.scrollUntilVisible(
          find.text(heading),
          400,
          scrollable: _feed,
        );
        expect(find.text(heading), findsOneWidget, reason: heading);
      }
      expect(find.text('01'), findsOneWidget);
      // Data Brief is empty in the live layout, so it is hidden.
      expect(find.text('DATA BRIEF'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('SUBSCRIBE'),
        400,
        scrollable: _feed,
      );
      expect(find.text('Stay briefed'.toUpperCase()), findsOneWidget);
    });

    testWidgets('two-column tablet layout', (tester) async {
      setScreenSize(tester, const Size(1024, 1366), ratio: 2);
      await tester.pumpWidget(routerTestApp(location: '/home'));
      await settle(tester);
      expect(find.text(lead.title), findsOneWidget);
      expect(find.text('FROM THIS ISSUE'), findsOneWidget);
    });

    testWidgets('survives 200% text without overflow', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(routerTestApp(location: '/home'));
      await settle(tester);
      await tester.scrollUntilVisible(
        find.text('IN THIS ISSUE'),
        600,
        scrollable: _feed,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark mode', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/home', dark: true));
      await settle(tester);
      expect(find.text(lead.title), findsOneWidget);
    });

    testWidgets('falls back to newest-first when the layout is unavailable', (
      tester,
    ) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        routerTestApp(
          location: '/home',
          stores: seededStores(withLayout: false),
        ),
      );
      await settle(tester, 40);
      expect(find.text(stories.first.title), findsOneWidget);
    });
  });

  group('Article', () {
    testWidgets('opens from the lead card, renders the body, saves offline', (
      tester,
    ) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/home'));
      await settle(tester);

      await tester.tap(find.text(lead.title));
      await settle(tester);

      // Header, byline and the HTML body from the cached detail.
      expect(find.text(lead.title), findsOneWidget);
      expect(find.textContaining('By ', findRichText: true), findsWidgets);
      final detail = parseStoryDetail(fixture('story_detail.json'));
      final firstWords = RegExp(r'<p>([^<]{20})').firstMatch(detail.body)![1]!;
      expect(
        find.textContaining(firstWords, findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Save for later'));
      await settle(tester, 4);
      expect(find.text('Saved for offline reading'), findsOneWidget);
      expect(find.byTooltip('Remove from Saved'), findsOneWidget);

      // Back to Home, then the Saved tab lists it.
      await tester.tap(find.byType(BackButton));
      await settle(tester);
      await tester.tap(find.text('Saved'));
      await settle(tester);
      expect(find.text(lead.title), findsOneWidget);
      expect(find.textContaining('available offline'), findsOneWidget);
    });

    testWidgets('a website link opens the article above Home', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        routerTestApp(location: '/article.html?id=${lead.id}'),
      );
      await settle(tester);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text(lead.title), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.text('BRIEFING'), findsOneWidget);
    });

    testWidgets('an unknown story shows a friendly message', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/story/missing'));
      await settle(tester, 80);
      expect(find.text('No connection'), findsOneWidget);
    });
  });

  group('Sections', () {
    testWidgets('categories use the website filter rule', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/sections'));
      await settle(tester);

      for (final category in NavCategory.fallback) {
        expect(find.text(category.text), findsOneWidget);
      }
      final europe = storiesForCategory(
        stories,
        const NavCategory(text: 'Europe'),
      );
      await tester.tap(find.text('Europe'));
      await settle(tester);
      expect(find.text('${europe.length} articles'), findsOneWidget);
      expect(find.text(europe.first.title), findsOneWidget);
    });

    testWidgets('a section includes Global and The Utah Lens', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/sections/c/Opinion'));
      await settle(tester);
      final expected = storiesForCategory(
        stories,
        const NavCategory(text: 'Opinion', section: true),
      );
      expect(find.text('${expected.length} articles'), findsOneWidget);
    });

    testWidgets('archive groups stories by issue month', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/sections/archive'));
      await settle(tester);
      expect(find.text('${stories.length} articles'), findsOneWidget);
      final newest = archiveStories(stories).first;
      expect(find.text(newest.title), findsOneWidget);
    });
  });

  group('Search', () {
    testWidgets('searches the cached list from the Home app bar', (
      tester,
    ) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/home'));
      await settle(tester);

      await tester.tap(find.byTooltip('Search'));
      await settle(tester);
      expect(find.text('BROWSE BY REGION'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'korea');
      await settle(tester, 3);
      final expected = searchStories(stories, 'korea');
      expect(expected, isNotEmpty);
      expect(find.text('${expected.length} results'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzzzqx');
      await settle(tester, 3);
      expect(find.textContaining('No results'), findsOneWidget);
    });
  });

  group('More', () {
    testWidgets('lists About pages and settings', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/more'));
      await settle(tester);
      expect(find.text('Our Mission'), findsOneWidget);
      // The CMS's internal "Home Page" entry is hidden.
      expect(find.text('Home Page'), findsNothing);

      await tester.tap(find.text('Our Mission'));
      await settle(tester);
      expect(
        find.textContaining('make global news accessible', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('appearance and text size settings', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(routerTestApp(location: '/more'));
      await settle(tester);
      // Build the row (lazy list), then bring it fully on screen.
      await tester.scrollUntilVisible(
        find.text('Dark'),
        300,
        scrollable: _feed,
      );
      await tester.ensureVisible(find.text('Dark'));
      await settle(tester, 3);
      await tester.tap(find.text('Dark'));
      await settle(tester, 4);
      final context = tester.element(find.text('Dark'));
      expect(Theme.of(context).brightness, Brightness.dark);

      // A+ in the article sheet and this slider share one setting.
      await tester.ensureVisible(find.byType(Slider));
      await settle(tester, 3);
      expect(find.text('Default'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(400, 0));
      await settle(tester, 3);
      expect(find.text('Largest'), findsOneWidget);
    });
  });
}
