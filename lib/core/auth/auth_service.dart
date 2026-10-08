import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The OAuth web client ID theutahview.com signs in with (it is public; it
/// ships in the website's HTML).
///
/// Mobile sign-in should request ID tokens for this audience
/// (`serverClientId` in google_sign_in). The tokens then carry the same `aud`
/// as the website's, so the Worker's `GET /api/me` accepts them unchanged.
const googleWebClientId =
    '562818410025-d6n1627aucueem1npk03mg5n7gs8i5t7.apps.googleusercontent.com';

@immutable
class AuthUser {
  const AuthUser({
    required this.email,
    required this.name,
    required this.idToken,
    this.photoUrl,
  });

  final String email;
  final String name;

  /// Google ID token, sent as `Authorization: Bearer` to `/api/me`.
  final String idToken;

  /// Google profile photo URL, if the account has one.
  final String? photoUrl;
}

/// Phase 2: Google Sign-In, used to sync saved stories across devices.
///
/// v1 has no sign-in ([SignedOutAuthService]); bookmarks are local only.
/// To enable it (details in docs/PHASE2.md):
///
///  1. `flutter pub add google_sign_in`
///  2. Google Cloud console → Credentials (same project as the web client):
///     * iOS client for bundle `com.theutahview.app`. Add `GIDClientID` and
///       the reversed client ID URL scheme to `ios/Runner/Info.plist`.
///     * Android client for package `com.theutahview.app` with the SHA-1 of
///       the debug, upload and Play app-signing keys.
///  3. Implement this interface:
///
/// ```dart
/// final signIn = GoogleSignIn.instance;
/// await signIn.initialize(serverClientId: googleWebClientId);
/// final account = await signIn.authenticate();
/// final idToken = account.authentication.idToken!;
/// await ref.read(apiClientProvider).getMe(idToken); // verifies + role
/// ```
///
/// TODO(backend): `/api/me` only identifies the user. Syncing bookmarks needs
/// endpoints such as `GET /api/me/saved` → `{ "ids": [...] }` and
/// `PUT /api/me/saved` with the same shape. The website keeps its bookmarks
/// in `localStorage['utv_saved']` (ids only), so sync should merge (union)
/// local and remote ids, then fetch any missing stories.
abstract interface class AuthService {
  AuthUser? get currentUser;
  Future<AuthUser?> signIn();
  Future<void> signOut();
}

/// v1: nobody is signed in.
class SignedOutAuthService implements AuthService {
  const SignedOutAuthService();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthUser?> signIn() async => null;

  @override
  Future<void> signOut() async {}
}

final authServiceProvider = Provider<AuthService>(
  (ref) => const SignedOutAuthService(),
);
