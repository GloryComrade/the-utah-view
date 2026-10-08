import '../api/models/models.dart';

const _folds = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a', //
  'ă': 'a', 'ą': 'a', 'ç': 'c', 'ć': 'c', 'č': 'c', 'ď': 'd', 'đ': 'd', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ę': 'e', 'ě': 'e', //
  'ğ': 'g', 'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'ı': 'i', //
  'ł': 'l', 'ñ': 'n', 'ń': 'n', 'ň': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', //
  'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o', 'ő': 'o', 'ř': 'r', 'ś': 's', //
  'ş': 's', 'š': 's', 'ș': 's', 'ť': 't', 'ț': 't', 'ù': 'u', 'ú': 'u', //
  'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u', 'ý': 'y', 'ÿ': 'y', //
  'ź': 'z', 'ż': 'z', 'ž': 'z', 'æ': 'ae', 'œ': 'oe', 'ß': 'ss', //
  '‘': "'", '’': "'", '“': '"', '”': '"', '–': '-', '—': '-',
};

/// Lower-cases and strips accents so "turkiye" finds "Türkiye".
String foldForSearch(String text) {
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    out.write(_folds[char] ?? char);
  }
  return out.toString();
}

/// The distinct search words in [query], folded.
List<String> searchTerms(String query) => {
  for (final word in foldForSearch(query).split(RegExp(r'\s+')))
    if (word.isNotEmpty) word,
}.toList();

/// Client-side search over title, summary, author and region.
///
/// Every word must appear somewhere in the story. Results are ranked by where
/// the words matched (title, then author, region, summary), then newest
/// first.
List<Story> searchStories(Iterable<Story> stories, String query) {
  final terms = searchTerms(query);
  if (terms.isEmpty) return const [];

  final hits = <(Story, int)>[];
  for (final story in stories) {
    final title = foldForSearch(story.title);
    final author = foldForSearch(story.author);
    final region = foldForSearch(story.region);
    final summary = foldForSearch(story.summary);
    var score = 0;
    var matchesAll = true;
    for (final term in terms) {
      final inTitle = title.contains(term);
      final inAuthor = author.contains(term);
      final inRegion = region.contains(term);
      final inSummary = summary.contains(term);
      if (!(inTitle || inAuthor || inRegion || inSummary)) {
        matchesAll = false;
        break;
      }
      score +=
          (inTitle ? 8 : 0) +
          (inAuthor ? 4 : 0) +
          (inRegion ? 3 : 0) +
          (inSummary ? 1 : 0);
    }
    if (matchesAll) hits.add((story, score));
  }

  // List.sort isn't stable; break ties on date, then the original order.
  final order = {for (final (i, (s, _)) in hits.indexed) s.id: i};
  hits.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    if (byScore != 0) return byScore;
    final byDate = b.$1.date.compareTo(a.$1.date);
    if (byDate != 0) return byDate;
    return order[a.$1.id]!.compareTo(order[b.$1.id]!);
  });
  return [for (final (story, _) in hits) story];
}
