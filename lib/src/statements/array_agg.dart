import 'package:postgres_builder/postgres_builder.dart';

/// ARRAY_AGG aggregate function
class ArrayAgg extends AggregateFunction {
  const ArrayAgg(
    SqlStatement expression, {
    super.distinct,
    this.orderBy,
    super.as,
  }) : super(
          expression: expression,
        );

  final List<Sort>? orderBy;

  @override
  String get functionName => 'ARRAY_AGG';

  @override
  String buildArguments(ProcessedSql expressionSql) {
    final expressionPart = expressionSql.query;
    final orderByPart = orderBy != null && orderBy!.isNotEmpty
        ? ' ORDER BY ${orderBy!.map((s) => s.toSql().query).join(', ')}'
        : '';
    return '$expressionPart$orderByPart';
  }

  @override
  ProcessedSql toSql() {
    final expressionSql = expression.toSql();
    final arguments = buildArguments(expressionSql);
    final distinctClause = distinct ? 'DISTINCT ' : '';
    final functionCall = '$functionName($distinctClause$arguments)';
    final query = as != null ? '$functionCall AS "$as"' : functionCall;

    final parameters = <String, dynamic>{...expressionSql.parameters};
    if (orderBy != null) {
      for (final sort in orderBy!) {
        parameters.addAll(sort.toSql().parameters);
      }
    }

    return ProcessedSql(
      query: query,
      parameters: parameters,
    );
  }
}
