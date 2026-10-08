import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/core/theme/theme.dart';

void main() {
  for (final (name, p) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    group('$name palette meets WCAG AA (4.5:1) for text', () {
      final textColors = <String, Color>{
        'ink': p.ink,
        'inkSecondary': p.inkSecondary,
        'inkMuted': p.inkMuted,
        'accent': p.accent,
        'accentPressed': p.accentPressed,
      };
      for (final MapEntry(key: role, value: color) in textColors.entries) {
        test('$role on background', () {
          expect(contrastRatio(color, p.background), greaterThanOrEqualTo(4.5));
        });
        test('$role on surfaceMuted', () {
          expect(
            contrastRatio(color, p.surfaceMuted),
            greaterThanOrEqualTo(4.5),
          );
        });
      }

      test('text on the red fill (ticker, buttons)', () {
        expect(
          contrastRatio(p.onAccentFill, p.accentFill),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('red "BRIEFING" label on its white badge', () {
        expect(
          contrastRatio(BrandColors.red, BrandColors.white),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('icons (inkFaint) meet the 3:1 non-text minimum', () {
        expect(
          contrastRatio(p.inkFaint, p.background),
          greaterThanOrEqualTo(3),
        );
      });
    });
  }
}
