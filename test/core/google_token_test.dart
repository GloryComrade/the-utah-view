import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/auth/google_auth.dart';

String _jwt(Map<String, Object?> claims) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part(claims)}.sig';
}

void main() {
  final now = DateTime.utc(2026, 10, 23, 12);
  int secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

  test('reads the expiry from an ID token', () {
    final exp = now.add(const Duration(hours: 1));
    expect(idTokenExpiry(_jwt({'exp': secs(exp)})), exp);
    expect(idTokenExpiry('not-a-jwt'), isNull);
    expect(idTokenExpiry(_jwt({'sub': 'x'})), isNull);
  });

  test('refreshes tokens that expire within five minutes', () {
    String token(Duration left) => _jwt({'exp': secs(now.add(left))});
    expect(
      idTokenNeedsRefresh(token(const Duration(minutes: 40)), now: now),
      isFalse,
    );
    expect(
      idTokenNeedsRefresh(token(const Duration(minutes: 3)), now: now),
      isTrue,
    );
    expect(
      idTokenNeedsRefresh(token(const Duration(minutes: -10)), now: now),
      isTrue,
    );
    // Unreadable tokens are left for the server to judge.
    expect(idTokenNeedsRefresh('opaque', now: now), isFalse);
  });
}
