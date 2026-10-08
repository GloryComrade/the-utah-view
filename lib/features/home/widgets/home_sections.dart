import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/models/models.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/links.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/labels.dart';
import '../../../shared/widgets/rules.dart';
import '../../../shared/widgets/story_cards.dart';

/// Stories stacked with thin rules between them.
class RuledStoryList extends StatelessWidget {
  const RuledStoryList({
    super.key,
    required this.stories,
    required this.slot,
    required this.onOpen,
    this.size = StoryTileSize.small,
    this.showLabel = true,
    this.showSummary = true,
    this.showByline = true,
    this.showDate = false,
    this.summaryMaxLines,
    this.lightRules = false,
  });

  final List<Story> stories;
  final String slot;
  final OpenStory onOpen;
  final StoryTileSize size;
  final bool showLabel;
  final bool showSummary;
  final bool showByline;
  final bool showDate;
  final int? summaryMaxLines;
  final bool lightRules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, story) in stories.indexed) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: lightRules ? 12 : Insets.storyGap,
              ),
              child: ThinRule(light: lightRules),
            ),
          StoryTile(
            story: story,
            slot: slot,
            onOpen: onOpen,
            size: size,
            showLabel: showLabel,
            showSummary: showSummary,
            showByline: showByline,
            showDate: showDate,
            summaryMaxLines: summaryMaxLines,
          ),
        ],
      ],
    );
  }
}

/// A column with a thin rule down its left edge (tablet sidebars).
class LeftRuled extends StatelessWidget {
  const LeftRuled({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: context.palette.rule)),
      ),
      child: Padding(padding: const EdgeInsets.only(left: 24), child: child),
    );
  }
}

/// `hero_right`: a gray "FROM THIS ISSUE" kicker over a ruled list.
class FromThisIssueBlock extends StatelessWidget {
  const FromThisIssueBlock({
    super.key,
    required this.stories,
    required this.onOpen,
    this.title = 'From This Issue',
  });

  final List<Story> stories;
  final OpenStory onOpen;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionLabel(title, muted: true),
        ),
        const SizedBox(height: 12),
        RuledStoryList(
          stories: stories,
          slot: 'home/right',
          onOpen: onOpen,
          showLabel: false,
        ),
      ],
    );
  }
}

/// "Editorial & Opinion": the first piece large, the rest compact.
class EditorialBlock extends StatelessWidget {
  const EditorialBlock({
    super.key,
    required this.stories,
    required this.onOpen,
    this.wide = false,
    this.title = 'Editorial & Opinion',
  });

  final List<Story> stories;
  final OpenStory onOpen;
  final String title;

  /// Side-by-side on tablets.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final main = StoryTile(
      story: stories.first,
      slot: 'home/editorial',
      onOpen: onOpen,
      size: StoryTileSize.large,
    );
    final rest = stories.skip(1).toList();
    final more = rest.isEmpty
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: const SectionLabel('More Opinion', muted: true),
              ),
              const SizedBox(height: 12),
              RuledStoryList(
                stories: rest,
                slot: 'home/editorial',
                onOpen: onOpen,
                showLabel: false,
                summaryMaxLines: 3,
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlockHeader(title: title),
        const SizedBox(height: 10),
        if (wide && more != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: main),
              const SizedBox(width: 28),
              Expanded(flex: 2, child: LeftRuled(child: more)),
            ],
          )
        else ...[
          main,
          if (more != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Insets.storyGap),
              child: ThinRule(),
            ),
            more,
          ],
        ],
      ],
    );
  }
}

/// "Around the World": one story per region. A swipeable strip on phones,
/// five columns on wide screens.
class AroundTheWorldBlock extends StatelessWidget {
  const AroundTheWorldBlock({
    super.key,
    required this.regions,
    required this.onOpen,
    required this.gutter,
    this.title = 'Around the World',
  });

  final List<(String, Story)> regions;
  final OpenStory onOpen;
  final double gutter;
  final String title;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    Widget card((String, Story) entry) => RegionStoryCard(
      region: entry.$1,
      story: entry.$2,
      slot: 'home/region',
      onOpen: onOpen,
    );

    final Widget body;
    if (width >= 1000 && regions.length > 1) {
      body = Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, entry) in regions.indexed) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ColumnRule(),
                  ),
                Expanded(child: card(entry)),
              ],
            ],
          ),
        ),
      );
    } else {
      final cardWidth = (width * 0.74).clamp(220.0, 300.0);
      body = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, entry) in regions.indexed) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ColumnRule(),
                  ),
                SizedBox(width: cardWidth, child: card(entry)),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: BlockHeader(title: title),
        ),
        const SizedBox(height: 12),
        body,
      ],
    );
  }
}

/// "In This Issue": numbered 01, 02, … with a link to the full archive.
class InThisIssueBlock extends StatelessWidget {
  const InThisIssueBlock({
    super.key,
    required this.stories,
    required this.onOpen,
    required this.onViewAll,
    this.title = 'In This Issue',
  });

  final List<Story> stories;
  final OpenStory onOpen;
  final VoidCallback onViewAll;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlockHeader(
          title: title,
          actionLabel: 'View full issue',
          onAction: onViewAll,
        ),
        const SizedBox(height: 8),
        for (final (i, story) in stories.indexed) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Insets.storyGap),
              child: ThinRule(),
            ),
          NumberedStoryTile(
            index: i,
            story: story,
            slot: 'home/featured',
            onOpen: onOpen,
          ),
        ],
      ],
    );
  }
}

/// "The Utah Lens" / "Data Brief": red-ruled title over compact headlines.
class SidebarBlock extends StatelessWidget {
  const SidebarBlock({
    super.key,
    required this.title,
    required this.stories,
    required this.slot,
    required this.onOpen,
  });

  final String title;
  final List<Story> stories;
  final String slot;
  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccentHeader(title),
        RuledStoryList(
          stories: stories,
          slot: slot,
          onOpen: onOpen,
          size: StoryTileSize.xsmall,
          showLabel: false,
          showByline: false,
          lightRules: true,
        ),
      ],
    );
  }
}

/// Small lockup, copyright and a link to the website.
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key, required this.copyright});

  final String copyright;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    return Padding(
      padding: EdgeInsets.fromLTRB(context.gutter, 28, context.gutter, 12),
      child: Column(
        children: [
          const Lockup(logoSize: 22, wordmarkSize: 14),
          const SizedBox(height: 10),
          Text(copyright, textAlign: TextAlign.center, style: news.meta),
          TextButton(
            onPressed: () => openExternalUrl(ApiConfig.siteUrl),
            child: const Text('theutahview.com'),
          ),
        ],
      ),
    );
  }
}
