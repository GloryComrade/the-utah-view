// Renders the app icon and splash images from the same painter the app uses
// for its logo, so every surface matches the website's SVG exactly.
//
//   flutter test tool/brand_assets/generate_brand_assets_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/core/theme/theme.dart';
import 'package:utah_view/shared/widgets/brand.dart';

import '../../test/support/test_harness.dart';

/// [logoFraction] is the logo's box as a share of the canvas. The mark fills
/// 92% of its own 100×100 box.
Future<void> _render(
  String path, {
  required int size,
  required double logoFraction,
  Color? background,
  UtvLogoPainter painter = const UtvLogoPainter(),
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final full = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
  if (background != null) canvas.drawRect(full, Paint()..color = background);
  final logo = size * logoFraction;
  canvas.translate((size - logo) / 2, (size - logo) / 2);
  painter.paint(canvas, Size.square(logo));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('generate brand assets', () async {
    const dir = 'assets/brand';
    // iOS + legacy Android: opaque white square, logo at ~2/3.
    await _render(
      '$dir/app_icon.png',
      size: 1024,
      logoFraction: 0.66,
      background: BrandColors.white,
    );
    // Android adaptive foreground: must fit the 66dp safe circle of a
    // 108dp canvas, corners included, so the mask never clips the brackets.
    await _render(
      '$dir/app_icon_foreground.png',
      size: 1024,
      logoFraction: 0.46,
    );
    // Android 13 themed icon: one opaque color, inner square punched out.
    await _render(
      '$dir/app_icon_monochrome.png',
      size: 1024,
      logoFraction: 0.46,
      painter: const UtvLogoPainter(color: Color(0xFF000000), innerColor: null),
    );
    // iOS / pre-12 Android splash, authored at 4x (120pt logo).
    await _render('$dir/splash_logo.png', size: 480, logoFraction: 1);
    // Android 12+ splash: 288dp icon area at 4x, logo inside the 192dp
    // circle the system crops to.
    await _render(
      '$dir/splash_logo_android12.png',
      size: 1152,
      logoFraction: 0.46,
    );
  });
}
