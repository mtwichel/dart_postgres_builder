import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

void main() {
  group('Min', () {
    group('toSql', () {
      test('returns correctly with column expression', () {
        expect(
          const Min(Column('age')).toSql(),
          equalsSql(query: 'MIN(age)'),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const Min(Column('age'), as: 'min_age').toSql(),
          equalsSql(query: 'MIN(age) AS "min_age"'),
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
          Min(mockExpression).toSql(),
          equalsSql(
            query: 'MIN(__expression__)',
            parameters: {'__key__': '__value__'},
          ),
        );
      });
    });
  });
}
