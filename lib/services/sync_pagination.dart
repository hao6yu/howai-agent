typedef KeysetPageFetcher =
    Future<List<Map<String, dynamic>>> Function(String? afterId, int limit);

/// Collects rows using an immutable string ID as the cursor.
///
/// Unlike offset pagination, inserts or updates to other rows cannot shift a
/// page boundary and make a row disappear from the current traversal.
class KeysetPagination {
  const KeysetPagination._();

  static Future<List<Map<String, dynamic>>> collect({
    required KeysetPageFetcher fetchPage,
    int pageSize = 200,
  }) async {
    if (pageSize < 1) {
      throw ArgumentError.value(pageSize, 'pageSize', 'Must be positive');
    }

    final rows = <Map<String, dynamic>>[];
    String? afterId;
    while (true) {
      final page = await fetchPage(afterId, pageSize);
      if (page.isEmpty) break;

      String? previousId = afterId;
      for (final row in page) {
        final id = row['id'];
        if (id is! String || id.isEmpty) {
          throw StateError('Keyset page contains a missing or invalid id');
        }
        if (previousId != null && id.compareTo(previousId) <= 0) {
          throw StateError('Keyset page did not advance past $previousId');
        }
        previousId = id;
      }

      rows.addAll(page);
      afterId = previousId;
      if (page.length < pageSize) break;
    }
    return rows;
  }
}
