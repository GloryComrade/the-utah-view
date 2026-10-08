import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/domain/story_index.dart';

/// The front page with every layout id resolved to a published story.
/// Unknown ids have already been dropped.
@immutable
class HomeFeed {
  const HomeFeed({
    this.ticker = '',
    this.lead,
    this.leadImageUrl,
    this.leadImageCaption = '',
    this.topStories = const [],
    this.fromThisIssue = const [],
    this.editorial = const [],
    this.regions = const [],
    this.featured = const [],
    this.utahLens = const [],
    this.dataBrief = const [],
    this.latest = const [],
    this.sectionOrder = const [],
    this.hiddenSections = const [],
    this.labels = const {},
  });

  /// Builds the feed from [layout], or a simple newest-first front page when
  /// the layout couldn't be loaded.
  factory HomeFeed.build(StoryIndex index, LayoutConfig? layout) {
    if (layout == null) {
      final all = index.stories;
      return HomeFeed(
        lead: all.firstOrNull,
        latest: all.skip(1).take(12).toList(),
      );
    }

    // If the lead is unpublished, promote the next story the editors placed.
    final configuredLead = index[layout.heroLead];
    final lead =
        configuredLead ??
        index.resolve([
          layout.heroSecondary,
          layout.heroCenter,
          ...layout.heroRight,
          ...layout.featured,
        ]).firstOrNull ??
        index.stories.firstOrNull;

    List<Story> resolve(Iterable<String> ids) => index.resolve(ids);

    return HomeFeed(
      ticker: layout.ticker,
      lead: lead,
      // The hero photo belongs to the configured lead; don't attach it to a
      // promoted stand-in.
      leadImageUrl: configuredLead == null ? null : layout.heroImageUrl,
      leadImageCaption: layout.heroCenterCaption,
      topStories: resolve([layout.heroSecondary, layout.heroCenter])
          .where((s) => s.id != lead?.id)
          .toList(),
      fromThisIssue: resolve(layout.heroRight),
      editorial: resolve(layout.editorial),
      regions: [
        for (final MapEntry(key: region, value: id) in layout.orderedRegions)
          if (index[id] case final story?) (region, story),
      ],
      featured: resolve(layout.featured),
      utahLens: resolve(layout.sidebarUtah),
      dataBrief: resolve(layout.sidebarData),
      sectionOrder: layout.sectionOrder,
      hiddenSections: layout.hiddenSections,
      labels: layout.sectionLabels,
    );
  }

  final String ticker;
  final Story? lead;
  final String? leadImageUrl;
  final String leadImageCaption;

  /// Secondary and center stories.
  final List<Story> topStories;

  /// `hero_right`.
  final List<Story> fromThisIssue;
  final List<Story> editorial;

  /// One story per region, in website order.
  final List<(String, Story)> regions;

  /// "In This Issue", numbered.
  final List<Story> featured;
  final List<Story> utahLens;
  final List<Story> dataBrief;

  /// Newest stories, used only when there is no layout.
  final List<Story> latest;

  /// Editor-chosen section order; empty means [defaultSectionOrder].
  final List<String> sectionOrder;

  /// Section ids the editor hid.
  final List<String> hiddenSections;

  /// Custom section labels by section id.
  final Map<String, String> labels;

  static const defaultSectionOrder = <String>[
    'hero',
    'editorial',
    'regions',
    'featured',
    'utahLens',
    'dataBrief',
  ];

  List<String> get orderedSections =>
      sectionOrder.isNotEmpty ? sectionOrder : defaultSectionOrder;

  bool isHidden(String id) => hiddenSections.contains(id);

  String labelFor(String id, String fallback) {
    final v = labels[id]?.trim();
    return (v != null && v.isNotEmpty) ? v : fallback;
  }
}

/// Combines stories and layout. Shows the cached front page immediately; if
/// only the layout is unavailable, falls back to newest-first.
final homeFeedProvider = Provider<AsyncValue<HomeFeed>>((ref) {
  final stories = ref.watch(storiesProvider);
  final layout = ref.watch(layoutProvider);
  final list = stories.value;
  if (list == null) {
    if (stories.hasError) {
      return AsyncError(
        stories.error!,
        stories.stackTrace ?? StackTrace.current,
      );
    }
    return const AsyncLoading();
  }
  final layoutValue = layout.value;
  if (layoutValue == null && !layout.hasError) return const AsyncLoading();
  return AsyncData(HomeFeed.build(StoryIndex(list), layoutValue));
});
