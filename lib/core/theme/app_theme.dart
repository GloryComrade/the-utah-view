import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for the app.
///
/// Material 3 is the engine, but nearly every component is restyled so the
/// result reads like a newspaper app: white pages, no tinted surfaces, no
/// pill indicators, square-cornered inputs and buttons, thin rules.
abstract final class AppTheme {
  static ThemeData light({TargetPlatform? platform}) =>
      _build(AppPalette.light, Brightness.light, platform);

  static ThemeData dark({TargetPlatform? platform}) =>
      _build(AppPalette.dark, Brightness.dark, platform);

  static ThemeData _build(
    AppPalette p,
    Brightness brightness,
    TargetPlatform? platformOverride,
  ) {
    final platform = platformOverride ?? defaultTargetPlatform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final news = NewsTextStyles.from(p);

    TextStyle sans(
      double size,
      FontWeight weight,
      Color color, {
      double spacing = 0,
      double height = 1.35,
    }) => TextStyle(
      fontFamily: AppFonts.sans,
      fontFamilyFallback: AppFonts.sansFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
      height: height,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accentFill,
      onPrimary: p.onAccentFill,
      primaryContainer: p.surfaceMuted,
      onPrimaryContainer: p.ink,
      secondary: p.ink,
      onSecondary: p.background,
      secondaryContainer: p.surfaceMuted,
      onSecondaryContainer: p.ink,
      tertiary: p.accent,
      onTertiary: p.onAccentFill,
      error: p.accent,
      onError: p.onAccentFill,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.background,
      surfaceContainer: p.background,
      surfaceContainerHigh: p.surfaceMuted,
      surfaceContainerHighest: p.surfaceMuted,
      outline: p.rule,
      outlineVariant: p.ruleLight,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: p.ink,
      onInverseSurface: p.background,
      inversePrimary: p.accent,
      surfaceTint: const Color(0x00000000),
    );

    // Material's own text roles. Content uses NewsTextStyles; these cover
    // chrome such as dialogs, text fields and list tiles.
    final textTheme = TextTheme(
      displayLarge: news.articleTitle.copyWith(fontSize: 44),
      displayMedium: news.articleTitle.copyWith(fontSize: 38),
      displaySmall: news.articleTitle,
      headlineLarge: news.pageTitle,
      headlineMedium: news.headlineL,
      headlineSmall: news.headlineM,
      titleLarge: news.headlineM,
      titleMedium: sans(16, FontWeight.w600, p.ink),
      titleSmall: sans(14, FontWeight.w600, p.ink),
      bodyLarge: sans(16, FontWeight.w400, p.ink, height: 1.45),
      bodyMedium: sans(14, FontWeight.w400, p.inkSecondary, height: 1.45),
      bodySmall: sans(12, FontWeight.w400, p.inkMuted, height: 1.4),
      labelLarge: sans(14, FontWeight.w600, p.ink),
      labelMedium: sans(12, FontWeight.w600, p.ink),
      labelSmall: sans(11, FontWeight.w600, p.inkMuted, spacing: 0.4),
    );

    final overlayStyle = brightness == Brightness.light
        ? SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: const Color(0x00000000),
            systemNavigationBarColor: p.background,
            systemNavigationBarIconBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: const Color(0x00000000),
            systemNavigationBarColor: p.background,
            systemNavigationBarIconBrightness: Brightness.light,
          );

    const squareCorners = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      platform: platformOverride,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.rule,
      fontFamily: AppFonts.sans,
      fontFamilyFallback: AppFonts.sansFallback,
      textTheme: textTheme,
      extensions: [p, news],
      // Newspapers don't ripple. Keep a quiet ripple on Android for feedback,
      // none on iOS where a highlight is the platform convention.
      splashFactory: isApple ? NoSplash.splashFactory : InkRipple.splashFactory,
      splashColor: p.ink.withValues(alpha: 0.05),
      highlightColor: p.highlight,
      hoverColor: p.highlight,
      focusColor: p.accent.withValues(alpha: 0.12),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      iconTheme: IconThemeData(color: p.ink, size: 24),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: p.accent,
        brightness: brightness,
        scaffoldBackgroundColor: p.background,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        centerTitle: true,
        titleTextStyle: sans(16, FontWeight.w700, p.ink, spacing: 0.2),
        toolbarTextStyle: sans(14, FontWeight.w500, p.ink),
        iconTheme: IconThemeData(color: p.ink, size: 24),
        actionsIconTheme: IconThemeData(color: p.ink, size: 24),
        shape: Border(bottom: BorderSide(color: p.rule)),
        systemOverlayStyle: overlayStyle,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.background,
        surfaceTintColor: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        elevation: 0,
        height: 62,
        indicatorColor: const Color(0x00000000),
        indicatorShape: const RoundedRectangleBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        overlayColor: const WidgetStatePropertyAll(Color(0x00000000)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return sans(
            11,
            selected ? FontWeight.w700 : FontWeight.w500,
            selected ? p.ink : p.inkMuted,
            spacing: 0.3,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? p.ink : p.inkMuted, size: 24);
        }),
      ),
      dividerTheme: DividerThemeData(color: p.rule, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: p.background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: sans(15, FontWeight.w400, p.inkMuted),
        labelStyle: sans(14, FontWeight.w500, p.inkMuted),
        floatingLabelStyle: sans(14, FontWeight.w600, p.accent),
        errorStyle: sans(12, FontWeight.w500, p.accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.accent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.25),
        selectionHandleColor: p.accent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accentFill,
          foregroundColor: p.onAccentFill,
          disabledBackgroundColor: p.rule,
          disabledForegroundColor: p.inkMuted,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: squareCorners,
          textStyle: news.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: squareCorners,
          side: BorderSide(color: p.ink),
          textStyle: news.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          minimumSize: const Size(48, 44),
          shape: squareCorners,
          textStyle: sans(13, FontWeight.w600, p.accent),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(48, 48),
          highlightColor: p.highlight,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? BrandColors.ink
            : const Color(0xFF2A2A2A),
        contentTextStyle: sans(14, FontWeight.w500, BrandColors.white),
        actionTextColor: BrandColors.redOnDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.ink,
        textColor: p.ink,
        titleTextStyle: sans(16, FontWeight.w500, p.ink),
        subtitleTextStyle: sans(13, FontWeight.w400, p.inkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        minVerticalPadding: 12,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: const Color(0x00000000),
        modalBackgroundColor: p.background,
        showDragHandle: true,
        dragHandleColor: p.rule,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.background,
        surfaceTintColor: const Color(0x00000000),
        shape: squareCorners,
        titleTextStyle: news.headlineM,
        contentTextStyle: sans(15, FontWeight.w400, p.inkSecondary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accentFill,
        linearTrackColor: const Color(0x00000000),
        circularTrackColor: const Color(0x00000000),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accentFill,
        inactiveTrackColor: p.rule,
        thumbColor: p.accentFill,
        overlayColor: p.accentFill.withValues(alpha: 0.12),
        activeTickMarkColor: p.onAccentFill,
        inactiveTickMarkColor: p.inkMuted,
        valueIndicatorColor: p.ink,
        valueIndicatorTextStyle: sans(12, FontWeight.w600, p.background),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(squareCorners),
          side: WidgetStatePropertyAll(BorderSide(color: p.rule)),
          textStyle: WidgetStatePropertyAll(sans(13, FontWeight.w600, p.ink)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.ink : p.background,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.background : p.ink,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.background : p.ink,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onAccentFill : p.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accentFill : p.rule,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Color(0x00000000)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.background,
        selectedColor: p.ink,
        side: BorderSide(color: p.rule),
        shape: squareCorners,
        labelStyle: sans(13, FontWeight.w600, p.ink),
        secondaryLabelStyle: sans(13, FontWeight.w600, p.background),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        showCheckmark: false,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: const BorderRadius.all(Radius.circular(3)),
        ),
        textStyle: sans(12, FontWeight.w500, p.background),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(p.inkFaint.withValues(alpha: 0.6)),
        radius: const Radius.circular(2),
        thickness: const WidgetStatePropertyAll(3),
      ),
    );
  }
}
