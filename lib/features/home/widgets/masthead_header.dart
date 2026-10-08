import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/google_auth.dart';
import '../../../core/auth/google_signin_button.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/html_image.dart';
import '../../../shared/widgets/rules.dart';

/// The front-page masthead. Expanded, it's the full newspaper flag (logo,
/// wordmark, tagline, today's date between rules); as the page scrolls it
/// collapses into a slim bar with a small lockup, like the WSJ app.
class MastheadHeaderDelegate extends SliverPersistentHeaderDelegate {
  MastheadHeaderDelegate({
    required this.topPadding,
    required this.textScaler,
    required this.date,
    required this.onSearch,
    required this.background,
  });

  static const toolbarHeight = 56.0;
  static const _logo = 38.0;

  final double topPadding;
  final TextScaler textScaler;
  final DateTime date;
  final VoidCallback onSearch;
  final Color background;

  // Mirrors the Column in _ExpandedMasthead so the header is exactly as tall
  // as its content at any text size.
  double get _expandedHeight =>
      10 +
      _logo +
      8 +
      textScaler.scale(10.5) * 1.3 +
      12 +
      2 +
      8 +
      textScaler.scale(11) * 1.3 +
      8 +
      1;

  @override
  double get minExtent => topPadding + toolbarHeight;

  @override
  double get maxExtent =>
      topPadding +
      (_expandedHeight > toolbarHeight ? _expandedHeight : toolbarHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final expandedOpacity = (1 - t * 1.7).clamp(0.0, 1.0);
    final compactOpacity = ((t - 0.55) / 0.45).clamp(0.0, 1.0);

    return Material(
      color: background,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: topPadding - shrinkOffset,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: expandedOpacity,
              child: _ExpandedMasthead(date: date, logoSize: _logo),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 56,
            right: 56,
            height: toolbarHeight,
            child: Opacity(
              opacity: compactOpacity,
              child: const Center(
                child: Lockup(logoSize: 24, wordmarkSize: 16),
              ),
            ),
          ),
          Positioned(
            top: topPadding + (toolbarHeight - 48) / 2,
            right: 4,
            child: IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
              onPressed: onSearch,
            ),
          ),
          Positioned(
            top: topPadding + (toolbarHeight - 40) / 2,
            left: 8,
            child: const _MastheadSignIn(),
          ),
          if (t >= 1)
            const Positioned(left: 0, right: 0, bottom: 0, child: ThinRule()),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(MastheadHeaderDelegate old) =>
      old.topPadding != topPadding ||
      old.textScaler != textScaler ||
      old.date != date ||
      old.background != background ||
      old.onSearch != onSearch;
}

class _ExpandedMasthead extends StatelessWidget {
  const _ExpandedMasthead({required this.date, required this.logoSize});

  final DateTime date;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final news = context.news;
    final today = formatMastheadDate(date);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: logoSize,
            child: Center(
              child: Padding(
                // Keep clear of the search button.
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Lockup(logoSize: logoSize, wordmarkSize: logoSize * 0.6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // One line at any text size, so the header height stays exact.
          const FittedBox(fit: BoxFit.scaleDown, child: Tagline()),
          const SizedBox(height: 12),
          const HeavyRule(),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              today.toUpperCase(),
              semanticsLabel: today,
              maxLines: 1,
              style: news.dateline,
            ),
          ),
          const SizedBox(height: 8),
          const ThinRule(),
        ],
      ),
    );
  }
}

/// Web-only Google sign-in in the masthead corner. Signed out: the compact
/// Google icon button. Signed in: an avatar with a sign-out menu. On mobile it
/// renders nothing (the More tab has the account controls there).
class _MastheadSignIn extends ConsumerWidget {
  const _MastheadSignIn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) return const SizedBox.shrink();
    final user = ref.watch(authControllerProvider).value;
    if (user == null) {
      return SizedBox(
        height: 40,
        width: 40,
        child: googleSignInButton(compact: true),
      );
    }
    final label = user.name.isNotEmpty ? user.name : user.email;
    final initial = label.isNotEmpty ? label.substring(0, 1).toUpperCase() : '?';
    return PopupMenuButton<String>(
      tooltip: user.email,
      position: PopupMenuPosition.under,
      onSelected: (v) {
        if (v == 'out') ref.read(authControllerProvider.notifier).signOut();
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(enabled: false, child: Text(user.email)),
        const PopupMenuItem<String>(value: 'out', child: Text('Sign out')),
      ],
      child: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
          ? ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: htmlImage(user.photoUrl!),
              ),
            )
          : CircleAvatar(
              radius: 16,
              backgroundColor: context.palette.accent,
              child: Text(
                initial,
                style: const TextStyle(
                  color: BrandColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
