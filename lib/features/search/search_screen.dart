import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/domain/story_search.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/story_cards.dart';
import 'recent_searches.dart';

/// Searches the cached stories list on the device (there is no search
/// endpoint), so it also works offline.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _query = value);
  }

  void _open(Story story, Object? heroTag) {
    ref.read(recentSearchesProvider.notifier).add(_query);
    context.openStory(story, heroTag);
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesProvider);
    final stories = storiesAsync.value;
    final results = stories == null
        ? const <Story>[]
        : searchStories(stories, _query);
    final terms = {
      for (final word in _query.toLowerCase().split(RegExp(r'\s+')))
        if (word.isNotEmpty) word,
    };
    final p = context.palette;
    final gutter = context.gutter;

    final Widget body;
    if (_query.trim().isEmpty) {
      body = _Suggestions(onPick: _setQuery);
    } else if (stories == null) {
      body = storiesAsync.hasError
          ? MessageView.error(
              storiesAsync.error!,
              onRetry: () => ref.invalidate(storiesProvider),
            )
          : const Center(child: CircularProgressIndicator.adaptive());
    } else if (results.isEmpty) {
      body = MessageView(
        icon: Icons.search_off_rounded,
        title: 'No results for “${_query.trim()}”',
        message:
            'Try another spelling, a region such as “Europe”, or an '
            'author’s name.',
      );
    } else {
      body = ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: results.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return ContentWidth(
              maxWidth: 760,
              child: Padding(
                padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 4),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    '${results.length} '
                    '${results.length == 1 ? 'result' : 'results'}',
                    style: context.news.meta,
                  ),
                ),
              ),
            );
          }
          return ContentWidth(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StoryTile(
                  story: results[i - 1],
                  slot: 'search',
                  size: StoryTileSize.small,
                  showDate: true,
                  summaryMaxLines: 3,
                  highlight: terms,
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 16),
                  onOpen: _open,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: const ThinRule(),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Sit next to the back button, or keep a margin when there is none.
        titleSpacing: Navigator.of(context).canPop() ? 0 : gutter,
        centerTitle: false,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          onSubmitted: (value) =>
              ref.read(recentSearchesProvider.notifier).add(value),
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search stories, authors, regions',
            semanticCounterText: '',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            hintStyle: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: p.inkMuted),
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => _setQuery(''),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: body,
    );
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider);
    final regions = ref
        .watch(navCategoriesProvider)
        .where((c) => !c.section)
        .map((c) => c.text);
    final news = context.news;
    final gutter = context.gutter;

    Widget heading(String text, {Widget? trailing}) => Padding(
      padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 10),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text.toUpperCase(),
                semanticsLabel: text,
                style: news.sectionLabelMuted,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    Widget chips(Iterable<String> labels) => Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final label in labels)
            ActionChip(label: Text(label), onPressed: () => onPick(label)),
        ],
      ),
    );

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ContentWidth(
          maxWidth: 760,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (recent.isNotEmpty) ...[
                heading(
                  'Recent searches',
                  trailing: TextButton(
                    onPressed: ref.read(recentSearchesProvider.notifier).clear,
                    child: const Text('Clear'),
                  ),
                ),
                chips(recent),
              ],
              heading('Browse by region'),
              chips(regions),
              Padding(
                padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
                child: Text(
                  'Search covers headlines, summaries, authors and regions, '
                  'and works offline.',
                  style: news.meta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
