import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/agent_action_contracts.dart';
import 'package:haogpt/features/actions/presentation/action_approval_card.dart';

void main() {
  ActionProposal proposal() => ActionProposal(
        proposalId: 'proposal-1',
        actionType: 'reminders_create',
        arguments: const {
          'title': 'Take medication',
          'timezone': 'America/Chicago',
        },
        summary: 'Every weekday at 8:00 AM',
        warnings: const ['Starts tomorrow'],
        origin: AgentActionOrigin.text,
        createdAt: DateTime.utc(2026, 7, 15),
      );

  testWidgets('requires an explicit approval or rejection', (tester) async {
    var approved = false;
    var rejected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionApprovalCard(
            proposal: proposal(),
            onApprove: () => approved = true,
            onReject: () => rejected = true,
          ),
        ),
      ),
    );

    expect(find.text('Every weekday at 8:00 AM'), findsOneWidget);
    expect(find.text('Starts tomorrow'), findsOneWidget);
    expect(approved, isFalse);

    await tester.tap(find.text('Create'));
    expect(approved, isTrue);

    await tester.tap(find.text('Cancel'));
    expect(rejected, isTrue);
  });

  testWidgets('disables decisions while an action is executing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionApprovalCard(
            proposal: proposal(),
            isBusy: true,
            onApprove: () {},
            onReject: () {},
          ),
        ),
      ),
    );

    final approve = tester.widget<FilledButton>(
      find.byWidgetPredicate((widget) => widget is FilledButton),
    );
    final reject = tester.widget<TextButton>(
      find.byWidgetPredicate((widget) => widget is TextButton),
    );
    expect(approve.onPressed, isNull);
    expect(reject.onPressed, isNull);
  });

  testWidgets('stays content-sized inside a confirmation dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    child: ActionApprovalCard(
                      proposal: proposal(),
                      onApprove: () {},
                      onReject: () {},
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(Card)).height, lessThan(420));
  });
}
