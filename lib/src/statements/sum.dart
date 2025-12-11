import 'package:postgres_builder/postgres_builder.dart';

/// SUM aggregate function
class Sum extends AggregateFunction {
  const Sum(
    SqlStatement expression, {
    super.distinct,
    super.as,
  }) : super(
          expression: expression,
        );

  @override
  String get functionName => 'SUM';

  @override
  String buildArguments(ProcessedSql expressionSql) => expressionSql.query;
}
