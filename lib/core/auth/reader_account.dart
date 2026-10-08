import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/saved/saved_stories.dart';
import '../api/api_client.dart';
import '../api/models/json_converters.dart';
import '../api/models/models.dart';
import '../api/providers.dart';
import '../storage/key_value_store.dart';
import 'google_auth.dart';

/// A first-party (email/password) reader account session.
@immutable
class ReaderAccount {
  const ReaderAccount({
    required this.email,
    required this.name,
    required this.token,
  });

  final String email;
  final String name;

  /// Opaque session token from the Worker, sent as `Authorization: Bearer`.
  final String token;
}

const _kToken = 'account_token';
const _kEmail = 'account_email';
const _kName = 'account_name';

class ReaderAccountController extends Notifier<ReaderAccount?> {
  KeyValueStore get _settings => ref.read(appStoresProvider).settings;
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  ReaderAccount? build() {
    final token = _settings.read(_kToken);
    if (token == null || token.isEmpty) return null;
    return ReaderAccount(
      email: _settings.read(_kEmail) ?? '',
      name: _settings.read(_kName) ?? '',
      token: token,
    );
  }

  /// Returns null on success, or a reader-facing error message.
  Future<String?> signUp(String email, String password, String name) => _auth(
    '/api/account/signup',
    {'email': email, 'password': password, 'name': name},
  );

  Future<String?> logIn(String email, String password) =>
      _auth('/api/account/login', {'email': email, 'password': password});

  Future<String?> _auth(String path, Map<String, Object?> body) async {
    try {
      final res = asJsonMap(await _api.postAuthed(path, body));
      final token = coerceJsonString(res?['token']);
      if (token.isEmpty) {
        final err = coerceJsonString(res?['error']);
        return err.isEmpty ? 'Sign-in failed. Please try again.' : err;
      }
      final email = coerceJsonString(res?['email']);
      final name = coerceJsonString(res?['name']);
      await _settings.write(_kToken, token);
      await _settings.write(_kEmail, email);
      await _settings.write(_kName, name);
      state = ReaderAccount(email: email, name: name, token: token);
      unawaited(mergeSavedStories(_api, ref.read(savedStoriesProvider.notifier), ref.read(savedStoriesProvider), token));
      return null;
    } on ApiException catch (e) {
      return switch (e.statusCode) {
        409 => 'An account with that email already exists.',
        401 => 'Invalid email or password.',
        400 => 'Enter a valid email and a password of at least 8 characters.',
        _ => e.userMessage,
      };
    }
  }

  Future<void> logOut() async {
    final token = state?.token;
    state = null;
    await _settings.delete(_kToken);
    await _settings.delete(_kEmail);
    await _settings.delete(_kName);
    if (token != null) {
      try {
        await _api.postAuthed('/api/account/logout', const {}, token);
      } on Object {
        // best effort
      }
    }
  }
}

final readerAccountProvider =
    NotifierProvider<ReaderAccountController, ReaderAccount?>(
      ReaderAccountController.new,
    );

/// Token used for saved-story sync: a reader session, else a Google ID token.
final savedAuthTokenProvider = Provider<String?>((ref) {
  final acct = ref.watch(readerAccountProvider);
  if (acct != null && acct.token.isNotEmpty) return acct.token;
  final g = ref.watch(authControllerProvider).value;
  if (g != null && g.idToken.isNotEmpty) return g.idToken;
  return null;
});

/// Pushes local bookmarks to the server whenever they change and the reader is
/// signed in. Keep it alive by watching it from a long-lived widget.
final savedSyncProvider = Provider<void>((ref) {
  ref.listen<List<SavedStory>>(savedStoriesProvider, (_, next) {
    final token = ref.read(savedAuthTokenProvider);
    if (token == null) return;
    unawaited(
      pushSavedIds(
        ref.read(apiClientProvider),
        token,
        [for (final s in next) s.story.id],
      ),
    );
  });
});

/// Union local + server bookmarks, download any missing stories, push the set.
Future<void> mergeSavedStories(
  ApiClient api,
  SavedStoriesNotifier saved,
  List<SavedStory> current,
  String token,
) async {
  try {
    final res = asJsonMap(await api.getAuthed('/api/me/saved', token));
    final serverIds = <String>[
      for (final x in (res?['ids'] as List? ?? const <Object?>[]))
        coerceJsonString(x),
    ].where((e) => e.isNotEmpty).toList();
    final localIds = {for (final s in current) s.story.id};
    for (final id in serverIds) {
      if (localIds.contains(id)) continue;
      try {
        final story = asJsonMap(await api.getJson('/api/stories/$id'));
        if (story != null) {
          final detail = StoryDetail.fromJson(story);
          if (detail.id.isNotEmpty) await saved.save(detail);
        }
      } on Object {
        // skip stories that won't load
      }
    }
    final union = {...localIds, ...serverIds}.toList();
    await api.putAuthed('/api/me/saved', {'ids': union}, token);
  } on Object {
    // best effort; local bookmarks are unaffected
  }
}

Future<void> pushSavedIds(ApiClient api, String token, List<String> ids) async {
  try {
    await api.putAuthed('/api/me/saved', {'ids': ids}, token);
  } on Object {
    // best effort
  }
}
