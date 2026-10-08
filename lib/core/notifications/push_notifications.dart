import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

/// FCM topic every installation subscribes to for new monthly issues.
const newIssueTopic = 'new-issue';

/// Topic every install subscribes to; the backend posts here when a story is
/// published.
const newStoryTopic = 'new-stories';

/// Phase 2: a push notification when each monthly issue is published.
///
/// v1 ships with [DisabledPushNotifications], so no Firebase SDK, config file
/// or permission prompt is included yet. The app already listens to
/// [openedStoryIds] (see `app.dart`), so enabling push only means providing
/// a real implementation. Steps are in docs/PHASE2.md:
///
///  1. `flutter pub add firebase_core firebase_messaging`
///  2. `flutterfire configure --platforms=ios,android` (writes
///     `lib/firebase_options.dart`, `GoogleService-Info.plist`,
///     `google-services.json`)
///  3. iOS: add the Push Notifications and Background Modes → Remote
///     notifications capabilities; upload an APNs auth key to Firebase.
///  4. Implement this interface with `FirebaseMessaging` (sketch below) and
///     override [pushNotificationsProvider] in `main()`.
///
/// ```dart
/// class FirebasePushNotifications implements PushNotifications {
///   final _opened = StreamController<String>.broadcast();
///
///   @override
///   Future<void> initialize() async {
///     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///     final messaging = FirebaseMessaging.instance;
///     await messaging.subscribeToTopic(newIssueTopic);
///     final initial = await messaging.getInitialMessage();
///     if (initial?.data['storyId'] case final String id) _opened.add(id);
///     FirebaseMessaging.onMessageOpenedApp.listen((m) {
///       if (m.data['storyId'] case final String id) _opened.add(id);
///     });
///   }
///
///   @override
///   Future<bool> requestPermission() async {
///     final settings = await FirebaseMessaging.instance.requestPermission();
///     return settings.authorizationStatus == AuthorizationStatus.authorized;
///   }
///
///   @override
///   Stream<String> get openedStoryIds => _opened.stream;
/// }
/// ```
//
// TODO(backend): send the notification when an issue is published. The
// Worker should POST one message to the FCM HTTP v1 API, e.g. from the
// editor's "save layout" handler or a dedicated "Publish issue" action:
//
//   POST https://fcm.googleapis.com/v1/projects/<project-id>/messages:send
//   Authorization: Bearer <OAuth token for a service account with the
//                          https://www.googleapis.com/auth/firebase.messaging scope>
//   {
//     "message": {
//       "topic": "new-issue",
//       "notification": {
//         "title": "The Utah View · October issue",
//         "body": "<lead headline>"
//       },
//       "data": { "storyId": "<layout.hero_lead>" }
//     }
//   }
//
// Keep the service-account key in a Worker secret, and send at most once per
// issue (e.g. remember the last notified hero_lead in D1).
abstract interface class PushNotifications {
  Future<void> initialize();

  /// Asks the OS for permission. Returns whether notifications are allowed.
  Future<bool> requestPermission();

  /// Story ids from notifications the reader tapped, including the one that
  /// launched the app.
  Stream<String> get openedStoryIds;
}

/// v1: notifications are off.
class DisabledPushNotifications implements PushNotifications {
  const DisabledPushNotifications();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Stream<String> get openedStoryIds => const Stream.empty();
}

final pushNotificationsProvider = Provider<PushNotifications>(
  (ref) => const DisabledPushNotifications(),
);

/// Story ids from tapped notifications; the app opens each one.
final openedFromNotificationProvider = StreamProvider<String>(
  (ref) => ref.watch(pushNotificationsProvider).openedStoryIds,
);

/// Handles messages while the app is backgrounded/terminated. The OS shows the
/// notification automatically; this just ensures Firebase is ready in the
/// background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Live push via FCM. Subscribes to [newStoryTopic] and surfaces the storyId of
/// any tapped notification through [openedStoryIds].
class FirebasePushNotifications implements PushNotifications {
  final _opened = StreamController<String>.broadcast();

  @override
  Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await requestPermission();
      await messaging.subscribeToTopic(newStoryTopic);
      _emit(await messaging.getInitialMessage());
      FirebaseMessaging.onMessageOpenedApp.listen(_emit);
    } on Object {
      // Push unavailable (e.g. no APNs on a free iOS account); app still works.
    }
  }

  void _emit(RemoteMessage? message) {
    final id = message?.data['storyId'];
    if (id is String && id.isNotEmpty) _opened.add(id);
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final s = await FirebaseMessaging.instance.requestPermission();
      return s.authorizationStatus == AuthorizationStatus.authorized ||
          s.authorizationStatus == AuthorizationStatus.provisional;
    } on Object {
      return false;
    }
  }

  @override
  Stream<String> get openedStoryIds => _opened.stream;
}
