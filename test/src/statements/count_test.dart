import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockSqlStatement extends Mock implements SqlStatement {}

void main() {
  group('Count', () {
    group('toSql', () {
      test('returns correctly with column expression', () {
        expect(
          const Count(Column('age')).toSql(),
          equalsSql(query: 'COUNT(age)'),
        );
      });

      test('returns correctly with table-qualified column', () {
        expect(
          const Count(Column('age', table: 'users')).toSql(),
          equalsSql(query: 'COUNT(users.age)'),
        );
      });

      test('returns correctly with DISTINCT', () {
        expect(
          const Count(Column('age'), distinct: true).toSql(),
          equalsSql(query: 'COUNT(DISTINCT age)'),
        );
      });

      test('returns correctly with alias', () {
        expect(
          const Count(Column('age'), as: 'total').toSql(),
          equalsSql(query: 'COUNT(age) AS "total"'),
        );
      });

      test('returns correctly with DISTINCT and alias', () {
        expect(
          const Count(Column('age'), distinct: true, as: 'unique_count')
              .toSql(),
          equalsSql(query: 'COUNT(DISTINCT age) AS "unique_count"'),
        );
      });

      test('Count.star returns COUNT(*)', () {
        expect(
          const Count.star().toSql(),
          equalsSql(query: 'COUNT(*)'),
        );
      });

      test('Count.star with alias returns correctly', () {
        expect(
          const Count.star(as: 'total').toSql(),
          equalsSql(query: 'COUNT(*) AS "total"'),
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
          Count(mockExpression).toSql(),
          equalsSql(
            query: 'COUNT(__expression__)',
            parameters: {'__key__': '__value__'},
          ),
        );
      });
    });
  });
}
