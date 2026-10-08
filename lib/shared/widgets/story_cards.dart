import 'package:material_ui/material_ui.dart';

import '../../core/api/models/models.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/formatters.dart';
import 'headline_hero.dart';
import 'labels.dart';
import 'story_image.dart';

/// Opens a story. [heroTag] is the tag of the headline that was tapped so
/// the article screen can fly it into place.
typedef OpenStory = void Function(Story story, Object? heroTag);

/// Makes a card one tappable, screen-reader-friendly unit.
class StoryTapTarget extends StatelessWidget {
  const StoryTapTarget({
    super.key,
    required this.onTap,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onLongPress,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        hint: 'Opens the article',
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The top story: photo, red kicker, big serif headline, summary, byline.
class LeadStoryCard extends StatelessWidget {
  const LeadStoryCard({
    super.key,
    required this.story,
    required this.slot,
    required this.onOpen,
    this.imageUrl,
    this.caption,
    this.headlineStyle,
    this.textPadding = EdgeInsets.zero,
  });

  final Story story;
  final String slot;
  final OpenStory onOpen;
  final String? imageUrl;
  final String? caption;

  /// Insets the text but not the photo, so the photo can run edge to edge.
  final EdgeInsetsGeometry textPadding;

  /// Overrides the default XL headline (tablets go bigger).
  final TextStyle? headlineStyle;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final tag = StoryHeroTag(story.id, slot);
    final image = imageUrl;
    return StoryTapTarget(
      onTap: () => onOpen(story, tag),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null) ...[
            Hero(
              tag: storyImageHeroTag(story.id),
              child: StoryImage(
                url: image,
                semanticLabel: caption?.isNotEmpty == true ? caption : null,
              ),
            ),
            if (caption?.isNotEmpty == true)
              Padding(
                padding: textPadding.add(const EdgeInsets.only(top: 6)),
                child: Text(
                  caption!,
                  style: news.meta.copyWith(fontSize: 11.5),
                ),
              ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: textPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(story.region),
                const SizedBox(height: 8),
                HeadlineHero(
                  tag: tag,
                  text: story.title,
                  style: headlineStyle ?? news.headlineXL,
                ),
                if (story.summary.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(story.summary, style: news.summaryL),
                ],
                const SizedBox(height: 10),
                Byline.forStory(story),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum StoryTileSize { large, medium, small, xsmall }

/// The workhorse story row: optional kicker, headline, summary, byline.
class StoryTile extends StatelessWidget {
  const StoryTile({
    super.key,
    required this.story,
    required this.slot,
    required this.onOpen,
    this.size = StoryTileSize.medium,
    this.showLabel = true,
    this.showSummary = true,
    this.showByline = true,
    this.showDate = false,
    this.summaryMaxLines,
    this.highlight = const {},
    this.padding = EdgeInsets.zero,
  });

  final Story story;
  final String slot;
  final OpenStory onOpen;
  final StoryTileSize size;
  final bool showLabel;
  final bool showSummary;
  final bool showByline;
  final bool showDate;
  final int? summaryMaxLines;

  /// Lower-case search terms to highlight in the headline and summary.
  final Set<String> highlight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final headlineStyle = switch (size) {
      StoryTileSize.large => news.headlineL,
      StoryTileSize.medium => news.headlineM,
      StoryTileSize.small => news.headlineS,
      StoryTileSize.xsmall => news.headlineXS,
    };
    final summaryStyle = size.index <= StoryTileSize.medium.index
        ? news.summary
        : news.summaryS;
    final tag = highlight.isEmpty ? StoryHeroTag(story.id, slot) : null;

    return StoryTapTarget(
      onTap: () => onOpen(story, tag),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLabel && story.region.isNotEmpty) ...[
            SectionLabel(story.region),
            const SizedBox(height: 6),
          ],
          if (highlight.isEmpty)
            HeadlineHero(tag: tag, text: story.title, style: headlineStyle)
          else
            HighlightedText(
              story.title,
              terms: highlight,
              style: headlineStyle,
            ),
          if (showSummary && story.summary.isNotEmpty) ...[
            SizedBox(height: size == StoryTileSize.xsmall ? 4 : 7),
            HighlightedText(
              story.summary,
              terms: highlight,
              style: summaryStyle,
              maxLines: summaryMaxLines,
            ),
          ],
          if (showByline) ...[
            const SizedBox(height: 8),
            Byline.forStory(story, showDate: showDate),
          ],
        ],
      ),
    );
  }
}

/// "01  Headline / summary / By Author · Region" in the In This Issue list.
class NumberedStoryTile extends StatelessWidget {
  const NumberedStoryTile({
    super.key,
    required this.index,
    required this.story,
    required this.slot,
    required this.onOpen,
  });

  final int index;
  final Story story;
  final String slot;
  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final tag = StoryHeroTag(story.id, slot);
    return StoryTapTarget(
      onTap: () => onOpen(story, tag),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 52),
            child: Padding(
              padding: const EdgeInsets.only(right: 12, top: 2),
              child: Text(
                formatListIndex(index),
                semanticsLabel: 'Number ${index + 1}.',
                style: news.numeral,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeadlineHero(
                  tag: tag,
                  text: story.title,
                  style: news.headlineS,
                ),
                if (story.summary.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(story.summary, style: news.summaryS),
                ],
                const SizedBox(height: 6),
                Byline(
                  author: story.author,
                  region: story.region.isEmpty ? 'Analysis' : story.region,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One column of "Around the World": red region name, headline, summary.
class RegionStoryCard extends StatelessWidget {
  const RegionStoryCard({
    super.key,
    required this.region,
    required this.story,
    required this.slot,
    required this.onOpen,
  });

  final String region;
  final Story story;
  final String slot;
  final OpenStory onOpen;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final tag = StoryHeroTag(story.id, slot);
    return StoryTapTarget(
      onTap: () => onOpen(story, tag),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccentHeader(region),
          HeadlineHero(tag: tag, text: story.title, style: news.headlineS),
          if (story.summary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              story.summary,
              style: news.summaryS,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Text with case-insensitive matches of [terms] marked.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    super.key,
    required this.terms,
    required this.style,
    this.maxLines,
  });

  final String text;
  final Set<String> terms;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final overflow = maxLines == null ? null : TextOverflow.ellipsis;
    if (terms.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }
    final p = context.palette;
    final mark = style.copyWith(
      backgroundColor: p.accent.withValues(alpha: 0.16),
      color: p.ink,
    );
    return Text.rich(
      TextSpan(style: style, children: highlightSpans(text, terms, mark)),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Splits [text] into spans, applying [mark] to every match of [terms].
List<TextSpan> highlightSpans(String text, Set<String> terms, TextStyle mark) {
  final lower = text.toLowerCase();
  final ranges = <(int, int)>[];
  for (final term in terms.where((t) => t.isNotEmpty)) {
    var start = lower.indexOf(term);
    while (start != -1) {
      ranges.add((start, start + term.length));
      start = lower.indexOf(term, start + term.length);
    }
  }
  if (ranges.isEmpty) return [TextSpan(text: text)];
  ranges.sort((a, b) => a.$1.compareTo(b.$1));

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final (start, end) in ranges) {
    if (end <= cursor) continue;
    final from = start < cursor ? cursor : start;
    if (from > cursor) spans.add(TextSpan(text: text.substring(cursor, from)));
    spans.add(TextSpan(text: text.substring(from, end), style: mark));
    cursor = end;
  }
  if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
  return spans;
}
