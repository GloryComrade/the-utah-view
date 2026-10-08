import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/theme.dart';
import 'rules.dart';

/// A gray bar standing in for text while content loads.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor = 1, this.height = 12});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: context.palette.ruleLight,
      ),
    );
  }
}

/// Placeholder for one story while the feed loads.
class StorySkeleton extends StatelessWidget {
  const StorySkeleton({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (large) ...[
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ColoredBox(color: context.palette.ruleLight),
          ),
          const SizedBox(height: 16),
        ],
        const SkeletonLine(widthFactor: 0.25, height: 9),
        const SizedBox(height: 6),
        SkeletonLine(height: large ? 26 : 18),
        SkeletonLine(widthFactor: 0.7, height: large ? 26 : 18),
        const SizedBox(height: 8),
        const SkeletonLine(height: 11),
        const SkeletonLine(widthFactor: 0.85, height: 11),
        const SizedBox(height: 8),
        const SkeletonLine(widthFactor: 0.4, height: 9),
      ],
    );
  }
}

/// A column of story skeletons separated by rules.
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key, this.count = 4, this.leadFirst = true});

  final int count;
  final bool leadFirst;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading stories',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Insets.storyGap),
                  child: ThinRule(),
                ),
              StorySkeleton(large: leadFirst && i == 0),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-area message with an optional action, used for empty and error
/// states.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Message for a failed load, with a Retry button.
  factory MessageView.error(Object error, {Key? key, VoidCallback? onRetry}) {
    final notFound =
        error is ApiException && error.kind == ApiErrorKind.notFound;
    final offline = error is ApiException && error.kind == ApiErrorKind.offline;
    return MessageView(
      key: key,
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: notFound
          ? 'Not available'
          : offline
          ? 'No connection'
          : "Couldn't load this",
      message: error is ApiException
          ? error.userMessage
          : 'Something went wrong. Try again shortly.',
      actionLabel: notFound ? null : 'Try again',
      onAction: notFound ? null : onRetry,
    );
  }

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: p.inkFaint),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: news.headlineM,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: news.summary.copyWith(color: p.inkMuted),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!.toUpperCase()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Centers [child] and caps its width so lines stay readable on tablets.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = Insets.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
