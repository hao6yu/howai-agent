import 'package:flutter/material.dart';

/// Opens a drawer after a short, intentional swipe from the leading edge.
///
/// A raw pointer listener is used instead of a competing drag recognizer so
/// vertical scrolling and other gestures in [child] keep working normally.
class EdgeSwipeDrawerOpener extends StatefulWidget {
  const EdgeSwipeDrawerOpener({
    super.key,
    required this.child,
    required this.onOpen,
    this.onTap,
    this.enabled = true,
    this.edgeWidth = 36,
    this.activationDistance = 28,
  });

  final Widget child;
  final VoidCallback onOpen;
  final GestureTapCallback? onTap;
  final bool enabled;
  final double edgeWidth;
  final double activationDistance;

  @override
  State<EdgeSwipeDrawerOpener> createState() => _EdgeSwipeDrawerOpenerState();
}

class _EdgeSwipeDrawerOpenerState extends State<EdgeSwipeDrawerOpener> {
  int? _trackedPointer;
  Offset? _dragStart;

  void _reset() {
    _trackedPointer = null;
    _dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          key: const ValueKey<String>('drawer_edge_swipe_listener'),
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (!widget.enabled || _trackedPointer != null) return;

            final distanceFromLeadingEdge = isRtl
                ? constraints.maxWidth - event.localPosition.dx
                : event.localPosition.dx;
            if (distanceFromLeadingEdge < 0 ||
                distanceFromLeadingEdge > widget.edgeWidth) {
              return;
            }

            _trackedPointer = event.pointer;
            _dragStart = event.localPosition;
          },
          onPointerMove: (event) {
            if (event.pointer != _trackedPointer || _dragStart == null) return;

            final delta = event.localPosition - _dragStart!;
            final openingDistance = isRtl ? -delta.dx : delta.dx;
            final isIntentionalHorizontalSwipe =
                openingDistance >= widget.activationDistance &&
                openingDistance > delta.dy.abs();

            if (!isIntentionalHorizontalSwipe) return;

            _reset();
            widget.onOpen();
          },
          onPointerUp: (event) {
            if (event.pointer == _trackedPointer) _reset();
          },
          onPointerCancel: (event) {
            if (event.pointer == _trackedPointer) _reset();
          },
          child: widget.onTap == null
              ? widget.child
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onTap,
                  child: widget.child,
                ),
        );
      },
    );
  }
}
