import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/api/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/article_body.dart';
import '../../shared/widgets/rules.dart';
import '../../shared/widgets/state_views.dart';

/// A static page from the CMS (Our Mission, Contact, Privacy Policy…).
class PageScreen extends ConsumerWidget {
  const PageScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(sitePageProvider(slug));
    final summary = ref
        .watch(pagesProvider)
        .value
        ?.firstWhereOrNull((p) => p.slug == slug);
    final scale = ref.watch(settingsProvider.select((s) => s.readingScale));
    final news = context.news;
    final title = page.value?.title.isNotEmpty == true
        ? page.value!.title
        : summary?.title ?? '';
    final subtitle = page.value?.subtitle.isNotEmpty == true
        ? page.value!.subtitle
        : summary?.subtitle ?? '';
    final error = page.error;
    final notFound =
        error is ApiException && error.kind == ApiErrorKind.notFound;

    final Widget body;
    if (page.value case final value?) {
      body = value.body.trim().isEmpty
          ? Text('This page is coming soon.', style: news.summary)
          : SelectionArea(
              child: ArticleBody(
                html: value.body,
                scale: scale,
                onTapUrl: context.followArticleLink,
              ),
            );
    } else if (page.hasError && !page.isLoading) {
      body = notFound
          ? const MessageView(
              icon: Icons.article_outlined,
              title: 'Not available yet',
              message:
                  'This page hasn’t been published in the app. Check '
                  'back soon.',
            )
          : MessageView.error(
              error!,
              onRetry: () => ref.invalidate(sitePageProvider(slug)),
            );
    } else {
      body = const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonLine(height: 14),
          SkeletonLine(height: 14),
          SkeletonLine(widthFactor: 0.7, height: 14),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.gutter,
          20,
          context.gutter,
          40 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          ContentWidth(
            maxWidth: Insets.maxReadingWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title.isNotEmpty)
                  Semantics(
                    header: true,
                    child: Text(title, style: news.pageTitle),
                  ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(subtitle, style: news.articleSummary),
                ],
                const SizedBox(height: 16),
                const ThickRule(),
                const SizedBox(height: 22),
                body,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
