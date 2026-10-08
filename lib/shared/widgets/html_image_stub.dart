import 'package:material_ui/material_ui.dart';

/// Non-web placeholder; never rendered (story_image.dart guards with kIsWeb).
Widget htmlImage(String url, {BoxFit fit = BoxFit.cover}) =>
    const SizedBox.shrink();
