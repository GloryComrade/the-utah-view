import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/providers.dart';
import 'package:utah_view/core/storage/key_value_store.dart';
import 'package:utah_view/features/saved/saved_stories.dart';

void main() {
  late AppStores stores;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appStoresProvider.overrideWithValue(stores)],
    );
    addTearDown(c.dispose);
    return c;
  }

  const a = StoryDetail(id: 'a', title: 'A', body: '<p>Alpha</p>');
  const b = StoryDetail(id: 'b', title: 'B', body: '<p>Beta</p>');

  setUp(() => stores = AppStores.inMemory());

  test('save, list newest first, and remove', () async {
    final c = container();
    final saved = c.read(savedStoriesProvider.notifier);
    await saved.save(a);
    await saved.save(b);
    expect(c.read(savedStoriesProvider).map((s) => s.story.id), ['b', 'a']);
    expect(c.read(isSavedProvider('a')), isTrue);

    await saved.remove('a');
    expect(c.read(savedStoriesProvider).map((s) => s.story.id), ['b']);
    expect(c.read(isSavedProvider('a')), isFalse);
  });

  test('saved stories keep their full body and survive a restart', () async {
    await container().read(savedStoriesProvider.notifier).save(a);

    final restarted = container();
    final notifier = restarted.read(savedStoriesProvider.notifier);
    expect(restarted.read(savedStoriesProvider).single.story, a);
    expect(notifier.detail('a')?.body, '<p>Alpha</p>');
  });

  test('toggle reports the new state', () async {
    final notifier = container().read(savedStoriesProvider.notifier);
    expect(await notifier.toggle(a), isTrue);
    expect(await notifier.toggle(a), isFalse);
    expect(notifier.isSaved('a'), isFalse);
  });

  test(
    'a newer copy replaces the saved body but keeps the saved date',
    () async {
      final c = container();
      final notifier = c.read(savedStoriesProvider.notifier);
      await notifier.save(a);
      final savedAt = c.read(savedStoriesProvider).single.savedAt;

      await notifier.updateIfSaved(a.copyWith(body: '<p>Updated</p>'));
      final entry = c.read(savedStoriesProvider).single;
      expect(entry.story.body, '<p>Updated</p>');
      expect(entry.savedAt, savedAt);

      await notifier.updateIfSaved(b);
      expect(c.read(savedStoriesProvider), hasLength(1));
    },
  );

  test('undo restores an entry in its original position', () async {
    final c = container();
    final notifier = c.read(savedStoriesProvider.notifier);
    await notifier.save(a);
    await notifier.save(b);
    final removed = c.read(savedStoriesProvider).last;
    await notifier.remove(removed.story.id);
    await notifier.restore(removed);
    expect(c.read(savedStoriesProvider).map((s) => s.story.id), ['b', 'a']);
  });

  test('corrupt entries are ignored', () async {
    await stores.savedStories.write('bad', 'not json');
    await stores.savedStories.write('empty', '{"story": {}}');
    expect(container().read(savedStoriesProvider), isEmpty);
  });
}
