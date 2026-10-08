import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import 'rules.dart';

/// Small gray uppercase heading above a group of rows.
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.gutter, 28, context.gutter, 10),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          semanticsLabel: text,
          style: context.news.sectionLabelMuted,
        ),
      ),
    );
  }
}

/// A full-width navigation row: serif title, optional subtitle, trailing
/// count or icon, and a rule underneath.
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingSemantics,
    this.icon = Icons.chevron_right_rounded,
    this.onTap,
    this.serif = true,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;

  /// Spoken form of [trailingText], e.g. "16 stories".
  final String? trailingSemantics;
  final IconData? icon;
  final VoidCallback? onTap;

  /// Serif headline style (sections) or sans (settings-style rows).
  final bool serif;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final p = context.palette;
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.gutter,
                vertical: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: serif
                              ? news.listTitle
                              : Theme.of(context).textTheme.titleMedium,
                        ),
                        if (subtitle?.isNotEmpty == true) ...[
                          const SizedBox(height: 3),
                          Text(subtitle!, style: news.meta),
                        ],
                      ],
                    ),
                  ),
                  if (trailingText != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        trailingText!,
                        semanticsLabel: trailingSemantics,
                        style: news.meta,
                      ),
                    ),
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(icon, color: p.inkFaint, size: 22),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              child: const ThinRule(light: true),
            ),
          ],
        ),
      ),
    );
  }
}
