import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Font families bundled in `assets/fonts` (see pubspec.yaml).
///
/// Two faces, by design: **Playfair Display Black Italic** for "The Utah View"
/// wordmark (the same face as the website masthead) and **Newsreader** for every other piece of text —
/// headlines, body, dates, image credits, section labels and UI chrome. The
/// `sans`/`body` aliases below now resolve to Newsreader too, so the whole
/// interface reads in the one editorial serif.
abstract final class AppFonts {
  /// The wordmark / display face. Only "The Utah View".
  static const display = 'PlayfairDisplay';

  /// Newsreader (variable opsz,wght). Deks and summaries (often italic).
  static const serif = 'Newsreader';

  /// Newsreader at display optical sizes. Headlines.
  static const headline = 'Newsreader';

  /// Newsreader. Kept as the "sans" alias so UI chrome reads in the one face.
  static const sans = 'Newsreader';

  /// Newsreader. Article body copy.
  static const body = 'Newsreader';

  /// Fallbacks used while a glyph is missing from the subset fonts.
  static const serifFallback = <String>['Georgia', 'Times New Roman', 'serif'];

  /// The text aliases are serif now, so they fall back to a serif too.
  static const sansFallback = <String>['Georgia', 'Times New Roman', 'serif'];

  /// The wordmark falls back to a heavy serif, as on the website.
  static const displayFallback = <String>['Georgia', 'Times New Roman', 'serif'];
}

/// The editorial type scale. Read it with `context.news` (see
/// `theme_context.dart`) rather than building TextStyles inline.
@immutable
class NewsTextStyles extends ThemeExtension<NewsTextStyles> {
  const NewsTextStyles({
    required this.wordmark,
    required this.tagline,
    required this.dateline,
    required this.sectionLabel,
    required this.sectionLabelMuted,
    required this.blockTitle,
    required this.headlineXL,
    required this.headlineL,
    required this.headlineM,
    required this.headlineS,
    required this.headlineXS,
    required this.articleTitle,
    required this.pageTitle,
    required this.summaryL,
    required this.summary,
    required this.summaryS,
    required this.articleSummary,
    required this.body,
    required this.byline,
    required this.bylineStrong,
    required this.meta,
    required this.numeral,
    required this.button,
    required this.ticker,
    required this.tickerLabel,
    required this.listTitle,
  });

  factory NewsTextStyles.from(AppPalette p) {
    TextStyle sans(
      double size,
      FontWeight weight,
      Color color, {
      double spacing = 0,
      double height = 1.3,
    }) => TextStyle(
      fontFamily: AppFonts.sans,
      fontFamilyFallback: AppFonts.sansFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
      height: height,
      leadingDistribution: TextLeadingDistribution.even,
    );
    // Newsreader is optically sized (6–72pt); drive the opsz axis from the
    // point size so big headlines use the display cut and small text the
    // text cut.
    TextStyle head(
      double size,
      double height, {
      FontWeight weight = FontWeight.w700,
      double spacing = -0.2,
    }) => TextStyle(
      fontFamily: AppFonts.headline,
      fontFamilyFallback: AppFonts.serifFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: p.ink,
      fontVariations: [FontVariation('opsz', size.clamp(6, 72))],
      leadingDistribution: TextLeadingDistribution.even,
    );
    // Deks and summaries: Newsreader, usually italic for the one-line dek.
    TextStyle serif(
      double size,
      double height,
      Color color, {
      FontWeight weight = FontWeight.w400,
      bool italic = false,
    }) => TextStyle(
      fontFamily: AppFonts.serif,
      fontFamilyFallback: AppFonts.serifFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontVariations: [FontVariation('opsz', size.clamp(6, 72))],
      leadingDistribution: TextLeadingDistribution.even,
    );
    // Body copy and running text: IBM Plex Sans.
    TextStyle plex(
      double size,
      FontWeight weight,
      Color color, {
      double spacing = 0,
      double height = 1.6,
    }) => TextStyle(
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.sansFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
      height: height,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return NewsTextStyles(
      // The one display face: Playfair Display Black Italic, as on the
      // website masthead, set tight with no tracking.
      wordmark: TextStyle(
        fontFamily: AppFonts.display,
        fontFamilyFallback: AppFonts.displayFallback,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: p.ink,
        letterSpacing: 0,
        height: 1.05,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      // Motto under the flag: editorial serif italic, untracked.
      tagline: serif(13, 1.3, p.inkMuted, italic: true),
      // Dateline set to match the article serif (no tracking).
      dateline: serif(12, 1.3, p.inkMuted, weight: FontWeight.w600),
      sectionLabel: sans(11, FontWeight.w700, p.accent, spacing: 0.5),
      sectionLabelMuted: sans(11, FontWeight.w700, p.inkMuted, spacing: 0.5),
      blockTitle: sans(13, FontWeight.w800, p.ink, spacing: 0.3),
      headlineXL: head(30, 1.12, spacing: -0.4),
      headlineL: head(24, 1.15, spacing: -0.3),
      headlineM: head(21, 1.2),
      headlineS: head(18, 1.24, spacing: -0.1),
      headlineXS: head(16, 1.28, spacing: 0),
      articleTitle: head(32, 1.12, spacing: -0.5),
      pageTitle: head(28, 1.15, spacing: -0.4),
      summaryL: serif(17, 1.5, p.inkSecondary),
      summary: serif(15.5, 1.5, p.inkSecondary),
      summaryS: serif(14.5, 1.45, p.inkMuted),
      articleSummary: serif(21, 1.42, p.inkSecondary, italic: true),
      body: plex(18, FontWeight.w400, p.inkSecondary, height: 1.6),
      byline: sans(12, FontWeight.w400, p.inkMuted, height: 1.4),
      bylineStrong: sans(12, FontWeight.w600, p.ink, height: 1.4),
      meta: sans(12, FontWeight.w500, p.inkMuted, height: 1.4),
      numeral: head(
        32,
        1,
        weight: FontWeight.w600,
        spacing: -0.5,
      ).copyWith(color: p.inkMuted),
      button: sans(12.5, FontWeight.w700, p.onAccentFill, spacing: 0.3),
      ticker: sans(13.5, FontWeight.w700, p.onAccentFill, spacing: 0.3, height: 1.35),
      tickerLabel: sans(10.5, FontWeight.w800, p.accent, spacing: 0.8),
      listTitle: head(20, 1.2, weight: FontWeight.w600),
    );
  }

  /// "The Utah View" wordmark (Playfair Display Black Italic).
  final TextStyle wordmark;

  /// "EVERY REGION · EVERY MONTH".
  final TextStyle tagline;

  /// Today's date under the masthead.
  final TextStyle dateline;

  /// Red uppercase kicker above a headline, e.g. "EUROPE".
  final TextStyle sectionLabel;

  /// Gray kicker, e.g. "FROM THIS ISSUE".
  final TextStyle sectionLabelMuted;

  /// Black uppercase block heading after a thick rule, e.g. "IN THIS ISSUE".
  final TextStyle blockTitle;

  /// Lead story headline.
  final TextStyle headlineXL;

  /// Large secondary headline (editorial lead).
  final TextStyle headlineL;

  /// Standard story headline.
  final TextStyle headlineM;

  /// Compact headline (lists, carousel).
  final TextStyle headlineS;

  /// Sidebar headline.
  final TextStyle headlineXS;

  /// Article screen headline.
  final TextStyle articleTitle;

  /// Title of a section or static page.
  final TextStyle pageTitle;

  /// Lead story summary.
  final TextStyle summaryL;

  /// Standard summary.
  final TextStyle summary;

  /// Small gray summary used in compact lists.
  final TextStyle summaryS;

  /// Gray deck under the article headline.
  final TextStyle articleSummary;

  /// Article body copy (before the reader's text-size multiplier).
  final TextStyle body;

  /// "By … · May 25, 2026 · 3 min read".
  final TextStyle byline;

  /// The author's name inside a byline.
  final TextStyle bylineStrong;

  /// Counts and secondary metadata.
  final TextStyle meta;

  /// "01", "02"… in numbered lists.
  final TextStyle numeral;

  /// Uppercase button label.
  final TextStyle button;

  /// Scrolling briefing text.
  final TextStyle ticker;

  /// "BRIEFING" badge.
  final TextStyle tickerLabel;

  /// Rows on the Sections tab.
  final TextStyle listTitle;

  @override
  NewsTextStyles copyWith() => this;

  @override
  NewsTextStyles lerp(ThemeExtension<NewsTextStyles>? other, double t) {
    if (other is! NewsTextStyles) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return NewsTextStyles(
      wordmark: l(wordmark, other.wordmark),
      tagline: l(tagline, other.tagline),
      dateline: l(dateline, other.dateline),
      sectionLabel: l(sectionLabel, other.sectionLabel),
      sectionLabelMuted: l(sectionLabelMuted, other.sectionLabelMuted),
      blockTitle: l(blockTitle, other.blockTitle),
      headlineXL: l(headlineXL, other.headlineXL),
      headlineL: l(headlineL, other.headlineL),
      headlineM: l(headlineM, other.headlineM),
      headlineS: l(headlineS, other.headlineS),
      headlineXS: l(headlineXS, other.headlineXS),
      articleTitle: l(articleTitle, other.articleTitle),
      pageTitle: l(pageTitle, other.pageTitle),
      summaryL: l(summaryL, other.summaryL),
      summary: l(summary, other.summary),
      summaryS: l(summaryS, other.summaryS),
      articleSummary: l(articleSummary, other.articleSummary),
      body: l(body, other.body),
      byline: l(byline, other.byline),
      bylineStrong: l(bylineStrong, other.bylineStrong),
      meta: l(meta, other.meta),
      numeral: l(numeral, other.numeral),
      button: l(button, other.button),
      ticker: l(ticker, other.ticker),
      tickerLabel: l(tickerLabel, other.tickerLabel),
      listTitle: l(listTitle, other.listTitle),
    );
  }
}
