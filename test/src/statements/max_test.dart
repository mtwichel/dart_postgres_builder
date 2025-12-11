import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

void main() {
  group('Max', () {
    group('toSql', () {
      test('returns correctly with column expression', () {
        expect(
          const Max(Column('age')).toSql(),
          equalsSql(query: 'MAX(age)'),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const Max(Column('age'), as: 'max_age').toSql(),
          equalsSql(query: 'MAX(age) AS "max_age"'),
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
          Max(mockExpression).toSql(),
          equalsSql(
            query: 'MAX(__expression__)',
            parameters: {'__key__': '__value__'},
          ),
        );
      });
    });
  });
}
