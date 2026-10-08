import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/utils/formatters.dart';
import 'package:utah_view/shared/widgets/article_body.dart';

void main() {
  group('formatStoryDate', () {
    test('YYYY-MM-DD becomes "May 25, 2026"', () {
      expect(formatStoryDate('2026-05-25'), 'May 25, 2026');
      expect(formatStoryDate('2026-01-01'), 'January 1, 2026');
      expect(formatStoryDate('2026-12-31'), 'December 31, 2026');
    });

    test('timestamps use their date part', () {
      expect(formatStoryDate('2026-07-23 03:20:02'), 'July 23, 2026');
      expect(formatStoryDate('2026-07-23T03:20:02Z'), 'July 23, 2026');
    });

    test('invalid dates are shown as typed', () {
      expect(formatStoryDate(''), '');
      expect(formatStoryDate('2026-02-31'), '2026-02-31');
      expect(formatStoryDate('2026-13-01'), '2026-13-01');
      expect(formatStoryDate(' Spring 2026 '), 'Spring 2026');
    });
  });

  test('formatMastheadDate', () {
    expect(
      formatMastheadDate(DateTime(2026, 10, 6)),
      'Tuesday, October 6, 2026',
    );
    expect(formatMastheadDate(DateTime(2026, 5, 25)), 'Monday, May 25, 2026');
  });

  group('formatReadTime', () {
    test('normalises durations', () {
      expect(formatReadTime('3 min'), '3 min read');
      expect(formatReadTime('3'), '3 min read');
      expect(formatReadTime(' 12 min '), '12 min read');
      expect(formatReadTime('5 min read'), '5 min read');
    });

    test('drops empty and non-duration values', () {
      expect(formatReadTime(''), isNull);
      expect(formatReadTime('   '), isNull);
      expect(formatReadTime('Charlie Kirk'), isNull);
      expect(formatReadTime('a very long value with 1 digit in it'), isNull);
    });
  });

  test('formatListIndex pads to two digits', () {
    expect(formatListIndex(0), '01');
    expect(formatListIndex(9), '10');
  });

  group('sanitizeArticleHtml', () {
    test('strips pasted inline styles and attributes', () {
      const html =
          '<p dir="ltr" style="line-height:1.38;background-color:#ffffff;">'
          '<span style="font-size:12pt;color:#333333;">Text</span></p>';
      expect(sanitizeArticleHtml(html), '<p><span>Text</span></p>');
    });

    test('removes empty paragraphs', () {
      expect(
        sanitizeArticleHtml('<p><br></p><p>Body</p><p>&nbsp;</p>'),
        '<p>Body</p>',
      );
    });

    test('keeps structure and links', () {
      const html =
          '<h3>Head</h3><blockquote>Q</blockquote>'
          '<a href="https://x.com">x</a><img src="/images/a.jpg">';
      expect(sanitizeArticleHtml(html), html);
    });
  });
}
