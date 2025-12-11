import 'package:postgres_builder/postgres_builder.dart';

/// Base class for aggregate functions
abstract class AggregateFunction implements SqlStatement {
  const AggregateFunction({
    required this.expression,
    this.distinct = false,
    this.as,
  });

  final SqlStatement expression;
  final bool distinct;
  final String? as;

  /// The SQL function name (e.g., 'COUNT', 'SUM', 'AVG')
  String get functionName;

  /// Builds the function arguments SQL (without parentheses)
  String buildArguments(ProcessedSql expressionSql);

  @override
  ProcessedSql toSql() {
    final expressionSql = expression.toSql();
    final arguments = buildArguments(expressionSql);
    final distinctClause = distinct ? 'DISTINCT ' : '';
    final functionCall = '$functionName($distinctClause$arguments)';
    final query = as != null ? '$functionCall AS "$as"' : functionCall;

    return ProcessedSql(
      query: query,
      parameters: expressionSql.parameters,
    );
  }
}
