import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app's navigation: web pages in an in-app browser
/// (SFSafariViewController / Custom Tabs), mail and phone links in their
/// apps. Returns false if nothing could handle it.
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return false;
  final isWeb = uri.scheme == 'http' || uri.scheme == 'https';
  final mode = isWeb && !kIsWeb
      ? LaunchMode.inAppBrowserView
      : LaunchMode.externalApplication;
  try {
    return await launchUrl(uri, mode: mode);
  } on Object {
    return false;
  }
}
