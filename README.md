# Postgres Builder

[![pub package](https://img.shields.io/pub/v/postgres_builder.svg)](https://pub.dev/packages/postgres_builder)
[![shorebird ci](https://api.shorebird.dev/api/v1/github/mtwichel/dart_postgres_builder/badge.svg)](https://console.shorebird.dev/ci)
[![codecov](https://codecov.io/gh/mtwichel/dart_postgres_builder/graph/badge.svg?token=EGXZKAH78S)](https://codecov.io/gh/mtwichel/dart_postgres_builder)
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A tool designed to make writing SQL statements easier.

## Usage

To start, create an instance of `PostgresBuilder` to run your queries. There is an included `PgPoolPostgresBuilder` that uses the [postgres_pool](https://pub.dev/packages/postgres_pool) package, but you can create your own by extending `PostgresBuilder`.

To create SQL strings, create `Statement`s, one of

- `Select`
- `Insert`
- `Update`
- `Delete`
- `Upsert` (insert unless the entity already exists, then update)

### Available Methods

- `execute`: run a statement and return nothing back
- `query`: run a query an get all the rows back as `Map<String, dynamic>`
- `singleQuery`: run a query and get a single row back as `Map<String, dynamic>`
- `mappedQuery`: run a query and get back rows parsed using your provided `fromJson` function
- `mappedSingleQuery`: run a query and get a single row parsed using your provided `fromJson` function

### Raw Queries

For all available methods, just add `raw` to the name to pass in a raw SQL string instead of a Statement.

## API Reference

### PostgresBuilder

The base abstract class for executing SQL queries. You can extend this class to create your own implementation or use the provided implementations.

#### Constructor Parameters

- `debug` (bool, default: `false`): When true, logs every query execution
- `logger` (Function, optional): Custom logger function. Defaults to `standardLogger` which writes to stdout
- `customTypeConverter` (Function, optional): Custom function to convert query result values

#### Query Execution Methods

- **`query(SqlStatement statement)`**: Executes a query and returns all rows as `List<Map<String, dynamic>>`
- **`execute(SqlStatement statement)`**: Executes a statement without returning any value
- **`singleQuery(SqlStatement statement)`**: Executes a query and returns a single row as `Map<String, dynamic>`
- **`mappedQuery<T>(SqlStatement statement, {required T Function(Map<String, dynamic> json) fromJson})`**: Executes a query and returns all rows parsed as `List<T>` using the provided `fromJson` function
- **`mappedSingleQuery<T>(SqlStatement statement, {required T Function(Map<String, dynamic> json) fromJson})`**: Executes a query and returns a single row parsed as `T` using the provided `fromJson` function

#### Raw Query Methods

All query methods have corresponding "raw" versions that accept SQL strings directly:

- **`rawQuery(String query, {Map<String, dynamic> substitutionValues = const {}})`**: Raw SQL version of `query`
- **`rawExecute(String query, {Map<String, dynamic> substitutionValues = const {}})`**: Raw SQL version of `execute`
- **`rawSingleQuery(String query, {Map<String, dynamic> substitutionValues = const {}})`**: Raw SQL version of `singleQuery`
- **`rawMappedQuery<T>(String query, {required T Function(Map<String, dynamic> json) fromJson, Map<String, dynamic> substitutionValues = const {}})`**: Raw SQL version of `mappedQuery`
- **`rawMappedSingleQuery<T>(String query, {required T Function(Map<String, dynamic> json) fromJson, Map<String, dynamic> substitutionValues = const {}})`**: Raw SQL version of `mappedSingleQuery`

### Statement Classes

#### Select

Creates a SELECT query statement.

**Constructor:**

```dart
Select(
  List<SqlStatement> columns, {
  required String from,
  FilterStatement? where,
  List<Sort>? order,
  int? limit,
  List<Join>? join,
  Group? group,
})
```

**Parameters:**

- `columns`: List of columns or expressions to select
- `from`: Table name (required)
- `where`: Optional WHERE clause filter
- `order`: Optional list of Sort objects for ORDER BY
- `limit`: Optional limit for number of rows
- `join`: Optional list of Join objects
- `group`: Optional Group object for GROUP BY

#### Insert

Creates an INSERT statement.

**Constructor:**

```dart
Insert(
  List<Map<String, dynamic>> values, {
  required String into,
  List<Column> returningColumns = const [Column.star()],
})
```

**Parameters:**

- `values`: List of maps representing rows to insert
- `into`: Table name (required)
- `returningColumns`: Columns to return after insert (defaults to all columns)

#### Update

Creates an UPDATE statement.

**Constructor:**

```dart
Update(
  Map<String, dynamic> values, {
  required String from,
  required FilterStatement where,
  List<Column> returningColumns = const [Column.star()],
})
```

**Parameters:**

- `values`: Map of column names to new values
- `from`: Table name (required)
- `where`: WHERE clause filter (required)
- `returningColumns`: Columns to return after update (defaults to all columns)

#### Delete

Creates a DELETE statement.

**Constructor:**

```dart
Delete({
  required String from,
  required FilterStatement where,
})
```

**Parameters:**

- `from`: Table name (required)
- `where`: WHERE clause filter (required)

#### Upsert

Creates an INSERT ... ON CONFLICT ... DO UPDATE statement (PostgreSQL UPSERT).

**Constructor:**

```dart
Upsert(
  List<Map<String, dynamic>> values, {
  required String into,
  required List<String> uniqueKeys,
  List<Column> returningColumns = const [Column.star()],
})
```

**Parameters:**

- `values`: List of maps representing rows to insert/update
- `into`: Table name (required)
- `uniqueKeys`: List of column names that form the unique constraint
- `returningColumns`: Columns to return after upsert (defaults to all columns)

### Column Operations

#### Column

Represents a database column in queries.

**Constructors:**

- `Column(String columnName, {String? as, String? table, String? customParameterName})`: Creates a column reference
- `Column.star({String? table})`: Creates a `*` column selector (all columns)
- `Column.nested(Select select, {required String? as, bool single = false, bool convertToJson = true})`: Creates a nested subquery column

**Methods:**

- `equals(dynamic other)`: Creates an Equals filter (column = value)
- `equalsOtherColumn(Column other)`: Creates an Equals filter comparing two columns
- `notEquals(dynamic other)`: Creates a NotEquals filter (column != value)
- `greaterThan(dynamic other)`: Creates a GreaterThan filter (column > value)
- `greaterThanOrEqual(dynamic other)`: Creates a GreaterThanOrEqual filter (column >= value)
- `lessThan(dynamic other)`: Creates a LessThan filter (column < value)
- `lessThanOrEqual(dynamic other)`: Creates a LessThanOrEqual filter (column <= value)
- `between(dynamic lowerValue, dynamic upperValue)`: Creates a Between filter
- `isNull()`: Creates an IsNull filter
- `isNotNull()`: Creates an IsNotNull filter
- `ascending()`: Creates a Sort in ascending order
- `descending()`: Creates a Sort in descending order

**Operators:**

- `~column`: Creates a Not filter (negates the column expression)

### Aggregate Functions

Aggregate functions compute a single result from a set of input values. All aggregate functions can be used in SELECT statements and support aliasing via the `as` parameter.

#### Count

Returns the number of input rows.

**Constructors:**

- `Count(SqlStatement expression, {bool distinct = false, String? as})`: Counts rows matching the expression
- `Count.star({String? as})`: Counts all rows (`COUNT(*)`)

**Parameters:**

- `expression`: The expression to count (typically a Column)
- `distinct`: If true, counts only distinct values
- `as`: Optional alias for the result

**Examples:**

```dart
// Count all rows
Select([Count.star()], from: 'users')

// Count distinct values
Select([Count(Column('age'), distinct: true)], from: 'users')

// Count with alias
Select([Count.star(as: 'total')], from: 'users')
```

#### Sum

Calculates the total sum of a numeric column.

**Constructor:**

```dart
Sum(SqlStatement expression, {bool distinct = false, String? as})
```

**Parameters:**

- `expression`: The numeric expression to sum (typically a Column)
- `distinct`: If true, sums only distinct values
- `as`: Optional alias for the result

**Example:**

```dart
Select([Sum(Column('price'), as: 'total_price')], from: 'orders')
```

#### Avg

Computes the average (arithmetic mean) of a numeric column.

**Constructor:**

```dart
Avg(SqlStatement expression, {bool distinct = false, String? as})
```

**Parameters:**

- `expression`: The numeric expression to average (typically a Column)
- `distinct`: If true, averages only distinct values
- `as`: Optional alias for the result

**Example:**

```dart
Select([Avg(Column('age'), as: 'avg_age')], from: 'users')
```

#### Max

Returns the maximum value of a column.

**Constructor:**

```dart
Max(SqlStatement expression, {String? as})
```

**Parameters:**

- `expression`: The expression to find the maximum of (typically a Column)
- `as`: Optional alias for the result

**Example:**

```dart
Select([Max(Column('age'), as: 'max_age')], from: 'users')
```

#### Min

Returns the minimum value of a column.

**Constructor:**

```dart
Min(SqlStatement expression, {String? as})
```

**Parameters:**

- `expression`: The expression to find the minimum of (typically a Column)
- `as`: Optional alias for the result

**Example:**

```dart
Select([Min(Column('age'), as: 'min_age')], from: 'users')
```

#### StringAgg

Concatenates non-null input values into a string, separated by a specified delimiter.

**Constructor:**

```dart
StringAgg(
  SqlStatement expression,
  String separator, {
  bool distinct = false,
  List<Sort>? orderBy,
  String? as,
})
```

**Parameters:**

- `expression`: The expression to concatenate (typically a Column)
- `separator`: The delimiter string to use between values
- `distinct`: If true, concatenates only distinct values
- `orderBy`: Optional list of Sort objects to order the concatenated values
- `as`: Optional alias for the result

**Example:**

```dart
Select(
  [
    Column('department'),
    StringAgg(
      Column('name'),
      ', ',
      orderBy: [Sort(Column('name'))],
      as: 'names',
    ),
  ],
  from: 'users',
  group: Group([Column('department')]),
)
```

#### ArrayAgg

Aggregates input values, including nulls, into an array.

**Constructor:**

```dart
ArrayAgg(
  SqlStatement expression, {
  bool distinct = false,
  List<Sort>? orderBy,
  String? as,
})
```

**Parameters:**

- `expression`: The expression to aggregate into an array (typically a Column)
- `distinct`: If true, aggregates only distinct values
- `orderBy`: Optional list of Sort objects to order the array values
- `as`: Optional alias for the result

**Example:**

```dart
Select(
  [
    Column('department'),
    ArrayAgg(
      Column('id'),
      orderBy: [Sort(Column('id'), direction: SortDirection.descending)],
      as: 'ids',
    ),
  ],
  from: 'users',
  group: Group([Column('department')]),
)
```

#### Aggregate Functions with GROUP BY

Aggregate functions are commonly used with GROUP BY clauses:

```dart
Select(
  [
    Column('department'),
    Count.star(as: 'count'),
    Avg(Column('age'), as: 'avg_age'),
    Sum(Column('salary'), as: 'total_salary'),
  ],
  from: 'users',
  group: Group([Column('department')]),
)
```

This generates: `SELECT department, COUNT(*) AS "count", AVG(age) AS "avg_age", SUM(salary) AS "total_salary" FROM users GROUP BY department`

### Filter and Comparison Operations

#### And

Combines multiple filter statements with AND logic.

**Constructor:**

```dart
And(List<SqlStatement> statements)
```

#### Or

Combines multiple filter statements with OR logic.

**Constructor:**

```dart
Or(List<SqlStatement> statements)
```

#### Not

Negates a filter statement.

**Constructor:**

```dart
Not(SqlStatement column)
```

#### NotEquals

Creates a NOT EQUALS comparison. Can compare a column to a value or two columns.

**Constructors:**

- `NotEquals(Column column, dynamic value)`: Compares column to a value
- `NotEquals.otherColumn(Column column1, Column column2)`: Compares two columns

#### In

Checks if a column value is in a list of values.

**Constructor:**

```dart
In<T>(Column column, List<T> values)
```

#### Exists

Checks if a subquery returns any rows.

**Constructor:**

```dart
Exists({required Select select})
```

#### TrueFilter

A filter that always evaluates to true.

**Constructor:**

```dart
TrueFilter()
```

#### FilterStatement Operators

- `filter1 & filter2`: Combines two filters with AND (returns And)
- `filter1 | filter2`: Combines two filters with OR (returns Or)

### Join Operations

#### Join

Creates a JOIN clause in a SELECT statement.

**Constructor:**

```dart
Join(
  String table, {
  required FilterStatement on,
  String type = 'LEFT',
  String? as,
})
```

**Parameters:**

- `table`: Table name to join
- `on`: Join condition (required)
- `type`: Join type - 'LEFT', 'RIGHT', 'INNER', or 'FULL OUTER' (default: 'LEFT')
- `as`: Optional alias for the joined table

### Sorting and Grouping

#### Sort

Creates an ORDER BY clause.

**Constructor:**

```dart
Sort(Column column, {SortDirection direction = SortDirection.ascending})
```

**Parameters:**

- `column`: Column to sort by
- `direction`: Sort direction (ascending or descending)

#### SortDirection

Enum for sort direction:

- `SortDirection.ascending`: Sort in ascending order (ASC)
- `SortDirection.descending`: Sort in descending order (DESC)

#### Group

Creates a GROUP BY clause.

**Constructor:**

```dart
Group(List<Column> columns)
```

**Parameters:**

- `columns`: List of columns to group by

### Table Operations

#### CreateTable

Creates a CREATE TABLE statement.

**Constructor:**

```dart
CreateTable({
  required String name,
  required List<ColumnDefinition> columns,
  bool ifNotExists = false,
  List<TableConstraint> constraints = const [],
})
```

**Parameters:**

- `name`: Table name (required)
- `columns`: List of column definitions (required)
- `ifNotExists`: If true, adds IF NOT EXISTS clause
- `constraints`: List of table-level constraints

#### DropTable

Creates a DROP TABLE statement.

**Constructor:**

```dart
DropTable({
  required String name,
  bool ifExists = false,
})
```

**Parameters:**

- `name`: Table name (required)
- `ifExists`: If true, adds IF EXISTS clause

#### AlterTable

Creates an ALTER TABLE statement.

**Constructor:**

```dart
AlterTable({
  required String table,
  required List<SqlStatement> operations,
})
```

**Parameters:**

- `table`: Table name (required)
- `operations`: List of ALTER TABLE operations (AddColumn, DropColumn, etc.)

#### RenameTable

Renames a table (used within AlterTable).

**Constructor:**

```dart
RenameTable({required String newName})
```

**Parameters:**

- `newName`: New table name (required)

### Column Definition and Alterations

#### ColumnDefinition

Defines a column in a CREATE TABLE statement.

**Constructor:**

```dart
ColumnDefinition({
  required String name,
  required String type,
  String? defaultValue,
  bool nullable = false,
  bool primaryKey = false,
  bool unique = false,
  bool autoIncrement = false,
  String? check,
  String? references,
  ReferentialAction? onDelete,
  ReferentialAction? onUpdate,
  String? collate,
  String? generated,
})
```

**Parameters:**

- `name`: Column name (required)
- `type`: Column data type (required)
- `defaultValue`: Default value for the column
- `nullable`: Whether the column allows NULL values (default: false)
- `primaryKey`: Whether the column is a primary key (default: false)
- `unique`: Whether the column has a unique constraint (default: false)
- `autoIncrement`: Whether the column auto-increments (default: false)
- `check`: CHECK constraint expression
- `references`: Foreign key reference in format 'table(column)'
- `onDelete`: Action to take when referenced row is deleted
- `onUpdate`: Action to take when referenced row is updated
- `collate`: Collation for the column
- `generated`: Expression for a generated column

#### AddColumn

Adds a column to a table (used within AlterTable).

**Constructor:**

```dart
AddColumn({
  required ColumnDefinition column,
  bool ifNotExists = false,
})
```

**Parameters:**

- `column`: Column definition (required)
- `ifNotExists`: If true, adds IF NOT EXISTS clause

#### DropColumn

Drops a column from a table (used within AlterTable).

**Constructor:**

```dart
DropColumn({
  required String column,
  bool ifExists = false,
})
```

**Parameters:**

- `column`: Column name (required)
- `ifExists`: If true, adds IF EXISTS clause

#### RenameColumn

Renames a column (used within AlterTable).

**Constructor:**

```dart
RenameColumn({required String column, required String newName})
```

**Parameters:**

- `column`: Current column name (required)
- `newName`: New column name (required)

#### AlterColumn

Alters a column (used within AlterTable).

**Constructor:**

```dart
AlterColumn({
  required String column,
  required List<SqlStatement> operations,
})
```

**Parameters:**

- `column`: Column name (required)
- `operations`: List of column alteration operations (SetDefault, SetNotNull, etc.)

### Column Alteration Operations

These operations are used within `AlterColumn`:

#### SetDefault

Sets a default value for a column.

**Constructor:**

```dart
SetDefault({required String defaultValue})
```

#### DropDefault

Removes the default value from a column.

**Constructor:**

```dart
DropDefault()
```

#### SetNotNull

Sets a NOT NULL constraint on a column.

**Constructor:**

```dart
SetNotNull()
```

#### DropNotNull

Removes the NOT NULL constraint from a column.

**Constructor:**

```dart
DropNotNull()
```

#### SetType

Changes the data type of a column.

**Constructor:**

```dart
SetType({required String newType, String? using})
```

**Parameters:**

- `newType`: New data type (required)
- `using`: Optional USING clause expression for type conversion

#### SetGenerated

Sets a generated column expression.

**Constructor:**

```dart
SetGenerated({required String expression})
```

#### DropExpression

Drops a generated column expression.

**Constructor:**

```dart
DropExpression()
```

#### SetSchema

Sets the schema for a column.

**Constructor:**

```dart
SetSchema({required String schema})
```

### Constraints

#### PrimaryKeyConstraint

Creates a PRIMARY KEY constraint at the table level.

**Constructor:**

```dart
PrimaryKeyConstraint(
  List<String> columns, {
  String? name,
})
```

**Parameters:**

- `columns`: List of column names that form the primary key (required, must have at least one)
- `name`: Optional constraint name

#### UniqueConstraint

Creates a UNIQUE constraint at the table level.

**Constructor:**

```dart
UniqueConstraint(
  List<String> columns, {
  String? name,
})
```

**Parameters:**

- `columns`: List of column names that form the unique constraint (required, must have at least one)
- `name`: Optional constraint name

#### ForeignKeyConstraint

Represents a foreign key constraint.

**Constructor:**

```dart
ForeignKeyConstraint({
  required List<String> columns,
  required String referencesTable,
  required List<String> referencesColumns,
  String? name,
  ReferentialAction? onDelete,
  ReferentialAction? onUpdate,
})
```

**Parameters:**

- `columns`: Column names in this table that form the foreign key (required)
- `referencesTable`: Table being referenced (required)
- `referencesColumns`: Column names in the referenced table (required)
- `name`: Optional constraint name
- `onDelete`: Action to take when referenced row is deleted
- `onUpdate`: Action to take when referenced row is updated

#### ForeignKeyTableConstraint

Wrapper for using ForeignKeyConstraint at the table level in CreateTable.

**Constructor:**

```dart
ForeignKeyTableConstraint(ForeignKeyConstraint foreignKeyConstraint)
```

#### CheckConstraint

Creates a CHECK constraint at the table level.

**Constructor:**

```dart
CheckConstraint(
  String expression, {
  String? name,
})
```

**Parameters:**

- `expression`: CHECK constraint expression (required)
- `name`: Optional constraint name

#### AddConstraint

Adds a generic constraint to a table (used within AlterTable).

**Constructor:**

```dart
AddConstraint({required String constraint})
```

#### DropConstraint

Drops a constraint from a table (used within AlterTable).

**Constructor:**

```dart
DropConstraint({required String constraintName})
```

**Parameters:**

- `constraintName`: Name of the constraint to drop (required)

#### ReferentialAction

Enum for foreign key referential actions:

- `ReferentialAction.cascade`: CASCADE
- `ReferentialAction.setNull`: SET NULL
- `ReferentialAction.setDefault`: SET DEFAULT
- `ReferentialAction.restrict`: RESTRICT
- `ReferentialAction.noAction`: NO ACTION

### Builder Implementations

#### PgPoolPostgresBuilder

A PostgresBuilder implementation that uses a connection pool from the `postgres` package.

**Constructor:**

```dart
PgPoolPostgresBuilder({
  required Endpoint endpoint,
  PoolSettings? poolSettings,
  bool debug = false,
  FutureOr<void> Function(ProcessedSql message)? logger,
  dynamic Function(dynamic input)? customTypeConverter,
})
```

**Parameters:**

- `endpoint`: Database endpoint (required)
- `poolSettings`: Optional pool settings
- `debug`: Enable query logging (default: false)
- `logger`: Custom logger function
- `customTypeConverter`: Custom type converter function

**Methods:**

- `close()`: Closes the connection pool

#### DirectPostgresBuilder

A PostgresBuilder implementation that uses a direct connection from the `postgres` package.

**Constructor:**

```dart
DirectPostgresBuilder({
  bool debug = false,
  FutureOr<void> Function(ProcessedSql message)? logger,
  dynamic Function(dynamic input)? customTypeConverter,
})
```

**Methods:**

- `initialize({required Endpoint endpoint, ConnectionSettings? settings})`: Initializes the database connection (must be called before use)
- `close()`: Closes the database connection

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
[ci_badge]: https://github.com/Morel-Tech/dart_postgres_builder/actions/workflows/postgres_builder_verify_and_test.yaml/badge.svg?branch=main
[ci_link]: https://github.com/Morel-Tech/dart_postgres_builder/actions/workflows/postgres_builder_verify_and_test.yaml
[coverage_badge]: https://img.shields.io/badge/coverage-100%25-brightgreen
