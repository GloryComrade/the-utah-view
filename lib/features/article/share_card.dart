import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';

import 'share_file_io.dart' if (dart.library.html) 'share_file_web.dart';

/// Draws a branded 1080×1350 (4:5) share image for a story — a typography-first
/// card that reads well in an Instagram feed post or Story. Rendered with a
/// [Canvas] (no widget tree) so it can be produced off-screen at exact pixels.
class StoryShareCard {
  StoryShareCard._();

  static const double _w = 1080;
  static const double _h = 1350;
  static const double _margin = 96;
  static const double _contentW = _w - _margin * 2;

  static const Color _cream = Color(0xFFF7F6F4);
  static const Color _ink = Color(0xFF141414);
  static const Color _red = Color(0xFFB53816);
  static const Color _gray = Color(0xFF6B6B6B);
  static const Color _white = Color(0xFFFFFFFF);

  /// PNG bytes for the card.
  static Future<Uint8List> render({
    required String title,
    String kicker = '',
    String byline = '',
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, _w, _h),
    );

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _w, _h),
      Paint()..color = _cream,
    );

    const logoSize = 92.0;
    const top = 112.0;
    double wordmarkX = _margin;
    final logo = await _loadLogo(logoSize.toInt());
    if (logo != null) {
      canvas.drawImage(logo, const Offset(_margin, top), Paint());
      wordmarkX = _margin + logoSize + 26;
    }

    final wordmark = _painter(
      'THE UTAH VIEW',
      const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
        fontSize: 36,
        color: _ink,
        letterSpacing: 2,
      ),
      _w - wordmarkX - _margin,
      maxLines: 1,
    );
    wordmark.paint(canvas, Offset(wordmarkX, top + (logoSize - wordmark.height) / 2));

    const ruleY = top + logoSize + 44;
    canvas.drawRect(
      const Rect.fromLTWH(_margin, ruleY, _contentW, 5),
      Paint()..color = _red,
    );

    var cursor = ruleY + 56;

    if (kicker.trim().isNotEmpty) {
      final kp = _painter(
        kicker.toUpperCase(),
        const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 32,
          color: _red,
          letterSpacing: 2.5,
        ),
        _contentW,
        maxLines: 2,
      );
      kp.paint(canvas, Offset(_margin, cursor));
      cursor += kp.height + 30;
    }

    final headline = _painter(
      title.isEmpty ? 'The Utah View' : title,
      const TextStyle(
        fontFamily: 'SourceSerif4Display',
        fontWeight: FontWeight.w700,
        fontSize: 78,
        height: 1.1,
        color: _ink,
      ),
      _contentW,
      maxLines: 7,
    );
    headline.paint(canvas, Offset(_margin, cursor));
    cursor += headline.height + 38;

    if (byline.trim().isNotEmpty) {
      final bp = _painter(
        byline,
        const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 34,
          color: _gray,
        ),
        _contentW,
        maxLines: 2,
      );
      bp.paint(canvas, Offset(_margin, cursor));
    }

    const barH = 136.0;
    canvas.drawRect(
      const Rect.fromLTWH(0, _h - barH, _w, barH),
      Paint()..color = _red,
    );
    final footer = _painter(
      'Read the full story  ·  theutahview.com',
      const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 34,
        color: _white,
      ),
      _w - _margin * 2,
      align: TextAlign.center,
      maxLines: 1,
    );
    footer.paint(canvas, Offset(_margin, _h - barH + (barH - footer.height) / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(_w.toInt(), _h.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  static Future<ui.Image?> _loadLogo(int size) async {
    try {
      final data = await rootBundle.load('assets/brand/logo.png');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: size,
        targetHeight: size,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static TextPainter _painter(
    String text,
    TextStyle style,
    double maxWidth, {
    int? maxLines,
    TextAlign align = TextAlign.left,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: maxLines != null ? '…' : null,
    )..layout(maxWidth: maxWidth);
  }
}

/// Builds the share card and opens the platform share sheet (which includes
/// Instagram Stories/Feed). [origin] anchors the sheet on iPad.
Future<void> shareStoryCard({
  required String title,
  required Uri url,
  String kicker = '',
  String byline = '',
  Rect? origin,
}) async {
  final bytes = await StoryShareCard.render(
    title: title,
    kicker: kicker,
    byline: byline,
  );
  final file = await pngToShareFile(
    bytes,
    'utahview-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await SharePlus.instance.share(
    ShareParams(
      files: [file],
      text: '$title\n\n$url',
      sharePositionOrigin: origin,
    ),
  );
}
