import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/article/article_screen.dart';
import '../../features/gallery/widget_gallery_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/more/page_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/sections/section_stories_screen.dart';
import '../../features/sections/sections_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/state_views.dart';
import 'deep_links.dart';
import 'navigation.dart';

/// Turns website URLs (universal links, app links, `theutahview://`) into
/// app locations. Returns null for the app's own routes.
///
/// Stories open as `/home/story/:id`, so a cold-start link shows the article
/// with Home underneath and Back stays in the app.
String? redirectWebsiteLinks(Uri uri) {
  final path = uri.path;
  final websitePath =
      path.isEmpty ||
      path == '/' ||
      path.endsWith('.html') ||
      path == '/article' ||
      path == '/page';
  if (!websitePath) return null;
  String enc(String s) => Uri.encodeComponent(s);
  return switch (DeepLinks.parse(uri) ?? const HomeTarget()) {
    HomeTarget() => '/home',
    StoryTarget(:final id) => '/home/story/${enc(id)}',
    PageTarget(:final slug) => '/more/page/${enc(slug)}',
    CategoryTarget(:final name) => '/sections/c/${enc(name)}',
    ArchiveTarget() => '/sections/archive',
    SavedTarget() => '/saved',
  };
}

Widget _article(BuildContext context, GoRouterState state) {
  final extra = state.extra;
  return ArticleScreen(
    storyId: state.pathParameters['id'] ?? '',
    args: extra is ArticleRouteArgs ? extra : null,
  );
}

GoRouter buildRouter({String initialLocation = '/home'}) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    redirect: (context, state) => redirectWebsiteLinks(state.uri),
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: MessageView(
        icon: Icons.travel_explore_rounded,
        title: 'Page not found',
        message: "We couldn't find that link in The Utah View.",
        actionLabel: 'Go to Home',
        onAction: () => context.goNamed(RouteNames.home),
      ),
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'story/:id',
                    name: RouteNames.homeStory,
                    parentNavigatorKey: rootKey,
                    builder: _article,
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sections',
                name: RouteNames.sections,
                builder: (context, state) => const SectionsScreen(),
                routes: [
                  GoRoute(
                    path: 'archive',
                    name: RouteNames.archive,
                    builder: (context, state) =>
                        const SectionStoriesScreen.archive(),
                  ),
                  GoRoute(
                    path: 'c/:name',
                    name: RouteNames.section,
                    builder: (context, state) => SectionStoriesScreen(
                      categoryName: state.pathParameters['name'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                name: RouteNames.saved,
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                name: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'page/:slug',
                    name: RouteNames.page,
                    builder: (context, state) =>
                        PageScreen(slug: state.pathParameters['slug'] ?? ''),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/story/:id',
        name: RouteNames.story,
        parentNavigatorKey: rootKey,
        builder: _article,
      ),
      GoRoute(
        path: '/search',
        name: RouteNames.search,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/gallery',
        name: RouteNames.gallery,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const WidgetGalleryScreen(),
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter();
  ref.onDispose(router.dispose);
  return router;
});
