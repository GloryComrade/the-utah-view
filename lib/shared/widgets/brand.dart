import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/formatters.dart';
import 'rules.dart';

/// The Utah View mark: two red L-brackets stepping down into a red-framed
/// white square holding "UT".
///
/// `assets/brand/logo.png` is rendered from [UtvLogoPainter], the same
/// vector the website's SVG and every icon and splash image come from.
class UtvLogo extends StatelessWidget {
  const UtvLogo({super.key, this.size = 44, this.semanticLabel});

  final double size;

  /// Leave null when the wordmark sits next to the logo (it's decorative).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/brand/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    if (semanticLabel == null) return ExcludeSemantics(child: logo);
    return Semantics(label: semanticLabel, image: true, child: logo);
  }
}

class UtvLogoPainter extends CustomPainter {
  const UtvLogoPainter({
    this.color = BrandColors.logo,
    this.innerColor = BrandColors.white,
  });

  final Color color;

  /// Fill for the white counters (the gap between the brackets and the inner
  /// square). Null leaves them transparent, which the monochrome (themed)
  /// Android icon needs.
  final Color? innerColor;

  static Path _path(List<List<List<double>>> shapes) {
    final path = Path()..fillType = PathFillType.evenOdd;
    for (final rings in shapes) {
      for (final ring in rings) {
        path.moveTo(ring[0], ring[1]);
        for (var k = 2; k < ring.length; k += 2) {
          path.lineTo(ring[k], ring[k + 1]);
        }
        path.close();
      }
    }
    return path;
  }

  static final _white = _path(_kLogoWhite);
  static final _red = _path(_kLogoRed);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas
      ..save()
      ..translate(
        (size.width - size.shortestSide) / 2,
        (size.height - size.shortestSide) / 2,
      )
      ..scale(scale);
    final inner = innerColor;
    if (inner != null) {
      canvas.drawPath(
        _white,
        Paint()
          ..color = inner
          ..isAntiAlias = true,
      );
    }
    canvas
      ..drawPath(
        _red,
        Paint()
          ..color = color
          ..isAntiAlias = true,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(UtvLogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.innerColor != innerColor;
}

/// "The Utah View", set like the website masthead. Treated as a logo, so it doesn't grow with dynamic type.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 20, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'The Utah View',
      semanticsLabel: 'The Utah View',
      maxLines: 1,
      softWrap: false,
      textScaler: TextScaler.noScaling,
      style: context.news.wordmark.copyWith(
        fontSize: fontSize,
        letterSpacing: 0,
        color: color,
      ),
    );
  }
}

/// Logo and wordmark side by side.
class Lockup extends StatelessWidget {
  const Lockup({super.key, this.logoSize = 44, this.wordmarkSize = 24});

  final double logoSize;
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UtvLogo(size: logoSize),
          SizedBox(width: logoSize * 0.3),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Wordmark(fontSize: wordmarkSize),
            ),
          ),
        ],
      ),
    );
  }
}

/// "EVERY REGION · EVERY MONTH".
class Tagline extends StatelessWidget {
  const Tagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Industry and Everything Else',
      semanticsLabel: 'Industry and everything else',
      textAlign: TextAlign.center,
      style: context.news.tagline,
    );
  }
}

/// The full newspaper masthead: lockup, tagline, a heavy rule and today's
/// date. Used at the top of Home (expanded) and on the More tab.
class Masthead extends StatelessWidget {
  const Masthead({super.key, this.date, this.logoSize = 40});

  /// Defaults to now. Injectable for screenshots and tests.
  final DateTime? date;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final today = date ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Lockup(logoSize: logoSize, wordmarkSize: logoSize * 0.6),
        ),
        const SizedBox(height: 8),
        const Tagline(),
        const SizedBox(height: 14),
        const HeavyRule(),
        const SizedBox(height: 8),
        Text(
          formatMastheadDate(today).toUpperCase(),
          semanticsLabel: formatMastheadDate(today),
          textAlign: TextAlign.center,
          style: context.news.dateline,
        ),
        const SizedBox(height: 8),
        const ThinRule(),
      ],
    );
  }
}

// ── Generated by tool/brand_assets/vectorize_logo.py — do not edit by hand. ──
// The mark in a 100×100 box (filling 4..96). Each shape is a list of rings
// (x, y pairs); the first ring is the outline, any others are holes.

/// The white counters behind the mark: the gap between the brackets and the
/// inner square.
const _kLogoWhite = <List<List<double>>>[
  [
    [
      4,
      4.36,
      4,
      85.34,
      38.34,
      85.34,
      38.34,
      95.59,
      95.95,
      95.59,
      95.95,
      38.39,
      85.6,
      38.39,
      85.6,
      4.36,
    ],
  ],
];

/// The red brackets, square frame and "UT".
const _kLogoRed = <List<List<double>>>[
  [
    [
      62.58,
      51.41,
      62.58,
      53.56,
      65.09,
      53.56,
      65.09,
      72.37,
      67.71,
      72.37,
      67.71,
      53.56,
      70.22,
      53.56,
      70.22,
      51.41,
    ],
  ],
  [
    [
      53.66,
      51.41,
      53.66,
      70.73,
      55.3,
      72.37,
      59.76,
      72.37,
      61.4,
      70.73,
      61.4,
      51.41,
      58.79,
      51.41,
      58.79,
      69.6,
      58.23,
      70.17,
      56.84,
      70.17,
      56.28,
      69.6,
      56.28,
      51.41,
    ],
  ],
  [
    [
      27.37,
      27.58,
      27.37,
      85.34,
      38.34,
      85.34,
      38.34,
      95.59,
      95.95,
      95.59,
      95.95,
      38.39,
      85.6,
      38.39,
      85.6,
      27.58,
    ],
    [38.34, 38.39, 85.6, 38.39, 85.6, 85.34, 38.34, 85.34],
  ],
  [
    [4, 85.34, 16.1, 85.34, 16.1, 16.35, 85.6, 16.35, 85.6, 4.36, 4, 4.36],
  ],
];
