import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/briefing_ticker.dart';
import '../../shared/widgets/labels.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/story_cards.dart';
import '../../shared/widgets/subscribe_card.dart';
import 'home_feed.dart';
import 'widgets/home_sections.dart';
import 'widgets/masthead_header.dart';

/// The front page ("Top News").
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.today});

  /// Fixed date for screenshots and tests; defaults to now.
  final DateTime? today;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      await Future.wait([
        ref.read(storiesProvider.notifier).refresh(),
        ref.read(layoutProvider.notifier).refresh(),
        ref.read(siteConfigProvider.notifier).refresh(),
      ]);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.kind == ApiErrorKind.offline
                  ? "You're offline. Showing the last saved edition."
                  : "Couldn't refresh. Showing the last saved edition.",
            ),
          ),
        );
    }
  }

  void _open(Story story, Object? heroTag) => context.openStory(story, heroTag);

  @override
  Widget build(BuildContext context) {
    listenForTabReselect(ref, 0, _scroll);
    final feed = ref.watch(homeFeedProvider);
    final site = ref.watch(siteConfigProvider).value;
    final theme = Theme.of(context);
    final padding = MediaQuery.paddingOf(context);
    final tablet = MediaQuery.sizeOf(context).width >= Insets.tabletBreakpoint;

    final header = SliverPersistentHeader(
      pinned: true,
      delegate: MastheadHeaderDelegate(
        topPadding: padding.top,
        textScaler: MediaQuery.textScalerOf(context),
        date: widget.today ?? DateTime.now(),
        onSearch: context.openSearch,
        background: context.palette.background,
      ),
    );

    final List<Widget> body = switch (feed) {
      AsyncData(:final value) when value.lead == null => [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView(
            icon: Icons.newspaper_outlined,
            title: 'No stories yet',
            message:
                'The next issue will appear here as soon as it is '
                'published.',
          ),
        ),
      ],
      AsyncData(:final value) => [
        if (value.ticker.trim().isNotEmpty)
          SliverToBoxAdapter(child: BriefingTicker(text: value.ticker)),
        if (tablet)
          SliverToBoxAdapter(
            child: _TabletFrontPage(feed: value, onOpen: _open),
          )
        else
          SliverList(
            delegate: SliverChildListDelegate(_phoneFrontPage(context, value)),
          ),
        SliverToBoxAdapter(child: SubscribeCard.fromConfig(site)),
        SliverToBoxAdapter(
          child: HomeFooter(
            copyright: (site ?? const SiteConfig()).copyrightLine,
          ),
        ),
      ],
      AsyncError(:final error) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView.error(
            error,
            onRetry: () {
              ref
                ..invalidate(storiesProvider)
                ..invalidate(layoutProvider);
            },
          ),
        ),
      ],
      _ => [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(context.gutter, 24, context.gutter, 24),
          sliver: const SliverToBoxAdapter(child: FeedSkeleton()),
        ),
      ],
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.appBarTheme.systemOverlayStyle ?? SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          edgeOffset: padding.top + MastheadHeaderDelegate.toolbarHeight,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [header, ...body],
          ),
        ),
      ),
    );
  }

  List<Widget> _phoneFrontPage(BuildContext context, HomeFeed feed) {
    final gutter = context.gutter;
    Widget padded(Widget child) => Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: child,
    );
    const ruled = Padding(
      padding: EdgeInsets.symmetric(vertical: Insets.storyGap),
      child: ThinRule(),
    );

    // Each homepage block, built once. Order and visibility are editor-driven
    // (see HomeFeed.orderedSections / isHidden); labels come from the config.
    final sections = <String, Widget>{};

    final heroChildren = <Widget>[
      SizedBox(height: feed.leadImageUrl == null ? 22 : 0),
      if (feed.lead case final lead?)
        LeadStoryCard(
          story: lead,
          slot: 'home/lead',
          onOpen: _open,
          imageUrl: feed.leadImageUrl,
          caption: feed.leadImageCaption,
          textPadding: EdgeInsets.symmetric(horizontal: gutter),
        ),
      for (final story in feed.topStories)
        padded(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ruled,
              StoryTile(story: story, slot: 'home/top', onOpen: _open),
            ],
          ),
        ),
      if (feed.fromThisIssue.isNotEmpty)
        padded(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              const ThinRule(),
              const SizedBox(height: 18),
              FromThisIssueBlock(
                stories: feed.fromThisIssue,
                onOpen: _open,
                title: feed.labelFor('fromThisIssue', 'From This Issue'),
              ),
            ],
          ),
        ),
      if (feed.latest.isNotEmpty)
        padded(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Insets.blockGap),
              const BlockHeader(title: 'Latest'),
              const SizedBox(height: 10),
              RuledStoryList(
                stories: feed.latest,
                slot: 'home/latest',
                onOpen: _open,
                showDate: true,
              ),
            ],
          ),
        ),
    ];
    if (feed.lead != null || feed.latest.isNotEmpty) {
      sections['hero'] = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: heroChildren,
      );
    }
    if (feed.editorial.isNotEmpty) {
      sections['editorial'] = padded(
        Padding(
          padding: const EdgeInsets.only(top: Insets.blockGap),
          child: EditorialBlock(
            stories: feed.editorial,
            onOpen: _open,
            title: feed.labelFor('editorial', 'Editorial & Opinion'),
          ),
        ),
      );
    }
    if (feed.regions.isNotEmpty) {
      sections['regions'] = Padding(
        padding: const EdgeInsets.only(top: Insets.blockGap),
        child: AroundTheWorldBlock(
          regions: feed.regions,
          onOpen: _open,
          gutter: gutter,
          title: feed.labelFor('regions', 'Around the World'),
        ),
      );
    }
    if (feed.featured.isNotEmpty) {
      sections['featured'] = padded(
        Padding(
          padding: const EdgeInsets.only(top: Insets.blockGap),
          child: InThisIssueBlock(
            stories: feed.featured,
            onOpen: _open,
            onViewAll: () => _openArchive(context),
            title: feed.labelFor('featured', 'In This Issue'),
          ),
        ),
      );
    }
    if (feed.utahLens.isNotEmpty) {
      sections['utahLens'] = padded(
        Padding(
          padding: const EdgeInsets.only(top: Insets.blockGap),
          child: SidebarBlock(
            title: feed.labelFor('utahLens', 'The Utah Lens'),
            stories: feed.utahLens,
            slot: 'home/utah',
            onOpen: _open,
          ),
        ),
      );
    }
    if (feed.dataBrief.isNotEmpty) {
      sections['dataBrief'] = padded(
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: SidebarBlock(
            title: feed.labelFor('dataBrief', 'Data Brief'),
            stories: feed.dataBrief,
            slot: 'home/data',
            onOpen: _open,
          ),
        ),
      );
    }

    final hidden = feed.hiddenSections.toSet();
    final order = feed.orderedSections;
    final shown = <String>{};
    return [
      for (final id in order)
        if (!hidden.contains(id) && sections[id] != null && shown.add(id))
          sections[id]!,
      // Any section the order doesn't name (e.g. a newly added one) still shows.
      for (final entry in sections.entries)
        if (!order.contains(entry.key) && !hidden.contains(entry.key))
          entry.value,
      const SizedBox(height: Insets.blockGap),
    ];
  }
}

/// The archive lives in the Sections tab; jump there.
void _openArchive(BuildContext context) {
  context.goToArchive();
}

/// Two-column front page for tablets, modeled on the website's grid.
class _TabletFrontPage extends StatelessWidget {
  const _TabletFrontPage({required this.feed, required this.onOpen});

  final HomeFeed feed;
  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    const gutter = Insets.gutterTablet;
    final lead = feed.lead;

    final leadColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lead != null)
          LeadStoryCard(
            story: lead,
            slot: 'home/lead',
            onOpen: onOpen,
            imageUrl: feed.leadImageUrl,
            caption: feed.leadImageCaption,
            headlineStyle: news.headlineXL.copyWith(fontSize: 38),
          ),
        if (feed.topStories.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Insets.storyGap),
            child: ThinRule(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, story) in feed.topStories.indexed) ...[
                if (i > 0) const SizedBox(width: 24),
                Expanded(
                  child: i == 0
                      ? StoryTile(
                          story: story,
                          slot: 'home/top',
                          onOpen: onOpen,
                        )
                      : LeftRuled(
                          child: StoryTile(
                            story: story,
                            slot: 'home/top',
                            onOpen: onOpen,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
        if (feed.latest.isNotEmpty) ...[
          const SizedBox(height: Insets.blockGap),
          const BlockHeader(title: 'Latest'),
          RuledStoryList(
            stories: feed.latest,
            slot: 'home/latest',
            onOpen: onOpen,
            showDate: true,
          ),
        ],
      ],
    );

    final sidebar = <Widget>[
      if (feed.utahLens.isNotEmpty && !feed.isHidden('utahLens'))
        SidebarBlock(
          title: feed.labelFor('utahLens', 'The Utah Lens'),
          stories: feed.utahLens,
          slot: 'home/utah',
          onOpen: onOpen,
        ),
      if (feed.dataBrief.isNotEmpty && !feed.isHidden('dataBrief'))
        SidebarBlock(
          title: feed.labelFor('dataBrief', 'Data Brief'),
          stories: feed.dataBrief,
          slot: 'home/data',
          onOpen: onOpen,
        ),
    ];

    return ContentWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: leadColumn),
                if (feed.fromThisIssue.isNotEmpty) ...[
                  const SizedBox(width: 28),
                  Expanded(
                    child: LeftRuled(
                      child: FromThisIssueBlock(
                        stories: feed.fromThisIssue,
                        onOpen: onOpen,
                        title: feed.labelFor('fromThisIssue', 'From This Issue'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (feed.editorial.isNotEmpty && !feed.isHidden('editorial'))
            Padding(
              padding: const EdgeInsets.fromLTRB(
                gutter,
                Insets.blockGap,
                gutter,
                0,
              ),
              child: EditorialBlock(
                stories: feed.editorial,
                onOpen: onOpen,
                wide: true,
                title: feed.labelFor('editorial', 'Editorial & Opinion'),
              ),
            ),
          if (feed.regions.isNotEmpty && !feed.isHidden('regions'))
            Padding(
              padding: const EdgeInsets.only(top: Insets.blockGap),
              child: AroundTheWorldBlock(
                regions: feed.regions,
                onOpen: onOpen,
                gutter: gutter,
                title: feed.labelFor('regions', 'Around the World'),
              ),
            ),
          if (feed.featured.isNotEmpty || sidebar.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                gutter,
                Insets.blockGap,
                gutter,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: feed.featured.isEmpty || feed.isHidden('featured')
                        ? const SizedBox.shrink()
                        : InThisIssueBlock(
                            stories: feed.featured,
                            onOpen: onOpen,
                            onViewAll: () => _openArchive(context),
                            title: feed.labelFor('featured', 'In This Issue'),
                          ),
                  ),
                  if (sidebar.isNotEmpty) ...[
                    const SizedBox(width: 28),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: LeftRuled(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final (i, block) in sidebar.indexed) ...[
                                if (i > 0) const SizedBox(height: 28),
                                block,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: Insets.blockGap),
        ],
      ),
    );
  }
}
