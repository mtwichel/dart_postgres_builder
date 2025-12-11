import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

void main() {
  group('Integration with Select', () {
    test('Count in Select statement', () {
      expect(
        const Select(
          [Count.star()],
          from: 'users',
        ).toSql(),
        equalsSql(query: 'SELECT COUNT(*) FROM users'),
      );
    });

    test('Multiple aggregates in Select', () {
      expect(
        const Select(
          [
            Count.star(as: 'total'),
            Sum(Column('price'), as: 'total_price'),
            Avg(Column('age'), as: 'avg_age'),
          ],
          from: 'orders',
        ).toSql(),
        equalsSql(
          query: 'SELECT COUNT(*) AS "total", SUM(price) AS "total_price", '
              'AVG(age) AS "avg_age" FROM orders',
        ),
      );
    });

    test('Aggregates with GROUP BY', () {
      expect(
        Select(
          [
            const Column('department'),
            const Count.star(as: 'count'),
            const Avg(Column('age'), as: 'avg_age'),
          ],
          from: 'users',
          group: Group([const Column('department')]),
        ).toSql(),
        equalsSql(
          query: 'SELECT department, COUNT(*) AS "count", '
              'AVG(age) AS "avg_age" FROM users GROUP BY department',
        ),
      );
    });

    test('Aggregates with WHERE clause', () {
      expect(
        Select(
          [
            const Count.star(),
          ],
          from: 'users',
          where: const Column('age').greaterThan(18),
        ).toSql(),
        equalsSql(
          query: 'SELECT COUNT(*) FROM users WHERE age > @age',
          parameters: {'age': 18},
        ),
      );
    });

    test('StringAgg with ORDER BY in Select', () {
      expect(
        Select(
          [
            const Column('department'),
            const StringAgg(
              Column('name'),
              ', ',
              orderBy: [Sort(Column('name'))],
              as: 'names',
            ),
          ],
          from: 'users',
          group: Group([const Column('department')]),
        ).toSql(),
        equalsSql(
          query: "SELECT department, STRING_AGG(name, ', ' ORDER BY name ASC) "
              'AS "names" FROM users GROUP BY department',
        ),
      );
    });

    test('Aggregates with HAVING clause', () {
      final result = Select(
        [
          const Column('age'),
          const Count.star(as: 'count'),
        ],
        from: 'users',
        group: Group([const Column('age')]),
        having: const Count.star().greaterThan(5),
      ).toSql();

      expect(
        result.query,
        equals(
          'SELECT age, COUNT(*) AS "count" FROM users '
          'GROUP BY age HAVING COUNT(*) > @${result.parameters.keys.first}',
        ),
      );
      expect(result.parameters.values.first, equals(5));
      expect(result.parameters.length, equals(1));
    });

    test('Aggregates with HAVING clause using multiple conditions', () {
      final result = Select(
        [
          const Column('department'),
          const Count.star(as: 'count'),
          const Avg(Column('age'), as: 'avg_age'),
        ],
        from: 'users',
        group: Group([const Column('department')]),
        having: const Count.star().greaterThan(5) &
            const Avg(Column('age')).greaterThan(30),
      ).toSql();

      expect(
        result.query,
        contains('SELECT department, COUNT(*) AS "count", '
            'AVG(age) AS "avg_age" FROM users GROUP BY department '
            'HAVING (COUNT(*) > @'),
      );
      expect(result.query, contains(' AND AVG(age) > @'));
      expect(result.parameters.length, equals(2));
      expect(result.parameters.values, containsAll([5, 30]));
    });

    test('Aggregates with WHERE and HAVING clauses', () {
      final result = Select(
        [
          const Column('department'),
          const Count.star(as: 'count'),
        ],
        from: 'users',
        where: const Column('active').equals(true),
        group: Group([const Column('department')]),
        having: const Count.star().greaterThan(10),
      ).toSql();

      expect(
        result.query,
        contains('SELECT department, COUNT(*) AS "count" FROM users '
            'WHERE active = @active GROUP BY department '
            'HAVING COUNT(*) > @'),
      );
      expect(result.parameters['active'], equals(true));
      expect(result.parameters.length, equals(2));
      expect(result.parameters.values, contains(10));
    });

    test('Aggregates with parameters preserved in HAVING clause', () {
      // Test that parameters from aggregate functions
      // (like StringAgg with orderBy) are preserved when used in HAVING clauses
      final result = Select(
        [
          const Column('department'),
          const StringAgg(
            Column('name'),
            ', ',
            orderBy: [Sort(Column('id'))],
            as: 'names',
          ),
        ],
        from: 'users',
        group: Group([const Column('department')]),
        having: const StringAgg(
          Column('name'),
          ', ',
          orderBy: [Sort(Column('id'))],
        ).greaterThan('test'),
      ).toSql();

      // Verify the query contains the HAVING clause
      expect(
        result.query,
        contains("HAVING STRING_AGG(name, ', ' ORDER BY id ASC) > @"),
      );
      // Verify parameters are present (the comparison value and any from
      // the aggregate)
      expect(result.parameters.length, greaterThanOrEqualTo(1));
      expect(result.parameters.values, contains('test'));
    });
  });
}
