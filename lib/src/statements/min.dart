import 'package:postgres_builder/postgres_builder.dart';

/// MIN aggregate function
class Min extends AggregateFunction {
  const Min(
    SqlStatement expression, {
    super.as,
  }) : super(
          expression: expression,
          distinct: false,
        );

  @override
  String get functionName => 'MIN';

  @override
  String buildArguments(ProcessedSql expressionSql) => expressionSql.query;
}
