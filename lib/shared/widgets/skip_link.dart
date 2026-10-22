import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

/// App-root focus target. Activating the skip link moves keyboard focus here,
/// so the next Tab lands in the page content instead of the navigation.
final mainContentFocusNode = FocusNode(debugLabel: 'mainContent');

/// Wraps [child] so keyboard users reach a "Skip to main content" link first
/// (web only — native platforms route this through their own screen readers).
Widget withSkipLink(Widget child) {
  final content = Focus(
    focusNode: mainContentFocusNode,
    child: child,
  );
  if (!kIsWeb) return content;
  return FocusTraversalGroup(
    policy: OrderedTraversalPolicy(),
    child: Stack(
      children: [
        FocusTraversalOrder(
          order: const NumericFocusOrder(2),
          child: content,
        ),
        const FocusTraversalOrder(
          order: NumericFocusOrder(1),
          child: Align(alignment: Alignment.topLeft, child: _SkipLink()),
        ),
      ],
    ),
  );
}

/// A link kept just off the top edge until it takes keyboard focus, then it
/// slides into view. It stays in the focus tree throughout, so Tab reaches it
/// first; a pointer never sees it.
class _SkipLink extends StatefulWidget {
  const _SkipLink();

  @override
  State<_SkipLink> createState() => _SkipLinkState();
}

class _SkipLinkState extends State<_SkipLink> {
  final _node = FocusNode(debugLabel: 'skipLink');

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _node
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  void _skip() => mainContentFocusNode.requestFocus();

  @override
  Widget build(BuildContext context) {
    final shown = _node.hasFocus;
    return Transform.translate(
      offset: shown ? Offset.zero : const Offset(0, -80),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FilledButton(
          focusNode: _node,
          onPressed: _skip,
          child: const Text('Skip to main content'),
        ),
      ),
    );
  }
}
