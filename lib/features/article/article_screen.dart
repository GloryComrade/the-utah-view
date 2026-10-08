import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/domain/story_filters.dart';
import '../../core/router/navigation.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/article_body.dart';
import '../../shared/widgets/brand.dart';
import '../../shared/widgets/headline_hero.dart';
import '../../shared/widgets/labels.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/story_cards.dart';
import '../../shared/widgets/story_image.dart';
import '../home/widgets/home_sections.dart';
import 'story_detail_provider.dart';
import 'widgets/article_actions.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key, required this.storyId, this.args});

  final String storyId;
  final ArticleRouteArgs? args;

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  final _scroll = ScrollController();
  final _progress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final max = position.maxScrollExtent;
    _progress.value = max <= 0 ? 0 : (position.pixels / max).clamp(0.0, 1.0);
  }

  void _open(Story story, Object? heroTag) => context.openStory(story, heroTag);

  @override
  Widget build(BuildContext context) {
    final id = widget.storyId;
    final detail = ref.watch(storyDetailProvider(id));
    final story =
        widget.args?.preview ??
        ref.watch(storyIndexProvider.select((index) => index?[id])) ??
        detail.value?.toStory();
    final layout = ref.watch(layoutProvider).value;
    final heroImage = layout?.heroLead == id ? layout?.heroImageUrl : null;
    final scale = ref.watch(settingsProvider.select((s) => s.readingScale));
    final canPop = GoRouter.of(context).canPop();
    final gutter = context.gutter;
    const readingWidth = Insets.maxReadingWidth + 2 * Insets.gutterTablet;

    final notFound =
        detail.hasError &&
        !detail.hasValue &&
        detail.error is ApiException &&
        (detail.error! as ApiException).kind == ApiErrorKind.notFound;

    Widget reading(Widget child) => ContentWidth(
      maxWidth: readingWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: child,
      ),
    );

    final Widget bodySliver;
    if (detail.value case final value?) {
      bodySliver = SliverToBoxAdapter(
        child: reading(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (value.body.trim().isEmpty)
                Text(
                  'The full text of this story isn’t available yet.',
                  style: context.news.summary,
                )
              else
                SelectionArea(
                  child: ArticleBody(
                    html: value.body,
                    scale: scale,
                    onTapUrl: context.followArticleLink,
                  ),
                ),
              const SizedBox(height: 12),
              Semantics(
                label: 'End of article',
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox.square(
                    dimension: 9,
                    child: ColoredBox(color: context.palette.accentFill),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (detail.hasError && !detail.isLoading) {
      bodySliver = SliverToBoxAdapter(
        child: notFound
            ? MessageView(
                icon: Icons.article_outlined,
                title: 'Story not available',
                message: 'It may have been moved or unpublished.',
                actionLabel: 'Go to Home',
                onAction: () => context.goNamed(RouteNames.home),
              )
            : MessageView.error(
                detail.error!,
                onRetry: () => ref.invalidate(storyDetailProvider(id)),
              ),
      );
    } else {
      bodySliver = SliverToBoxAdapter(child: reading(const _BodySkeleton()));
    }

    final related = moreFromThisIssue(
      storyId: id,
      storyDate: story?.date ?? '',
      stories: ref.watch(storiesProvider).value ?? const [],
      layout: layout,
    );

    return PopScope(
      // A deep link can open an article with nothing beneath it; Back then
      // goes to the front page instead of leaving the app.
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(RouteNames.home);
      },
      child: Scaffold(
        appBar: AppBar(
          // Tap the logo to return to the front page (there may be nothing to
          // pop back to on a cold-opened / shared link). The default Back
          // button still shows when the article was opened from within the app.
          centerTitle: true,
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.goNamed(RouteNames.home),
            child: Semantics(
              button: true,
              label: 'The Utah View, front page',
              child: const UtvLogo(size: 30),
            ),
          ),
          actions: [
            const TextSizeButton(),
            SaveStoryButton(storyId: id, detail: detail.value),
            ShareStoryButton(storyId: id, title: story?.title),
            const SizedBox(width: 4),
          ],
          bottom: ReadingProgressBar(progress: _progress),
        ),
        body: CustomScrollView(
          controller: _scroll,
          slivers: [
            if (heroImage != null)
              SliverToBoxAdapter(
                child: ContentWidth(
                  maxWidth: 900,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: storyImageHeroTag(id),
                        child: StoryImage(
                          url: heroImage,
                          semanticLabel:
                              layout?.heroCenterCaption.isNotEmpty == true
                              ? layout!.heroCenterCaption
                              : null,
                        ),
                      ),
                      if (layout?.heroCenterCaption.isNotEmpty == true)
                        Padding(
                          padding: EdgeInsets.fromLTRB(gutter, 6, gutter, 0),
                          child: Text(
                            layout!.heroCenterCaption,
                            style: context.news.meta.copyWith(fontSize: 11.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: reading(
                story == null
                    ? (notFound
                          ? const SizedBox(height: 24)
                          : const _HeaderSkeleton())
                    : _ArticleHeader(
                        story: story,
                        heroTag: widget.args?.heroTag,
                      ),
              ),
            ),
            bodySliver,
            if (related.isNotEmpty && !notFound)
              SliverToBoxAdapter(
                child: reading(
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: _MoreFromThisIssue(
                      stories: related,
                      slot: 'related/$id',
                      onOpen: _open,
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 32 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleHeader extends StatelessWidget {
  const _ArticleHeader({required this.story, this.heroTag});

  final Story story;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final title = context.isTablet
        ? news.articleTitle.copyWith(fontSize: 40)
        : news.articleTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        SectionLabel(story.region.isEmpty ? 'Analysis' : story.region),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: HeadlineHero(tag: heroTag, text: story.title, style: title),
        ),
        if (story.summary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(story.summary, style: news.articleSummary),
        ],
        const SizedBox(height: 14),
        Byline.forStory(story),
        const SizedBox(height: 18),
        const ThinRule(),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _MoreFromThisIssue extends StatelessWidget {
  const _MoreFromThisIssue({
    required this.stories,
    required this.slot,
    required this.onOpen,
  });

  final List<Story> stories;
  final String slot;
  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BlockHeader(title: 'More from this issue'),
        const SizedBox(height: 8),
        RuledStoryList(
          stories: stories,
          slot: slot,
          onOpen: onOpen,
          showSummary: false,
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 24, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonLine(widthFactor: 0.25, height: 10),
          SizedBox(height: 10),
          SkeletonLine(height: 30),
          SkeletonLine(widthFactor: 0.8, height: 30),
          SizedBox(height: 12),
          SkeletonLine(height: 16),
          SkeletonLine(widthFactor: 0.6, height: 16),
        ],
      ),
    );
  }
}

class _BodySkeleton extends StatelessWidget {
  const _BodySkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading story',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var p = 0; p < 3; p++) ...const [
              SkeletonLine(height: 14),
              SkeletonLine(height: 14),
              SkeletonLine(height: 14),
              SkeletonLine(widthFactor: 0.7, height: 14),
              SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
