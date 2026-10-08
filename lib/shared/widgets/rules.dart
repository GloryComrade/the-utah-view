import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

/// 1px gray rule between stories.
class ThinRule extends StatelessWidget {
  const ThinRule({super.key, this.light = false});

  /// Use the lighter hairline (between compact items).
  final bool light;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(
        color: light ? context.palette.ruleLight : context.palette.rule,
      ),
    ),
  );
}

/// 3px ink rule that opens a new block of the front page.
class ThickRule extends StatelessWidget {
  const ThickRule({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 3,
      width: double.infinity,
      child: ColoredBox(color: context.palette.ruleStrong),
    ),
  );
}

/// 2px ink rule under the masthead (the website's nav border).
class HeavyRule extends StatelessWidget {
  const HeavyRule({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 2,
      width: double.infinity,
      child: ColoredBox(color: context.palette.ruleStrong),
    ),
  );
}

/// 2px red rule under red block titles ("THE UTAH LENS", region names).
class AccentRule extends StatelessWidget {
  const AccentRule({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 2,
      width: double.infinity,
      child: ColoredBox(color: context.palette.accent),
    ),
  );
}

/// Vertical 1px rule between tablet columns.
class ColumnRule extends StatelessWidget {
  const ColumnRule({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(width: 1, child: ColoredBox(color: context.palette.rule)),
  );
}
