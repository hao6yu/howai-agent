import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/features/actions/presentation/automation_edit_dialog.dart';
import 'package:haogpt/models/reminder.dart';

void main() {
  Reminder reminder() => Reminder(
        id: 'reminder-1',
        userId: 'user-1',
        title: 'Pick up my daughter from school',
        timezone: 'America/Chicago',
        startLocal: DateTime(2026, 7, 21, 15, 30),
        nextFireAt: DateTime.utc(2026, 7, 21, 20, 30),
        recurrence: const ReminderRecurrence(
          frequency: ReminderFrequency.weekly,
          interval: 2,
          weekdays: [DateTime.tuesday],
        ),
        status: ReminderStatus.active,
        version: 1,
        createdAt: DateTime.utc(2026, 7, 16),
        updatedAt: DateTime.utc(2026, 7, 16),
        notes: 'Bring the school pickup card and water bottle.',
      );

  testWidgets('puts schedule first and removes the redundant type label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showAutomationEditDialog(
                context: context,
                reminder: reminder(),
              ),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Reminder'), findsNothing);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Every 2 weeks · Tue'), findsOneWidget);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(
      tester.getTopLeft(find.text('Schedule')).dy,
      lessThan(tester.getTopLeft(find.text('Title')).dy),
    );
  });

  testWidgets('keeps actions visible with large text and the keyboard open', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetViewInsets());
    tester.view.viewInsets = const FakeViewPadding(bottom: 180);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.5),
          ),
          child: child!,
        ),
        home: Scaffold(body: AutomationEditDialog(reminder: reminder())),
      ),
    );
    await tester.pumpAndSettle();

    final notesField = find.byType(TextField).last;
    await tester.showKeyboard(notesField);
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Every 2 weeks · Tue'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
