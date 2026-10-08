// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SitePageSummary {

 String get slug; String get title; String get subtitle;
/// Create a copy of SitePageSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SitePageSummaryCopyWith<SitePageSummary> get copyWith => _$SitePageSummaryCopyWithImpl<SitePageSummary>(this as SitePageSummary, _$identity);

  /// Serializes this SitePageSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SitePageSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SitePageSummary&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SitePageSummary;
  return Object.hash(runtimeType,_this.slug,_this.title,_this.subtitle);
}

@override
String toString() {
  final _this = this as SitePageSummary;
  return 'SitePageSummary(slug: ${_this.slug}, title: ${_this.title}, subtitle: ${_this.subtitle})';
}


}

/// @nodoc
abstract mixin class $SitePageSummaryCopyWith<$Res>  {
  factory $SitePageSummaryCopyWith(SitePageSummary value, $Res Function(SitePageSummary) _then) = _$SitePageSummaryCopyWithImpl;
@useResult
$Res call({
 String slug, String title, String subtitle
});




}
/// @nodoc
class _$SitePageSummaryCopyWithImpl<$Res>
    implements $SitePageSummaryCopyWith<$Res> {
  _$SitePageSummaryCopyWithImpl(this._self, this._then);

  final SitePageSummary _self;
  final $Res Function(SitePageSummary) _then;

/// Create a copy of SitePageSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? title = null,Object? subtitle = null,}) {
  return _then(SitePageSummary(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SitePageSummary].
extension SitePageSummaryPatterns on SitePageSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SitePageSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SitePageSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SitePageSummary value)  $default,){
final _that = this;
switch (_that) {
case _SitePageSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SitePageSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SitePageSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String title,  String subtitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SitePageSummary() when $default != null:
return $default(_that.slug,_that.title,_that.subtitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String title,  String subtitle)  $default,) {final _that = this;
switch (_that) {
case _SitePageSummary():
return $default(_that.slug,_that.title,_that.subtitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String title,  String subtitle)?  $default,) {final _that = this;
switch (_that) {
case _SitePageSummary() when $default != null:
return $default(_that.slug,_that.title,_that.subtitle);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _SitePageSummary implements SitePageSummary {
  const _SitePageSummary({this.slug = '', this.title = '', this.subtitle = ''});
  factory _SitePageSummary.fromJson(Map<String, dynamic> json) => _$SitePageSummaryFromJson(json);

@override@JsonKey() final  String slug;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;

/// Create a copy of SitePageSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SitePageSummaryCopyWith<_SitePageSummary> get copyWith => __$SitePageSummaryCopyWithImpl<_SitePageSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SitePageSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SitePageSummary&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,slug,title,subtitle);
}

@override
String toString() {
    return 'SitePageSummary(slug: $slug, title: $title, subtitle: $subtitle)';
}


}

/// @nodoc
abstract mixin class _$SitePageSummaryCopyWith<$Res> implements $SitePageSummaryCopyWith<$Res> {
  factory _$SitePageSummaryCopyWith(_SitePageSummary value, $Res Function(_SitePageSummary) _then) = __$SitePageSummaryCopyWithImpl;
@override @useResult
$Res call({
 String slug, String title, String subtitle
});




}
/// @nodoc
class __$SitePageSummaryCopyWithImpl<$Res>
    implements _$SitePageSummaryCopyWith<$Res> {
  __$SitePageSummaryCopyWithImpl(this._self, this._then);

  final _SitePageSummary _self;
  final $Res Function(_SitePageSummary) _then;

/// Create a copy of SitePageSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? title = null,Object? subtitle = null,}) {
  return _then(_SitePageSummary(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SitePage {

 String get slug; String get title; String get subtitle; String get body;
/// Create a copy of SitePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SitePageCopyWith<SitePage> get copyWith => _$SitePageCopyWithImpl<SitePage>(this as SitePage, _$identity);

  /// Serializes this SitePage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SitePage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SitePage&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.body, _this.body) || other.body == _this.body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SitePage;
  return Object.hash(runtimeType,_this.slug,_this.title,_this.subtitle,_this.body);
}

@override
String toString() {
  final _this = this as SitePage;
  return 'SitePage(slug: ${_this.slug}, title: ${_this.title}, subtitle: ${_this.subtitle}, body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $SitePageCopyWith<$Res>  {
  factory $SitePageCopyWith(SitePage value, $Res Function(SitePage) _then) = _$SitePageCopyWithImpl;
@useResult
$Res call({
 String slug, String title, String subtitle, String body
});




}
/// @nodoc
class _$SitePageCopyWithImpl<$Res>
    implements $SitePageCopyWith<$Res> {
  _$SitePageCopyWithImpl(this._self, this._then);

  final SitePage _self;
  final $Res Function(SitePage) _then;

/// Create a copy of SitePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? title = null,Object? subtitle = null,Object? body = null,}) {
  return _then(SitePage(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SitePage].
extension SitePagePatterns on SitePage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SitePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SitePage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SitePage value)  $default,){
final _that = this;
switch (_that) {
case _SitePage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SitePage value)?  $default,){
final _that = this;
switch (_that) {
case _SitePage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String title,  String subtitle,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SitePage() when $default != null:
return $default(_that.slug,_that.title,_that.subtitle,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String title,  String subtitle,  String body)  $default,) {final _that = this;
switch (_that) {
case _SitePage():
return $default(_that.slug,_that.title,_that.subtitle,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String title,  String subtitle,  String body)?  $default,) {final _that = this;
switch (_that) {
case _SitePage() when $default != null:
return $default(_that.slug,_that.title,_that.subtitle,_that.body);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _SitePage implements SitePage {
  const _SitePage({this.slug = '', this.title = '', this.subtitle = '', this.body = ''});
  factory _SitePage.fromJson(Map<String, dynamic> json) => _$SitePageFromJson(json);

@override@JsonKey() final  String slug;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  String body;

/// Create a copy of SitePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SitePageCopyWith<_SitePage> get copyWith => __$SitePageCopyWithImpl<_SitePage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SitePageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SitePage&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,slug,title,subtitle,body);
}

@override
String toString() {
    return 'SitePage(slug: $slug, title: $title, subtitle: $subtitle, body: $body)';
}


}

/// @nodoc
abstract mixin class _$SitePageCopyWith<$Res> implements $SitePageCopyWith<$Res> {
  factory _$SitePageCopyWith(_SitePage value, $Res Function(_SitePage) _then) = __$SitePageCopyWithImpl;
@override @useResult
$Res call({
 String slug, String title, String subtitle, String body
});




}
/// @nodoc
class __$SitePageCopyWithImpl<$Res>
    implements _$SitePageCopyWith<$Res> {
  __$SitePageCopyWithImpl(this._self, this._then);

  final _SitePage _self;
  final $Res Function(_SitePage) _then;

/// Create a copy of SitePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? title = null,Object? subtitle = null,Object? body = null,}) {
  return _then(_SitePage(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
