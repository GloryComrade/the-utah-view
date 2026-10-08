// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LayoutConfig _$LayoutConfigFromJson(Map<String, dynamic> json) =>
    _LayoutConfig(
      ticker: json['ticker'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['ticker']),
      heroLead: json['hero_lead'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['hero_lead']),
      heroSecondary: json['hero_secondary'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['hero_secondary']),
      heroCenter: json['hero_center'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['hero_center']),
      heroImage: json['hero_image'] == null
          ? ''
          : const LenientStringConverter().fromJson(json['hero_image']),
      heroCenterCaption: json['hero_center_caption'] == null
          ? ''
          : const LenientStringConverter().fromJson(
              json['hero_center_caption'],
            ),
      heroRight: json['hero_right'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['hero_right']),
      editorial: json['editorial'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['editorial']),
      regions: json['regions'] == null
          ? const <String, String>{}
          : const StringMapConverter().fromJson(json['regions']),
      featured: json['featured'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['featured']),
      sidebarUtah: json['sidebar_utah'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['sidebar_utah']),
      sidebarData: json['sidebar_data'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['sidebar_data']),
      sectionOrder: json['section_order'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['section_order']),
      hiddenSections: json['hidden_sections'] == null
          ? const <String>[]
          : const StringListConverter().fromJson(json['hidden_sections']),
      sectionLabels: json['section_labels'] == null
          ? const <String, String>{}
          : const StringMapConverter().fromJson(json['section_labels']),
    );

Map<String, dynamic> _$LayoutConfigToJson(
  _LayoutConfig instance,
) => <String, dynamic>{
  'ticker': ?const LenientStringConverter().toJson(instance.ticker),
  'hero_lead': ?const LenientStringConverter().toJson(instance.heroLead),
  'hero_secondary': ?const LenientStringConverter().toJson(
    instance.heroSecondary,
  ),
  'hero_center': ?const LenientStringConverter().toJson(instance.heroCenter),
  'hero_image': ?const LenientStringConverter().toJson(instance.heroImage),
  'hero_center_caption': ?const LenientStringConverter().toJson(
    instance.heroCenterCaption,
  ),
  'hero_right': ?const StringListConverter().toJson(instance.heroRight),
  'editorial': ?const StringListConverter().toJson(instance.editorial),
  'regions': ?const StringMapConverter().toJson(instance.regions),
  'featured': ?const StringListConverter().toJson(instance.featured),
  'sidebar_utah': ?const StringListConverter().toJson(instance.sidebarUtah),
  'sidebar_data': ?const StringListConverter().toJson(instance.sidebarData),
  'section_order': ?const StringListConverter().toJson(instance.sectionOrder),
  'hidden_sections': ?const StringListConverter().toJson(
    instance.hiddenSections,
  ),
  'section_labels': ?const StringMapConverter().toJson(instance.sectionLabels),
};
