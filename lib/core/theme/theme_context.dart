import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Layout constants shared by every screen.
abstract final class Insets {
  /// Horizontal page padding on phones.
  static const gutter = 20.0;

  /// Horizontal page padding on tablets.
  static const gutterTablet = 32.0;

  /// Vertical breathing room above and below a thin rule.
  static const storyGap = 18.0;

  /// Space before a thick rule that opens a new block.
  static const blockGap = 36.0;

  /// The front page never grows wider than this.
  static const maxContentWidth = 1120.0;

  /// Comfortable measure for long-form reading.
  static const maxReadingWidth = 680.0;

  /// Width at which the Home tab switches to two columns.
  static const tabletBreakpoint = 700.0;
}

extension ThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  NewsTextStyles get news =>
      Theme.of(this).extension<NewsTextStyles>() ??
      NewsTextStyles.from(AppPalette.light);

  bool get isTablet =>
      MediaQuery.sizeOf(this).shortestSide >= 600 ||
      MediaQuery.sizeOf(this).width >= Insets.tabletBreakpoint;

  double get gutter => isTablet ? Insets.gutterTablet : Insets.gutter;
}
