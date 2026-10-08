// Renders the design gallery to PNGs for review without a simulator.
//
//   flutter test tool/screenshots/gallery_screenshot_test.dart
//
// Output: docs/screenshots/gallery-{light,dark}.png
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/features/gallery/widget_gallery_screen.dart';

import '../../test/support/test_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final dark in [false, true]) {
    testWidgets('gallery ${dark ? 'dark' : 'light'}', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      setScreenSize(tester, const Size(402, 874));
      await tester.pumpWidget(
        testApp(
          WidgetGalleryScreen(initialDark: dark, date: DateTime(2026, 10, 6)),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      await expandToFullHeight(tester, 402);
      await tester.pump(const Duration(seconds: 2));
      await captureScreen(
        tester,
        'docs/screenshots/gallery-${dark ? 'dark' : 'light'}.png',
      );
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
