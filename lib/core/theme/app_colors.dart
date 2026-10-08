import 'package:material_ui/material_ui.dart';

/// Raw brand values, taken from the CSS variables on theutahview.com.
///
/// Widgets should not use these directly; read the semantic [AppPalette]
/// from the theme instead so dark mode keeps working.
abstract final class BrandColors {
  static const red = Color(0xFFB53816);
  static const redDark = Color(0xFF902C11);
  static const ink = Color(0xFF121212);
  static const gray700 = Color(0xFF333333);
  static const gray500 = Color(0xFF666666);
  static const gray400 = Color(0xFF888888);
  static const gray200 = Color(0xFFD4D4D4);
  static const gray100 = Color(0xFFEEEEEE);
  static const gray50 = Color(0xFFF7F7F7);
  static const white = Color(0xFFFFFFFF);

  /// Brand red lifted for dark backgrounds (6.0:1 on #121212). The true
  /// brand red is only 3.5:1 there, which fails WCAG AA for text.
  static const redOnDark = Color(0xFFEB6A5C);
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
    background: BrandColors.white,
    surfaceMuted: BrandColors.gray50,
    ink: BrandColors.ink,
    inkSecondary: BrandColors.gray700,
    inkMuted: BrandColors.gray500,
    inkFaint: BrandColors.gray400,
    rule: BrandColors.gray200,
    ruleLight: BrandColors.gray100,
    ruleStrong: BrandColors.ink,
    accent: BrandColors.red,
    accentPressed: BrandColors.redDark,
    accentFill: BrandColors.red,
    onAccentFill: BrandColors.white,
    placeholderStart: BrandColors.gray100,
    placeholderEnd: BrandColors.gray200,
    highlight: BrandColors.gray50,
  );

  static const dark = AppPalette(
    background: Color(0xFF121212),
    surfaceMuted: Color(0xFF1C1C1C),
    ink: Color(0xFFEDEDED),
    inkSecondary: Color(0xFFD4D4D4),
    inkMuted: Color(0xFFA6A6A6),
    inkFaint: Color(0xFF8A8A8A),
    rule: Color(0xFF333333),
    ruleLight: Color(0xFF262626),
    ruleStrong: Color(0xFFD4D4D4),
    accent: BrandColors.redOnDark,
    accentPressed: Color(0xFFF07B6E),
    accentFill: BrandColors.red,
    onAccentFill: BrandColors.white,
    placeholderStart: Color(0xFF242424),
    placeholderEnd: Color(0xFF2E2E2E),
    highlight: Color(0xFF1C1C1C),
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
