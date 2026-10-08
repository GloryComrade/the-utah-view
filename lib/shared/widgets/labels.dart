import 'package:material_ui/material_ui.dart';

import '../../core/api/models/models.dart';
import '../../core/theme/theme.dart';
import 'rules.dart';

/// Small uppercase kicker above a headline, e.g. "EUROPE".
///
/// Screen readers get the original casing so the word isn't spelled out.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.muted = false});

  final String text;

  /// Gray instead of red (used for "FROM THIS ISSUE").
  final bool muted;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Text(
      text.toUpperCase(),
      semanticsLabel: text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: muted ? context.news.sectionLabelMuted : context.news.sectionLabel,
    );
  }
}

/// Opens a block of the front page: thick rule, then an uppercase title and
/// an optional link on the right ("View full issue →").
class BlockHeader extends StatelessWidget {
  const BlockHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ThickRule(),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title.toUpperCase(),
                  semanticsLabel: title,
                  style: context.news.blockTitle,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(48, 40),
                ),
                child: Text('$actionLabel →'),
              ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// Red title with a 2px red underline ("THE UTAH LENS", region names).
class AccentHeader extends StatelessWidget {
  const AccentHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            semanticsLabel: title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.news.sectionLabel.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        const AccentRule(),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// "By Author · May 25, 2026 · 3 min read", with the author in bold ink.
class Byline extends StatelessWidget {
  const Byline({
    super.key,
    required this.author,
    this.date,
    this.readTime,
    this.region,
    this.prefix = 'By ',
  });

  /// Builds the byline for [story]. Segments that are empty or junk drop out.
  factory Byline.forStory(
    Story story, {
    Key? key,
    bool showDate = true,
    bool showReadTime = true,
    bool showRegion = false,
  }) => Byline(
    key: key,
    author: story.author,
    date: showDate ? story.displayDate : null,
    readTime: showReadTime ? story.readTimeLabel : null,
    region: showRegion ? story.region : null,
  );

  final String author;
  final String? date;
  final String? readTime;
  final String? region;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final extras = [
      for (final s in [date, readTime, region])
        if (s != null && s.trim().isNotEmpty) s.trim(),
    ];
    final hasAuthor = author.trim().isNotEmpty;
    if (!hasAuthor && extras.isEmpty) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(
        style: news.byline,
        children: [
          if (hasAuthor) ...[
            TextSpan(text: prefix),
            TextSpan(text: author.trim(), style: news.bylineStrong),
          ],
          for (final (i, s) in extras.indexed)
            TextSpan(text: (i == 0 && !hasAuthor) ? s : ' · $s'),
        ],
      ),
    );
  }
}
