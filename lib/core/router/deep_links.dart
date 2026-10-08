import '../api/api_config.dart';

/// Somewhere a website URL can take the reader inside the app.
sealed class DeepLinkTarget {
  const DeepLinkTarget();
}

class HomeTarget extends DeepLinkTarget {
  const HomeTarget();
}

class StoryTarget extends DeepLinkTarget {
  const StoryTarget(this.id);
  final String id;
}

class PageTarget extends DeepLinkTarget {
  const PageTarget(this.slug);
  final String slug;
}

class CategoryTarget extends DeepLinkTarget {
  const CategoryTarget(this.name);
  final String name;
}

class ArchiveTarget extends DeepLinkTarget {
  const ArchiveTarget();
}

class SavedTarget extends DeepLinkTarget {
  const SavedTarget();
}

/// Maps theutahview.com URLs (and the `theutahview://` test scheme) to app
/// destinations, using the same query parameters as the website:
///
/// * `/article.html?id=X` (or `/article?id=X`) → story X
/// * `/page.html?p=slug` (or `/page?p=slug`) → static page
/// * `/?cat=Europe` → section, `/?view=archive` → archive, `/?view=saved`
abstract final class DeepLinks {
  static const appScheme = 'theutahview';

  /// Returns null for links that belong outside the app (other sites,
  /// mailto:, unknown website paths).
  static DeepLinkTarget? parse(Uri uri) {
    if (uri.hasScheme) {
      final web = uri.scheme == 'https' || uri.scheme == 'http';
      final site = web && ApiConfig.siteHosts.contains(uri.host.toLowerCase());
      if (!site && uri.scheme != appScheme) return null;
    }

    var path = uri.path.toLowerCase();
    // theutahview://article?id=X arrives with "article" as the host.
    if (uri.scheme == appScheme && (path.isEmpty || path == '/')) {
      path = uri.host.isEmpty ? '/' : '/${uri.host.toLowerCase()}';
    }
    if (!path.startsWith('/')) path = '/$path';
    if (path.endsWith('.html')) path = path.substring(0, path.length - 5);
    final q = uri.queryParameters;
    String? param(String key) {
      final value = q[key]?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    switch (path) {
      case '/article':
        final id = param('id');
        return id == null ? const HomeTarget() : StoryTarget(id);
      case '/page':
        final slug = param('p');
        return slug == null ? const HomeTarget() : PageTarget(slug);
      case '/' || '/index':
        if (param('id') case final id?) return StoryTarget(id);
        if (param('p') case final slug?) return PageTarget(slug);
        if (param('cat') case final cat?) return CategoryTarget(cat);
        return switch (param('view')) {
          'archive' => const ArchiveTarget(),
          'saved' => const SavedTarget(),
          _ => const HomeTarget(),
        };
      default:
        return null;
    }
  }

  /// [parse] for a link found in article HTML, where `article.html?id=X`
  /// may be relative to the website.
  static DeepLinkTarget? parseLink(String href) {
    final uri = Uri.tryParse(href.trim());
    if (uri == null) return null;
    return parse(
      uri.hasScheme ? uri : Uri.parse(ApiConfig.siteUrl).resolveUri(uri),
    );
  }
}
