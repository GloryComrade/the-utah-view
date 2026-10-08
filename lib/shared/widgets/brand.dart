import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/formatters.dart';
import 'rules.dart';

/// The Utah View mark: two red L-brackets stepping down into a red square
/// with a white inner square and "UT".
///
/// Drawn from the website's 100×100 SVG so the app and site match exactly.
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
    this.color = BrandColors.red,
    this.innerColor = BrandColors.white,
  });

  final Color color;

  /// Fill for the inner square. Null punches it out to transparent, which
  /// the monochrome (themed) Android icon needs.
  final Color? innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    final knockout = innerColor == null;
    if (knockout) canvas.saveLayer(Offset.zero & size, Paint());
    canvas
      ..save()
      ..translate(
        (size.width - size.shortestSide) / 2,
        (size.height - size.shortestSide) / 2,
      )
      ..scale(scale);

    final red = Paint()
      ..color = color
      ..isAntiAlias = true;

    // <path d="M4 4 H40 V16 H16 V52 H4 Z"/>
    canvas.drawPath(
      Path()
        ..moveTo(4, 4)
        ..lineTo(40, 4)
        ..lineTo(40, 16)
        ..lineTo(16, 16)
        ..lineTo(16, 52)
        ..lineTo(4, 52)
        ..close(),
      red,
    );
    // <path d="M20 20 H56 V32 H32 V68 H20 Z"/>
    canvas.drawPath(
      Path()
        ..moveTo(20, 20)
        ..lineTo(56, 20)
        ..lineTo(56, 32)
        ..lineTo(32, 32)
        ..lineTo(32, 68)
        ..lineTo(20, 68)
        ..close(),
      red,
    );
    canvas
      ..drawRect(const Rect.fromLTWH(40, 40, 56, 56), red)
      ..drawRect(
        const Rect.fromLTWH(48, 48, 40, 40),
        knockout
            ? (Paint()..blendMode = BlendMode.clear)
            : (Paint()..color = innerColor!),
      );

    // <text x="68" y="76" text-anchor="middle" font-size="24" weight 700>UT
    final ut = TextPainter(
      text: TextSpan(
        text: 'UT',
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontFamilyFallback: AppFonts.sansFallback,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: color,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final baseline = ut.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    ut
      ..paint(canvas, Offset(68 - ut.width / 2, 76 - baseline))
      ..dispose();

    canvas.restore();
    if (knockout) canvas.restore();
  }

  @override
  bool shouldRepaint(UtvLogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.innerColor != innerColor;
}

/// "THE UTAH VIEW". Treated as a logo, so it doesn't grow with dynamic type.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 20, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'THE UTAH VIEW',
      semanticsLabel: 'The Utah View',
      maxLines: 1,
      softWrap: false,
      textScaler: TextScaler.noScaling,
      style: context.news.wordmark.copyWith(
        fontSize: fontSize,
        letterSpacing: fontSize * 0.11,
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
      'EVERY REGION · EVERY MONTH',
      semanticsLabel: 'Every region, every month',
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
