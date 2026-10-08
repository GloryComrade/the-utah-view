import 'package:json_annotation/json_annotation.dart';

/// Converters that never throw on unexpected JSON.
///
/// The CMS behind the API is edited by hand, so fields can be missing,
/// `null`, or the wrong type (a number where a string is expected, a single
/// id where a list is expected). These converters coerce what they can and
/// fall back to an empty value otherwise.
const lenientJsonConverters = <JsonConverter<Object?, Object?>>[
  LenientStringConverter(),
  LenientBoolConverter(),
  StringListConverter(),
  StringMapConverter(),
];

/// Any scalar becomes a trimmed string; `null`, maps and lists become `''`.
class LenientStringConverter implements JsonConverter<String, Object?> {
  const LenientStringConverter();

  @override
  String fromJson(Object? json) => coerceJsonString(json);

  @override
  Object? toJson(String object) => object;
}

/// `true`, `"true"`, `1`, `"1"` and `"yes"` are true; everything else false.
class LenientBoolConverter implements JsonConverter<bool, Object?> {
  const LenientBoolConverter();

  @override
  bool fromJson(Object? json) => switch (json) {
    final bool b => b,
    final num n => n != 0,
    final String s => const {
      'true',
      '1',
      'yes',
    }.contains(s.trim().toLowerCase()),
    _ => false,
  };

  @override
  Object? toJson(bool object) => object;
}

/// A list of story ids. Accepts a JSON array, a single id, or a
/// comma-separated string. Blank entries are dropped.
class StringListConverter implements JsonConverter<List<String>, Object?> {
  const StringListConverter();

  @override
  List<String> fromJson(Object? json) {
    final Iterable<Object?> items = switch (json) {
      final List<Object?> list => list,
      final String s => s.split(','),
      final num n => [n],
      _ => const [],
    };
    return [
      for (final item in items)
        if (coerceJsonString(item) case final value when value.isNotEmpty)
          value,
    ];
  }

  @override
  Object? toJson(List<String> object) => object;
}

/// A string-to-string map (e.g. region name to story id). Non-scalar or
/// blank values are dropped; key order is preserved.
class StringMapConverter
    implements JsonConverter<Map<String, String>, Object?> {
  const StringMapConverter();

  @override
  Map<String, String> fromJson(Object? json) {
    if (json is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in json.entries)
        if (coerceJsonString(value) case final v when v.isNotEmpty)
          key.toString().trim(): v,
    };
  }

  @override
  Object? toJson(Map<String, String> object) => object;
}

// Kept as a top-level function: if a converter held another converter in a
// `static const` field, json_serializable would try to reference that private
// field from generated code.

/// Any scalar becomes a trimmed string; `null`, maps and lists become `''`.
String coerceJsonString(Object? json) => switch (json) {
  final String s => s.trim(),
  final int n => n.toString(),
  final double n when n.isFinite && n == n.truncateToDouble() =>
    n.toInt().toString(),
  final num n => n.toString(),
  final bool b => b.toString(),
  _ => '',
};

/// Converts `json` into a `Map<String, dynamic>` if it is any kind of map.
Map<String, dynamic>? asJsonMap(Object? json) {
  if (json is Map<String, dynamic>) return json;
  if (json is Map) {
    return {
      for (final MapEntry(:key, :value) in json.entries) key.toString(): value,
    };
  }
  return null;
}

/// Parses each element of a JSON array with [fromJson], skipping anything
/// that is not an object or fails to parse.
List<T> parseObjectList<T>(
  Object? json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (json is! List) return const [];
  final out = <T>[];
  for (final item in json) {
    final map = asJsonMap(item);
    if (map == null) continue;
    try {
      out.add(fromJson(map));
    } on Object {
      // A malformed entry should not take the whole list down with it.
      continue;
    }
  }
  return out;
}
