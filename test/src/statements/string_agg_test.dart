import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

class _MockColumn extends Mock implements Column {}

void main() {
  group('StringAgg', () {
    group('toSql', () {
      test('returns correctly with column and separator', () {
        expect(
          const StringAgg(Column('name'), ', ').toSql(),
          equalsSql(query: "STRING_AGG(name, ', ')"),
        );
      });

      test('returns correctly with DISTINCT', () {
        expect(
          const StringAgg(Column('name'), ', ', distinct: true).toSql(),
          equalsSql(query: "STRING_AGG(DISTINCT name, ', ')"),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const StringAgg(Column('name'), ', ', as: 'names').toSql(),
          equalsSql(query: "STRING_AGG(name, ', ') AS \"names\""),
        );
      });

      test('returns correctly with ORDER BY', () {
        expect(
          const StringAgg(
            Column('name'),
            ', ',
            orderBy: [Sort(Column('name'))],
          ).toSql(),
          equalsSql(query: "STRING_AGG(name, ', ' ORDER BY name ASC)"),
        );
      });

      test('returns correctly with ORDER BY descending', () {
        expect(
          const StringAgg(
            Column('name'),
            ', ',
            orderBy: [
              Sort(Column('name'), direction: SortDirection.descending),
            ],
          ).toSql(),
          equalsSql(query: "STRING_AGG(name, ', ' ORDER BY name DESC)"),
        );
      });

      test('returns correctly with multiple ORDER BY columns', () {
        expect(
          const StringAgg(
            Column('name'),
            ', ',
            orderBy: [
              Sort(Column('department')),
              Sort(Column('name')),
            ],
          ).toSql(),
          equalsSql(
            query: "STRING_AGG(name, ', ' ORDER BY department ASC, name ASC)",
          ),
        );
      });

      test('returns correctly with DISTINCT, ORDER BY, and alias', () {
        expect(
          const StringAgg(
            Column('name'),
            ' | ',
            distinct: true,
            orderBy: [Sort(Column('name'))],
            as: 'unique_names',
          ).toSql(),
          equalsSql(
            query: "STRING_AGG(DISTINCT name, ' | ' "
                'ORDER BY name ASC) AS "unique_names"',
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
          StringAgg(
            mockExpression,
            ', ',
            orderBy: [Sort(mockColumn)],
          ).toSql(),
          equalsSql(
            query:
                "STRING_AGG(__expression__, ', ' ORDER BY __sort_column__ ASC)",
            parameters: {
              '__key1__': '__value1__',
              '__key2__': '__value2__',
            },
          ),
        );
      });

      test('handles empty ORDER BY list', () {
        expect(
          const StringAgg(Column('name'), ', ', orderBy: []).toSql(),
          equalsSql(query: "STRING_AGG(name, ', ')"),
        );
      });

      test('handles null ORDER BY', () {
        expect(
          const StringAgg(Column('name'), ', ').toSql(),
          equalsSql(query: "STRING_AGG(name, ', ')"),
        );
      });
    });
  });
}
