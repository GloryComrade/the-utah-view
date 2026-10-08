import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/models/models.dart';
import '../../../core/router/navigation.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/theme.dart';
import '../../saved/saved_stories.dart';

/// Bookmark toggle. Saving stores the full story so it reads offline, so it
/// is enabled once the body has loaded.
class SaveStoryButton extends ConsumerWidget {
  const SaveStoryButton({super.key, required this.storyId, this.detail});

  final String storyId;
  final StoryDetail? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isSavedProvider(storyId));
    final story = detail;
    return IconButton(
      tooltip: saved ? 'Remove from Saved' : 'Save for later',
      isSelected: saved,
      icon: const Icon(Icons.bookmark_border_rounded),
      selectedIcon: Icon(Icons.bookmark_rounded, color: context.palette.accent),
      onPressed: !saved && story == null
          ? null
          : () async {
              unawaited(HapticFeedback.selectionClick());
              final notifier = ref.read(savedStoriesProvider.notifier);
              if (saved) {
                await notifier.remove(storyId);
              } else {
                await notifier.save(story!);
              }
              if (!context.mounted) return;
              final router = GoRouter.of(context);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      saved
                          ? 'Removed from Saved'
                          : 'Saved for offline reading',
                    ),
                    action: saved
                        ? null
                        : SnackBarAction(
                            label: 'VIEW',
                            onPressed: () => router.goNamed(RouteNames.saved),
                          ),
                  ),
                );
            },
    );
  }
}

/// Shares the website link, so it opens for anyone (and in the app for
/// readers who have it).
class ShareStoryButton extends StatelessWidget {
  const ShareStoryButton({super.key, required this.storyId, this.title});

  final String storyId;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Share',
      icon: Icon(Icons.adaptive.share),
      onPressed: () {
        // iPad anchors the share sheet to the button.
        final box = context.findRenderObject() as RenderBox?;
        final origin = box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size;
        final subject = title?.isNotEmpty == true ? title : 'The Utah View';
        SharePlus.instance.share(
          ShareParams(
            uri: ApiConfig.articleWebUri(storyId),
            subject: subject,
            title: subject,
            sharePositionOrigin: origin,
          ),
        );
      },
    );
  }
}

/// Opens the A− / A+ sheet. Changes apply live to the article behind it.
class TextSizeButton extends StatelessWidget {
  const TextSizeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Text size',
      icon: const Icon(Icons.text_fields_rounded),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => const TextSizeSheet(),
      ),
    );
  }
}

class TextSizeSheet extends ConsumerWidget {
  const TextSizeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final news = context.news;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text('TEXT SIZE', style: news.blockTitle),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _SizeStep(
                  label: 'A−',
                  semanticsLabel: 'Smaller text',
                  fontSize: 18,
                  onPressed: settings.canDecreaseText
                      ? notifier.decreaseText
                      : null,
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      settings.readingScaleLabel,
                      textAlign: TextAlign.center,
                      style: news.bylineStrong.copyWith(fontSize: 15),
                    ),
                  ),
                ),
                _SizeStep(
                  label: 'A+',
                  semanticsLabel: 'Larger text',
                  fontSize: 26,
                  onPressed: settings.canIncreaseText
                      ? notifier.increaseText
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Applies to article text. Your device’s text size setting '
              'is respected too.',
              textAlign: TextAlign.center,
              style: news.meta,
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeStep extends StatelessWidget {
  const _SizeStep({
    required this.label,
    required this.semanticsLabel,
    required this.fontSize,
    required this.onPressed,
  });

  final String label;
  final String semanticsLabel;
  final double fontSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(
          label,
          semanticsLabel: semanticsLabel,
          style: context.news.headlineM.copyWith(
            fontSize: fontSize,
            color: onPressed == null
                ? context.palette.inkFaint
                : context.palette.ink,
          ),
        ),
      ),
    );
  }
}

/// Thin red bar under the app bar showing how far through the story the
/// reader is.
class ReadingProgressBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ReadingProgressBar({super.key, required this.progress});

  final ValueListenable<double> progress;

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) {
    final color = context.palette.accentFill;
    return ExcludeSemantics(
      child: SizedBox(
        height: 3,
        child: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, _) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: value,
              heightFactor: 1,
              child: ColoredBox(color: color),
            ),
          ),
        ),
      ),
    );
  }
}
