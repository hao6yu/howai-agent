import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/serial_task_queue.dart';

void main() {
  test('runs purchase updates strictly in arrival order', () async {
    final queue = SerialTaskQueue();
    final releaseFirst = Completer<void>();
    final order = <String>[];

    final first = queue.enqueue(() async {
      order.add('first-start');
      await releaseFirst.future;
      order.add('first-end');
    });
    final second = queue.enqueue(() async {
      order.add('second');
    });

    await Future<void>.delayed(Duration.zero);
    expect(order, ['first-start']);
    expect(queue.pendingCount, 2);

    releaseFirst.complete();
    await Future.wait([first, second]);
    expect(order, ['first-start', 'first-end', 'second']);
    expect(queue.pendingCount, 0);
  });

  test('a failed update does not poison later queue work', () async {
    final queue = SerialTaskQueue();
    final order = <String>[];

    final failed = queue.enqueue(() async {
      throw StateError('verification failed');
    });
    final recovered = queue.enqueue(() async {
      order.add('recovered');
    });

    await expectLater(failed, throwsStateError);
    await recovered;
    expect(order, ['recovered']);
    expect(queue.pendingCount, 0);
  });
}
