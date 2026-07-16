import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/features/actions/presentation/recurrence_editor.dart';
import 'package:haogpt/models/reminder.dart';

void main() {
  test('aligns a start date to every selected weekly pattern', () {
    const recurrence = ReminderRecurrence(
      frequency: ReminderFrequency.weekly,
      interval: 2,
      weekdays: [1],
    );

    final result = alignStartToRecurrence(
      DateTime(2026, 7, 16, 13, 30),
      recurrence,
    );

    expect(result, DateTime(2026, 7, 20, 13, 30));
  });

  test('aligns a start date to the first Monday of a month', () {
    const recurrence = ReminderRecurrence(
      frequency: ReminderFrequency.monthly,
      interval: 1,
      weekdays: [],
      monthWeek: 1,
      monthWeekday: DateTime.monday,
    );

    final result = alignStartToRecurrence(
      DateTime(2026, 7, 16, 13, 30),
      recurrence,
    );

    expect(result, DateTime(2026, 8, 3, 13, 30));
  });

  testWidgets('shows Outlook-style recurrence controls', (tester) async {
    const recurrence = ReminderRecurrence(
      frequency: ReminderFrequency.monthly,
      interval: 1,
      weekdays: [],
      monthWeek: -1,
      monthWeekday: DateTime.friday,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showRecurrenceEditor(
                context: context,
                initial: recurrence,
                start: DateTime(2026, 7, 31, 8),
              ),
              child: const Text('Edit repeat'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit repeat'));
    await tester.pumpAndSettle();

    expect(find.text('Recurring automation'), findsOneWidget);
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text('On day'), findsOneWidget);
    expect(find.text('On the'), findsOneWidget);
    expect(find.text('End on a date'), findsOneWidget);
    expect(find.text('last'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
  });

  testWidgets('returns the complete recurrence for review', (tester) async {
    RecurrenceEditResult? result;
    const recurrence = ReminderRecurrence(
      frequency: ReminderFrequency.weekly,
      interval: 2,
      weekdays: [DateTime.tuesday, DateTime.thursday],
      endsOnDate: '2026-10-31',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showRecurrenceEditor(
                  context: context,
                  initial: recurrence,
                  start: DateTime(2026, 7, 21, 15, 30),
                );
              },
              child: const Text('Edit schedule'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(result?.recurrence?.interval, 2);
    expect(result?.recurrence?.weekdays, [2, 4]);
    expect(result?.recurrence?.endsOnDate, '2026-10-31');
  });

  testWidgets('remains scrollable with large text in dark mode',
      (tester) async {
    const recurrence = ReminderRecurrence(
      frequency: ReminderFrequency.weekly,
      interval: 2,
      weekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.7),
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showRecurrenceEditor(
                context: context,
                initial: recurrence,
                start: DateTime(2026, 7, 20, 8),
              ),
              child: const Text('Open recurrence'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open recurrence'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
