import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../api/providers.dart';
import '../storage/key_value_store.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.readingScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
  });

  /// Steps offered by A−/A+ and the text-size setting. Applied to article
  /// and page body copy on top of the system's dynamic type.
  static const readingScales = <double>[0.88, 1.0, 1.12, 1.25, 1.4];

  final ThemeMode themeMode;
  final double readingScale;

  /// Maximum-contrast palette (pure black/white, heavier rules).
  final bool highContrast;

  /// Suppress non-essential animation (also honors the OS reduce-motion flag).
  final bool reduceMotion;

  int get readingScaleIndex {
    final i = readingScales.indexOf(readingScale);
    return i == -1 ? 1 : i;
  }

  bool get canDecreaseText => readingScaleIndex > 0;
  bool get canIncreaseText => readingScaleIndex < readingScales.length - 1;

  String get readingScaleLabel => switch (readingScaleIndex) {
    0 => 'Small',
    1 => 'Default',
    2 => 'Large',
    3 => 'Larger',
    _ => 'Largest',
  };

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? readingScale,
    bool? highContrast,
    bool? reduceMotion,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    readingScale: readingScale ?? this.readingScale,
    highContrast: highContrast ?? this.highContrast,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _scaleKey = 'reading_scale';
  static const _contrastKey = 'high_contrast';
  static const _motionKey = 'reduce_motion';

  KeyValueStore get _store => ref.read(appStoresProvider).settings;

  @override
  AppSettings build() {
    final store = _store;
    final mode = ThemeMode.values.asNameMap()[store.read(_themeKey)];
    final scale = double.tryParse(store.read(_scaleKey) ?? '');
    return AppSettings(
      themeMode: mode ?? ThemeMode.system,
      readingScale: AppSettings.readingScales.contains(scale) ? scale! : 1.0,
      highContrast: store.read(_contrastKey) == 'true',
      reduceMotion: store.read(_motionKey) == 'true',
    );
  }

  Future<void> setHighContrast(bool on) async {
    state = state.copyWith(highContrast: on);
    await _store.write(_contrastKey, on.toString());
  }

  Future<void> setReduceMotion(bool on) async {
    state = state.copyWith(reduceMotion: on);
    await _store.write(_motionKey, on.toString());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _store.write(_themeKey, mode.name);
  }

  Future<void> setReadingScaleIndex(int index) async {
    final i = index.clamp(0, AppSettings.readingScales.length - 1);
    final scale = AppSettings.readingScales[i];
    state = state.copyWith(readingScale: scale);
    await _store.write(_scaleKey, scale.toString());
  }

  Future<void> increaseText() =>
      setReadingScaleIndex(state.readingScaleIndex + 1);

  Future<void> decreaseText() =>
      setReadingScaleIndex(state.readingScaleIndex - 1);
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
