import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/id_mapping_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IDMappingService().deactivate();
  });

  test('keeps mappings isolated by recoverable account', () async {
    final service = IDMappingService();

    await service.initialize('account-a');
    await service.storeConversationMapping(
      7,
      '10000000-0000-4000-8000-000000000007',
    );

    await service.initialize('account-b');
    expect(service.getConversationUUID(7), isNull);

    await service.initialize('account-a');
    expect(
      service.getConversationUUID(7),
      '10000000-0000-4000-8000-000000000007',
    );
  });

  test('malformed persisted mappings fail closed without blocking startup',
      () async {
    SharedPreferences.setMockInitialValues({
      'conversation_id_mapping_account-a': '{not-json',
      'message_id_mapping_account-a': '{"bad-key":"message-id"}',
    });
    final service = IDMappingService();

    await service.initialize('account-a');

    expect(service.getStats()['conversations'], 0);
    expect(service.getStats()['messages'], 0);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('conversation_id_mapping_account-a'),
      '{}',
    );
    expect(preferences.getString('message_id_mapping_account-a'), '{}');
  });

  test('removes message mappings in one persisted batch', () async {
    final service = IDMappingService();
    await service.initialize('account-a');
    await service.storeMessageMapping(
      1,
      '20000000-0000-4000-8000-000000000001',
    );
    await service.storeMessageMapping(
      2,
      '20000000-0000-4000-8000-000000000002',
    );

    await service.removeMessageMappings([1, 2]);

    expect(service.getMessageUUID(1), isNull);
    expect(service.getMessageUUID(2), isNull);
    service.deactivate();
    await service.initialize('account-a');
    expect(service.getStats()['messages'], 0);
  });

  test('rebinding a local ID removes the stale reverse mapping', () async {
    final service = IDMappingService();
    await service.initialize('account-a');
    await service.storeConversationMapping(
      7,
      '10000000-0000-4000-8000-000000000007',
    );

    await service.storeConversationMapping(
      7,
      '20000000-0000-4000-8000-000000000007',
    );

    expect(
      service.getConversationLocalId(
        '10000000-0000-4000-8000-000000000007',
      ),
      isNull,
    );
    expect(
      service.getConversationLocalId(
        '20000000-0000-4000-8000-000000000007',
      ),
      7,
    );
    expect(
      service.getConversationUUID(7),
      '20000000-0000-4000-8000-000000000007',
    );
  });

  test('moving a UUID removes the old local forward mapping', () async {
    final service = IDMappingService();
    await service.initialize('account-a');
    const uuid = '10000000-0000-4000-8000-000000000007';
    await service.storeMessageMapping(7, uuid);

    await service.storeMessageMapping(8, uuid);

    expect(service.getMessageUUID(7), isNull);
    expect(service.getMessageUUID(8), uuid);
    expect(service.getMessageLocalId(uuid), 8);
  });
}
