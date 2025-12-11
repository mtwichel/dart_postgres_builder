import 'dart:math';

import 'package:postgres_builder/postgres_builder.dart';

class GreaterThan extends OperatorComparison {
  const GreaterThan(super.column, super.value)
      : super(operator: '>', columnFirst: true);
}

class GreaterThanOrEqual extends OperatorComparison {
  const GreaterThanOrEqual(super.column, super.value)
      : super(operator: '>=', columnFirst: true);
}

class LessThan extends OperatorComparison {
  const LessThan(super.column, super.value)
      : super(operator: '<', columnFirst: true);
}

class LessThanOrEqual extends OperatorComparison {
  const LessThanOrEqual(super.column, super.value)
      : super(operator: '<=', columnFirst: true);
}

class Between extends FilterStatement {
  const Between(this.column, this.lowerValue, this.upperValue);

  final SqlStatement column;
  final dynamic lowerValue;
  final dynamic upperValue;

  String _getParameterName() {
    if (column is Column) {
      return (column as Column).parameterName;
    }
    // Generate a unique parameter name for non-Column SqlStatements
    return 'param_${_generateRandomString()}';
  }

  String _generateRandomString({int length = 16}) {
    final random = Random();
    const letters = 'abcdefghijklmnopqrstuvwxyz';

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => letters.codeUnitAt(random.nextInt(letters.length)),
      ),
    );
  }

  @override
  ProcessedSql toSql() {
    final columnSqlResult = column.toSql();
    final columnSql = columnSqlResult.query;
    final parameterName = _getParameterName();

    return ProcessedSql(
      query: '$columnSql BETWEEN @${parameterName}_lower '
          'AND @${parameterName}_upper',
      parameters: {
        ...columnSqlResult.parameters,
        '${parameterName}_lower': lowerValue,
        '${parameterName}_upper': upperValue,
      },
    );
  }
}
