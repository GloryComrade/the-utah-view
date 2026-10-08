import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/core/domain/story_search.dart';

import '../support/fixtures.dart';

void main() {
  const stories = [
    Story(
      id: 'turkey',
      title: 'Türkiye: A Democracy Decided by Tear Gas',
      author: 'Benjamin Koh',
      region: 'Europe',
      summary: 'Protests in Istanbul.',
      date: '2026-05-25',
    ),
    Story(
      id: 'korea-summary',
      title: 'Drone Education',
      author: 'Benjamin Koh',
      region: 'Asia-Pacific',
      summary: 'What 15,000 North Korean soldiers are learning.',
      date: '2026-05-26',
    ),
    Story(
      id: 'korea-title',
      title: 'North Korea Builds Rocket Shelters',
      author: 'Benjamin Koh',
      region: 'Asia-Pacific',
      summary: 'Twenty-one new structures near Kaesong.',
      date: '2026-07-22',
    ),
    Story(
      id: 'algorithm',
      title: 'The Algorithm Has More Power Than You Think',
      author: 'Ryan Cheng',
      region: 'Global',
      summary: 'Transparency, not elimination.',
      date: '2026-05-25',
    ),
  ];

  List<String> ids(String query) =>
      searchStories(stories, query).map((s) => s.id).toList();

  test('folding strips accents and case', () {
    expect(foldForSearch('Türkiye'), 'turkiye');
    expect(foldForSearch('ŁÓDŹ Œuvre'), 'lodz oeuvre');
    expect(foldForSearch('It’s'), "it's");
  });

  test('an empty query returns nothing', () {
    expect(ids(''), isEmpty);
    expect(ids('   '), isEmpty);
  });

  test('searches title, summary, author and region', () {
    expect(ids('tear gas'), ['turkey']);
    expect(ids('kaesong'), ['korea-title']);
    expect(ids('ryan'), ['algorithm']);
    expect(ids('global'), ['algorithm']);
  });

  test('accent-insensitive', () {
    expect(ids('turkiye'), ['turkey']);
    expect(ids('TÜRKIYE'), ['turkey']);
  });

  test('every word must match', () {
    expect(ids('korea rocket'), ['korea-title']);
    expect(ids('korea europe'), isEmpty);
  });

  test('title matches rank above summary matches', () {
    expect(ids('korea'), ['korea-title', 'korea-summary']);
  });

  test('ties go to the newest story', () {
    expect(ids('benjamin'), ['korea-title', 'korea-summary', 'turkey']);
  });

  test('works on the live stories list', () {
    final live = parseStoryList(fixture('stories.json'));
    final results = searchStories(live, 'zelenskyy');
    expect(results, isNotEmpty);
    expect(
      results.every(
        (s) => foldForSearch('${s.title} ${s.summary}').contains('zelenskyy'),
      ),
      isTrue,
    );
  });
}
