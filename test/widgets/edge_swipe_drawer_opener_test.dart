import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/widgets/edge_swipe_drawer_opener.dart';

void main() {
  Future<({GlobalKey<ScaffoldState> scaffoldKey, ValueNotifier<int> opens})>
  pumpDrawer(
    WidgetTester tester, {
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final opens = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            key: scaffoldKey,
            drawerEnableOpenDragGesture: false,
            drawer: const Drawer(child: Text('Conversations')),
            body: EdgeSwipeDrawerOpener(
              onOpen: () {
                opens.value++;
                scaffoldKey.currentState?.openDrawer();
              },
              child: const SizedBox.expand(
                child: ColoredBox(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    return (scaffoldKey: scaffoldKey, opens: opens);
  }

  testWidgets('short swipe from the leading edge opens the drawer', (
    tester,
  ) async {
    final result = await pumpDrawer(tester);
    final listener = find.byKey(
      const ValueKey<String>('drawer_edge_swipe_listener'),
    );
    expect(listener, findsOneWidget);
    expect(tester.getSize(listener).width, 800);

    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(30, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(result.opens.value, 1);
    expect(result.scaffoldKey.currentState?.isDrawerOpen, isTrue);
  });

  testWidgets('swipes away from the edge do not open the drawer', (
    tester,
  ) async {
    final result = await pumpDrawer(tester);

    final gesture = await tester.startGesture(const Offset(100, 300));
    await gesture.moveBy(const Offset(80, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(result.opens.value, 0);
    expect(result.scaffoldKey.currentState?.isDrawerOpen, isFalse);
  });

  testWidgets('vertical edge scrolling does not open the drawer', (
    tester,
  ) async {
    final result = await pumpDrawer(tester);

    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(12, 80));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(result.opens.value, 0);
    expect(result.scaffoldKey.currentState?.isDrawerOpen, isFalse);
  });

  testWidgets('leading edge follows right-to-left directionality', (
    tester,
  ) async {
    final result = await pumpDrawer(tester, textDirection: TextDirection.rtl);

    final gesture = await tester.startGesture(const Offset(799, 300));
    await gesture.moveBy(const Offset(-30, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(result.opens.value, 1);
    expect(result.scaffoldKey.currentState?.isDrawerOpen, isTrue);
  });
}
