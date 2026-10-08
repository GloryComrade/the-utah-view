// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Story _$StoryFromJson(Map<String, dynamic> json) => _Story(
  id: json['id'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['id']),
  title: json['title'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['title']),
  author: json['author'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['author']),
  region: json['region'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['region']),
  summary: json['summary'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['summary']),
  readTime: json['read_time'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['read_time']),
  date: json['date'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['date']),
);

Map<String, dynamic> _$StoryToJson(_Story instance) => <String, dynamic>{
  'id': ?const LenientStringConverter().toJson(instance.id),
  'title': ?const LenientStringConverter().toJson(instance.title),
  'author': ?const LenientStringConverter().toJson(instance.author),
  'region': ?const LenientStringConverter().toJson(instance.region),
  'summary': ?const LenientStringConverter().toJson(instance.summary),
  'read_time': ?const LenientStringConverter().toJson(instance.readTime),
  'date': ?const LenientStringConverter().toJson(instance.date),
};

_StoryDetail _$StoryDetailFromJson(Map<String, dynamic> json) => _StoryDetail(
  id: json['id'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['id']),
  title: json['title'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['title']),
  author: json['author'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['author']),
  region: json['region'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['region']),
  status: json['status'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['status']),
  summary: json['summary'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['summary']),
  body: json['body'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['body']),
  readTime: json['read_time'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['read_time']),
  date: json['date'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['date']),
  createdAt: json['created_at'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['created_at']),
  updatedAt: json['updated_at'] == null
      ? ''
      : const LenientStringConverter().fromJson(json['updated_at']),
);

Map<String, dynamic> _$StoryDetailToJson(_StoryDetail instance) =>
    <String, dynamic>{
      'id': ?const LenientStringConverter().toJson(instance.id),
      'title': ?const LenientStringConverter().toJson(instance.title),
      'author': ?const LenientStringConverter().toJson(instance.author),
      'region': ?const LenientStringConverter().toJson(instance.region),
      'status': ?const LenientStringConverter().toJson(instance.status),
      'summary': ?const LenientStringConverter().toJson(instance.summary),
      'body': ?const LenientStringConverter().toJson(instance.body),
      'read_time': ?const LenientStringConverter().toJson(instance.readTime),
      'date': ?const LenientStringConverter().toJson(instance.date),
      'created_at': ?const LenientStringConverter().toJson(instance.createdAt),
      'updated_at': ?const LenientStringConverter().toJson(instance.updatedAt),
    };
