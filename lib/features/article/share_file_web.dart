import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Web: the bytes ride along in memory; the Web Share API takes them directly.
Future<XFile> pngToShareFile(Uint8List bytes, String name) async =>
    XFile.fromData(bytes, mimeType: 'image/png', name: name);
