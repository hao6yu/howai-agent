import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/features/workspace/presentation/workspace_empty_state.dart';

void main() {
  testWidgets('supports large accessibility text without overflowing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2.5),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: WorkspaceEmptyState(
            icon: Icons.travel_explore_rounded,
            eyebrow: 'PREVIEW',
            title: 'Research that keeps working',
            description:
                'Start a research project and return to a saved report.',
            actionLabel: 'Start in Chat',
            onAction: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Research that keeps working'), findsOneWidget);
    expect(find.text('Start in Chat'), findsOneWidget);
  });

  testWidgets('marks only the title as a semantic header', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceEmptyState(
            icon: Icons.checklist_rounded,
            eyebrow: 'PREVIEW',
            title: 'Your actions, in one place',
            description: 'Approved actions will appear here.',
            actionLabel: 'Create in Chat',
            onAction: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Your actions, in one place')),
      matchesSemantics(
        label: 'Your actions, in one place',
        isHeader: true,
        textDirection: TextDirection.ltr,
      ),
    );
    semantics.dispose();
  });
}
