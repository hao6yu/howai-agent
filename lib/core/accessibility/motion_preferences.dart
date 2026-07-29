import 'package:flutter/material.dart';

abstract final class HowAIMotion {
  static const Duration quick = Duration(milliseconds: 140);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration drawerTransition = Duration(milliseconds: 250);
  static const Duration deliberate = Duration(milliseconds: 280);
  static const Duration routeExit = Duration(milliseconds: 200);

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
}

bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

Duration motionDuration(BuildContext context, Duration duration) {
  return prefersReducedMotion(context) ? Duration.zero : duration;
}

Widget fadeSlideTransition(
  Widget child,
  Animation<double> animation, {
  Offset begin = const Offset(0, 0.025),
}) {
  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: HowAIMotion.enterCurve,
    reverseCurve: HowAIMotion.exitCurve,
  );
  return FadeTransition(
    opacity: curvedAnimation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    ),
  );
}

class HowAIModalPageRoute<T> extends MaterialPageRoute<T> {
  HowAIModalPageRoute({
    required super.builder,
    super.settings,
    super.requestFocus,
    bool reducedMotion = false,
  })  : _reducedMotion = reducedMotion,
        super(fullscreenDialog: true);

  final bool _reducedMotion;

  @override
  Duration get transitionDuration =>
      _reducedMotion ? Duration.zero : HowAIMotion.deliberate;

  @override
  Duration get reverseTransitionDuration =>
      _reducedMotion ? Duration.zero : HowAIMotion.routeExit;
}

class HowAIAnimatedPresence extends StatefulWidget {
  const HowAIAnimatedPresence({
    super.key,
    required this.child,
    required this.duration,
    this.axisAlignment = -1,
  });

  final Widget? child;
  final Duration duration;
  final double axisAlignment;

  @override
  State<HowAIAnimatedPresence> createState() => _HowAIAnimatedPresenceState();
}

class _HowAIAnimatedPresenceState extends State<HowAIAnimatedPresence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  Widget? _retainedChild;

  @override
  void initState() {
    super.initState();
    _retainedChild = widget.child;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.child == null ? 0 : 1,
    )..addStatusListener(_handleAnimationStatus);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: HowAIMotion.enterCurve,
      reverseCurve: HowAIMotion.exitCurve,
    );
  }

  @override
  void didUpdateWidget(HowAIAnimatedPresence oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.duration == Duration.zero) {
      _retainedChild = widget.child;
      _controller.value = widget.child == null ? 0 : 1;
      return;
    }
    if (widget.child != null) {
      _retainedChild = widget.child;
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        widget.child == null &&
        _retainedChild != null) {
      setState(() => _retainedChild = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child ?? _retainedChild;
    if (child == null) return const SizedBox.shrink();

    return ClipRect(
      child: SizeTransition(
        sizeFactor: _animation,
        alignment: AlignmentDirectional(-1, widget.axisAlignment),
        child: FadeTransition(
          opacity: _animation,
          child: child,
        ),
      ),
    );
  }
}
