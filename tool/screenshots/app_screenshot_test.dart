// Renders the real screens, using the live-API fixtures, to PNGs.
//
//   flutter test tool/screenshots/app_screenshot_test.dart
//
// Output: docs/screenshots/*.png (network photos show the placeholder).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/features/saved/saved_stories.dart';

import '../../test/support/app_harness.dart';
import '../../test/support/fixtures.dart';
import '../../test/support/test_harness.dart';

const _phone = Size(402, 874);
const _tablet = Size(1024, 1366);

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required String location,
  Size size = _phone,
  bool dark = false,
  bool fullHeight = false,
  Future<void> Function()? before,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  setScreenSize(tester, size, ratio: 2);
  final stores = seededStores();
  // One saved story so the Saved tab has something to show.
  final detail = parseStoryDetail(fixture('story_detail.json'));
  await stores.savedStories.write(
    detail.id,
    jsonEncode(SavedStory(detail, DateTime(2026, 10, 5)).toJson()),
  );
  await tester.pumpWidget(
    routerTestApp(location: location, stores: stores, dark: dark),
  );
  await settle(tester, 15);
  await before?.call();
  if (fullHeight) await expandToFullHeight(tester, size.width);
  await settle(tester, 5);
  await captureScreen(tester, 'docs/screenshots/$name.png');
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('home', (t) => _shoot(t, name: 'home', location: '/home'));
  testWidgets(
    'home full',
    (t) => _shoot(t, name: 'home-full', location: '/home', fullHeight: true),
  );
  testWidgets(
    'home dark',
    (t) => _shoot(t, name: 'home-dark', location: '/home', dark: true),
  );
  testWidgets(
    'home tablet',
    (t) => _shoot(
      t,
      name: 'home-tablet',
      location: '/home',
      size: _tablet,
      fullHeight: true,
    ),
  );
  testWidgets('article', (t) async {
    final id = fixtureLeadId;
    await _shoot(
      t,
      name: 'article',
      location: '/home/story/$id',
      fullHeight: true,
    );
  });
  testWidgets(
    'sections',
    (t) => _shoot(t, name: 'sections', location: '/sections'),
  );
  testWidgets(
    'section list',
    (t) => _shoot(t, name: 'section-europe', location: '/sections/c/Europe'),
  );
  testWidgets(
    'archive',
    (t) => _shoot(t, name: 'archive', location: '/sections/archive'),
  );
  testWidgets('saved', (t) => _shoot(t, name: 'saved', location: '/saved'));
  testWidgets(
    'search',
    (t) => _shoot(
      t,
      name: 'search',
      location: '/search',
      before: () async {
        await t.enterText(find.byType(TextField), 'korea');
        await settle(t, 3);
      },
    ),
  );
  testWidgets(
    'more',
    (t) => _shoot(t, name: 'more', location: '/more', fullHeight: true),
  );
}
