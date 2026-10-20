import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

/// A photo caption + credit line shown under a lead image, newspaper-style:
/// the caption in muted ink, the credit set off after an em dash in a fainter
/// tone. Renders whichever parts are present.
class ImageCaption extends StatelessWidget {
  const ImageCaption({super.key, this.caption = '', this.credit = ''});

  final String caption;
  final String credit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final news = context.news;
    final cap = caption.trim();
    final cr = credit.trim();
    if (cap.isEmpty && cr.isEmpty) return const SizedBox.shrink();

    final faint = news.meta.copyWith(color: p.inkFaint);
    return Text.rich(
      TextSpan(
        children: [
          if (cap.isNotEmpty) TextSpan(text: cap),
          if (cap.isNotEmpty && cr.isNotEmpty)
            TextSpan(text: '  —  ', style: faint),
          if (cr.isNotEmpty) TextSpan(text: cr, style: faint),
        ],
      ),
      style: news.meta.copyWith(
        fontSize: 12.5,
        color: p.inkMuted,
        height: 1.4,
      ),
    );
  }
}
