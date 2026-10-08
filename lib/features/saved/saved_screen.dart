import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/navigation.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/story_cards.dart';
import 'saved_stories.dart';

/// Bookmarked stories, stored on the device with their full text.
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _remove(SavedStory entry) async {
    final notifier = ref.read(savedStoriesProvider.notifier);
    await notifier.remove(entry.story.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Removed from Saved'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => notifier.restore(entry),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    listenForTabReselect(ref, 2, _scroll);
    final saved = ref.watch(savedStoriesProvider);
    final gutter = context.gutter;
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: saved.isEmpty
          ? const MessageView(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved stories yet',
              message:
                  'Tap the bookmark on any article to keep it here. '
                  'Saved stories are available offline.',
            )
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: saved.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ContentWidth(
                    maxWidth: 760,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.offline_pin_outlined,
                            size: 16,
                            color: p.inkMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${saved.length} '
                              '${saved.length == 1 ? 'story' : 'stories'} · '
                              'available offline · swipe left to remove',
                              style: context.news.meta,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final entry = saved[index - 1];
                final story = entry.story.toStory();
                return ContentWidth(
                  maxWidth: 760,
                  child: Dismissible(
                    key: ValueKey('saved-${story.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _remove(entry),
                    background: ColoredBox(
                      color: p.accentFill,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_remove_outlined,
                                color: p.onAccentFill,
                              ),
                              const SizedBox(width: 8),
                              Text('REMOVE', style: context.news.button),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Semantics(
                      customSemanticsActions: {
                        const CustomSemanticsAction(
                          label: 'Remove from Saved',
                        ): () =>
                            _remove(entry),
                      },
                      child: ColoredBox(
                        color: p.background,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StoryTile(
                              story: story,
                              slot: 'saved',
                              size: StoryTileSize.small,
                              showDate: true,
                              summaryMaxLines: 3,
                              padding: EdgeInsets.fromLTRB(
                                gutter,
                                Insets.storyGap,
                                gutter,
                                Insets.storyGap,
                              ),
                              onOpen: (s, tag) => context.openStory(s, tag),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: gutter),
                              child: const ThinRule(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
