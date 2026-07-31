import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/accessibility/motion_preferences.dart';

void main() {
  testWidgets('removes optional motion when the platform requests it',
      (tester) async {
    late Duration result;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            result = motionDuration(
              context,
              const Duration(milliseconds: 300),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(result, Duration.zero);
  });

  test('modal route keeps native transitions with consistent timing', () {
    final route = HowAIModalPageRoute<void>(
      builder: (_) => const SizedBox.shrink(),
    );
    final reducedRoute = HowAIModalPageRoute<void>(
      builder: (_) => const SizedBox.shrink(),
      reducedMotion: true,
    );

    expect(route.transitionDuration, HowAIMotion.deliberate);
    expect(route.reverseTransitionDuration, HowAIMotion.routeExit);
    expect(route.fullscreenDialog, isTrue);
    expect(reducedRoute.transitionDuration, Duration.zero);
    expect(reducedRoute.reverseTransitionDuration, Duration.zero);
  });

  testWidgets('animated presence retains content through its exit motion',
      (tester) async {
    var visible = true;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return HowAIAnimatedPresence(
              duration: HowAIMotion.standard,
              child: visible ? const Text('Status panel') : null,
            );
          },
        ),
      ),
    );

    update(() => visible = false);
    await tester.pump();
    expect(find.text('Status panel'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Status panel'), findsNothing);
  });

  testWidgets('animated presence exits immediately with reduced motion',
      (tester) async {
    var visible = true;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return HowAIAnimatedPresence(
                duration: motionDuration(context, HowAIMotion.standard),
                child: visible ? const Text('Reduced panel') : null,
              );
            },
          ),
        ),
      ),
    );

    update(() => visible = false);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Reduced panel'), findsNothing);
  });
}
