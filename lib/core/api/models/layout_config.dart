import 'package:freezed_annotation/freezed_annotation.dart';

import '../api_config.dart';
import 'json_converters.dart';

part 'layout_config.freezed.dart';
part 'layout_config.g.dart';

/// Front-page layout from `GET /api/config/layout` (`value`).
///
/// Every story reference is an id into the published stories list. Ids can
/// point at drafts that aren't published yet; resolve them through
/// `StoryIndex`, which skips unknown ids.
@freezed
abstract class LayoutConfig with _$LayoutConfig {
  const LayoutConfig._();

  @JsonSerializable(converters: lenientJsonConverters)
  const factory LayoutConfig({
    @Default('') String ticker,
    @Default('') String heroLead,
    @Default('') String heroSecondary,
    @Default('') String heroCenter,
    @Default('') String heroImage,
    @Default('') String heroCenterCaption,
    @Default(<String>[]) List<String> heroRight,
    @Default(<String>[]) List<String> editorial,
    @Default(<String, String>{}) Map<String, String> regions,
    @Default(<String>[]) List<String> featured,
    @Default(<String>[]) List<String> sidebarUtah,
    @Default(<String>[]) List<String> sidebarData,
    // Homepage customization (editor-driven). Empty = defaults.
    @Default(<String>[]) List<String> sectionOrder,
    @Default(<String>[]) List<String> hiddenSections,
    @Default(<String, String>{}) Map<String, String> sectionLabels,
  }) = _LayoutConfig;

  factory LayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$LayoutConfigFromJson(json);

  /// The order the website shows region columns in.
  static const regionOrder = [
    'The Americas',
    'Europe',
    'Asia-Pacific',
    'Middle East',
    'Africa',
  ];

  /// Absolute URL for [heroImage], or null when there isn't one.
  String? get heroImageUrl => ApiConfig.resolveUrl(heroImage);

  /// Region picks in website order, followed by any regions the CMS adds.
  List<MapEntry<String, String>> get orderedRegions {
    final known = [
      for (final name in regionOrder)
        if (regions[name] case final id?) MapEntry(name, id),
    ];
    final extra = regions.entries.where((e) => !regionOrder.contains(e.key));
    return [...known, ...extra];
  }

  /// Every story id the front page references, in reading order, once each.
  List<String> get referencedIds {
    final ids = <String>{
      heroLead,
      heroSecondary,
      heroCenter,
      ...heroRight,
      ...editorial,
      for (final entry in orderedRegions) entry.value,
      ...featured,
      ...sidebarUtah,
      ...sidebarData,
    }..remove('');
    return ids.toList();
  }
}
