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
  });
}
