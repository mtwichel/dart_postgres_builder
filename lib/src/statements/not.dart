import 'package:postgres_builder/postgres_builder.dart';

class Not extends FilterStatement {
  const Not(this.column);

  final SqlStatement column;

  @override
  ProcessedSql toSql() {
    final columnSql = column.toSql();
    return ProcessedSql(
      query: 'NOT ${columnSql.query}',
      parameters: columnSql.parameters,
    );
  }
}
