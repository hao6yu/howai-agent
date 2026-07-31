import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/runtime/guarded_tasks.dart';

void main() {
  test('initializes bindings and bootstraps in the same guarded zone',
      () async {
    late Zone initializationZone;
    Object? reportedError;

    await runGuardedStartup(
      initializeBinding: () {
        initializationZone = Zone.current;
      },
      bootstrap: () async {
        await Future<void>.delayed(Duration.zero);
        expect(Zone.current, same(initializationZone));
      },
      onError: (error, _) {
        reportedError = error;
      },
    );

    expect(reportedError, isNull);
  });

  test('reports asynchronous startup failures without leaking them', () async {
    Object? reportedError;

    await runGuardedStartup(
      initializeBinding: () {},
      bootstrap: () async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('startup failed');
      },
      onError: (error, _) {
        reportedError = error;
      },
    );

    expect(reportedError, isA<StateError>());
  });

  test('contains fire-and-forget task failures', () async {
    Object? reportedError;

    await runContainedTask(
      () async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('sync failed');
      },
      onError: (error, _) {
        reportedError = error;
      },
    );

    expect(reportedError, isA<StateError>());
  });
}
