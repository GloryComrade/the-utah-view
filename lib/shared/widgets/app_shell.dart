import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

/// Which tab was re-tapped (and a counter so repeat taps still notify).
/// Screens listen and scroll back to the top, like every news app.
class TabReselectNotifier extends Notifier<(int, int)> {
  @override
  (int, int) build() => (-1, 0);

  void reselect(int tab) => state = (tab, state.$2 + 1);
}

final tabReselectProvider = NotifierProvider<TabReselectNotifier, (int, int)>(
  TabReselectNotifier.new,
);

/// Scrolls [controller] to the top whenever [tab] is re-tapped.
void listenForTabReselect(WidgetRef ref, int tab, ScrollController controller) {
  ref.listen(tabReselectProvider, (_, next) {
    if (next.$1 == tab && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  });
}

/// The four-tab frame: Home, Sections, Saved, More.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        // Foreground, or the bar's own background would paint over it.
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.palette.rule)),
        ),
        // Tab labels stay legible at large text sizes without overflowing.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: NavigationBar(
            selectedIndex: current,
            onDestinationSelected: (index) {
              if (index == current) {
                ref.read(tabReselectProvider.notifier).reselect(index);
              }
              navigationShell.goBranch(
                index,
                initialLocation: index == current,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_agenda_outlined),
                selectedIcon: Icon(Icons.view_agenda),
                label: 'Sections',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_rounded),
                selectedIcon: Icon(Icons.menu_open_rounded),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
