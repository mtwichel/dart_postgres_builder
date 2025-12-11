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

  /// Creates an Equals filter (aggregate = value)
  Equals equals(dynamic other) => Equals(this, other);

  /// Creates a NotEquals filter (aggregate != value)
  NotEquals notEquals(dynamic other) => NotEquals(this, other);

  /// Creates a GreaterThan filter (aggregate > value)
  GreaterThan greaterThan(dynamic other) => GreaterThan(this, other);

  /// Creates a GreaterThanOrEqual filter (aggregate >= value)
  GreaterThanOrEqual greaterThanOrEqual(dynamic other) =>
      GreaterThanOrEqual(this, other);

  /// Creates a LessThan filter (aggregate < value)
  LessThan lessThan(dynamic other) => LessThan(this, other);

  /// Creates a LessThanOrEqual filter (aggregate <= value)
  LessThanOrEqual lessThanOrEqual(dynamic other) =>
      LessThanOrEqual(this, other);

  /// Creates a Between filter
  Between between(dynamic lowerValue, dynamic upperValue) =>
      Between(this, lowerValue, upperValue);
}
