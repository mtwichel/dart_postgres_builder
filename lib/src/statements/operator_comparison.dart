import 'dart:math';

import 'package:meta/meta.dart';
import 'package:postgres_builder/postgres_builder.dart';

class OperatorComparison extends FilterStatement {
  const OperatorComparison(
    this.column,
    this.value, {
    required this.operator,
    this.columnFirst = true,
  }) : useParameter = true;

  const OperatorComparison.otherColumn(
    Column column1,
    Column column2, {
    required this.operator,
  })  : column = column1,
        value = column2,
        useParameter = false,
        columnFirst = false;

  final SqlStatement column;
  final dynamic value;
  final bool useParameter;
  final String operator;
  final bool columnFirst;

  String _getParameterName() {
    if (column is Column) {
      return (column as Column).parameterName;
    }
    // Generate a unique parameter name for non-Column SqlStatements
    return 'param_${generateRandomString()}';
  }

  @override
  ProcessedSql toSql() {
    final columnSqlResult = column.toSql();
    final columnSql = columnSqlResult.query;
    if (useParameter) {
      final parameterName = _getParameterName();
      return ProcessedSql(
        query: columnFirst
            ? '$columnSql $operator @$parameterName'
            : '@$parameterName $operator $columnSql',
        parameters: {
          ...columnSqlResult.parameters,
          parameterName: value,
        },
      );
    }

    return ProcessedSql(
      query: '$columnSql $operator $value',
      parameters: columnSqlResult.parameters,
    );
  }
}

@visibleForTesting
String generateRandomString({int length = 16}) {
  final random = Random();
  const letters = 'abcdefghijklmnopqrstuvwxyz';

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => letters.codeUnitAt(random.nextInt(letters.length)),
    ),
  );
}
