import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/router/app_router.dart';
import 'package:utah_view/core/router/deep_links.dart';

DeepLinkTarget? parse(String url) => DeepLinks.parse(Uri.parse(url));

void main() {
  group('website URLs', () {
    test('article links open the story', () {
      expect(
        parse('https://theutahview.com/article.html?id=abc'),
        isA<StoryTarget>().having((t) => t.id, 'id', 'abc'),
      );
      expect(
        parse('https://www.theutahview.com/article?id=abc'),
        isA<StoryTarget>().having((t) => t.id, 'id', 'abc'),
      );
      expect(parse('https://theutahview.com/article.html'), isA<HomeTarget>());
    });

    test('pages, categories, archive and saved', () {
      expect(
        parse('https://theutahview.com/page.html?p=our-mission'),
        isA<PageTarget>().having((t) => t.slug, 'slug', 'our-mission'),
      );
      expect(
        parse('https://theutahview.com/?cat=The%20Americas'),
        isA<CategoryTarget>().having((t) => t.name, 'name', 'The Americas'),
      );
      expect(
        parse('https://theutahview.com/?view=archive'),
        isA<ArchiveTarget>(),
      );
      expect(parse('https://theutahview.com/?view=saved'), isA<SavedTarget>());
      expect(parse('https://theutahview.com/'), isA<HomeTarget>());
      expect(parse('https://theutahview.com/index.html'), isA<HomeTarget>());
    });

    test('other sites, other schemes and unknown paths stay outside', () {
      expect(parse('https://example.com/article.html?id=x'), isNull);
      expect(parse('mailto:editor@theutahview.com'), isNull);
      expect(parse('https://theutahview.com/editor.html'), isNull);
    });

    test('the theutahview:// test scheme', () {
      expect(
        parse('theutahview://article?id=abc'),
        isA<StoryTarget>().having((t) => t.id, 'id', 'abc'),
      );
      expect(
        parse('theutahview://app/article.html?id=abc'),
        isA<StoryTarget>().having((t) => t.id, 'id', 'abc'),
      );
    });

    test('relative links inside article HTML', () {
      expect(
        DeepLinks.parseLink('article.html?id=abc'),
        isA<StoryTarget>().having((t) => t.id, 'id', 'abc'),
      );
      expect(
        DeepLinks.parseLink('/page?p=contact'),
        isA<PageTarget>().having((t) => t.slug, 'slug', 'contact'),
      );
      expect(DeepLinks.parseLink('https://www.npr.org/story'), isNull);
    });
  });

  group('router redirect', () {
    String? redirect(String location) =>
        redirectWebsiteLinks(Uri.parse(location));

    test('website paths map to app routes', () {
      expect(redirect('/'), '/home');
      expect(redirect('/article.html?id=abc'), '/home/story/abc');
      expect(redirect('/article.html?id=a%20b'), '/home/story/a%20b');
      expect(redirect('/page.html?p=About%20Us'), '/more/page/About%20Us');
      expect(redirect('/?cat=Middle%20East'), '/sections/c/Middle%20East');
      expect(redirect('/?view=archive'), '/sections/archive');
      expect(redirect('/?view=saved'), '/saved');
      expect(redirect('/editor.html'), '/home');
    });

    test("the app's own routes are left alone", () {
      for (final path in [
        '/home',
        '/story/abc',
        '/sections/c/Europe',
        '/more/page/contact',
        '/search',
      ]) {
        expect(redirect(path), isNull, reason: path);
      }
    });
  });
}
