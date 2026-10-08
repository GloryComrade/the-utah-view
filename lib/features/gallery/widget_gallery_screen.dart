import 'package:material_ui/material_ui.dart';

import '../../core/api/models/models.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/article_body.dart';
import '../../shared/widgets/brand.dart';
import '../../shared/widgets/briefing_ticker.dart';
import '../../shared/widgets/labels.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/story_cards.dart';
import '../../shared/widgets/story_image.dart';
import '../../shared/widgets/subscribe_card.dart';
import 'gallery_samples.dart';

/// Every building block of the design system on one screen, in light and
/// dark. Reachable from More → Design gallery in debug builds.
class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key, this.initialDark = false, this.date});

  final bool initialDark;

  /// Fixed date for screenshots; defaults to today.
  final DateTime? date;

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  late bool _dark = widget.initialDark;

  void _open(Story story, Object? _) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Opens “${story.title}”')));
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final theme = _dark
        ? AppTheme.dark(platform: platform)
        : AppTheme.light(platform: platform);
    return Theme(
      data: theme,
      child: ImagePolicy(
        loadNetworkImages: false,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Design Gallery'),
              actions: [
                IconButton(
                  tooltip: _dark ? 'Show light theme' : 'Show dark theme',
                  icon: Icon(
                    _dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: () => setState(() => _dark = !_dark),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 48),
              children: [
                _Section(
                  number: 1,
                  title: 'Brand',
                  child: _BrandSpecimen(date: widget.date),
                ),
                const _Section(number: 2, title: 'Color', child: _Swatches()),
                const _Section(number: 3, title: 'Type', child: _TypeScale()),
                const _Section(
                  number: 4,
                  title: 'Rules & labels',
                  child: _RulesAndLabels(),
                ),
                const _Section(
                  number: 5,
                  title: 'Briefing ticker',
                  padded: false,
                  child: BriefingTicker(text: GallerySamples.ticker),
                ),
                _Section(
                  number: 6,
                  title: 'Lead story',
                  child: LeadStoryCard(
                    story: GallerySamples.lead,
                    slot: 'gallery/lead',
                    imageUrl: 'placeholder',
                    caption: 'Hero image placeholder (the site’s gradient box)',
                    onOpen: _open,
                  ),
                ),
                _Section(
                  number: 7,
                  title: 'Story tiles',
                  child: _StoryTiles(onOpen: _open),
                ),
                _Section(
                  number: 8,
                  title: 'Front-page blocks',
                  child: _FrontPageBlocks(onOpen: _open),
                ),
                _Section(
                  number: 9,
                  title: 'Around the World',
                  padded: false,
                  child: _RegionCarousel(onOpen: _open),
                ),
                const _Section(
                  number: 10,
                  title: 'Subscribe card',
                  padded: false,
                  child: SubscribeCard(
                    overline: 'Stay briefed',
                    heading: 'Independent analysis, delivered monthly',
                    description:
                        'Clarity Over Ideology. Every Month. Every Region.',
                  ),
                ),
                const _Section(
                  number: 11,
                  title: 'Article',
                  child: _ArticleSpecimen(),
                ),
                const _Section(
                  number: 12,
                  title: 'Controls',
                  child: _Controls(),
                ),
                const _Section(
                  number: 13,
                  title: 'Loading, empty & error',
                  child: _States(),
                ),
                const _Section(
                  number: 14,
                  title: 'Tab bar',
                  padded: false,
                  child: _TabBarPreview(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.child,
    this.padded = true,
  });

  final int number;
  final String title;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: p.surfaceMuted,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          margin: const EdgeInsets.only(top: 28, bottom: 20),
          child: Semantics(
            header: true,
            child: Text(
              '${number.toString().padLeft(2, '0')} · ${title.toUpperCase()}',
              style: context.news.sectionLabelMuted,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padded ? 20 : 0),
          child: child,
        ),
      ],
    );
  }
}

class _BrandSpecimen extends StatelessWidget {
  const _BrandSpecimen({this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Masthead(date: date),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final size in [24.0, 44.0, 72.0])
              Column(
                children: [
                  UtvLogo(size: size, semanticLabel: 'Logo at ${size.round()}'),
                  const SizedBox(height: 6),
                  Text('${size.round()}pt', style: context.news.meta),
                ],
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Compact app bar title', style: context.news.meta),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: p.rule)),
          child: const SizedBox(
            height: 56,
            child: Center(child: Lockup(logoSize: 26, wordmarkSize: 17)),
          ),
        ),
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final swatches = <(String, Color, bool)>[
      ('ink · headlines', p.ink, true),
      ('inkSecondary · body', p.inkSecondary, true),
      ('inkMuted · bylines', p.inkMuted, true),
      ('accent · labels, links', p.accent, true),
      ('accentFill · ticker, buttons', p.accentFill, false),
      ('inkFaint · icons only', p.inkFaint, false),
      ('rule', p.rule, false),
      ('ruleLight', p.ruleLight, false),
      ('surfaceMuted', p.surfaceMuted, false),
    ];
    return Column(
      children: [
        for (final (name, color, isText) in swatches)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: p.rule),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                  style: context.news.meta,
                ),
                SizedBox(
                  width: 76,
                  child: Text(
                    isText
                        ? '${contrastRatio(color, p.background).toStringAsFixed(1)}:1'
                        : '—',
                    textAlign: TextAlign.end,
                    style: context.news.bylineStrong,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text(
          'Contrast measured against the page background. Every text color '
          'clears WCAG AA (4.5:1).',
          style: context.news.meta,
        ),
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final n = context.news;
    final specimens = <(String, TextStyle, String)>[
      ('articleTitle · Display 32', n.articleTitle, 'Article headline'),
      ('headlineXL · Display 30', n.headlineXL, 'Lead story headline'),
      ('headlineL · Display 24', n.headlineL, 'Editorial headline'),
      ('headlineM · Display 21', n.headlineM, 'Standard headline'),
      ('headlineS · Display 18', n.headlineS, 'Compact headline'),
      ('headlineXS · Display 16', n.headlineXS, 'Sidebar headline'),
      (
        'articleSummary · Serif 20',
        n.articleSummary,
        'The deck under a headline',
      ),
      ('summary · Serif 15.5', n.summary, 'A standard story summary.'),
      ('summaryS · Serif 14.5', n.summaryS, 'A compact gray summary.'),
      ('body · Serif 18.5 / 1.65', n.body, 'Article body copy.'),
      ('sectionLabel · Inter 11 Bold', n.sectionLabel, 'EUROPE'),
      ('blockTitle · Inter 13 ExtraBold', n.blockTitle, 'IN THIS ISSUE'),
      ('byline · Inter 12', n.byline, 'By Benjamin Koh · July 22, 2026'),
      ('numeral · Display 32', n.numeral, '01'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (name, style, sample) in specimens) ...[
          Text(name, style: n.meta.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(sample, style: style),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: ThinRule(light: true),
          ),
        ],
      ],
    );
  }
}

class _RulesAndLabels extends StatelessWidget {
  const _RulesAndLabels();

  @override
  Widget build(BuildContext context) {
    final meta = context.news.meta.copyWith(fontSize: 11);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Thin rule (between stories)', style: meta),
        const SizedBox(height: 8),
        const ThinRule(),
        const SizedBox(height: 16),
        Text('Thick rule + block header', style: meta),
        const SizedBox(height: 8),
        BlockHeader(
          title: 'In This Issue',
          actionLabel: 'View full issue',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        Text('Accent header (sidebar blocks, regions)', style: meta),
        const SizedBox(height: 8),
        const AccentHeader('The Utah Lens'),
        const SizedBox(height: 8),
        Text('Section labels', style: meta),
        const SizedBox(height: 8),
        const Row(
          children: [
            SectionLabel('Europe'),
            SizedBox(width: 24),
            SectionLabel('From This Issue', muted: true),
          ],
        ),
        const SizedBox(height: 16),
        Text('Byline', style: meta),
        const SizedBox(height: 8),
        Byline.forStory(GallerySamples.lead),
      ],
    );
  }
}

class _StoryTiles extends StatelessWidget {
  const _StoryTiles({required this.onOpen});

  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    final meta = context.news.meta.copyWith(fontSize: 11);
    Widget gap() => const Padding(
      padding: EdgeInsets.symmetric(vertical: Insets.storyGap),
      child: ThinRule(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Medium (secondary & center stories)', style: meta),
        const SizedBox(height: 8),
        StoryTile(
          story: GallerySamples.secondary,
          slot: 'gallery/medium',
          onOpen: onOpen,
        ),
        gap(),
        Text('Small, with date (section lists)', style: meta),
        const SizedBox(height: 8),
        StoryTile(
          story: GallerySamples.europe,
          slot: 'gallery/small',
          size: StoryTileSize.small,
          showDate: true,
          onOpen: onOpen,
        ),
        gap(),
        Text('Search result with highlighted terms', style: meta),
        const SizedBox(height: 8),
        StoryTile(
          story: GallerySamples.americas,
          slot: 'gallery/search',
          size: StoryTileSize.small,
          showDate: true,
          highlight: const {'maduro', 'trial'},
          onOpen: onOpen,
        ),
      ],
    );
  }
}

class _FrontPageBlocks extends StatelessWidget {
  const _FrontPageBlocks({required this.onOpen});

  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    Widget rule({bool light = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.storyGap),
      child: ThinRule(light: light),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('From This Issue', muted: true),
        const SizedBox(height: 12),
        StoryTile(
          story: GallerySamples.northKorea,
          slot: 'gallery/right',
          size: StoryTileSize.small,
          showLabel: false,
          onOpen: onOpen,
        ),
        const SizedBox(height: Insets.blockGap),
        const BlockHeader(title: 'Editorial & Opinion'),
        const SizedBox(height: 8),
        StoryTile(
          story: GallerySamples.opinion,
          slot: 'gallery/editorial',
          size: StoryTileSize.large,
          onOpen: onOpen,
        ),
        rule(),
        StoryTile(
          story: GallerySamples.europe,
          slot: 'gallery/editorial-2',
          size: StoryTileSize.small,
          showLabel: false,
          onOpen: onOpen,
        ),
        const SizedBox(height: Insets.blockGap),
        BlockHeader(
          title: 'In This Issue',
          actionLabel: 'View full issue',
          onAction: () {},
        ),
        const SizedBox(height: 8),
        for (final (i, story) in [
          GallerySamples.americas,
          GallerySamples.northKorea,
          GallerySamples.europe,
        ].indexed) ...[
          if (i > 0) rule(),
          NumberedStoryTile(
            index: i,
            story: story,
            slot: 'gallery/featured',
            onOpen: onOpen,
          ),
        ],
        const SizedBox(height: Insets.blockGap),
        const AccentHeader('The Utah Lens'),
        for (final (i, story) in [
          GallerySamples.draper,
          GallerySamples.utah,
        ].indexed) ...[
          if (i > 0) rule(light: true),
          StoryTile(
            story: story,
            slot: 'gallery/utah',
            size: StoryTileSize.xsmall,
            showLabel: false,
            showByline: false,
            onOpen: onOpen,
          ),
        ],
      ],
    );
  }
}

class _RegionCarousel extends StatelessWidget {
  const _RegionCarousel({required this.onOpen});

  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, (region, story))
                in GallerySamples.regions.indexed) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ColumnRule(),
                ),
              SizedBox(
                width: 260,
                child: RegionStoryCard(
                  region: region,
                  story: story,
                  slot: 'gallery/region',
                  onOpen: onOpen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArticleSpecimen extends StatelessWidget {
  const _ArticleSpecimen();

  @override
  Widget build(BuildContext context) {
    final n = context.news;
    const story = GallerySamples.lead;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Asia-Pacific'),
        const SizedBox(height: 10),
        Text(story.title, style: n.articleTitle),
        const SizedBox(height: 12),
        Text(story.summary, style: n.articleSummary),
        const SizedBox(height: 14),
        Byline.forStory(story),
        const SizedBox(height: 18),
        const ThinRule(),
        const SizedBox(height: 22),
        const ArticleBody(html: GallerySamples.bodyHtml),
      ],
    );
  }
}

class _Controls extends StatefulWidget {
  const _Controls();

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  ThemeMode _mode = ThemeMode.system;
  double _scale = 1;
  bool _toggle = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(onPressed: () {}, child: const Text('SUBSCRIBE')),
            OutlinedButton(onPressed: () {}, child: const Text('TRY AGAIN')),
            TextButton(
              onPressed: () {},
              child: const Text('View full issue →'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Search stories, authors, regions',
          ),
        ),
        const SizedBox(height: 20),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {_mode},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('A', style: context.news.headlineXS.copyWith(fontSize: 14)),
            Expanded(
              child: Slider(
                value: _scale,
                min: 0,
                max: 4,
                divisions: 4,
                label: 'Text size',
                onChanged: (v) => setState(() => _scale = v),
              ),
            ),
            Text('A', style: context.news.headlineXS.copyWith(fontSize: 24)),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('New issue notifications'),
          value: _toggle,
          onChanged: (v) => setState(() => _toggle = v),
        ),
      ],
    );
  }
}

class _States extends StatelessWidget {
  const _States();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FeedSkeleton(count: 2),
        const SizedBox(height: 12),
        const ThinRule(),
        const MessageView(
          icon: Icons.bookmark_border_rounded,
          title: 'No saved stories yet',
          message:
              'Tap the bookmark on any article to read it later, '
              'even offline.',
        ),
        const ThinRule(),
        MessageView.error(Exception('Gallery sample'), onRetry: () {}),
      ],
    );
  }
}

class _TabBarPreview extends StatelessWidget {
  const _TabBarPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.palette.rule)),
      ),
      child: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
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
            selectedIcon: Icon(Icons.menu_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
