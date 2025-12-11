import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

void main() {
  group('Avg', () {
    group('toSql', () {
      test('returns correctly with column expression', () {
        expect(
          const Avg(Column('age')).toSql(),
          equalsSql(query: 'AVG(age)'),
        );
      });

      test('returns correctly with DISTINCT', () {
        expect(
          const Avg(Column('age'), distinct: true).toSql(),
          equalsSql(query: 'AVG(DISTINCT age)'),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const Avg(Column('age'), as: 'average_age').toSql(),
          equalsSql(query: 'AVG(age) AS "average_age"'),
        );
      });

      test('handles parameters from expression', () {
        final mockExpression = _MockSqlStatement();
        when(mockExpression.toSql).thenReturn(
          const ProcessedSql(
            query: '__expression__',
            parameters: {'__key__': '__value__'},
          ),
        );

        expect(
          Avg(mockExpression).toSql(),
          equalsSql(
            query: 'AVG(__expression__)',
            parameters: {'__key__': '__value__'},
          ),
        );
      });
    });
  });
}
