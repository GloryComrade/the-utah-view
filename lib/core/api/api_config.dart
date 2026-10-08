/// Endpoints and URL helpers for theutahview.com.
abstract final class ApiConfig {
  /// Cloudflare Worker that serves all JSON and images.
  static const baseUrl = 'https://api.theutahview.com';

  /// Public website. Shared links point here so they work without the app.
  static const siteUrl = 'https://theutahview.com';

  /// Hosts the app accepts as deep links.
  static const siteHosts = {'theutahview.com', 'www.theutahview.com'};

  /// The website's article URL, used for sharing and as a deep link.
  static Uri articleWebUri(String id) =>
      Uri.parse('$siteUrl/article.html').replace(queryParameters: {'id': id});

  /// Resolves an image or link found in CMS content to an absolute URL.
  /// Relative paths are resolved against the API host, where
  /// `/images/...` is served. Returns null for blank input.
  static String? resolveUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) return 'https:$value';
    return Uri.parse('$baseUrl/').resolve(value).toString();
  }
}
