import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/auth/reader_account.dart';
import 'core/notifications/push_notifications.dart';
import 'core/router/app_router.dart';
import 'core/router/navigation.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/theme.dart';
import 'shared/widgets/skip_link.dart';

class UtahViewApp extends ConsumerWidget {
  const UtahViewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final highContrast = ref.watch(
      settingsProvider.select((s) => s.highContrast),
    );
    final reduceMotion = ref.watch(
      settingsProvider.select((s) => s.reduceMotion),
    );
    final router = ref.watch(routerProvider);

    // Keep bookmarks in step with the reader's account: on sign-in, on
    // launch while signed in, and after every change.
    ref.watch(savedSyncProvider);

    // Phase 2: open the story behind a tapped "new issue" notification.
    ref.listen(openedFromNotificationProvider, (_, next) {
      if (next case AsyncData(:final value)) {
        router.pushNamed(RouteNames.story, pathParameters: {'id': value});
      }
    });

    return MaterialApp.router(
      title: 'The Utah View',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        highContrast: highContrast,
        reduceMotion: reduceMotion,
      ),
      darkTheme: AppTheme.dark(
        highContrast: highContrast,
        reduceMotion: reduceMotion,
      ),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Honor the in-app toggle and the OS reduce-motion setting.
        final reduce = reduceMotion || media.disableAnimations;
        return MediaQuery(
          data: media.copyWith(disableAnimations: reduce),
          child: withSkipLink(child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
