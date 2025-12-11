import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

class _MockColumn extends Mock implements Column {}

void main() {
  group('ArrayAgg', () {
    group('toSql', () {
      test('returns correctly with column expression', () {
        expect(
          const ArrayAgg(Column('id')).toSql(),
          equalsSql(query: 'ARRAY_AGG(id)'),
        );
      });

      test('returns correctly with DISTINCT', () {
        expect(
          const ArrayAgg(Column('id'), distinct: true).toSql(),
          equalsSql(query: 'ARRAY_AGG(DISTINCT id)'),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const ArrayAgg(Column('id'), as: 'ids').toSql(),
          equalsSql(query: 'ARRAY_AGG(id) AS "ids"'),
        );
      });

      test('returns correctly with ORDER BY', () {
        expect(
          const ArrayAgg(
            Column('id'),
            orderBy: [Sort(Column('id'))],
          ).toSql(),
          equalsSql(query: 'ARRAY_AGG(id ORDER BY id ASC)'),
        );
      });

      test('returns correctly with ORDER BY descending', () {
        expect(
          const ArrayAgg(
            Column('id'),
            orderBy: [
              Sort(Column('id'), direction: SortDirection.descending),
            ],
          ).toSql(),
          equalsSql(query: 'ARRAY_AGG(id ORDER BY id DESC)'),
        );
      });

      test('returns correctly with multiple ORDER BY columns', () {
        expect(
          const ArrayAgg(
            Column('id'),
            orderBy: [
              Sort(Column('created_at')),
              Sort(Column('id')),
            ],
          ).toSql(),
          equalsSql(
            query: 'ARRAY_AGG(id ORDER BY created_at ASC, id ASC)',
          ),
        );
      });

      test('returns correctly with DISTINCT, ORDER BY, and alias', () {
        expect(
          const ArrayAgg(
            Column('id'),
            distinct: true,
            orderBy: [Sort(Column('id'))],
            as: 'unique_ids',
          ).toSql(),
          equalsSql(
            query: 'ARRAY_AGG(DISTINCT id ORDER BY id ASC) AS "unique_ids"',
          ),
        );
      });

      test('handles parameters from expression and ORDER BY', () {
        final mockExpression = _MockSqlStatement();
        when(mockExpression.toSql).thenReturn(
          const ProcessedSql(
            query: '__expression__',
            parameters: {'__key1__': '__value1__'},
          ),
        );

        final mockColumn = _MockColumn();
        when(mockColumn.toSql).thenReturn(
          const ProcessedSql(
            query: '__sort_column__',
            parameters: {'__key2__': '__value2__'},
          ),
        );

        expect(
          ArrayAgg(
            mockExpression,
            orderBy: [Sort(mockColumn)],
          ).toSql(),
          equalsSql(
            query: 'ARRAY_AGG(__expression__ ORDER BY __sort_column__ ASC)',
            parameters: {
              '__key1__': '__value1__',
              '__key2__': '__value2__',
            },
          ),
        );
      });

      test('handles empty ORDER BY list', () {
        expect(
          const ArrayAgg(Column('id'), orderBy: []).toSql(),
          equalsSql(query: 'ARRAY_AGG(id)'),
        );
      });

      test('handles null ORDER BY', () {
        expect(
          const ArrayAgg(Column('id')).toSql(),
          equalsSql(query: 'ARRAY_AGG(id)'),
        );
      });
    });
  });
}
