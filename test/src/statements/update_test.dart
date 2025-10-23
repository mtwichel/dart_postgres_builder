import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockFilterStatement extends Mock implements FilterStatement {}

void main() {
  group('Update', () {
    test('toSql() returns correctly', () {
      final filterStatement = _MockFilterStatement();
      when(filterStatement.toSql)
          .thenReturn(const ProcessedSql(query: '__where__', parameters: {}));
      expect(
        Update(
          {
            'key1': 'value1',
            'key2': 'value3',
          },
          from: '__table__',
          where: filterStatement,
        ).toSql(),
        equalsSql(
          query:
              '''UPDATE __table__ SET key1=@valkey1, key2=@valkey2 WHERE __where__ RETURNING *''',
        ),
      );
    });
  });
}
