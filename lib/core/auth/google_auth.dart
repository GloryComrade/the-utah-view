import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

/// Reactive Google Sign-In (Phase 2 groundwork).
///
/// Reader features don't require sign-in; this powers the optional "Sign in"
/// entry and is the base for saved-story sync once the backend exposes
/// `/api/me/saved` (see docs/PHASE2.md). On the web, interactive sign-in is the
/// Google-rendered button ([googleSignInButton]); on mobile it's [signIn].
class AuthController extends AsyncNotifier<AuthUser?> {
  bool _listening = false;
  AuthUser? _current;

  /// Why setup failed, if it did. Kept so the button can say so instead of
  /// silently doing nothing.
  Object? _initError;

  @override
  Future<AuthUser?> build() async {
    await _init();
    return _current;
  }

  Future<void> _init() async {
    try {
      _initError = null;
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: kIsWeb ? googleWebClientId : null,
        serverClientId: kIsWeb ? null : googleWebClientId,
      );
      if (!_listening) {
        _listening = true;
        signIn.authenticationEvents.listen(
          _onEvent,
          // Failures are already reported by signIn(); don't log them twice
          // as unhandled.
          onError: (Object e) => debugPrint('Google sign-in event: $e'),
        );
      }
      await signIn.attemptLightweightAuthentication();
    } catch (e) {
      // Sign-in unavailable (e.g. origin not yet authorized); stay signed out.
      // A failed lightweight attempt after a good initialize is not an error.
      if (!_listening) _initError = e;
      debugPrint('Google sign-in setup: $e');
    }
  }

  void _onEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        _setUser(user);
      case GoogleSignInAuthenticationEventSignOut():
        _current = null;
        state = const AsyncData(null);
    }
  }

  void _setUser(GoogleSignInAccount user) {
    _current = AuthUser(
      email: user.email,
      name: user.displayName ?? user.email,
      idToken: user.authentication.idToken ?? '',
      photoUrl: user.photoUrl,
    );
    state = AsyncData(_current);
  }

  /// Interactive sign-in on platforms that support it (mobile/desktop).
  /// Returns a message for the reader when it fails, or null on success or
  /// when they cancelled.
  Future<String?> signIn() async {
    if (_initError != null) return googleSignInErrorMessage(_initError!);
    final signIn = GoogleSignIn.instance;
    if (!signIn.supportsAuthenticate()) {
      return "Google sign-in isn't available on this device.";
    }
    try {
      await signIn.authenticate();
      return null;
    } catch (e) {
      debugPrint('Google sign-in: $e');
      return googleSignInErrorMessage(e);
    }
  }

  /// Makes sure the Google ID token is good for at least a few more minutes,
  /// silently signing in again when it isn't. Google ID tokens last about an
  /// hour, and the Worker rejects expired ones.
  Future<void> ensureFreshToken({DateTime? now}) async {
    final user = _current;
    if (user == null || !idTokenNeedsRefresh(user.idToken, now: now)) return;
    try {
      final account = await GoogleSignIn.instance
          .attemptLightweightAuthentication();
      if (account != null) _setUser(account);
    } catch (e) {
      debugPrint('Google token refresh: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    _current = null;
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

/// What to tell the reader when Google sign-in fails. Null means say nothing
/// (they closed the Google sheet themselves).
String? googleSignInErrorMessage(Object error) {
  if (error is GoogleSignInException) {
    final detail = error.description?.trim();
    final suffix = detail == null || detail.isEmpty ? '' : ' ($detail)';
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return null;
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return "Google sign-in isn't set up for this version of the app yet. "
            'Please use email instead for now.$suffix';
      case GoogleSignInExceptionCode.uiUnavailable:
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was interrupted. Please try again.$suffix';
      default:
        return 'Google sign-in failed. Please try again.$suffix';
    }
  }
  // iOS reports a missing GIDClientID as a plain PlatformException.
  if (error is PlatformException &&
      '${error.message}'.contains('No active configuration')) {
    return "Google sign-in isn't set up for this version of the app yet. "
        'Please use email instead for now. (${error.message})';
  }
  return 'Google sign-in failed. Please try again. ($error)';
}

/// When a JWT's `exp` claim says it expires, or null if it can't be read.
DateTime? idTokenExpiry(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload is Map ? payload['exp'] : null;
    return exp is int
        ? DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true)
        : null;
  } on Object {
    return null;
  }
}

/// Whether [token] is expired or will be within five minutes. A token whose
/// expiry can't be read is left alone.
bool idTokenNeedsRefresh(String token, {DateTime? now}) {
  final exp = idTokenExpiry(token);
  if (exp == null) return false;
  return !exp.isAfter(
    (now ?? DateTime.now()).toUtc().add(const Duration(minutes: 5)),
  );
}
