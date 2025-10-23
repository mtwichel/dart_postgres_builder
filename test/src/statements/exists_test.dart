import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSelect extends Mock implements Select {}

void main() {
  group('Exists', () {
    test('toSql() returns correctly', () {
      final select = _MockSelect();
      when(select.toSql).thenReturn(
        const ProcessedSql(
          query: '__query__',
          parameters: {'__key__': '__value__'},
        ),
      );
      expect(
        Exists(select: select).toSql(),
        equalsSql(
          query: 'EXISTS (__query__)',
          parameters: {'__key__': '__value__'},
        ),
      );
    });
  });
}
