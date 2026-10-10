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
import '../share_card.dart';

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

/// Share menu: the website link (opens for anyone), or a branded image card
/// for Instagram / Stories.
class ShareStoryButton extends StatelessWidget {
  const ShareStoryButton({
    super.key,
    required this.storyId,
    this.title,
    this.kicker = '',
    this.byline = '',
  });

  final String storyId;
  final String? title;

  /// Region/section, shown as the red kicker on the image card.
  final String kicker;

  /// e.g. "By Jane Doe", shown under the headline on the image card.
  final String byline;

  Rect? _origin(BuildContext context) {
    // iPad anchors the share sheet to the button.
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final uri = ApiConfig.articleWebUri(storyId);
    final subject = title?.isNotEmpty == true ? title! : 'The Utah View';
    return PopupMenuButton<int>(
      tooltip: 'Share',
      icon: Icon(Icons.adaptive.share),
      onSelected: (choice) async {
        final origin = _origin(context);
        final messenger = ScaffoldMessenger.of(context);
        if (choice == 0) {
          await SharePlus.instance.share(
            ShareParams(
              uri: uri,
              subject: subject,
              title: subject,
              sharePositionOrigin: origin,
            ),
          );
          return;
        }
        try {
          await shareStoryCard(
            title: subject,
            url: uri,
            kicker: kicker,
            byline: byline,
            origin: origin,
          );
        } catch (_) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Couldn’t create the share image')),
            );
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem<int>(
          value: 0,
          child: _ShareOption(
            icon: Icons.link_rounded,
            label: 'Share link',
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: _ShareOption(
            icon: Icons.image_outlined,
            label: 'Share as image',
            subtitle: 'For Instagram, Stories…',
          ),
        ),
      ],
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({required this.icon, required this.label, this.subtitle});

  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: context.palette.inkFaint),
              ),
          ],
        ),
      ],
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
