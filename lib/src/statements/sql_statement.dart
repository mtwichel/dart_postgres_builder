import 'package:postgres_builder/postgres_builder.dart';

// One member abstract class is allowed for SqlStatement
// ignore: one_member_abstracts
abstract class SqlStatement {
  const SqlStatement();
  ProcessedSql toSql();
}

abstract class FilterStatement implements SqlStatement {
  const FilterStatement();

  FilterStatement operator &(FilterStatement other) => And([this, other]);
  FilterStatement operator |(FilterStatement other) => Or([this, other]);
}
