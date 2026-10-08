import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import 'html_image.dart';

/// Lets tests and the design gallery turn off network images (they fall
/// back to the placeholder) without touching every widget.
class ImagePolicy extends InheritedWidget {
  const ImagePolicy({
    super.key,
    required this.loadNetworkImages,
    required super.child,
  });

  final bool loadNetworkImages;

  static bool networkEnabled(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ImagePolicy>()
          ?.loadNetworkImages ??
      true;

  @override
  bool updateShouldNotify(ImagePolicy oldWidget) =>
      oldWidget.loadNetworkImages != loadNetworkImages;
}

/// The website's 135° light-gray gradient box, used while images load and
/// whenever there is no image.
class GradientPlaceholder extends StatelessWidget {
  const GradientPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.placeholderStart, p.placeholderEnd],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

/// A cached network image with the gradient placeholder.
///
/// On the web, fixed-ratio images render through a DOM `<img>` (see
/// [htmlImage]) so cross-origin images without CORS headers still display —
/// CanvasKit cannot decode those. Native platforms use [CachedNetworkImage].
class StoryImage extends StatelessWidget {
  const StoryImage({
    super.key,
    required this.url,
    this.aspectRatio = 16 / 10,
    this.borderRadius = 0,
    this.semanticLabel,
  });

  final String? url;

  /// Null keeps the image's own aspect ratio (article body images).
  final double? aspectRatio;
  final double borderRadius;

  /// Alt text. Null marks the image as decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    const placeholder = GradientPlaceholder();
    final src = url;
    final loadNetwork = src != null && ImagePolicy.networkEnabled(context);

    Widget image;
    if (!loadNetwork) {
      image = aspectRatio == null
          ? const AspectRatio(aspectRatio: 16 / 10, child: placeholder)
          : placeholder;
    } else if (kIsWeb && aspectRatio != null) {
      // Web, fixed box: a DOM <img> over the placeholder. The <img> is
      // transparent until it loads, so the gradient shows through meanwhile,
      // and a cross-origin source without CORS headers still renders.
      image = Stack(
        fit: StackFit.expand,
        children: [placeholder, htmlImage(src, fit: BoxFit.cover)],
      );
    } else {
      // Decode no larger than the screen is wide. (No LayoutBuilder here:
      // it would break IntrinsicHeight rows on tablets.)
      final mq = MediaQuery.of(context);
      final fallback = aspectRatio == null
          ? const AspectRatio(aspectRatio: 16 / 10, child: placeholder)
          : placeholder;
      image = CachedNetworkImage(
        imageUrl: src,
        fit: aspectRatio == null ? BoxFit.fitWidth : BoxFit.cover,
        width: double.infinity,
        memCacheWidth: (mq.size.width * mq.devicePixelRatio).round(),
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      );
    }

    if (aspectRatio != null) {
      image = AspectRatio(aspectRatio: aspectRatio!, child: image);
    }
    if (borderRadius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: image,
    );
  }
}
