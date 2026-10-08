import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/domain/story_filters.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/list_rows.dart';
import '../../shared/widgets/state_views.dart';

/// Regions, sections and the archive.
class SectionsScreen extends ConsumerStatefulWidget {
  const SectionsScreen({super.key});

  @override
  ConsumerState<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends ConsumerState<SectionsScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listenForTabReselect(ref, 1, _scroll);
    final categories = ref.watch(navCategoriesProvider);
    final stories = ref.watch(storiesProvider).value;

    Widget row(NavCategory category) {
      final count = stories == null
          ? null
          : storiesForCategory(stories, category).length;
      return NavRow(
        title: category.text,
        trailingText: count?.toString(),
        trailingSemantics: count == null
            ? null
            : '$count ${count == 1 ? 'story' : 'stories'}',
        onTap: () => context.openCategory(category.text),
      );
    }

    final regions = categories.where((c) => !c.section).toList();
    final sections = categories.where((c) => c.section).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sections')),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ContentWidth(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (regions.isNotEmpty) ...[
                  const GroupLabel('Regions'),
                  for (final c in regions) row(c),
                ],
                if (sections.isNotEmpty) ...[
                  const GroupLabel('Sections'),
                  for (final c in sections) row(c),
                ],
                const GroupLabel('Archive'),
                NavRow(
                  title: 'All stories',
                  subtitle: 'Every issue, newest first',
                  trailingText: stories?.length.toString(),
                  trailingSemantics: stories == null
                      ? null
                      : '${stories.length} stories',
                  onTap: context.openArchive,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.gutter,
                    24,
                    context.gutter,
                    0,
                  ),
                  child: Text(
                    'Analysis, Opinion and Data also include global pieces '
                    'and The Utah Lens.',
                    style: context.news.meta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
