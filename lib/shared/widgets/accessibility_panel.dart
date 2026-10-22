import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/theme.dart';
import 'rules.dart';

/// Opens the accessibility controls as a bottom sheet.
Future<void> showAccessibilitySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AccessibilitySheet(),
  );
}

/// A reusable entry point for the accessibility controls.
class AccessibilityButton extends StatelessWidget {
  const AccessibilityButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Accessibility options',
      icon: const Icon(Icons.accessibility_new_rounded),
      onPressed: () => showAccessibilitySheet(context),
    );
  }
}

class _AccessibilitySheet extends ConsumerWidget {
  const _AccessibilitySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final news = context.news;
    final p = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text('ACCESSIBILITY', style: news.blockTitle),
            ),
            const SizedBox(height: 10),
            const ThickRule(),
            const SizedBox(height: 16),
            // Text size: A− · label · A+
            Row(
              children: [
                Expanded(
                  child: Text('Text size', style: news.summary),
                ),
                IconButton(
                  tooltip: 'Smaller text',
                  onPressed: s.canDecreaseText ? notifier.decreaseText : null,
                  icon: const Icon(Icons.text_decrease_rounded),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    s.readingScaleLabel,
                    textAlign: TextAlign.center,
                    style: news.meta.copyWith(color: p.ink),
                  ),
                ),
                IconButton(
                  tooltip: 'Larger text',
                  onPressed: s.canIncreaseText ? notifier.increaseText : null,
                  icon: const Icon(Icons.text_increase_rounded),
                ),
              ],
            ),
            const ThinRule(light: true),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text('High contrast', style: news.summary),
              subtitle: Text(
                'Pure black and white with heavier rules.',
                style: news.meta,
              ),
              value: s.highContrast,
              onChanged: notifier.setHighContrast,
            ),
            const ThinRule(light: true),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text('Reduce motion', style: news.summary),
              subtitle: Text(
                'Turn off page and scrolling animations.',
                style: news.meta,
              ),
              value: s.reduceMotion,
              onChanged: notifier.setReduceMotion,
            ),
            const SizedBox(height: 12),
            Text(
              'Open any article to use "Listen" for read-aloud.',
              style: news.meta,
            ),
          ],
        ),
      ),
    );
  }
}
