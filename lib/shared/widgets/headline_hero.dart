import 'package:material_ui/material_ui.dart';

/// Identifies one placement of a story so the same story can appear in
/// several slots (Home shows some stories twice) without Hero tag clashes.
@immutable
class StoryHeroTag {
  const StoryHeroTag(this.storyId, this.slot);

  final String storyId;

  /// Where the card sits, e.g. `home/lead` or `section/Europe`.
  final String slot;

  @override
  bool operator ==(Object other) =>
      other is StoryHeroTag && other.storyId == storyId && other.slot == slot;

  @override
  int get hashCode => Object.hash(storyId, slot);

  @override
  String toString() => 'StoryHeroTag($storyId @ $slot)';
}

/// Tag for the lead photo, which only ever appears once per screen.
Object storyImageHeroTag(String storyId) => 'story-image:$storyId';

/// A headline that flies from a list card into the article screen.
///
/// The flight interpolates between the two text styles and lets the text
/// overflow its moving bounds, so the headline grows smoothly instead of
/// snapping or throwing overflow errors mid-transition.
class HeadlineHero extends StatelessWidget {
  const HeadlineHero({
    super.key,
    required this.tag,
    required this.text,
    required this.style,
    this.maxLines,
  });

  /// Null renders a plain [Text] with no Hero.
  final Object? tag;
  final String text;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
    final heroTag = tag;
    if (heroTag == null) return label;
    return Hero(
      tag: heroTag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: _flight,
      child: _HeroText(
        style: style,
        text: text,
        child: Material(type: MaterialType.transparency, child: label),
      ),
    );
  }

  static Widget _flight(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final from = (fromHeroContext.widget as Hero).child;
    final to = (toHeroContext.widget as Hero).child;
    if (from is! _HeroText || to is! _HeroText) return to;
    // The lower route's headline is always the animation's start value.
    final (start, end) = direction == HeroFlightDirection.push
        ? (from, to)
        : (to, from);
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => OverflowBox(
          alignment: AlignmentDirectional.topStart,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Text(
            end.text,
            style: TextStyle.lerp(start.style, end.style, animation.value),
          ),
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.style,
    required this.text,
    required this.child,
  });

  final TextStyle style;
  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
