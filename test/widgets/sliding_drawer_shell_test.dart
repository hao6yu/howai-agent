import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/widgets/sliding_drawer_shell.dart';

void main() {
  const drawerExtent = 360.0;

  Future<GlobalKey<SlidingDrawerShellState>> pumpShell(
    WidgetTester tester, {
    TextDirection textDirection = TextDirection.ltr,
    Widget? drawer,
  }) async {
    final shellKey = GlobalKey<SlidingDrawerShellState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: textDirection,
          child: SlidingDrawerShell(
            key: shellKey,
            drawer:
                drawer ??
                const ColoredBox(
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

  testWidgets('drawer controls work while the opening spring is in flight', (
    tester,
  ) async {
    var tapCount = 0;
    final shellKey = await pumpShell(
      tester,
      drawer: Material(
        color: Colors.white,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              key: const ValueKey<String>('drawer_action'),
              onPressed: () => tapCount += 1,
              icon: const Icon(Icons.settings),
            ),
          ),
        ),
      ),
    );

    shellKey.currentState?.open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(shellKey.currentState!.progress, greaterThan(0));
    expect(shellKey.currentState!.progress, lessThan(1));

    await tester.tap(find.byKey(const ValueKey<String>('drawer_action')));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
    expect(shellKey.currentState?.isOpen, isTrue);
  });

  testWidgets('drawer can scroll while the opening spring is in flight', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final shellKey = await pumpShell(
      tester,
      drawer: Material(
        color: Colors.white,
        child: ListView.builder(
          controller: scrollController,
          itemCount: 40,
          itemBuilder: (context, index) =>
              SizedBox(height: 48, child: Text('Conversation $index')),
        ),
      ),
    );

    shellKey.currentState?.open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(shellKey.currentState!.progress, lessThan(1));

    await tester.dragFrom(const Offset(24, 300), const Offset(0, -180));
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0));
    expect(shellKey.currentState?.isOpen, isTrue);
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
