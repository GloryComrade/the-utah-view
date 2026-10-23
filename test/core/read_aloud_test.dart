import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/features/article/read_aloud.dart';

void main() {
  test('short text is one piece', () {
    expect(splitForSpeech('  One sentence. Two.  '), ['One sentence. Two.']);
    expect(splitForSpeech('   '), isEmpty);
  });

  test('long articles split under the Android limit, at sentence ends', () {
    const sentence = 'The council met on Tuesday to discuss the budget. ';
    final text = sentence * 200; // about 10,000 characters
    final chunks = splitForSpeech(text);
    expect(chunks.length, greaterThan(2));
    for (final c in chunks) {
      expect(c.length, lessThanOrEqualTo(maxSpeechChunk));
      expect(c, endsWith('.'));
    }
    expect(chunks.join(' '), text.trim());
  });

  test('falls back to spaces, then hard cuts', () {
    expect(splitForSpeech('aaaa bbbb cccc', max: 10), ['aaaa bbbb', 'cccc']);
    expect(splitForSpeech('abcdefghij', max: 4), ['abcd', 'efgh', 'ij']);
  });
}
