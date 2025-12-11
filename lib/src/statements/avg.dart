import 'package:postgres_builder/postgres_builder.dart';

/// AVG aggregate function
class Avg extends AggregateFunction {
  const Avg(
    SqlStatement expression, {
    super.distinct,
    super.as,
  }) : super(
          expression: expression,
        );

  @override
  String get functionName => 'AVG';

  @override
  String buildArguments(ProcessedSql expressionSql) => expressionSql.query;
}
