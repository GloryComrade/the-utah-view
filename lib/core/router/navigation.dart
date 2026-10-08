import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../api/models/models.dart';
import 'deep_links.dart';

/// Route names, so call sites never build paths by hand (path parameters
/// like "The Americas" and "About Us" need encoding).
abstract final class RouteNames {
  static const home = 'home';
  static const homeStory = 'home-story';
  static const sections = 'sections';
  static const archive = 'archive';
  static const section = 'section';
  static const saved = 'saved';
  static const more = 'more';
  static const page = 'page';
  static const story = 'story';
  static const search = 'search';
  static const gallery = 'gallery';
}

/// Extra data handed to the article route by the card that was tapped.
class ArticleRouteArgs {
  const ArticleRouteArgs({this.heroTag, this.preview});

  /// Tag of the tapped headline, so it can fly into the article.
  final Object? heroTag;

  /// The list-view story, so the header renders before the body loads.
  final Story? preview;
}

extension AppNavigation on BuildContext {
  /// Opens a story over the tabs (full-screen reading, like WSJ).
  void openStory(Story story, [Object? heroTag]) => pushNamed(
    RouteNames.story,
    pathParameters: {'id': story.id},
    extra: ArticleRouteArgs(heroTag: heroTag, preview: story),
  );

  void openStoryById(String id) =>
      pushNamed(RouteNames.story, pathParameters: {'id': id});

  void openCategory(String name) =>
      pushNamed(RouteNames.section, pathParameters: {'name': name});

  void openArchive() => pushNamed(RouteNames.archive);

  /// Switches to the Sections tab and shows the archive ("View full issue").
  void goToArchive() => goNamed(RouteNames.archive);

  void openPage(String slug) =>
      pushNamed(RouteNames.page, pathParameters: {'slug': slug});

  void openSearch() => pushNamed(RouteNames.search);

  /// Handles a link tapped inside article HTML. Links to other stories open
  /// in the app; everything else returns false so it opens in the browser.
  bool followArticleLink(String href) {
    if (DeepLinks.parseLink(href) case StoryTarget(:final id)) {
      openStoryById(id);
      return true;
    }
    return false;
  }
}
