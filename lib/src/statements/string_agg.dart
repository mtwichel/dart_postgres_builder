import 'package:postgres_builder/postgres_builder.dart';

/// STRING_AGG aggregate function
class StringAgg extends AggregateFunction {
  const StringAgg(
    SqlStatement expression,
    this.separator, {
    super.distinct,
    this.orderBy,
    super.as,
  }) : super(
          expression: expression,
        );

  final String separator;
  final List<Sort>? orderBy;

  @override
  String get functionName => 'STRING_AGG';

  @override
  String buildArguments(ProcessedSql expressionSql) {
    final expressionPart = expressionSql.query;
    final separatorPart = "'$separator'";
    final orderByPart = orderBy != null && orderBy!.isNotEmpty
        ? ' ORDER BY ${orderBy!.map((s) => s.toSql().query).join(', ')}'
        : '';
    return '$expressionPart, $separatorPart$orderByPart';
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
