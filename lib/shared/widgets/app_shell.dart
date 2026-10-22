import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/navigation.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/theme.dart';
import 'accessibility_panel.dart';
import 'brand.dart';

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
      if (ref.read(settingsProvider).reduceMotion) {
        controller.jumpTo(0);
      } else {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  });
}

/// The four primary destinations, shared by the phone bottom bar and the
/// desktop top-nav menu: (index, label, icon, selected icon).
const _destinations = <(int, String, IconData, IconData)>[
  (0, 'Home', Icons.newspaper_outlined, Icons.newspaper),
  (1, 'Sections', Icons.view_agenda_outlined, Icons.view_agenda),
  (2, 'Saved', Icons.bookmark_border_rounded, Icons.bookmark_rounded),
  (3, 'More', Icons.menu_rounded, Icons.menu_open_rounded),
];

/// Regions and topics offered in the desktop menu; they deep-link to the
/// Sections category view (same filter the footer and app use).
const _regions = <String>[
  'The Americas',
  'Europe',
  'Asia-Pacific',
  'Middle East',
  'Africa',
];
const _topics = <String>['Analysis', 'Opinion', 'Data'];

/// The app frame. On phones it's the four-tab bottom bar; on tablet/desktop
/// the bottom bar is dropped and navigation moves to a slim top strip — a
/// single dropdown menu beside a search button (no per-item icons).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(WidgetRef ref, int index) {
    final current = navigationShell.currentIndex;
    if (index == current) {
      ref.read(tabReselectProvider.notifier).reselect(index);
    }
    navigationShell.goBranch(index, initialLocation: index == current);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= Insets.tabletBreakpoint;
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: wide
          ? Column(
              children: [
                _DesktopTopNav(
                  currentIndex: current,
                  onSelect: (i) => _select(ref, i),
                ),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: wide
          ? null
          : _BottomBar(currentIndex: current, onSelect: (i) => _select(ref, i)),
    );
  }
}

/// The phone bottom navigation bar.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Foreground, or the bar's own background would paint over it.
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.palette.rule)),
      ),
      // Tab labels stay legible at large text sizes without overflowing.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          destinations: [
            for (final (_, label, icon, selectedIcon) in _destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selectedIcon),
                label: label,
              ),
          ],
        ),
      ),
    );
  }
}

/// The tablet/desktop top strip: wordmark (links Home) · menu dropdown · search.
class _DesktopTopNav extends StatelessWidget {
  const _DesktopTopNav({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.rule)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'The Utah View, home',
                    child: InkWell(
                      onTap: () => onSelect(0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Lockup(logoSize: 22, wordmarkSize: 15),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _NavMenu(currentIndex: currentIndex, onSelect: onSelect),
                  const SizedBox(width: 4),
                  const AccessibilityButton(),
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search_rounded),
                    onPressed: context.openSearch,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The single dropdown for the desktop top strip: the four destinations, then
/// regions and topics that open the Sections category view. Text only.
class _NavMenu extends StatelessWidget {
  const _NavMenu({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  PopupMenuItem<VoidCallback> _header(BuildContext context, String text) {
    return PopupMenuItem<VoidCallback>(
      enabled: false,
      height: 30,
      child: Text(text.toUpperCase(), style: context.news.sectionLabelMuted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Menu',
      position: PopupMenuPosition.under,
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        for (final (index, label, _, _) in _destinations)
          PopupMenuItem<VoidCallback>(
            value: () => onSelect(index),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: index == currentIndex
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        const PopupMenuDivider(),
        _header(context, 'Regions'),
        for (final name in _regions)
          PopupMenuItem<VoidCallback>(
            value: () => context.openCategory(name),
            child: Text(name),
          ),
        const PopupMenuDivider(),
        _header(context, 'Topics'),
        for (final name in _topics)
          PopupMenuItem<VoidCallback>(
            value: () => context.openCategory(name),
            child: Text(name),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<VoidCallback>(
          value: () => context.goToArchive(),
          child: const Text('Full archive'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Menu', style: news.blockTitle),
            const Icon(Icons.arrow_drop_down_rounded, size: 22),
          ],
        ),
      ),
    );
  }
}
