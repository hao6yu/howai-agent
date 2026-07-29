import 'dart:async';

/// Starts Flutter initialization and app bootstrap in the same guarded zone.
///
/// The returned future completes normally after either bootstrap completes or
/// [onError] handles a startup failure. A separate completer is used so an
/// error future never has to cross the guarded zone boundary.
Future<void> runGuardedStartup({
  required void Function() initializeBinding,
  required Future<void> Function() bootstrap,
  required void Function(Object error, StackTrace stackTrace) onError,
}) {
  final completion = Completer<void>();

  runZonedGuarded<void>(
    () {
      initializeBinding();
      unawaited(
        bootstrap().then((_) {
          if (!completion.isCompleted) {
            completion.complete();
          }
        }),
      );
    },
    (error, stackTrace) {
      onError(error, stackTrace);
      if (!completion.isCompleted) {
        completion.complete();
      }
    },
  );

  return completion.future;
}

/// Runs a fire-and-forget task without allowing its error to escape to the
/// application's global error zone.
Future<void> runContainedTask(
  Future<void> Function() task, {
  required void Function(Object error, StackTrace stackTrace) onError,
}) async {
  try {
    await task();
  } catch (error, stackTrace) {
    onError(error, stackTrace);
  }
}
