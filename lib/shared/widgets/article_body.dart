import 'dart:async';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_config.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/links.dart';
import 'story_image.dart';

/// Strips presentation the CMS lets editors paste in (Google Docs inline
/// styles force white backgrounds and fixed colors, which break dark mode
/// and the type scale) and drops empty paragraphs.
String sanitizeArticleHtml(String html) => html
    .replaceAll(
      RegExp(r'''\s+style\s*=\s*("[^"]*"|'[^']*')''', caseSensitive: false),
      '',
    )
    .replaceAll(
      RegExp(
        r'''\s+(dir|class|id)\s*=\s*("[^"]*"|'[^']*')''',
        caseSensitive: false,
      ),
      '',
    )
    .replaceAll(
      RegExp(r'<p>(\s|&nbsp;|<br\s*/?>)*</p>', caseSensitive: false),
      '',
    )
    .trim();

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Renders a story or page body natively, styled like the website's
/// `.article-body`: serif copy at a comfortable measure, bold serif subheads,
/// red-ruled blockquotes and full-width rounded images.
class ArticleBody extends StatelessWidget {
  const ArticleBody({
    super.key,
    required this.html,
    this.scale = 1.0,
    this.onTapUrl,
  });

  final String html;

  /// The reader's text-size preference (A−/A+).
  final double scale;

  /// Handles a tapped link. Return true if handled; otherwise the link
  /// opens in the in-app browser.
  final FutureOr<bool> Function(String url)? onTapUrl;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final news = context.news;
    final base = news.body.copyWith(fontSize: news.body.fontSize! * scale);
    final ink = _hex(p.ink);
    final accent = _hex(p.accent);

    return HtmlWidget(
      sanitizeArticleHtml(html),
      textStyle: base,
      baseUrl: Uri.parse('${ApiConfig.baseUrl}/'),
      customStylesBuilder: (element) => switch (element.localName) {
        'p' => const {'margin': '0 0 1.1em 0'},
        'h1' || 'h2' || 'h3' || 'h4' => {
          'font-family': AppFonts.headline,
          'font-weight': '700',
          'font-size': element.localName == 'h4' ? '1.1em' : '1.3em',
          'line-height': '1.25',
          'margin': '1.6em 0 0.55em 0',
          'color': ink,
        },
        'blockquote' => {
          'border-left': '3px solid $accent',
          'padding': '0.1em 0 0.1em 1em',
          'margin': '1.4em 0',
          'font-style': 'italic',
          'font-size': '1.08em',
          'color': ink,
        },
        'a' => {'color': accent, 'text-decoration': 'underline'},
        'strong' || 'b' => {'color': ink, 'font-weight': '700'},
        'ul' ||
        'ol' => const {'margin': '0 0 1.1em 0', 'padding-left': '1.4em'},
        'li' => const {'margin': '0 0 0.45em 0'},
        'figure' => const {'margin': '1em 0'},
        'figcaption' => {
          'font-family': AppFonts.sans,
          'font-size': '0.7em',
          'line-height': '1.4',
          'color': _hex(p.inkMuted),
          'margin': '0.5em 0 0 0',
        },
        _ => null,
      },
      customWidgetBuilder: (element) {
        if (element.localName != 'img') return null;
        final src = ApiConfig.resolveUrl(element.attributes['src']);
        if (src == null) return const SizedBox.shrink();
        final alt = element.attributes['alt']?.trim();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: StoryImage(
            url: src,
            aspectRatio: null,
            borderRadius: 4,
            semanticLabel: alt == null || alt.isEmpty ? null : alt,
          ),
        );
      },
      onTapUrl: (url) async {
        final handled = await onTapUrl?.call(url) ?? false;
        return handled || await openExternalUrl(url);
      },
    );
  }
}
