import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:utah_view/core/auth/google_auth.dart';

void main() {
  GoogleSignInException ex(GoogleSignInExceptionCode code, [String? d]) =>
      GoogleSignInException(code: code, description: d);

  test('cancelling the Google sheet shows nothing', () {
    expect(googleSignInErrorMessage(ex(GoogleSignInExceptionCode.canceled)),
        isNull);
  });

  test('setup problems say so and keep the detail', () {
    final msg = googleSignInErrorMessage(ex(
        GoogleSignInExceptionCode.clientConfigurationError,
        '[28444] Developer console is not set up correctly.'));
    expect(msg, contains("isn't set up"));
    expect(msg, contains('28444'));
  });

  test('any other failure still produces a message', () {
    expect(googleSignInErrorMessage(ex(GoogleSignInExceptionCode.unknownError)),
        startsWith('Google sign-in failed'));
    expect(googleSignInErrorMessage(StateError('boom')), contains('boom'));
  });
}
