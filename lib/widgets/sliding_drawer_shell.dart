import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../core/accessibility/motion_preferences.dart';

/// An interactive leading-edge drawer that moves the main surface with the
/// user's finger instead of covering it.
class SlidingDrawerShell extends StatefulWidget {
  const SlidingDrawerShell({
    super.key,
    required this.drawer,
    required this.child,
    this.onChildTap,
    this.onOpening,
    this.edgeWidth = 42,
    this.drawerWidthFactor = 0.84,
    this.maxDrawerWidth = 360,
    this.settleThreshold = 0.3,
    this.flingVelocity = 420,
    this.closeSemanticsLabel = 'Close navigation',
  });

  final Widget drawer;
  final Widget child;
  final GestureTapCallback? onChildTap;
  final VoidCallback? onOpening;
  final double edgeWidth;
  final double drawerWidthFactor;
  final double maxDrawerWidth;
  final double settleThreshold;
  final double flingVelocity;
  final String closeSemanticsLabel;

  @override
  State<SlidingDrawerShell> createState() => SlidingDrawerShellState();
}

class SlidingDrawerShellState extends State<SlidingDrawerShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _trackedPointer;
  Offset? _dragStart;
  double _dragStartValue = 0;
  bool _horizontalDragAccepted = false;
  VelocityTracker? _velocityTracker;

  bool get isOpen => _controller.value >= 1;
  double get progress => _controller.value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: HowAIMotion.drawerTransition,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> open() {
    if (_controller.value == 0) widget.onOpening?.call();
    return _animateTo(1);
  }

  Future<void> close() => _animateTo(0);

  Future<void> _animateTo(double target, {double velocity = 0}) async {
    _controller.stop();
    if (prefersReducedMotion(context)) {
      _controller.value = target;
      return;
    }

    final simulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 380, damping: 39),
      _controller.value,
      target,
      velocity.clamp(-4.0, 4.0),
    );
    await _controller.animateWith(simulation);
    if (mounted) _controller.value = target;
  }

  void _resetDrag() {
    _trackedPointer = null;
    _dragStart = null;
    _horizontalDragAccepted = false;
    _velocityTracker = null;
  }

  void _settleDrawer({required bool isRtl, required double drawerExtent}) {
    final velocity = _velocityTracker?.getVelocity().pixelsPerSecond.dx ?? 0;
    final openingVelocity = isRtl ? -velocity : velocity;
    final shouldOpen = openingVelocity.abs() >= widget.flingVelocity
        ? openingVelocity > 0
        : _controller.value >= widget.settleThreshold;
    _resetDrag();
    unawaited(
      _animateTo(shouldOpen ? 1 : 0, velocity: openingVelocity / drawerExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final drawerExtent = (constraints.maxWidth * widget.drawerWidthFactor)
            .clamp(0.0, widget.maxDrawerWidth)
            .toDouble();

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final currentProgress = _controller.value;
            final direction = isRtl ? -1.0 : 1.0;
            final panelOffset = drawerExtent * currentProgress * direction;

            return PopScope(
              canPop: currentProgress == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) unawaited(close());
              },
              child: Listener(
                key: const ValueKey<String>('sliding_drawer_pointer_listener'),
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  if (_trackedPointer != null) return;

                  final distanceFromLeadingEdge = isRtl
                      ? constraints.maxWidth - event.localPosition.dx
                      : event.localPosition.dx;
                  final canStart =
                      currentProgress > 0 ||
                      (distanceFromLeadingEdge >= 0 &&
                          distanceFromLeadingEdge <= widget.edgeWidth);
                  if (!canStart) return;

                  _controller.stop();
                  _trackedPointer = event.pointer;
                  _dragStart = event.localPosition;
                  _dragStartValue = currentProgress;
                  _horizontalDragAccepted = false;
                  _velocityTracker = VelocityTracker.withKind(event.kind)
                    ..addPosition(event.timeStamp, event.localPosition);
                },
                onPointerMove: (event) {
                  if (event.pointer != _trackedPointer || _dragStart == null) {
                    return;
                  }

                  _velocityTracker?.addPosition(
                    event.timeStamp,
                    event.localPosition,
                  );
                  var delta = event.localPosition - _dragStart!;
                  var openingDistance = isRtl ? -delta.dx : delta.dx;

                  if (!_horizontalDragAccepted) {
                    if (delta.distance < kTouchSlop) return;
                    if (delta.dy.abs() >= delta.dx.abs() ||
                        (_dragStartValue == 0 && openingDistance <= 0)) {
                      _resetDrag();
                      return;
                    }
                    _horizontalDragAccepted = true;
                    if (_dragStartValue == 0) widget.onOpening?.call();
                    // Discard the gesture-recognition slop so accepting the
                    // horizontal swipe does not make the panel jump.
                    _dragStart =
                        _dragStart! + Offset(delta.dx.sign * kTouchSlop, 0);
                    _dragStartValue = _controller.value;
                    delta = event.localPosition - _dragStart!;
                    openingDistance = isRtl ? -delta.dx : delta.dx;
                  }

                  _controller.value =
                      (_dragStartValue + openingDistance / drawerExtent).clamp(
                        0.0,
                        1.0,
                      );
                },
                onPointerUp: (event) {
                  if (event.pointer != _trackedPointer) return;
                  _velocityTracker?.addPosition(
                    event.timeStamp,
                    event.localPosition,
                  );
                  if (_horizontalDragAccepted) {
                    _settleDrawer(isRtl: isRtl, drawerExtent: drawerExtent);
                  } else {
                    _resetDrag();
                  }
                },
                onPointerCancel: (event) {
                  if (event.pointer != _trackedPointer) return;
                  if (_horizontalDragAccepted) {
                    _settleDrawer(isRtl: isRtl, drawerExtent: drawerExtent);
                  } else {
                    _resetDrag();
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      bottom: 0,
                      width: drawerExtent,
                      child: IgnorePointer(
                        ignoring: currentProgress < 1,
                        child: Transform.translate(
                          offset: Offset(
                            -direction *
                                drawerExtent *
                                0.06 *
                                (1 - currentProgress),
                            0,
                          ),
                          child: RepaintBoundary(
                            key: const ValueKey<String>(
                              'sliding_drawer_repaint_boundary',
                            ),
                            child: widget.drawer,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(panelOffset, 0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: widget.onChildTap,
                              child: RepaintBoundary(
                                key: const ValueKey<String>(
                                  'sliding_chat_repaint_boundary',
                                ),
                                child: widget.child,
                              ),
                            ),
                            if (currentProgress > 0)
                              Semantics(
                                button: true,
                                label: widget.closeSemanticsLabel,
                                child: GestureDetector(
                                  key: const ValueKey<String>(
                                    'sliding_drawer_scrim',
                                  ),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: close,
                                  child: ColoredBox(
                                    color: Colors.black.withValues(
                                      alpha: 0.24 * currentProgress,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
