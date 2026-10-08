import 'dart:convert';
import 'dart:io';

/// Raw JSON captured from the live API by `dart run tool/verify_api.dart
/// --fixtures`.
Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync());
