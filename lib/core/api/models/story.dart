import 'package:freezed_annotation/freezed_annotation.dart';

import '../../utils/formatters.dart';
import 'json_converters.dart';

part 'story.freezed.dart';
part 'story.g.dart';

/// A story as it appears in `GET /api/stories` (no body).
@freezed
abstract class Story with _$Story {
  const Story._();

  @JsonSerializable(converters: lenientJsonConverters)
  const factory Story({
    @Default('') String id,
    @Default('') String title,
    @Default('') String author,
    @Default('') String region,
    @Default('') String summary,
    @Default('') String readTime,
    @Default('') String date,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  /// `3 min read`, or null when the CMS field is empty or junk.
  String? get readTimeLabel => formatReadTime(readTime);

  /// `May 25, 2026`.
  String get displayDate => formatStoryDate(date);
}

/// A full story from `GET /api/stories/{id}`, including the HTML body.
@freezed
abstract class StoryDetail with _$StoryDetail {
  const StoryDetail._();

  @JsonSerializable(converters: lenientJsonConverters)
  const factory StoryDetail({
    @Default('') String id,
    @Default('') String title,
    @Default('') String author,
    @Default('') String region,
    @Default('') String status,
    @Default('') String summary,
    @Default('') String body,
    @Default('') String readTime,
    @Default('') String date,
    @Default('') String createdAt,
    @Default('') String updatedAt,
  }) = _StoryDetail;

  factory StoryDetail.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailFromJson(json);

  /// The list-view projection of this story.
  Story toStory() => Story(
    id: id,
    title: title,
    author: author,
    region: region,
    summary: summary,
    readTime: readTime,
    date: date,
  );
}
