// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NavCategory {

 String get text; bool get section;
/// Create a copy of NavCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavCategoryCopyWith<NavCategory> get copyWith => _$NavCategoryCopyWithImpl<NavCategory>(this as NavCategory, _$identity);

  /// Serializes this NavCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NavCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavCategory&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.section, _this.section) || other.section == _this.section));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NavCategory;
  return Object.hash(runtimeType,_this.text,_this.section);
}

@override
String toString() {
  final _this = this as NavCategory;
  return 'NavCategory(text: ${_this.text}, section: ${_this.section})';
}


}

/// @nodoc
abstract mixin class $NavCategoryCopyWith<$Res>  {
  factory $NavCategoryCopyWith(NavCategory value, $Res Function(NavCategory) _then) = _$NavCategoryCopyWithImpl;
@useResult
$Res call({
 String text, bool section
});




}
/// @nodoc
class _$NavCategoryCopyWithImpl<$Res>
    implements $NavCategoryCopyWith<$Res> {
  _$NavCategoryCopyWithImpl(this._self, this._then);

  final NavCategory _self;
  final $Res Function(NavCategory) _then;

/// Create a copy of NavCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? section = null,}) {
  return _then(NavCategory(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NavCategory].
extension NavCategoryPatterns on NavCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavCategory value)  $default,){
final _that = this;
switch (_that) {
case _NavCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavCategory value)?  $default,){
final _that = this;
switch (_that) {
case _NavCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  bool section)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavCategory() when $default != null:
return $default(_that.text,_that.section);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  bool section)  $default,) {final _that = this;
switch (_that) {
case _NavCategory():
return $default(_that.text,_that.section);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  bool section)?  $default,) {final _that = this;
switch (_that) {
case _NavCategory() when $default != null:
return $default(_that.text,_that.section);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _NavCategory implements NavCategory {
  const _NavCategory({this.text = '', this.section = false});
  factory _NavCategory.fromJson(Map<String, dynamic> json) => _$NavCategoryFromJson(json);

@override@JsonKey() final  String text;
@override@JsonKey() final  bool section;

/// Create a copy of NavCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavCategoryCopyWith<_NavCategory> get copyWith => __$NavCategoryCopyWithImpl<_NavCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavCategory&&(identical(other.text, text) || other.text == text)&&(identical(other.section, section) || other.section == section));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,section);
}

@override
String toString() {
    return 'NavCategory(text: $text, section: $section)';
}


}

/// @nodoc
abstract mixin class _$NavCategoryCopyWith<$Res> implements $NavCategoryCopyWith<$Res> {
  factory _$NavCategoryCopyWith(_NavCategory value, $Res Function(_NavCategory) _then) = __$NavCategoryCopyWithImpl;
@override @useResult
$Res call({
 String text, bool section
});




}
/// @nodoc
class __$NavCategoryCopyWithImpl<$Res>
    implements _$NavCategoryCopyWith<$Res> {
  __$NavCategoryCopyWithImpl(this._self, this._then);

  final _NavCategory _self;
  final $Res Function(_NavCategory) _then;

/// Create a copy of NavCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? section = null,}) {
  return _then(_NavCategory(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FooterLink {

 String get text; String get url;
/// Create a copy of FooterLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FooterLinkCopyWith<FooterLink> get copyWith => _$FooterLinkCopyWithImpl<FooterLink>(this as FooterLink, _$identity);

  /// Serializes this FooterLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FooterLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FooterLink&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FooterLink;
  return Object.hash(runtimeType,_this.text,_this.url);
}

@override
String toString() {
  final _this = this as FooterLink;
  return 'FooterLink(text: ${_this.text}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $FooterLinkCopyWith<$Res>  {
  factory $FooterLinkCopyWith(FooterLink value, $Res Function(FooterLink) _then) = _$FooterLinkCopyWithImpl;
@useResult
$Res call({
 String text, String url
});




}
/// @nodoc
class _$FooterLinkCopyWithImpl<$Res>
    implements $FooterLinkCopyWith<$Res> {
  _$FooterLinkCopyWithImpl(this._self, this._then);

  final FooterLink _self;
  final $Res Function(FooterLink) _then;

/// Create a copy of FooterLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? url = null,}) {
  return _then(FooterLink(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FooterLink].
extension FooterLinkPatterns on FooterLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FooterLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FooterLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FooterLink value)  $default,){
final _that = this;
switch (_that) {
case _FooterLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FooterLink value)?  $default,){
final _that = this;
switch (_that) {
case _FooterLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FooterLink() when $default != null:
return $default(_that.text,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String url)  $default,) {final _that = this;
switch (_that) {
case _FooterLink():
return $default(_that.text,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String url)?  $default,) {final _that = this;
switch (_that) {
case _FooterLink() when $default != null:
return $default(_that.text,_that.url);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _FooterLink implements FooterLink {
  const _FooterLink({this.text = '', this.url = ''});
  factory _FooterLink.fromJson(Map<String, dynamic> json) => _$FooterLinkFromJson(json);

@override@JsonKey() final  String text;
@override@JsonKey() final  String url;

/// Create a copy of FooterLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FooterLinkCopyWith<_FooterLink> get copyWith => __$FooterLinkCopyWithImpl<_FooterLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FooterLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FooterLink&&(identical(other.text, text) || other.text == text)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,url);
}

@override
String toString() {
    return 'FooterLink(text: $text, url: $url)';
}


}

/// @nodoc
abstract mixin class _$FooterLinkCopyWith<$Res> implements $FooterLinkCopyWith<$Res> {
  factory _$FooterLinkCopyWith(_FooterLink value, $Res Function(_FooterLink) _then) = __$FooterLinkCopyWithImpl;
@override @useResult
$Res call({
 String text, String url
});




}
/// @nodoc
class __$FooterLinkCopyWithImpl<$Res>
    implements _$FooterLinkCopyWith<$Res> {
  __$FooterLinkCopyWithImpl(this._self, this._then);

  final _FooterLink _self;
  final $Res Function(_FooterLink) _then;

/// Create a copy of FooterLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? url = null,}) {
  return _then(_FooterLink(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FooterColumn {

 String get title;@FooterLinkListConverter() List<FooterLink> get links;
/// Create a copy of FooterColumn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FooterColumnCopyWith<FooterColumn> get copyWith => _$FooterColumnCopyWithImpl<FooterColumn>(this as FooterColumn, _$identity);

  /// Serializes this FooterColumn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FooterColumn;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FooterColumn&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.links, _this.links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FooterColumn;
  return Object.hash(runtimeType,_this.title,const DeepCollectionEquality().hash(_this.links));
}

@override
String toString() {
  final _this = this as FooterColumn;
  return 'FooterColumn(title: ${_this.title}, links: ${_this.links})';
}


}

/// @nodoc
abstract mixin class $FooterColumnCopyWith<$Res>  {
  factory $FooterColumnCopyWith(FooterColumn value, $Res Function(FooterColumn) _then) = _$FooterColumnCopyWithImpl;
@useResult
$Res call({
 String title,@FooterLinkListConverter() List<FooterLink> links
});




}
/// @nodoc
class _$FooterColumnCopyWithImpl<$Res>
    implements $FooterColumnCopyWith<$Res> {
  _$FooterColumnCopyWithImpl(this._self, this._then);

  final FooterColumn _self;
  final $Res Function(FooterColumn) _then;

/// Create a copy of FooterColumn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? links = null,}) {
  return _then(FooterColumn(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<FooterLink>,
  ));
}

}


/// Adds pattern-matching-related methods to [FooterColumn].
extension FooterColumnPatterns on FooterColumn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FooterColumn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FooterColumn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FooterColumn value)  $default,){
final _that = this;
switch (_that) {
case _FooterColumn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FooterColumn value)?  $default,){
final _that = this;
switch (_that) {
case _FooterColumn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title, @FooterLinkListConverter()  List<FooterLink> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FooterColumn() when $default != null:
return $default(_that.title,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title, @FooterLinkListConverter()  List<FooterLink> links)  $default,) {final _that = this;
switch (_that) {
case _FooterColumn():
return $default(_that.title,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title, @FooterLinkListConverter()  List<FooterLink> links)?  $default,) {final _that = this;
switch (_that) {
case _FooterColumn() when $default != null:
return $default(_that.title,_that.links);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _FooterColumn implements FooterColumn {
  const _FooterColumn({this.title = '', @FooterLinkListConverter()  List<FooterLink> links = const <FooterLink>[]}): _links = links;
  factory _FooterColumn.fromJson(Map<String, dynamic> json) => _$FooterColumnFromJson(json);

@override@JsonKey() final  String title;
 final  List<FooterLink> _links;
@override@JsonKey()@FooterLinkListConverter() List<FooterLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of FooterColumn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FooterColumnCopyWith<_FooterColumn> get copyWith => __$FooterColumnCopyWithImpl<_FooterColumn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FooterColumnToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FooterColumn&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.links, _links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_links));
}

@override
String toString() {
    return 'FooterColumn(title: $title, links: $links)';
}


}

/// @nodoc
abstract mixin class _$FooterColumnCopyWith<$Res> implements $FooterColumnCopyWith<$Res> {
  factory _$FooterColumnCopyWith(_FooterColumn value, $Res Function(_FooterColumn) _then) = __$FooterColumnCopyWithImpl;
@override @useResult
$Res call({
 String title,@FooterLinkListConverter() List<FooterLink> links
});




}
/// @nodoc
class __$FooterColumnCopyWithImpl<$Res>
    implements _$FooterColumnCopyWith<$Res> {
  __$FooterColumnCopyWithImpl(this._self, this._then);

  final _FooterColumn _self;
  final $Res Function(_FooterColumn) _then;

/// Create a copy of FooterColumn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? links = null,}) {
  return _then(_FooterColumn(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<FooterLink>,
  ));
}


}


/// @nodoc
mixin _$SiteConfig {

/// Null when the CMS hasn't configured navigation.
@NavCategoryListConverter() List<NavCategory>? get navCategories; String get subOverline; String get subHeading; String get subDesc; String get copyright; String get aboutText; String get aboutUrl;@FooterColumnListConverter() List<FooterColumn> get footerCols;
/// Create a copy of SiteConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteConfigCopyWith<SiteConfig> get copyWith => _$SiteConfigCopyWithImpl<SiteConfig>(this as SiteConfig, _$identity);

  /// Serializes this SiteConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SiteConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteConfig&&const DeepCollectionEquality().equals(other.navCategories, _this.navCategories)&&(identical(other.subOverline, _this.subOverline) || other.subOverline == _this.subOverline)&&(identical(other.subHeading, _this.subHeading) || other.subHeading == _this.subHeading)&&(identical(other.subDesc, _this.subDesc) || other.subDesc == _this.subDesc)&&(identical(other.copyright, _this.copyright) || other.copyright == _this.copyright)&&(identical(other.aboutText, _this.aboutText) || other.aboutText == _this.aboutText)&&(identical(other.aboutUrl, _this.aboutUrl) || other.aboutUrl == _this.aboutUrl)&&const DeepCollectionEquality().equals(other.footerCols, _this.footerCols));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SiteConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.navCategories),_this.subOverline,_this.subHeading,_this.subDesc,_this.copyright,_this.aboutText,_this.aboutUrl,const DeepCollectionEquality().hash(_this.footerCols));
}

@override
String toString() {
  final _this = this as SiteConfig;
  return 'SiteConfig(navCategories: ${_this.navCategories}, subOverline: ${_this.subOverline}, subHeading: ${_this.subHeading}, subDesc: ${_this.subDesc}, copyright: ${_this.copyright}, aboutText: ${_this.aboutText}, aboutUrl: ${_this.aboutUrl}, footerCols: ${_this.footerCols})';
}


}

/// @nodoc
abstract mixin class $SiteConfigCopyWith<$Res>  {
  factory $SiteConfigCopyWith(SiteConfig value, $Res Function(SiteConfig) _then) = _$SiteConfigCopyWithImpl;
@useResult
$Res call({
@NavCategoryListConverter() List<NavCategory>? navCategories, String subOverline, String subHeading, String subDesc, String copyright, String aboutText, String aboutUrl,@FooterColumnListConverter() List<FooterColumn> footerCols
});




}
/// @nodoc
class _$SiteConfigCopyWithImpl<$Res>
    implements $SiteConfigCopyWith<$Res> {
  _$SiteConfigCopyWithImpl(this._self, this._then);

  final SiteConfig _self;
  final $Res Function(SiteConfig) _then;

/// Create a copy of SiteConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? navCategories = freezed,Object? subOverline = null,Object? subHeading = null,Object? subDesc = null,Object? copyright = null,Object? aboutText = null,Object? aboutUrl = null,Object? footerCols = null,}) {
  return _then(SiteConfig(
navCategories: freezed == navCategories ? _self.navCategories : navCategories // ignore: cast_nullable_to_non_nullable
as List<NavCategory>?,subOverline: null == subOverline ? _self.subOverline : subOverline // ignore: cast_nullable_to_non_nullable
as String,subHeading: null == subHeading ? _self.subHeading : subHeading // ignore: cast_nullable_to_non_nullable
as String,subDesc: null == subDesc ? _self.subDesc : subDesc // ignore: cast_nullable_to_non_nullable
as String,copyright: null == copyright ? _self.copyright : copyright // ignore: cast_nullable_to_non_nullable
as String,aboutText: null == aboutText ? _self.aboutText : aboutText // ignore: cast_nullable_to_non_nullable
as String,aboutUrl: null == aboutUrl ? _self.aboutUrl : aboutUrl // ignore: cast_nullable_to_non_nullable
as String,footerCols: null == footerCols ? _self.footerCols : footerCols // ignore: cast_nullable_to_non_nullable
as List<FooterColumn>,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteConfig].
extension SiteConfigPatterns on SiteConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteConfig value)  $default,){
final _that = this;
switch (_that) {
case _SiteConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SiteConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NavCategoryListConverter()  List<NavCategory>? navCategories,  String subOverline,  String subHeading,  String subDesc,  String copyright,  String aboutText,  String aboutUrl, @FooterColumnListConverter()  List<FooterColumn> footerCols)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteConfig() when $default != null:
return $default(_that.navCategories,_that.subOverline,_that.subHeading,_that.subDesc,_that.copyright,_that.aboutText,_that.aboutUrl,_that.footerCols);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NavCategoryListConverter()  List<NavCategory>? navCategories,  String subOverline,  String subHeading,  String subDesc,  String copyright,  String aboutText,  String aboutUrl, @FooterColumnListConverter()  List<FooterColumn> footerCols)  $default,) {final _that = this;
switch (_that) {
case _SiteConfig():
return $default(_that.navCategories,_that.subOverline,_that.subHeading,_that.subDesc,_that.copyright,_that.aboutText,_that.aboutUrl,_that.footerCols);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NavCategoryListConverter()  List<NavCategory>? navCategories,  String subOverline,  String subHeading,  String subDesc,  String copyright,  String aboutText,  String aboutUrl, @FooterColumnListConverter()  List<FooterColumn> footerCols)?  $default,) {final _that = this;
switch (_that) {
case _SiteConfig() when $default != null:
return $default(_that.navCategories,_that.subOverline,_that.subHeading,_that.subDesc,_that.copyright,_that.aboutText,_that.aboutUrl,_that.footerCols);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(converters: lenientJsonConverters)
class _SiteConfig extends SiteConfig {
  const _SiteConfig({@NavCategoryListConverter()  List<NavCategory>? navCategories, this.subOverline = '', this.subHeading = '', this.subDesc = '', this.copyright = '', this.aboutText = '', this.aboutUrl = '', @FooterColumnListConverter()  List<FooterColumn> footerCols = const <FooterColumn>[]}): _navCategories = navCategories,_footerCols = footerCols,super._();
  factory _SiteConfig.fromJson(Map<String, dynamic> json) => _$SiteConfigFromJson(json);

/// Null when the CMS hasn't configured navigation.
 final  List<NavCategory>? _navCategories;
/// Null when the CMS hasn't configured navigation.
@override@NavCategoryListConverter() List<NavCategory>? get navCategories {
  final value = _navCategories;
  if (value == null) return null;
  if (_navCategories is EqualUnmodifiableListView) return _navCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  String subOverline;
@override@JsonKey() final  String subHeading;
@override@JsonKey() final  String subDesc;
@override@JsonKey() final  String copyright;
@override@JsonKey() final  String aboutText;
@override@JsonKey() final  String aboutUrl;
 final  List<FooterColumn> _footerCols;
@override@JsonKey()@FooterColumnListConverter() List<FooterColumn> get footerCols {
  if (_footerCols is EqualUnmodifiableListView) return _footerCols;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_footerCols);
}


/// Create a copy of SiteConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteConfigCopyWith<_SiteConfig> get copyWith => __$SiteConfigCopyWithImpl<_SiteConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteConfig&&const DeepCollectionEquality().equals(other.navCategories, _navCategories)&&(identical(other.subOverline, subOverline) || other.subOverline == subOverline)&&(identical(other.subHeading, subHeading) || other.subHeading == subHeading)&&(identical(other.subDesc, subDesc) || other.subDesc == subDesc)&&(identical(other.copyright, copyright) || other.copyright == copyright)&&(identical(other.aboutText, aboutText) || other.aboutText == aboutText)&&(identical(other.aboutUrl, aboutUrl) || other.aboutUrl == aboutUrl)&&const DeepCollectionEquality().equals(other.footerCols, _footerCols));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_navCategories),subOverline,subHeading,subDesc,copyright,aboutText,aboutUrl,const DeepCollectionEquality().hash(_footerCols));
}

@override
String toString() {
    return 'SiteConfig(navCategories: $navCategories, subOverline: $subOverline, subHeading: $subHeading, subDesc: $subDesc, copyright: $copyright, aboutText: $aboutText, aboutUrl: $aboutUrl, footerCols: $footerCols)';
}


}

/// @nodoc
abstract mixin class _$SiteConfigCopyWith<$Res> implements $SiteConfigCopyWith<$Res> {
  factory _$SiteConfigCopyWith(_SiteConfig value, $Res Function(_SiteConfig) _then) = __$SiteConfigCopyWithImpl;
@override @useResult
$Res call({
@NavCategoryListConverter() List<NavCategory>? navCategories, String subOverline, String subHeading, String subDesc, String copyright, String aboutText, String aboutUrl,@FooterColumnListConverter() List<FooterColumn> footerCols
});




}
/// @nodoc
class __$SiteConfigCopyWithImpl<$Res>
    implements _$SiteConfigCopyWith<$Res> {
  __$SiteConfigCopyWithImpl(this._self, this._then);

  final _SiteConfig _self;
  final $Res Function(_SiteConfig) _then;

/// Create a copy of SiteConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? navCategories = freezed,Object? subOverline = null,Object? subHeading = null,Object? subDesc = null,Object? copyright = null,Object? aboutText = null,Object? aboutUrl = null,Object? footerCols = null,}) {
  return _then(_SiteConfig(
navCategories: freezed == navCategories ? _self._navCategories : navCategories // ignore: cast_nullable_to_non_nullable
as List<NavCategory>?,subOverline: null == subOverline ? _self.subOverline : subOverline // ignore: cast_nullable_to_non_nullable
as String,subHeading: null == subHeading ? _self.subHeading : subHeading // ignore: cast_nullable_to_non_nullable
as String,subDesc: null == subDesc ? _self.subDesc : subDesc // ignore: cast_nullable_to_non_nullable
as String,copyright: null == copyright ? _self.copyright : copyright // ignore: cast_nullable_to_non_nullable
as String,aboutText: null == aboutText ? _self.aboutText : aboutText // ignore: cast_nullable_to_non_nullable
as String,aboutUrl: null == aboutUrl ? _self.aboutUrl : aboutUrl // ignore: cast_nullable_to_non_nullable
as String,footerCols: null == footerCols ? _self._footerCols : footerCols // ignore: cast_nullable_to_non_nullable
as List<FooterColumn>,
  ));
}


}

// dart format on
