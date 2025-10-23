## 2.6.0

- Added `Exists` to support `EXISTS` clauses

## 2.5.0

- Added `IsNull` to support `IS NULL` clauses
- Added `IsNotNull` to support `IS NOT NULL` clauses
- Added `isNull()` and `isNotNull()` helper methods to `Column` class
- Added `TrueFilter` to support unconditional `TRUE` filter statements

## 2.4.0

- Added `ForeignKeyConstraint` to support `FOREIGN KEY` constraints
- Added `ForeignKeyTableConstraint` to support `FOREIGN KEY` constraints in `CreateTable`
- Added `UniqueConstraint` to support `UNIQUE` constraints
- Added `CheckConstraint` to support `CHECK` constraints
- Added `PrimaryKeyConstraint` to support `PRIMARY KEY` constraints

## 2.3.0

- Added `AlterTable` to support `ALTER TABLE` statements
- Added `AlterColumn` to support `ALTER COLUMN` statements, along with a bunch of other column operations

## 2.2.1

- Exported `ConnectionSettings`
- Fixed `ColumnDefinition` to not automatically quote default values

## 2.2.0

- Added `CreateTable` to support `CREATE TABLE` statements
- Added `DropTable` to support `DROP TABLE` statements

## 2.1.0

- Added `Between` to support `BETWEEN` clauses
- Added a bunch of helper functions to `Column` to make it easier to use
- Added & and | operators to FilterStatement to make it easier to group

## 2.0.0

- **Breaking** Fixed spelling on `OperatorComparison`
- **Breaking** Added `parameterName` to `Column` to make it easy to add an explicit parameter name
- **Breaking** Changed Ordering so that you can sort each column individually
- Added `DirectPostgresBuilder` to support direct connection to a Postgres server
- Added `toString` method to `PostgresBuilderException`

## 1.0.1

- Added much more detail to errors when `ServerError` is throw on `PgPoolPostgresBuilder`

## 1.0.0

- Changed `PgPoolPostgresBuilder` implementation to use `postgres` package in place of the discontinued `postgres_pool`.
- **breaking** removed `PgPoolPostgresBuilder.status` due to this change.

## 0.3.1

- Fixed a bug with `And` and `Or` not passing parameters correctly.

## 0.3.0

- Fixed spelling on `OperatorComparison`
- Fixed issue with `OperatorComparison` not always generating correct SQL

## 0.2.0

- Added `columnFirst` parameter on `OperatorComparison`

## 0.1.1

- Fixed `Group` not generating correct query

## 0.1.0

- Added `Group` to support `GROUP BY` clauses

## 0.0.3

- Added some documentation
- Fixed some exports
- Added `rawExecute` to keep parity with other `raw` methods
- Changed `PgPoolPostgresBuilder.status()` to `PgPoolPostgresBuilder.status`

## 0.0.2

- Added more specific options to `PgPoolPostgresBuilder`

## 0.0.1

- First public release!
