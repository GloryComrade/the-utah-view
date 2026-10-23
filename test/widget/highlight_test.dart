import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/shared/widgets/story_cards.dart';

void main() {
  const mark = TextStyle(fontWeight: FontWeight.w900);
  List<String> marked(String text, Set<String> terms) => [
    for (final s in highlightSpans(text, terms, mark))
      if (s.style == mark) s.text!,
  ];

  test('marks plain matches', () {
    expect(marked('Europe and Asia', {'europe'}), ['Europe']);
  });

  test('accent-free searches mark the accented word', () {
    expect(marked('Türkiye votes', {'turkiye'}), ['Türkiye']);
    expect(marked('Café talks in São Paulo', {'sao', 'cafe'}), ['Café', 'São']);
  });

  test('a match ending inside a folded letter covers the whole letter', () {
    expect(marked('Straße', {'strass'}), ['Straß']);
  });
}
