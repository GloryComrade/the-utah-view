import 'package:material_ui/material_ui.dart';

/// Raw brand values, taken from the CSS variables on theutahview.com.
///
/// Widgets should not use these directly; read the semantic [AppPalette]
/// from the theme instead so dark mode keeps working.
abstract final class BrandColors {
  /// Flag red — the signature accent fill (2026 red/white/grey scheme).
  static const red = Color(0xFFCE1126);

  /// Deep red — accent text, links and pressed fills (AA on white and grey).
  static const redDark = Color(0xFFA11121);

  /// Near-black ink — a neutral, not a mid-tone.
  static const ink = Color(0xFF15171B);
  static const gray700 = Color(0xFF2C3036); // secondary text
  static const gray500 = Color(0xFF4F545C); // metadata
  static const gray400 = Color(0xFF7A7F88); // icons / decoration (≥3:1)
  static const gray300 = Color(0xFFA2A9AF); // decorative mid-grey ONLY, never text
  static const gray200 = Color(0xFFE3E3E3); // hairline rules
  static const gray100 = Color(0xFFEEEEEF); // light hairline
  static const gray50 = Color(0xFFF2F2F3); // tinted panels
  static const white = Color(0xFFFFFFFF);

  /// Page base — pure white.
  static const paper = Color(0xFFFFFFFF);

  /// Red lifted for dark backgrounds (AA on the near-black base).
  static const redOnDark = Color(0xFFF26A72);
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
    background: BrandColors.white, // pure white
    surfaceMuted: BrandColors.gray50, // #F2F2F3
    ink: BrandColors.ink, // #15171B
    inkSecondary: BrandColors.gray700, // #2C3036
    inkMuted: BrandColors.gray500, // #4F545C
    inkFaint: BrandColors.gray400, // #7A7F88 (decoration, ≥3:1)
    rule: BrandColors.gray200, // #E3E3E3 hairline
    ruleLight: BrandColors.gray100,
    ruleStrong: BrandColors.ink,
    accent: BrandColors.redDark, // #A11121 text/links (8:1 on white)
    accentPressed: Color(0xFF7E0E19),
    accentFill: BrandColors.red, // #CE1126 fills
    onAccentFill: BrandColors.white,
    placeholderStart: BrandColors.gray100,
    placeholderEnd: BrandColors.gray200,
    highlight: BrandColors.gray50,
  );

  static const dark = AppPalette(
    background: Color(0xFF111113), // near-black
    surfaceMuted: Color(0xFF1C1C20),
    ink: Color(0xFFF2F3F5),
    inkSecondary: Color(0xFFC9CCD2),
    inkMuted: Color(0xFF9CA1A9),
    inkFaint: Color(0xFF71767E),
    rule: Color(0xFF2E2F33),
    ruleLight: Color(0xFF232428),
    ruleStrong: Color(0xFFC9CCD2),
    accent: BrandColors.redOnDark, // #F26A72 (AA on near-black)
    accentPressed: Color(0xFFF7858B),
    accentFill: BrandColors.red, // #CE1126 fills, white text
    onAccentFill: BrandColors.white,
    placeholderStart: Color(0xFF1E1E22),
    placeholderEnd: Color(0xFF27272C),
    highlight: Color(0xFF1C1C20),
  );

  /// Maximum-contrast light palette: pure black text and rules on white.
  static const highContrastLight = AppPalette(
    background: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF2F2F2),
    ink: Color(0xFF000000),
    inkSecondary: Color(0xFF000000),
    inkMuted: Color(0xFF1C1C1C),
    inkFaint: Color(0xFF404040),
    rule: Color(0xFF000000),
    ruleLight: Color(0xFF000000),
    ruleStrong: Color(0xFF000000),
    accent: Color(0xFF8A0E19), // deep red, ~11:1 on white
    accentPressed: Color(0xFF5E0A12),
    accentFill: Color(0xFFA11121),
    onAccentFill: Color(0xFFFFFFFF),
    placeholderStart: Color(0xFFE0E0E0),
    placeholderEnd: Color(0xFFCFCFCF),
    highlight: Color(0xFFE8E8E8),
  );

  /// Maximum-contrast dark palette: pure white text and rules on black.
  static const highContrastDark = AppPalette(
    background: Color(0xFF000000),
    surfaceMuted: Color(0xFF0A0A0A),
    ink: Color(0xFFFFFFFF),
    inkSecondary: Color(0xFFFFFFFF),
    inkMuted: Color(0xFFE0E0E0),
    inkFaint: Color(0xFFBDBDBD),
    rule: Color(0xFFFFFFFF),
    ruleLight: Color(0xFFFFFFFF),
    ruleStrong: Color(0xFFFFFFFF),
    accent: Color(0xFFFF9099), // bright red, high contrast on black
    accentPressed: Color(0xFFFFB8BD),
    accentFill: Color(0xFFCE1126),
    onAccentFill: Color(0xFFFFFFFF),
    placeholderStart: Color(0xFF1A1A1A),
    placeholderEnd: Color(0xFF2A2A2A),
    highlight: Color(0xFF1A1A1A),
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
