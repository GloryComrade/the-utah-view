import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/core/api/providers.dart';
import 'package:utah_view/core/storage/key_value_store.dart';
import 'package:utah_view/core/theme/theme.dart';
import 'package:utah_view/shared/widgets/story_image.dart';

/// Wraps the whole app in [testApp] so [captureScreen] can grab it.
const screenshotKey = ValueKey('screenshot-root');

/// Loads every font in the app's FontManifest so widget tests and
/// screenshots render real glyphs instead of the test font's boxes.
Future<void> loadAppFonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json'));
  if (manifest is! List) return;
  for (final family in manifest.whereType<Map<String, Object?>>()) {
    final name = family['family'];
    final fonts = family['fonts'];
    if (name is! String || fonts is! List) continue;
    final loader = FontLoader(name);
    for (final font in fonts.whereType<Map<String, Object?>>()) {
      final asset = font['asset'];
      if (asset is String) loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

/// Wraps [child] in the app's theme, an in-memory ProviderScope and a
/// network-free image policy.
Widget testApp(
  Widget child, {
  bool dark = false,
  List<Object> overrides = const [],
  AppStores? stores,
}) {
  return ProviderScope(
    overrides: [
      appStoresProvider.overrideWithValue(stores ?? AppStores.inMemory()),
      ...overrides.cast(),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, app) =>
          RepaintBoundary(key: screenshotKey, child: app),
      home: ImagePolicy(loadNetworkImages: false, child: child),
    ),
  );
}

/// Sets the logical screen size for the current test.
void setScreenSize(WidgetTester tester, Size size, {double ratio = 3}) {
  tester.view
    ..physicalSize = size * ratio
    ..devicePixelRatio = ratio;
  addTearDown(tester.view.reset);
}

/// Grows the screen until the first vertical scrollable fits entirely,
/// so a single capture shows the whole page.
Future<void> expandToFullHeight(WidgetTester tester, double width) async {
  final scrollable = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  // Lazy slivers only estimate their extent, so grow until it stops moving.
  var previous = 0.0;
  for (var pass = 0; pass < 6; pass++) {
    final position = tester.state<ScrollableState>(scrollable.first).position;
    final fullHeight = position.maxScrollExtent + position.viewportDimension;
    if ((fullHeight - previous).abs() < 1) break;
    previous = fullHeight;
    setScreenSize(tester, Size(width, fullHeight), ratio: 2);
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// Writes the current screen to [path] as a PNG.
Future<void> captureScreen(WidgetTester tester, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(screenshotKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
