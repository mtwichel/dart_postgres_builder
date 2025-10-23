import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockColumn extends Mock implements Column {}

class _MockJoin extends Mock implements Join {}

class _MockFilterStatement extends Mock implements FilterStatement {}

class _MockGroup extends Mock implements Group {}

class _MockSort extends Mock implements Sort {}

void main() {
  group('Select', () {
    group('toSql() returns correctly', () {
      test('with minimal parameters', () {
        final column = _MockColumn();
        when(column.toSql)
            .thenReturn(const ProcessedSql(query: '__query__', parameters: {}));
        final select = Select([column], from: '__table__');
        expect(
          select.toSql(),
          equalsSql(
            query: '''SELECT __query__ FROM __table__''',
          ),
        );
      });
      test('with join is provided', () {
        final column = _MockColumn();
        final join = _MockJoin();
        when(column.toSql).thenReturn(
          const ProcessedSql(query: '__column__', parameters: {}),
        );
        when(join.toSql)
            .thenReturn(const ProcessedSql(query: '__join__', parameters: {}));

        final select = Select([column], join: [join], from: '__table__');
        expect(
          select.toSql(),
          equalsSql(
            query: '''SELECT __column__ FROM __table__ __join__''',
          ),
        );
      });
      test('with where is provided', () {
        final column = _MockColumn();
        final where = _MockFilterStatement();
        when(column.toSql).thenReturn(
          const ProcessedSql(query: '__column__', parameters: {}),
        );
        when(where.toSql).thenReturn(
          const ProcessedSql(
            query: '__where__',
            parameters: {'__key__': '__value__'},
          ),
        );

        final select = Select([column], where: where, from: '__table__');
        expect(
          select.toSql(),
          equalsSql(
            query: '''SELECT __column__ FROM __table__ WHERE __where__''',
            parameters: {'__key__': '__value__'},
          ),
        );
      });

      test('with order is provided', () {
        final column = _MockColumn();
        final sort = _MockSort();
        when(column.toSql).thenReturn(
          const ProcessedSql(query: '__column__', parameters: {}),
        );
        when(sort.toSql).thenReturn(
          const ProcessedSql(query: '__order__', parameters: {}),
        );

        final select = Select([column], order: [sort], from: '__table__');
        expect(
          select.toSql(),
          equalsSql(
            query: '''SELECT __column__ FROM __table__ ORDER BY __order__''',
          ),
        );
      });

      test('with limit is provided', () {
        final column = _MockColumn();

        when(column.toSql).thenReturn(
          const ProcessedSql(query: '__column__', parameters: {}),
        );

        final select = Select([column], limit: 1, from: '__table__');
        expect(
          select.toSql(),
          equalsSql(
            query: '''SELECT __column__ FROM __table__ LIMIT 1''',
          ),
        );
      });
      test('with group is provided', () {
        final column = _MockColumn();

        when(column.toSql).thenReturn(
          const ProcessedSql(query: '__column__', parameters: {}),
        );
        final group = _MockGroup();
        when(group.toSql).thenReturn(
          const ProcessedSql(query: '__group__', parameters: {}),
        );
        final select = Select([column], group: group, from: '__table__');
        expect(
          select.toSql(),
          equalsSql(
            query: '''SELECT __column__ FROM __table__ __group__''',
          ),
        );
      });
    });
  });
}
