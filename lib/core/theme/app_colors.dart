import 'package:material_ui/material_ui.dart';

/// Raw brand values, taken from the CSS variables on theutahview.com.
///
/// Widgets should not use these directly; read the semantic [AppPalette]
/// from the theme instead so dark mode keeps working.
abstract final class BrandColors {
  /// Red-rock terracotta — the single signature accent (2026 redesign).
  static const red = Color(0xFFB5401F);
  static const redDark = Color(0xFF8F3015);
  static const ink = Color(0xFF1A1A18);
  static const gray700 = Color(0xFF403D36);
  static const gray500 = Color(0xFF6B655C);
  static const gray400 = Color(0xFF847D72);
  static const gray200 = Color(0xFFDED8CD);
  static const gray100 = Color(0xFFECE8DF);
  static const gray50 = Color(0xFFF2EFE7);
  static const white = Color(0xFFFFFFFF);

  /// Newsprint-warm page base.
  static const paper = Color(0xFFFAF8F3);

  /// Terracotta lifted for dark backgrounds (AA on the warm near-black base).
  static const redOnDark = Color(0xFFE0724C);
}

/// Semantic color tokens for one brightness.
///
/// Every `ink*` and `accent` token is at least 4.5:1 against [background]
/// and [surfaceMuted]; `test/core/contrast_test.dart` enforces this.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSecondary,
    required this.inkMuted,
    required this.inkFaint,
    required this.rule,
    required this.ruleLight,
    required this.ruleStrong,
    required this.accent,
    required this.accentPressed,
    required this.accentFill,
    required this.onAccentFill,
    required this.placeholderStart,
    required this.placeholderEnd,
    required this.highlight,
  });

  /// Page background.
  final Color background;

  /// Tinted panels such as the subscribe card.
  final Color surfaceMuted;

  /// Headlines and primary text.
  final Color ink;

  /// Summaries and article body copy.
  final Color inkSecondary;

  /// Bylines, datelines and other metadata.
  final Color inkMuted;

  /// Icons and decoration only. Not contrast-safe for body text.
  final Color inkFaint;

  /// Thin 1px rules between stories.
  final Color rule;

  /// Hairlines between compact list items.
  final Color ruleLight;

  /// Thick rules that open a new section of the front page.
  final Color ruleStrong;

  /// Red text: section labels, links, overlines.
  final Color accent;

  /// Pressed/hovered state for red text and headlines.
  final Color accentPressed;

  /// Red fills: the briefing strip, primary buttons, progress bar.
  final Color accentFill;

  /// Text and icons placed on [accentFill].
  final Color onAccentFill;

  /// Gradient used for image placeholders (matches the site's hero boxes).
  final Color placeholderStart;
  final Color placeholderEnd;

  /// Background flash when a story is pressed.
  final Color highlight;

  static const light = AppPalette(
    background: BrandColors.paper, // newsprint-warm #FAF8F3
    surfaceMuted: BrandColors.gray50, // #F2EFE7
    ink: BrandColors.ink, // #1A1A18
    inkSecondary: BrandColors.gray700, // #403D36
    inkMuted: BrandColors.gray500, // #6B655C
    inkFaint: BrandColors.gray400,
    rule: BrandColors.gray200, // #DED8CD warm hairline
    ruleLight: BrandColors.gray100,
    ruleStrong: BrandColors.ink,
    accent: BrandColors.red, // terracotta #B5401F
    accentPressed: BrandColors.redDark,
    accentFill: BrandColors.red,
    onAccentFill: BrandColors.white,
    placeholderStart: BrandColors.gray100,
    placeholderEnd: BrandColors.gray200,
    highlight: BrandColors.gray50,
  );

  static const dark = AppPalette(
    background: Color(0xFF161411), // warm near-black
    surfaceMuted: Color(0xFF201D18),
    ink: Color(0xFFF2EDE4),
    inkSecondary: Color(0xFFD4CEC2),
    inkMuted: Color(0xFFA49D90),
    inkFaint: Color(0xFF7E776B),
    rule: Color(0xFF343029),
    ruleLight: Color(0xFF26231D),
    ruleStrong: Color(0xFFD4CEC2),
    accent: BrandColors.redOnDark, // #E0724C
    accentPressed: Color(0xFFEC8260),
    accentFill: BrandColors.red,
    onAccentFill: BrandColors.white,
    placeholderStart: Color(0xFF221F19),
    placeholderEnd: Color(0xFF2B281F),
    highlight: Color(0xFF201D18),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surfaceMuted,
    Color? ink,
    Color? inkSecondary,
    Color? inkMuted,
    Color? inkFaint,
    Color? rule,
    Color? ruleLight,
    Color? ruleStrong,
    Color? accent,
    Color? accentPressed,
    Color? accentFill,
    Color? onAccentFill,
    Color? placeholderStart,
    Color? placeholderEnd,
    Color? highlight,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      rule: rule ?? this.rule,
      ruleLight: ruleLight ?? this.ruleLight,
      ruleStrong: ruleStrong ?? this.ruleStrong,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      accentFill: accentFill ?? this.accentFill,
      onAccentFill: onAccentFill ?? this.onAccentFill,
      placeholderStart: placeholderStart ?? this.placeholderStart,
      placeholderEnd: placeholderEnd ?? this.placeholderEnd,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      ink: c(ink, other.ink),
      inkSecondary: c(inkSecondary, other.inkSecondary),
      inkMuted: c(inkMuted, other.inkMuted),
      inkFaint: c(inkFaint, other.inkFaint),
      rule: c(rule, other.rule),
      ruleLight: c(ruleLight, other.ruleLight),
      ruleStrong: c(ruleStrong, other.ruleStrong),
      accent: c(accent, other.accent),
      accentPressed: c(accentPressed, other.accentPressed),
      accentFill: c(accentFill, other.accentFill),
      onAccentFill: c(onAccentFill, other.onAccentFill),
      placeholderStart: c(placeholderStart, other.placeholderStart),
      placeholderEnd: c(placeholderEnd, other.placeholderEnd),
      highlight: c(highlight, other.highlight),
    );
  }
}

/// WCAG 2.x contrast ratio between two opaque colors (1.0 to 21.0).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
