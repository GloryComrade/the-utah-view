import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/domain/story_filters.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/labels.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/story_cards.dart';

/// Stories in one category (website filter rule), or the whole archive.
class SectionStoriesScreen extends ConsumerWidget {
  const SectionStoriesScreen({super.key, required this.categoryName})
    : archive = false;

  const SectionStoriesScreen.archive({super.key})
    : categoryName = 'Archive',
      archive = true;

  final String categoryName;
  final bool archive;

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(storiesProvider.notifier).refresh();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category =
        ref
            .watch(navCategoriesProvider)
            .firstWhereOrNull((c) => c.text == categoryName) ??
        NavCategory(text: categoryName);
    final storiesAsync = ref.watch(storiesProvider);
    final all = storiesAsync.value;
    final stories = all == null
        ? null
        : archive
        ? archiveStories(all)
        : storiesForCategory(all, category);
    final gutter = context.gutter;
    final news = context.news;
    // Region pages don't need a red kicker on every story; mixed lists do.
    final showLabels = archive || category.section;

    final header = Padding(
      padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(
            archive
                ? 'Every issue'
                : category.section
                ? 'Section'
                : 'Region',
            muted: true,
          ),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(category.text, style: news.pageTitle),
          ),
          if (stories != null) ...[
            const SizedBox(height: 4),
            Text(
              '${stories.length} article${stories.length == 1 ? '' : 's'}',
              style: news.meta,
            ),
          ],
          const SizedBox(height: 16),
          const ThickRule(),
        ],
      ),
    );

    final List<Widget> content;
    if (stories != null) {
      content = stories.isEmpty
          ? [
              const SliverFillRemaining(
                hasScrollBody: false,
                child: MessageView(
                  icon: Icons.inbox_outlined,
                  title: 'No stories here yet',
                  message:
                      'New stories appear here when an issue is '
                      'published.',
                ),
              ),
            ]
          : [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 32),
                sliver: SliverList.builder(
                  itemCount: stories.length,
                  itemBuilder: (context, i) {
                    final story = stories[i];
                    final month = formatIssueMonth(story.date);
                    final newIssue =
                        archive &&
                        (i == 0 ||
                            formatIssueMonth(stories[i - 1].date) != month);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (newIssue && month.isNotEmpty) ...[
                          if (i > 0) const SizedBox(height: 28),
                          AccentHeader(month),
                        ] else if (i > 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Insets.storyGap,
                            ),
                            child: ThinRule(),
                          ),
                        StoryTile(
                          story: story,
                          slot: 'list/$categoryName',
                          size: StoryTileSize.small,
                          showLabel: showLabels,
                          showDate: true,
                          onOpen: (s, tag) => context.openStory(s, tag),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ];
    } else if (storiesAsync.hasError) {
      content = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView.error(
            storiesAsync.error!,
            onRetry: () => ref.invalidate(storiesProvider),
          ),
        ),
      ];
    } else {
      content = [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
          sliver: const SliverToBoxAdapter(
            child: FeedSkeleton(leadFirst: false, count: 5),
          ),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator.adaptive(
        onRefresh: () => _refresh(context, ref),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ContentWidth(maxWidth: 760, child: header),
            ),
            ...content.map(
              (sliver) =>
                  SliverCrossAxisConstrained(maxExtent: 760, sliver: sliver),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centers a sliver and caps its width (readable lists on tablets).
class SliverCrossAxisConstrained extends StatelessWidget {
  const SliverCrossAxisConstrained({
    super.key,
    required this.maxExtent,
    required this.sliver,
  });

  final double maxExtent;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = width > maxExtent ? (width - maxExtent) / 2 : 0.0;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: side),
      sliver: sliver,
    );
  }
}
