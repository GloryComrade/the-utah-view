import 'package:flutter/foundation.dart';
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

  @override
  Future<AuthUser?> build() async {
    await _init();
    return _current;
  }

  Future<void> _init() async {
    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: kIsWeb ? googleWebClientId : null,
        serverClientId: kIsWeb ? null : googleWebClientId,
      );
      if (!_listening) {
        _listening = true;
        signIn.authenticationEvents.listen(_onEvent);
      }
      await signIn.attemptLightweightAuthentication();
    } catch (_) {
      // Sign-in unavailable (e.g. origin not yet authorized); stay signed out.
    }
  }

  void _onEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        _current = AuthUser(
          email: user.email,
          name: user.displayName ?? user.email,
          idToken: user.authentication.idToken ?? '',
          photoUrl: user.photoUrl,
        );
        state = AsyncData(_current);
      case GoogleSignInAuthenticationEventSignOut():
        _current = null;
        state = const AsyncData(null);
    }
  }

  /// Interactive sign-in on platforms that support it (mobile/desktop).
  Future<void> signIn() async {
    final signIn = GoogleSignIn.instance;
    if (signIn.supportsAuthenticate()) {
      try {
        await signIn.authenticate();
      } catch (_) {}
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
