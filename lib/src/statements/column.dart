// Suppressing so we can override operators
// ignore_for_file: use_to_and_as_if_applicable

import 'package:postgres_builder/postgres_builder.dart';
import 'package:recase/recase.dart';

class Column implements SqlStatement {
  const Column(
    String columnName, {
    this.as,
    this.table,
    this.customParameterName,
  }) : name = columnName;

  const Column.star({this.table})
      : name = '*',
        as = null,
        customParameterName = null;

  const Column._({
    this.name,
    this.as,
    this.table,
    this.customParameterName,
  });
  factory Column.nested(
    Select select, {
    required String? as,
    bool single = false,
    bool convertToJson = true,
  }) =>
      _NestedColumn(
        select,
        as: as,
        single: single,
        convertToJson: convertToJson,
      );

  final String? name;
  final String? table;
  final String? as;
  final String? customParameterName;

  String get parameterName {
    if (customParameterName != null) return customParameterName!;

    if (name == null) throw Exception('Column name is null');
    return table != null
        ? '${table?.camelCase}_${name?.camelCase}'.camelCase
        : '${name?.camelCase}';
  }

  @override
  ProcessedSql toSql() {
    if (as == null) {
      return ProcessedSql(query: toString(), parameters: {});
    }
    return ProcessedSql(query: '$this AS "$as"', parameters: {});
  }

  @override
  String toString() => table != null ? '$table.$name' : '$name';

  FilterStatement operator ~() => Not(this);

  Equals equals(dynamic other) => Equals(this, other);
  NotEquals notEquals(dynamic other) => NotEquals(this, other);
  GreaterThan greaterThan(dynamic other) => GreaterThan(this, other);
  GreaterThanOrEqual greaterThanOrEqual(dynamic other) =>
      GreaterThanOrEqual(this, other);
  LessThan lessThan(dynamic other) => LessThan(this, other);
  LessThanOrEqual lessThanOrEqual(dynamic other) =>
      LessThanOrEqual(this, other);
  Between between(dynamic lowerValue, dynamic upperValue) =>
      Between(this, lowerValue, upperValue);

  IsNull isNull() => IsNull(this);
  IsNotNull isNotNull() => IsNotNull(this);

  Sort ascending() => Sort(this);
  Sort descending() => Sort(this, direction: SortDirection.descending);
}

class _NestedColumn extends Column {
  const _NestedColumn(
    this.select, {
    required this.single,
    required this.convertToJson,
    super.as,
  }) : super._();

  final Select select;
  final bool single;
  final bool convertToJson;

  @override
  ProcessedSql toSql() {
    final selectSql = select.toSql();
    final String query;
    if (convertToJson) {
      if (as == null) {
        query = single
            ? '''(SELECT row_to_json(*) FROM (${selectSql.query}))'''
            : '''(SELECT COALESCE(json_agg(*), '[]'::json) FROM (${selectSql.query}))''';
      } else {
        query = single
            ? '''(SELECT row_to_json($as.*) FROM (${selectSql.query}) as $as) as "$as"'''
            : '''(SELECT COALESCE(json_agg($as.*), '[]'::json) FROM (${selectSql.query}) as $as) as "$as"''';
      }
    } else {
      if (as == null) {
        query = '(${selectSql.query})';
      } else {
        query = '(${selectSql.query}) AS "$as"';
      }
    }

    return ProcessedSql(
      query: query,
      parameters: selectSql.parameters,
    );
  }
}
