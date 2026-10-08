import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/api/providers.dart';
import 'core/auth/google_auth.dart';
import 'core/auth/reader_account.dart';
import 'core/notifications/push_notifications.dart';
import 'core/router/app_router.dart';
import 'core/router/navigation.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/theme.dart';
import 'features/saved/saved_stories.dart';

class UtahViewApp extends ConsumerWidget {
  const UtahViewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final router = ref.watch(routerProvider);

    // Keep local bookmarks pushed to the server while signed in, and merge the
    // server's set in when a Google sign-in completes.
    ref.watch(savedSyncProvider);
    ref.listen(authControllerProvider, (_, next) {
      final u = next.value;
      if (u != null && u.idToken.isNotEmpty) {
        unawaited(mergeSavedStories(ref.read(apiClientProvider), ref.read(savedStoriesProvider.notifier), ref.read(savedStoriesProvider), u.idToken));
      }
    });

    // Phase 2: open the story behind a tapped "new issue" notification.
    ref.listen(openedFromNotificationProvider, (_, next) {
      if (next case AsyncData(:final value)) {
        router.pushNamed(RouteNames.story, pathParameters: {'id': value});
      }
    });

    return MaterialApp.router(
      title: 'The Utah View',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
