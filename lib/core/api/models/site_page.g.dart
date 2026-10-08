// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SitePageSummary _$SitePageSummaryFromJson(Map<String, dynamic> json) =>
    _SitePageSummary(
      slug: json['slug'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['slug']),
      title: json['title'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['title']),
      subtitle: json['subtitle'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['subtitle']),
    );

Map<String, dynamic> _$SitePageSummaryToJson(_SitePageSummary instance) =>
    <String, dynamic>{
      'slug': ?const LenientStringConverter().toJson(instance.slug),
      'title': ?const LenientStringConverter().toJson(instance.title),
      'subtitle': ?const LenientStringConverter().toJson(instance.subtitle),
    };

_SitePage _$SitePageFromJson(Map<String, dynamic> json) => _SitePage(
  slug: json['slug'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['slug']),
  title: json['title'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['title']),
  subtitle: json['subtitle'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['subtitle']),
  body: json['body'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['body']),
);

Map<String, dynamic> _$SitePageToJson(_SitePage instance) => <String, dynamic>{
  'slug': ?const LenientStringConverter().toJson(instance.slug),
  'title': ?const LenientStringConverter().toJson(instance.title),
  'subtitle': ?const LenientStringConverter().toJson(instance.subtitle),
  'body': ?const LenientStringConverter().toJson(instance.body),
};
