import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'site_page.freezed.dart';
part 'site_page.g.dart';

// Named SitePage rather than Page to avoid clashing with Flutter's
// navigation `Page` class.

/// An entry in `GET /api/pages`.
@freezed
abstract class SitePageSummary with _$SitePageSummary {
  @JsonSerializable(converters: lenientJsonConverters)
  const factory SitePageSummary({
    @Default('') String slug,
    @Default('') String title,
    @Default('') String subtitle,
  }) = _SitePageSummary;

  factory SitePageSummary.fromJson(Map<String, dynamic> json) =>
      _$SitePageSummaryFromJson(json);
}

/// A static page from `GET /api/pages/{slug}`. [body] is HTML.
@freezed
abstract class SitePage with _$SitePage {
  @JsonSerializable(converters: lenientJsonConverters)
  const factory SitePage({
    @Default('') String slug,
    @Default('') String title,
    @Default('') String subtitle,
    @Default('') String body,
  }) = _SitePage;

  factory SitePage.fromJson(Map<String, dynamic> json) =>
      _$SitePageFromJson(json);
}
