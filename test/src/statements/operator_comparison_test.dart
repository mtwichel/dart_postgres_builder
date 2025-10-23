import 'package:mocktail/mocktail.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

import '../../_helpers.dart';

class _MockColumn extends Mock implements Column {
  @override
  String toString() {
    return '__colName__';
  }
}

void main() {
  group('OperatorComparison', () {
    test('toSql() returns correctly', () {
      final column = _MockColumn();
      when(column.toSql)
          .thenReturn(const ProcessedSql(query: '__sql__', parameters: {}));
      when(() => column.parameterName).thenReturn('__parameter__');

      final comparison = OperatorComparison(
        column,
        '__value__',
        operator: '__operator__',
      );
      expect(
        comparison.toSql(),
        equalsSql(
          query: '__sql__ __operator__ @__parameter__',
          parameters: {'__parameter__': '__value__'},
        ),
      );
    });

    test('toSql() returns correctly when use', () {
      final column = _MockColumn();
      when(column.toSql)
          .thenReturn(const ProcessedSql(query: '__sql__', parameters: {}));
      when(() => column.parameterName).thenReturn('__parameter__');
      final comparison = OperatorComparison(
        column,
        '__value__',
        operator: '__operator__',
        columnFirst: false,
      );
      expect(
        comparison.toSql(),
        equalsSql(
          query: '@__parameter__ __operator__ __sql__',
          parameters: {'__parameter__': '__value__'},
        ),
      );
    });
  });
  group('OperatorComparison.otherColumn', () {
    test('toSql() returns correctly', () {
      final column1 = _MockColumn();
      final column2 = _MockColumn();
      when(column1.toSql)
          .thenReturn(const ProcessedSql(query: '__sql__', parameters: {}));

      final comparison = OperatorComparison.otherColumn(
        column1,
        column2,
        operator: '__operator__',
      );
      expect(
        comparison.toSql(),
        equalsSql(
          query: '__sql__ __operator__ __colName__',
          parameters: {},
        ),
      );
    });
  });

  test('generateRandomString generates string', () {
    expect(generateRandomString(), isA<String>());
  });
}
