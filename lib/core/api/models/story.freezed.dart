// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Story {

 String get id; String get title; String get author; String get region; String get summary; String get readTime; String get date;
/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryCopyWith<Story> get copyWith => _$StoryCopyWithImpl<Story>(this as Story, _$identity);

  /// Serializes this Story to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Story;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Story&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.readTime, _this.readTime) || other.readTime == _this.readTime)&&(identical(other.date, _this.date) || other.date == _this.date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Story;
  return Object.hash(runtimeType,_this.id,_this.title,_this.author,_this.region,_this.summary,_this.readTime,_this.date);
}

@override
String toString() {
  final _this = this as Story;
  return 'Story(id: ${_this.id}, title: ${_this.title}, author: ${_this.author}, region: ${_this.region}, summary: ${_this.summary}, readTime: ${_this.readTime}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $StoryCopyWith<$Res>  {
  factory $StoryCopyWith(Story value, $Res Function(Story) _then) = _$StoryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String author, String region, String summary, String readTime, String date
});




}
/// @nodoc
class _$StoryCopyWithImpl<$Res>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._self, this._then);

  final Story _self;
  final $Res Function(Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? region = null,Object? summary = null,Object? readTime = null,Object? date = null,}) {
  return _then(Story(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,readTime: null == readTime ? _self.readTime : readTime // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Story].
extension StoryPatterns on Story {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Story value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Story value)  $default,){
final _that = this;
switch (_that) {
case _Story():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Story value)?  $default,){
final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String author,  String region,  String summary,  String readTime,  String date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.region,_that.summary,_that.readTime,_that.date);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String author,  String region,  String summary,  String readTime,  String date)  $default,) {final _that = this;
switch (_that) {
case _Story():
return $default(_that.id,_that.title,_that.author,_that.region,_that.summary,_that.readTime,_that.date);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String author,  String region,  String summary,  String readTime,  String date)?  $default,) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.region,_that.summary,_that.readTime,_that.date);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _Story extends Story {
  const _Story({this.id = '', this.title = '', this.author = '', this.region = '', this.summary = '', this.readTime = '', this.date = ''}): super._();
  factory _Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String region;
@override@JsonKey() final  String summary;
@override@JsonKey() final  String readTime;
@override@JsonKey() final  String date;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryCopyWith<_Story> get copyWith => __$StoryCopyWithImpl<_Story>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Story&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.region, region) || other.region == region)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.readTime, readTime) || other.readTime == readTime)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,author,region,summary,readTime,date);
}

@override
String toString() {
    return 'Story(id: $id, title: $title, author: $author, region: $region, summary: $summary, readTime: $readTime, date: $date)';
}


}

/// @nodoc
abstract mixin class _$StoryCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$StoryCopyWith(_Story value, $Res Function(_Story) _then) = __$StoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String author, String region, String summary, String readTime, String date
});




}
/// @nodoc
class __$StoryCopyWithImpl<$Res>
    implements _$StoryCopyWith<$Res> {
  __$StoryCopyWithImpl(this._self, this._then);

  final _Story _self;
  final $Res Function(_Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? region = null,Object? summary = null,Object? readTime = null,Object? date = null,}) {
  return _then(_Story(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,readTime: null == readTime ? _self.readTime : readTime // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StoryDetail {

 String get id; String get title; String get author; String get region; String get status; String get summary; String get body; String get readTime; String get date; String get createdAt; String get updatedAt;
/// Create a copy of StoryDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryDetailCopyWith<StoryDetail> get copyWith => _$StoryDetailCopyWithImpl<StoryDetail>(this as StoryDetail, _$identity);

  /// Serializes this StoryDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StoryDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.readTime, _this.readTime) || other.readTime == _this.readTime)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StoryDetail;
  return Object.hash(runtimeType,_this.id,_this.title,_this.author,_this.region,_this.status,_this.summary,_this.body,_this.readTime,_this.date,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as StoryDetail;
  return 'StoryDetail(id: ${_this.id}, title: ${_this.title}, author: ${_this.author}, region: ${_this.region}, status: ${_this.status}, summary: ${_this.summary}, body: ${_this.body}, readTime: ${_this.readTime}, date: ${_this.date}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $StoryDetailCopyWith<$Res>  {
  factory $StoryDetailCopyWith(StoryDetail value, $Res Function(StoryDetail) _then) = _$StoryDetailCopyWithImpl;
@useResult
$Res call({
 String id, String title, String author, String region, String status, String summary, String body, String readTime, String date, String createdAt, String updatedAt
});




}
/// @nodoc
class _$StoryDetailCopyWithImpl<$Res>
    implements $StoryDetailCopyWith<$Res> {
  _$StoryDetailCopyWithImpl(this._self, this._then);

  final StoryDetail _self;
  final $Res Function(StoryDetail) _then;

/// Create a copy of StoryDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? region = null,Object? status = null,Object? summary = null,Object? body = null,Object? readTime = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(StoryDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,readTime: null == readTime ? _self.readTime : readTime // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryDetail].
extension StoryDetailPatterns on StoryDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryDetail value)  $default,){
final _that = this;
switch (_that) {
case _StoryDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryDetail value)?  $default,){
final _that = this;
switch (_that) {
case _StoryDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String author,  String region,  String status,  String summary,  String body,  String readTime,  String date,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryDetail() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.region,_that.status,_that.summary,_that.body,_that.readTime,_that.date,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String author,  String region,  String status,  String summary,  String body,  String readTime,  String date,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StoryDetail():
return $default(_that.id,_that.title,_that.author,_that.region,_that.status,_that.summary,_that.body,_that.readTime,_that.date,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String author,  String region,  String status,  String summary,  String body,  String readTime,  String date,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StoryDetail() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.region,_that.status,_that.summary,_that.body,_that.readTime,_that.date,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _StoryDetail extends StoryDetail {
  const _StoryDetail({this.id = '', this.title = '', this.author = '', this.region = '', this.status = '', this.summary = '', this.body = '', this.readTime = '', this.date = '', this.createdAt = '', this.updatedAt = ''}): super._();
  factory _StoryDetail.fromJson(Map<String, dynamic> json) => _$StoryDetailFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String region;
@override@JsonKey() final  String status;
@override@JsonKey() final  String summary;
@override@JsonKey() final  String body;
@override@JsonKey() final  String readTime;
@override@JsonKey() final  String date;
@override@JsonKey() final  String createdAt;
@override@JsonKey() final  String updatedAt;

/// Create a copy of StoryDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryDetailCopyWith<_StoryDetail> get copyWith => __$StoryDetailCopyWithImpl<_StoryDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.region, region) || other.region == region)&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.body, body) || other.body == body)&&(identical(other.readTime, readTime) || other.readTime == readTime)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,author,region,status,summary,body,readTime,date,createdAt,updatedAt);
}

@override
String toString() {
    return 'StoryDetail(id: $id, title: $title, author: $author, region: $region, status: $status, summary: $summary, body: $body, readTime: $readTime, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StoryDetailCopyWith<$Res> implements $StoryDetailCopyWith<$Res> {
  factory _$StoryDetailCopyWith(_StoryDetail value, $Res Function(_StoryDetail) _then) = __$StoryDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String author, String region, String status, String summary, String body, String readTime, String date, String createdAt, String updatedAt
});




}
/// @nodoc
class __$StoryDetailCopyWithImpl<$Res>
    implements _$StoryDetailCopyWith<$Res> {
  __$StoryDetailCopyWithImpl(this._self, this._then);

  final _StoryDetail _self;
  final $Res Function(_StoryDetail) _then;

/// Create a copy of StoryDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? region = null,Object? status = null,Object? summary = null,Object? body = null,Object? readTime = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_StoryDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,readTime: null == readTime ? _self.readTime : readTime // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
