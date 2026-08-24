import 'dart:async';

/// Runs asynchronous work in arrival order.
///
/// Store purchase streams may invoke an asynchronous listener again before its
/// previous invocation has completed. This queue prevents those callbacks from
/// racing. Explicit restore flows enqueue deterministic store snapshots rather
/// than guessing when a callback stream has become quiet.
class SerialTaskQueue {
  Future<void> _tail = Future<void>.value();
  int _pendingCount = 0;

  int get pendingCount => _pendingCount;

  Future<void> enqueue(Future<void> Function() task) {
    final completion = Completer<void>();
    _pendingCount++;

    final previousTail = _tail;
    _tail = previousTail.then((_) async {
      try {
        await task();
        completion.complete();
      } catch (error, stackTrace) {
        completion.completeError(error, stackTrace);
      } finally {
        _pendingCount--;
      }
    });

    return completion.future;
  }
}
