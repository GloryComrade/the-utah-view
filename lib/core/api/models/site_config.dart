import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'site_config.freezed.dart';
part 'site_config.g.dart';

/// A navigation category. Plain categories filter by exact region; a
/// `section` also includes "Global" and "The Utah Lens" stories.
@freezed
abstract class NavCategory with _$NavCategory {
  @JsonSerializable(converters: lenientJsonConverters)
  const factory NavCategory({
    @Default('') String text,
    @Default(false) bool section,
  }) = _NavCategory;

  factory NavCategory.fromJson(Map<String, dynamic> json) =>
      _$NavCategoryFromJson(json);

  /// Used when the site config has no `nav_categories` (true in production
  /// today). Mirrors the website's hard-coded navigation.
  static const fallback = <NavCategory>[
    NavCategory(text: 'The Americas'),
    NavCategory(text: 'Europe'),
    NavCategory(text: 'Asia-Pacific'),
    NavCategory(text: 'Middle East'),
    NavCategory(text: 'Africa'),
    NavCategory(text: 'Analysis', section: true),
    NavCategory(text: 'Opinion', section: true),
    NavCategory(text: 'Data', section: true),
  ];
}

@freezed
abstract class FooterLink with _$FooterLink {
  @JsonSerializable(converters: lenientJsonConverters)
  const factory FooterLink({
    @Default('') String text,
    @Default('') String url,
  }) = _FooterLink;

  factory FooterLink.fromJson(Map<String, dynamic> json) =>
      _$FooterLinkFromJson(json);
}

@freezed
abstract class FooterColumn with _$FooterColumn {
  @JsonSerializable(converters: lenientJsonConverters)
  const factory FooterColumn({
    @Default('') String title,
    @FooterLinkListConverter() @Default(<FooterLink>[]) List<FooterLink> links,
  }) = _FooterColumn;

  factory FooterColumn.fromJson(Map<String, dynamic> json) =>
      _$FooterColumnFromJson(json);
}

/// Site-wide copy from `GET /api/config/site` (`value`).
@freezed
abstract class SiteConfig with _$SiteConfig {
  const SiteConfig._();

  @JsonSerializable(converters: lenientJsonConverters)
  const factory SiteConfig({
    /// Null when the CMS hasn't configured navigation.
    @NavCategoryListConverter() List<NavCategory>? navCategories,
    @Default('') String subOverline,
    @Default('') String subHeading,
    @Default('') String subDesc,
    @Default('') String copyright,
    @Default('') String aboutText,
    @Default('') String aboutUrl,
    @FooterColumnListConverter()
    @Default(<FooterColumn>[])
    List<FooterColumn> footerCols,
  }) = _SiteConfig;

  factory SiteConfig.fromJson(Map<String, dynamic> json) =>
      _$SiteConfigFromJson(json);

  /// The configured categories, or [NavCategory.fallback] when none are set.
  List<NavCategory> get effectiveNavCategories {
    final configured = [
      for (final c in navCategories ?? const <NavCategory>[])
        if (c.text.isNotEmpty) c,
    ];
    return configured.isEmpty ? NavCategory.fallback : configured;
  }

  // Subscribe-card copy, with the same defaults the website uses.
  String get subscribeOverline =>
      subOverline.isEmpty ? 'Stay briefed' : subOverline;
  String get subscribeHeading => subHeading.isEmpty
      ? 'Independent analysis, delivered monthly'
      : subHeading;
  String get subscribeDescription => subDesc.isEmpty
      ? 'The Utah View covers every region, every month — with the depth of '
            'a journal and the clarity of a briefing.'
      : subDesc;
  String get copyrightLine =>
      copyright.isEmpty ? '© ${DateTime.now().year} The Utah View.' : copyright;
}

/// `nav_categories` entries may be objects or, in older configs, bare strings.
class NavCategoryListConverter
    implements JsonConverter<List<NavCategory>?, Object?> {
  const NavCategoryListConverter();

  @override
  List<NavCategory>? fromJson(Object? json) {
    if (json is! List) return null;
    return [
      for (final item in json)
        if (item is String && item.trim().isNotEmpty)
          NavCategory(text: item.trim())
        else if (asJsonMap(item) case final map?)
          NavCategory.fromJson(map),
    ];
  }

  @override
  Object? toJson(List<NavCategory>? object) =>
      object?.map((c) => c.toJson()).toList();
}

class FooterColumnListConverter
    implements JsonConverter<List<FooterColumn>, Object?> {
  const FooterColumnListConverter();

  @override
  List<FooterColumn> fromJson(Object? json) =>
      parseObjectList(json, FooterColumn.fromJson);

  @override
  Object? toJson(List<FooterColumn> object) =>
      object.map((c) => c.toJson()).toList();
}

class FooterLinkListConverter
    implements JsonConverter<List<FooterLink>, Object?> {
  const FooterLinkListConverter();

  @override
  List<FooterLink> fromJson(Object? json) =>
      parseObjectList(json, FooterLink.fromJson);

  @override
  Object? toJson(List<FooterLink> object) =>
      object.map((l) => l.toJson()).toList();
}
