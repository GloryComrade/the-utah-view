import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import 'rules.dart';

/// The red "BRIEFING" strip with the ticker scrolling across it.
///
/// Scrolling is painted, not rebuilt, so it costs one repaint per frame. It
/// stops while its tab is offstage (TickerMode) and stays still when the
/// system's reduce-motion setting is on. Tapping it opens the full briefing
/// as a readable list.
class BriefingTicker extends StatefulWidget {
  const BriefingTicker({
    super.key,
    required this.text,
    this.label = 'Briefing',
    this.pixelsPerSecond = 40,
  });

  final String text;
  final String label;
  final double pixelsPerSecond;

  /// Ticker items are separated by bullets in the CMS.
  static List<String> itemsOf(String text) => [
    for (final item in text.split(RegExp(r'\s*[•·|]\s*')))
      if (item.trim().isNotEmpty) item.trim(),
  ];

  @override
  State<BriefingTicker> createState() => _BriefingTickerState();
}

class _BriefingTickerState extends State<BriefingTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _offset = ValueNotifier<double>(0);
  Duration _last = Duration.zero;
  TextPainter? _painter;
  bool _animate = false;

  void _tick(Duration elapsed) {
    final dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;
    _offset.value += widget.pixelsPerSecond * dt;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate = !MediaQuery.disableAnimationsOf(context);
    if (_animate && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!_animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    _painter?.dispose();
    super.dispose();
  }

  TextPainter _layoutText(TextStyle style, TextScaler scaler) {
    final text = widget.text.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
    final existing = _painter;
    if (existing != null &&
        existing.textScaler == scaler &&
        existing.text == TextSpan(text: text, style: style)) {
      return existing;
    }
    existing?.dispose();
    return _painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
  }

  void _openBriefing() {
    final items = BriefingTicker.itemsOf(widget.text);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BriefingSheet(items: items, title: widget.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();
    final p = context.palette;
    final news = context.news;
    final scaler = MediaQuery.textScalerOf(context);
    final painter = _layoutText(news.ticker, scaler);

    return Semantics(
      container: true,
      button: true,
      label: '${widget.label}: ${widget.text}',
      hint: 'Shows the full briefing',
      excludeSemantics: true,
      child: Material(
        color: p.accentFill,
        child: InkWell(
          onTap: _openBriefing,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: BrandColors.white),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        widget.label.toUpperCase(),
                        style: news.tickerLabel,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: painter.height,
                    child: _animate
                        ? RepaintBoundary(
                            child: CustomPaint(
                              painter: _MarqueePainter(painter, _offset),
                            ),
                          )
                        : Text(
                            (BriefingTicker.itemsOf(widget.text).firstOrNull ?? '')
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: news.ticker,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarqueePainter extends CustomPainter {
  _MarqueePainter(this.text, this.offset) : super(repaint: offset);

  static const gap = 56.0;

  final TextPainter text;
  final ValueNotifier<double> offset;

  @override
  void paint(Canvas canvas, Size size) {
    final cycle = text.width + gap;
    if (cycle <= gap) return;
    canvas.clipRect(Offset.zero & size);
    // Start a little in from the right edge, then loop seamlessly.
    final shift = (offset.value - size.width * 0.35) % cycle;
    for (var x = -shift; x < size.width; x += cycle) {
      text.paint(canvas, Offset(x, (size.height - text.height) / 2));
    }
  }

  @override
  bool shouldRepaint(_MarqueePainter oldDelegate) =>
      oldDelegate.text != text || oldDelegate.offset != offset;
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
