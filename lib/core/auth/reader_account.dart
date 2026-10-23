import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
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

/// Permanently deletes the signed-in reader's account and all server-side
/// data tied to it (saved stories, newsletter subscription), then signs out
/// locally. Returns null on success, or a reader-facing error message.
Future<String?> deleteReaderAccount(WidgetRef ref) async {
  await ref.read(authControllerProvider.notifier).ensureFreshToken();
  final token = ref.read(savedAuthTokenProvider);
  if (token == null) return 'You’re not signed in.';
  try {
    await ref
        .read(apiClientProvider)
        .postAuthed('/api/account/delete', const {}, token);
  } on ApiException catch (e) {
    return e.userMessage;
  } on Object {
    return 'Couldn’t delete your account. Check your connection and try again.';
  }
  if (ref.read(readerAccountProvider) != null) {
    await ref.read(readerAccountProvider.notifier).logOut();
  }
  if (ref.read(authControllerProvider).value != null) {
    await ref.read(authControllerProvider.notifier).signOut();
  }
  return null;
}

/// Who saved-story sync acts for: a reader session, else a Google ID token.
@immutable
class SyncIdentity {
  const SyncIdentity(this.token, this.email);

  final String token;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is SyncIdentity && other.token == token && other.email == email;

  @override
  int get hashCode => Object.hash(token, email);
}

final savedSyncIdentityProvider = Provider<SyncIdentity?>((ref) {
  final acct = ref.watch(readerAccountProvider);
  if (acct != null && acct.token.isNotEmpty) {
    return SyncIdentity(acct.token, acct.email);
  }
  final g = ref.watch(authControllerProvider).value;
  if (g != null && g.idToken.isNotEmpty) {
    return SyncIdentity(g.idToken, g.email);
  }
  return null;
});

/// Token used for saved-story sync and account deletion.
final savedAuthTokenProvider = Provider<String?>(
  (ref) => ref.watch(savedSyncIdentityProvider)?.token,
);

/// The result of a three-way merge of bookmark ids.
@immutable
class SavedIdsMerge {
  const SavedIdsMerge({
    required this.ids,
    required this.toDownload,
    required this.toRemove,
  });

  /// The set both sides should end up with, local order first.
  final List<String> ids;

  /// Saved on another device; fetch and save here.
  final List<String> toDownload;

  /// Removed on another device; remove here too.
  final List<String> toRemove;
}

/// Merges [local] and [remote] against [base], the set both sides agreed on
/// at the last sync (null before the first sync on this device).
///
/// A story saved on either side is kept, and a story removed on either side
/// since [base] is dropped. Without a [base] nothing is dropped: the result is
/// the union, so signing in never loses a bookmark.
SavedIdsMerge mergeSavedIds({
  required List<String> local,
  required List<String> remote,
  Set<String>? base,
}) {
  final localSet = local.toSet();
  final remoteSet = remote.toSet();
  final removedHere = base == null ? <String>{} : base.difference(localSet);
  final removedThere = base == null
      ? <String>{}
      : base.intersection(localSet).difference(remoteSet);
  final ids = <String>{
    for (final id in local)
      if (!removedThere.contains(id)) id,
    for (final id in remote)
      if (!removedHere.contains(id)) id,
  }.toList();
  return SavedIdsMerge(
    ids: ids,
    toDownload: [
      for (final id in ids)
        if (!localSet.contains(id)) id,
    ],
    toRemove: removedThere.toList(),
  );
}

/// Keeps this device's bookmarks and the reader's account in step.
///
/// Every sync reads the server's list first and merges it with the local one
/// (see [mergeSavedIds]), so a save on this phone never wipes what another
/// device saved. Syncs run one at a time.
class SavedSync {
  SavedSync(this._ref);

  final Ref _ref;
  Future<void> _queue = Future.value();
  bool _applyingRemote = false;
  bool _again = false;
  bool _running = false;

  static String baseKey(String email) => 'saved_sync_base:$email';

  /// Runs a sync now, or once more after the one in progress.
  Future<void> schedule() {
    if (_applyingRemote) return _queue;
    if (_running) {
      _again = true;
      return _queue;
    }
    _running = true;
    return _queue = _run();
  }

  Future<void> _run() async {
    try {
      do {
        _again = false;
        await _syncOnce();
      } while (_again);
    } finally {
      _running = false;
    }
  }

  Future<void> _syncOnce() async {
    if (_ref.read(readerAccountProvider) == null) {
      await _ref.read(authControllerProvider.notifier).ensureFreshToken();
    }
    final who = _ref.read(savedSyncIdentityProvider);
    if (who == null) return;
    final api = _ref.read(apiClientProvider);
    final settings = _ref.read(appStoresProvider).settings;
    final saved = _ref.read(savedStoriesProvider.notifier);
    try {
      final res = asJsonMap(await api.getAuthed('/api/me/saved', who.token));
      final remote = <String>[
        for (final x in (res?['ids'] as List? ?? const <Object?>[]))
          if (coerceJsonString(x) case final id when id.isNotEmpty) id,
      ];
      final rawBase = settings.read(baseKey(who.email));
      final base = rawBase == null
          ? null
          : {
              for (final x in (jsonDecode(rawBase) as List? ?? const []))
                coerceJsonString(x),
            };
      final local = [
        for (final s in _ref.read(savedStoriesProvider)) s.story.id,
      ];
      final merge = mergeSavedIds(local: local, remote: remote, base: base);

      _applyingRemote = true;
      try {
        for (final id in merge.toRemove) {
          await saved.remove(id);
        }
        for (final id in merge.toDownload) {
          try {
            final story = asJsonMap(
              await api.getJson('/api/stories/${Uri.encodeComponent(id)}'),
            );
            final detail = story == null ? null : StoryDetail.fromJson(story);
            if (detail != null && detail.id.isNotEmpty) {
              await saved.save(detail);
            }
          } on Object {
            // Keep the id on the server even if the story won't load now.
          }
        }
      } finally {
        _applyingRemote = false;
      }

      if (!const ListEquality<String>().equals(merge.ids, remote)) {
        await api.putAuthed('/api/me/saved', {'ids': merge.ids}, who.token);
      }
      await settings.write(baseKey(who.email), jsonEncode(merge.ids));
    } on Object {
      // Best effort: offline or signed out mid-sync. Local bookmarks are
      // untouched and the next change or launch tries again.
    }
  }
}

/// Syncs bookmarks whenever the reader signs in (or the app opens signed in)
/// and whenever they change. Keep it alive by watching it from a long-lived
/// widget.
final savedSyncProvider = Provider<SavedSync>((ref) {
  final sync = SavedSync(ref);
  ref.listen<SyncIdentity?>(savedSyncIdentityProvider, (previous, next) {
    if (next == null) {
      // Signed out: the next sign-in starts from a plain union again, so
      // stories removed while signed out are never deleted from the account.
      if (previous != null) {
        unawaited(
          ref
              .read(appStoresProvider)
              .settings
              .delete(SavedSync.baseKey(previous.email)),
        );
      }
    } else if (next.email != previous?.email) {
      unawaited(sync.schedule());
    }
  }, fireImmediately: true);
  ref.listen<List<SavedStory>>(savedStoriesProvider, (_, _) {
    unawaited(sync.schedule());
  });
  return sync;
});
