import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/api/providers.dart';
import 'core/notifications/push_notifications.dart';
import 'core/storage/hive_stores.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  final stores = await openHiveStores();

  // Push notifications for new stories (FCM). Tolerant of failure so the app
  // still launches if Firebase/APNs isn't available.
  final push = FirebasePushNotifications();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } on Object catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        appStoresProvider.overrideWithValue(stores),
        pushNotificationsProvider.overrideWithValue(push),
      ],
      child: const UtahViewApp(),
    ),
  );
  unawaited(push.initialize());
}

/// Newsreader and Archivo Black are SIL OFL fonts; list them on the licenses
/// page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in [
      ('Newsreader', 'OFL-Newsreader.txt'),
      ('Archivo Black', 'ArchivoBlack-OFL.txt'),
    ]) {
      final text = await rootBundle.loadString('assets/licenses/$file');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
