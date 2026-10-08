// A plain web <img> image used only on Flutter web so cross-origin images
// (e.g. a hot-linked hero without CORS headers) still display.
export 'html_image_stub.dart' if (dart.library.html) 'html_image_web.dart';
