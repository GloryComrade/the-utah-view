import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/features/article/share_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders a non-empty PNG for a story', () async {
    final bytes = await StoryShareCard.render(
      title: 'A test headline that is reasonably long to wrap a few lines',
      kicker: 'Europe',
      byline: 'By Jane Doe',
    );
    expect(bytes, isNotEmpty);
    // PNG magic number: 89 50 4E 47.
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  test('handles an empty title without throwing', () async {
    final bytes = await StoryShareCard.render(title: '');
    expect(bytes, isNotEmpty);
  });
}
