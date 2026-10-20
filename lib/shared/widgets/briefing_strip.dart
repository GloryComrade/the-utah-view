import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import 'rules.dart';

/// The static "BRIEFING" strip that sits under the masthead.
///
/// Replaces the old scrolling marquee (see 2026 redesign): a terracotta
/// "BRIEFING" tag followed by the briefing items set in the editorial serif,
/// bounded below by a thin rule. It does not animate. When the briefing has
/// more than one item (or the line is long enough to clip) tapping it opens
/// the full briefing as a readable list.
class BriefingStrip extends StatelessWidget {
  const BriefingStrip({super.key, required this.text, this.label = 'Briefing'});

  final String text;
  final String label;

  /// Briefing items are separated by bullets in the CMS.
  static List<String> itemsOf(String text) => [
    for (final item in text.split(RegExp(r'\s*[•·|]\s*')))
      if (item.trim().isNotEmpty) item.trim(),
  ];

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BriefingSheet(items: itemsOf(text), title: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final p = context.palette;
    final news = context.news;
    final items = itemsOf(text);
    final line = items.join('   ·   ');
    final expandable = items.length > 1;

    return Material(
      color: p.background,
      child: Semantics(
        container: true,
        button: expandable,
        label: '${label.toUpperCase()}: $line',
        hint: expandable ? 'Shows the full briefing' : null,
        excludeSemantics: true,
        child: InkWell(
          onTap: expandable ? () => _open(context) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(context.gutter, 11, context.gutter, 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1, right: 12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: p.accentFill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          child: Text(
                            label.toUpperCase(),
                            style: news.tickerLabel.copyWith(
                              color: p.onAccentFill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: news.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (expandable)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 1),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: p.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const ThinRule(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BriefingSheet extends StatelessWidget {
  const _BriefingSheet({required this.items, required this.title});

  final List<String> items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Semantics(
            header: true,
            child: Text(title.toUpperCase(), style: news.blockTitle),
          ),
          const SizedBox(height: 10),
          const ThickRule(),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 12),
                    child: SizedBox.square(
                      dimension: 6,
                      child: ColoredBox(color: context.palette.accent),
                    ),
                  ),
                  Expanded(child: Text(item, style: news.summary)),
                ],
              ),
            ),
            const ThinRule(light: true),
          ],
        ],
      ),
    );
  }
}
