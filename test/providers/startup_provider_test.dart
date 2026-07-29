import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/providers/startup_provider.dart';

void main() {
  test('marks startup ready once without duplicate notifications', () {
    final provider = StartupProvider();
    var notifications = 0;
    provider.addListener(() => notifications += 1);

    provider.markReady();
    provider.markReady();

    expect(provider.isReady, isTrue);
    expect(notifications, 1);
  });

  test('retains the latest non-fatal initialization error', () {
    final provider = StartupProvider();
    final error = StateError('offline');

    provider.recordNonFatalError(error);

    expect(provider.lastNonFatalError, same(error));
    expect(provider.isReady, isFalse);
  });
}
