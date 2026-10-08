// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:material_ui/material_ui.dart';

final Set<String> _registered = <String>{};

/// Renders [url] as a DOM <img> overlaid by the Flutter engine. Works for
/// cross-origin images without CORS headers (unlike CanvasKit decoding).
Widget htmlImage(String url, {BoxFit fit = BoxFit.cover}) {
  final viewType = 'utv-img:$url';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final img = html.ImageElement()
        ..src = url
        ..referrerPolicy = 'no-referrer'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..style.objectFit = fit == BoxFit.cover ? 'cover' : 'contain';
      return img;
    });
  }
  return HtmlElementView(viewType: viewType);
}
