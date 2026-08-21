import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/widgets/sliding_drawer_shell.dart';

void main() {
  const drawerExtent = 360.0;

  Future<GlobalKey<SlidingDrawerShellState>> pumpShell(
    WidgetTester tester, {
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final shellKey = GlobalKey<SlidingDrawerShellState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: textDirection,
          child: SlidingDrawerShell(
            key: shellKey,
            drawer: const ColoredBox(
              key: ValueKey<String>('drawer_panel'),
              color: Colors.white,
              child: Text('Conversations'),
            ),
            child: const ColoredBox(
              key: ValueKey<String>('chat_panel'),
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );

    return shellKey;
  }

  testWidgets('chat panel follows an edge swipe before it settles open', (
    tester,
  ) async {
    final shellKey = await pumpShell(tester);
    final chatPanel = find.byKey(const ValueKey<String>('chat_panel'));

    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();

    final trackedDistance = 160 - kTouchSlop;
    expect(tester.getTopLeft(chatPanel).dx, closeTo(trackedDistance, 0.5));
    expect(
      shellKey.currentState?.progress,
      closeTo(trackedDistance / drawerExtent, 0.01),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(shellKey.currentState?.isOpen, isTrue);
    expect(tester.getTopLeft(chatPanel).dx, closeTo(drawerExtent, 0.5));
  });

  testWidgets('vertical edge scrolling leaves the chat panel in place', (
    tester,
  ) async {
    final shellKey = await pumpShell(tester);
    final chatPanel = find.byKey(const ValueKey<String>('chat_panel'));

    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(12, 80));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(shellKey.currentState?.isOpen, isFalse);
    expect(tester.getTopLeft(chatPanel).dx, 0);
  });

  testWidgets('horizontal swipes away from the edge do not move the panel', (
    tester,
  ) async {
    final shellKey = await pumpShell(tester);
    final chatPanel = find.byKey(const ValueKey<String>('chat_panel'));

    final gesture = await tester.startGesture(const Offset(100, 300));
    await gesture.moveBy(const Offset(180, 0));
    await tester.pump();
    await gesture.up();

    expect(shellKey.currentState?.isOpen, isFalse);
    expect(tester.getTopLeft(chatPanel).dx, 0);
  });

  testWidgets('tapping the shifted chat panel closes the drawer', (
    tester,
  ) async {
    final shellKey = await pumpShell(tester);
    shellKey.currentState?.open();
    await tester.pumpAndSettle();

    expect(shellKey.currentState?.isOpen, isTrue);
    await tester.tap(
      find.byKey(const ValueKey<String>('sliding_drawer_scrim')),
    );
    await tester.pumpAndSettle();

    expect(shellKey.currentState?.isOpen, isFalse);
  });

  testWidgets('chat panel follows a closing swipe while the drawer is open', (
    tester,
  ) async {
    final shellKey = await pumpShell(tester);
    final chatPanel = find.byKey(const ValueKey<String>('chat_panel'));
    shellKey.currentState?.open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(700, 300));
    await gesture.moveBy(const Offset(-280, 0));
    await tester.pump();

    final trackedDistance = drawerExtent - (280 - kTouchSlop);
    expect(tester.getTopLeft(chatPanel).dx, closeTo(trackedDistance, 0.5));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(shellKey.currentState?.isOpen, isFalse);
  });

  testWidgets('right-to-left swipes move the chat panel left', (tester) async {
    final shellKey = await pumpShell(tester, textDirection: TextDirection.rtl);
    final chatPanel = find.byKey(const ValueKey<String>('chat_panel'));

    final gesture = await tester.startGesture(const Offset(799, 300));
    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();

    final trackedDistance = 160 - kTouchSlop;
    expect(tester.getTopLeft(chatPanel).dx, closeTo(-trackedDistance, 0.5));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(shellKey.currentState?.isOpen, isTrue);
  });
}
