import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Native: write the PNG to a temp file so the OS share sheet can attach it.
Future<XFile> pngToShareFile(Uint8List bytes, String name) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return XFile(file.path, mimeType: 'image/png', name: name);
}
