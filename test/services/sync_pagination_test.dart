import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/sync_pagination.dart';

void main() {
  test('keyset pagination collects more than one page exactly once', () async {
    final source = List.generate(
      503,
      (index) => <String, dynamic>{
        'id': index.toString().padLeft(4, '0'),
        'updated_at': 'mutable-$index',
      },
    );

    final rows = await KeysetPagination.collect(
      pageSize: 200,
      fetchPage: (afterId, limit) async => source
          .where((row) => afterId == null || row['id']!.compareTo(afterId) > 0)
          .take(limit)
          .toList(),
    );

    expect(rows, hasLength(503));
    expect(rows.map((row) => row['id']).toSet(), hasLength(503));
  });

  test('mutating a non-cursor field cannot shift a keyset boundary', () async {
    final source = List.generate(
      7,
      (index) => <String, dynamic>{
        'id': 'id-${index.toString().padLeft(2, '0')}',
        'updated_at': index,
      },
    );
    var pageCount = 0;

    final rows = await KeysetPagination.collect(
      pageSize: 3,
      fetchPage: (afterId, limit) async {
        pageCount++;
        if (pageCount == 2) {
          source.first['updated_at'] = 9999;
          source.last['updated_at'] = -9999;
        }
        return source
            .where(
              (row) => afterId == null || row['id']!.compareTo(afterId) > 0,
            )
            .take(limit)
            .toList();
      },
    );

    expect(rows.map((row) => row['id']), [
      'id-00',
      'id-01',
      'id-02',
      'id-03',
      'id-04',
      'id-05',
      'id-06',
    ]);
  });

  test('a non-advancing cursor is rejected instead of looping forever', () {
    expect(
      () => KeysetPagination.collect(
        pageSize: 1,
        fetchPage: (afterId, _) async => [
          {'id': afterId ?? 'same'},
        ],
      ),
      throwsA(isA<StateError>()),
    );
  });
}
