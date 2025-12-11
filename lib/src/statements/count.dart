import 'package:postgres_builder/postgres_builder.dart';

/// COUNT aggregate function
class Count extends AggregateFunction {
  const Count(
    SqlStatement expression, {
    super.distinct,
    super.as,
  }) : super(
          expression: expression,
        );

  /// Creates COUNT(*) aggregate
  const Count.star({super.as})
      : super(
          expression: const Column.star(),
          distinct: false,
        );

  @override
  String get functionName => 'COUNT';

  @override
  String buildArguments(ProcessedSql expressionSql) => expressionSql.query;
}
