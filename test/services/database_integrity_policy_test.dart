import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/database_service.dart';

void main() {
  test('only SQLite quick_check ok is considered healthy', () {
    expect(DatabaseService.isIntegrityResultHealthy(['ok']), isTrue);
    expect(
      DatabaseService.isIntegrityResultHealthy(
          ['database disk image malformed']),
      isFalse,
    );
    expect(DatabaseService.isIntegrityResultHealthy([]), isFalse);
    expect(DatabaseService.isIntegrityResultHealthy(['ok', 'extra']), isFalse);
  });

  test('account database names are isolated and traversal-safe', () {
    expect(DatabaseService.databaseNameForAccount(null), 'haogpt.db');
    expect(
      DatabaseService.databaseNameForAccount(
        '51000000-0000-4000-8000-000000000001',
      ),
      'haogpt_account_51000000-0000-4000-8000-000000000001.db',
    );
    expect(
      () => DatabaseService.databaseNameForAccount('../other-user'),
      throwsFormatException,
    );
  });
}
