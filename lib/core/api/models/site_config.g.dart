// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NavCategory _$NavCategoryFromJson(Map<String, dynamic> json) => _NavCategory(
  text: json['text'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['text']),
  section: json['section'] == null
      ? false
      : const LenientBoolConverter().fromJson(json['section']),
);

Map<String, dynamic> _$NavCategoryToJson(_NavCategory instance) =>
    <String, dynamic>{
      'text': ?const LenientStringConverter().toJson(instance.text),
      'section': ?const LenientBoolConverter().toJson(instance.section),
    };

_FooterLink _$FooterLinkFromJson(Map<String, dynamic> json) => _FooterLink(
  text: json['text'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['text']),
  url: json['url'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['url']),
);

Map<String, dynamic> _$FooterLinkToJson(_FooterLink instance) =>
    <String, dynamic>{
      'text': ?const LenientStringConverter().toJson(instance.text),
      'url': ?const LenientStringConverter().toJson(instance.url),
    };

_FooterColumn _$FooterColumnFromJson(Map<String, dynamic> json) =>
    _FooterColumn(
      title: json['title'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['title']),
      links: json['links'] == null
          ? const <FooterLink>[]
          : const FooterLinkListConverter().fromJson(json['links']),
    );

Map<String, dynamic> _$FooterColumnToJson(_FooterColumn instance) =>
    <String, dynamic>{
      'title': ?const LenientStringConverter().toJson(instance.title),
      'links': ?const FooterLinkListConverter().toJson(instance.links),
    };

_SiteConfig _$SiteConfigFromJson(Map<String, dynamic> json) => _SiteConfig(
  navCategories: const NavCategoryListConverter().fromJson(
    json['nav_categories'],
  ),
  subOverline: json['sub_overline'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['sub_overline']),
  subHeading: json['sub_heading'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['sub_heading']),
  subDesc: json['sub_desc'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['sub_desc']),
  copyright: json['copyright'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['copyright']),
  aboutText: json['about_text'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['about_text']),
  aboutUrl: json['about_url'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['about_url']),
  footerCols: json['footer_cols'] == null
      ? const <FooterColumn>[]
      : const FooterColumnListConverter().fromJson(json['footer_cols']),
);

Map<String, dynamic> _$SiteConfigToJson(
  _SiteConfig instance,
) => <String, dynamic>{
  'nav_categories': ?const NavCategoryListConverter().toJson(
    instance.navCategories,
  ),
  'sub_overline': ?const LenientStringConverter().toJson(instance.subOverline),
  'sub_heading': ?const LenientStringConverter().toJson(instance.subHeading),
  'sub_desc': ?const LenientStringConverter().toJson(instance.subDesc),
  'copyright': ?const LenientStringConverter().toJson(instance.copyright),
  'about_text': ?const LenientStringConverter().toJson(instance.aboutText),
  'about_url': ?const LenientStringConverter().toJson(instance.aboutUrl),
  'footer_cols': ?const FooterColumnListConverter().toJson(instance.footerCols),
};
