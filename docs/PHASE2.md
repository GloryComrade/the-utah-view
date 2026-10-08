# Phase 2: push notifications and Google Sign-In

Both are scaffolded, not enabled. v1 ships with no Firebase SDK, no sign-in
and no permission prompts. The seams are in place, so turning each one on is
a contained change.

## Push notifications for each new issue (FCM)

**Already in the app**

- `lib/core/notifications/push_notifications.dart` holds the
  `PushNotifications` interface, the `DisabledPushNotifications` v1
  implementation, and `pushNotificationsProvider`.
- `app.dart` already opens the story behind a tapped notification
  (`openedFromNotificationProvider` → `/story/:id`).

**To enable**

1. Create a Firebase project and add the iOS app (`com.theutahview.app`) and
   the Android app (`com.theutahview.app`).
2. `flutter pub add firebase_core firebase_messaging`
3. `dart pub global activate flutterfire_cli && flutterfire configure --platforms=ios,android`
   (writes `lib/firebase_options.dart`, `ios/Runner/GoogleService-Info.plist`,
   `android/app/google-services.json`).
4. iOS: in Xcode, add the **Push Notifications** capability and **Background
   Modes → Remote notifications**. Create an APNs auth key (.p8) in the Apple
   developer portal and upload it in Firebase → Project settings → Cloud
   Messaging.
5. Implement `FirebasePushNotifications` (sketch in the file's doc comment):
   subscribe to the `new-issue` topic, read `storyId` from
   `getInitialMessage()` / `onMessageOpenedApp`, and ask permission at a
   sensible moment (e.g. after the reader saves their first story, not on
   first launch).
6. Override `pushNotificationsProvider` in `main()` and call `initialize()`.
7. Add a "New issue alerts" switch on the More tab.

**Backend hook (TODO in the Worker)**

When an issue is published, send one FCM HTTP v1 message:

```http
POST https://fcm.googleapis.com/v1/projects/<project-id>/messages:send
Authorization: Bearer <OAuth token for a service account with the firebase.messaging scope>
Content-Type: application/json

{
  "message": {
    "topic": "new-issue",
    "notification": { "title": "The Utah View · October issue", "body": "<lead headline>" },
    "data": { "storyId": "<layout.hero_lead>" }
  }
}
```

Trigger it from the editor's layout save or a dedicated "Publish issue"
action. Store the service-account key as a Worker secret, and record the
last notified issue in D1 so it sends once per issue.

## Google Sign-In to sync saved stories

**Already in the app**

- `lib/core/auth/auth_service.dart` holds the `AuthService` interface, the
  `SignedOutAuthService` v1 implementation, and `googleWebClientId` (the
  website's public OAuth client id).
- `ApiClient.getMe(idToken)` calls `GET /api/me` with
  `Authorization: Bearer <Google ID token>`.
- Bookmarks already live behind `SavedStoriesNotifier`, so a sync layer can
  sit next to it.

**Key point:** request ID tokens with `serverClientId: googleWebClientId`.
The token's audience then matches what the website sends, so the Worker
accepts mobile sign-ins with no backend change.

**To enable**

1. `flutter pub add google_sign_in`
2. In Google Cloud console → APIs & Services → Credentials, using the
   **same project** as the web client `562818410025-…`:
   - **iOS client** for bundle id `com.theutahview.app`. Put its client id in
     `ios/Runner/Info.plist` as `GIDClientID`, and add its *reversed* client
     id as a URL scheme (`CFBundleURLTypes`).
   - **Android client** for package `com.theutahview.app` with the SHA-1 of
     the debug key, the upload key, and the Play app-signing key (Play
     Console → Setup → App signing).
3. Implement `GoogleAuthService`:
   ```dart
   final signIn = GoogleSignIn.instance;
   await signIn.initialize(serverClientId: googleWebClientId);
   final account = await signIn.authenticate();
   final idToken = account.authentication.idToken!;
   await ref.read(apiClientProvider).getMe(idToken);
   ```
4. Add "Sign in to sync" to More and Saved.

**Backend work needed (TODO)**

`GET /api/me` only identifies the user (today it returns 401 without a
token). Nothing stores bookmarks on the server. Proposed endpoints:

```
GET  /api/me/saved            → { "ids": ["story-id", …] }
PUT  /api/me/saved            ← { "ids": ["story-id", …] }
```

The website keeps bookmarks in `localStorage['utv_saved']` (ids only). Sync
should merge (union) local and remote ids, then fetch any stories the device
doesn't have yet.
