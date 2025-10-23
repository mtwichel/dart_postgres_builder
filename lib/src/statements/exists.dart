import 'package:postgres_builder/postgres_builder.dart';

/// {@template exists}
/// A filter statement that checks if a sub query exists.
/// {@endtemplate}
class Exists extends FilterStatement {
  /// {@macro exists}
  Exists({
    required this.select,
  });

  /// The select statement to check if it exists.
  final Select select;

  @override
  ProcessedSql toSql() {
    final sql = select.toSql();
    return ProcessedSql(
      query: 'EXISTS (${sql.query})',
      parameters: sql.parameters,
    );
  }
}
