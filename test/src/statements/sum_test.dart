import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

void main() {
  group('Sum', () {
    group('toSql', () {
      test('returns correctly with column expression', () {
        expect(
          const Sum(Column('price')).toSql(),
          equalsSql(query: 'SUM(price)'),
        );
      });

      test('returns correctly with DISTINCT', () {
        expect(
          const Sum(Column('price'), distinct: true).toSql(),
          equalsSql(query: 'SUM(DISTINCT price)'),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const Sum(Column('price'), as: 'total_price').toSql(),
          equalsSql(query: 'SUM(price) AS "total_price"'),
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
          Sum(mockExpression).toSql(),
          equalsSql(
            query: 'SUM(__expression__)',
            parameters: {'__key__': '__value__'},
          ),
        );
      });
    });
  });
}
