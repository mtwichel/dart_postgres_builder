import 'package:postgres_builder/postgres_builder.dart';

/// MAX aggregate function
class Max extends AggregateFunction {
  const Max(
    SqlStatement expression, {
    super.as,
  }) : super(
          expression: expression,
          distinct: false,
        );

  @override
  String get functionName => 'MAX';

  @override
  String buildArguments(ProcessedSql expressionSql) => expressionSql.query;
}
