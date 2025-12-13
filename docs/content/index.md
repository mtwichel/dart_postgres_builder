---
title: Postgres Builder
description: A tool designed to make writing SQL statements easier in Dart.
---

# Postgres Builder

**Postgres Builder** is a Dart package that makes writing SQL statements easier and more type-safe. Instead of manually constructing SQL strings, you can build queries programmatically using a fluent, builder-style API.

## What is Postgres Builder?

Postgres Builder provides a clean, intuitive way to construct and execute PostgreSQL queries in Dart. It eliminates the need for string concatenation and manual parameter binding, reducing the risk of SQL injection and making your code more maintainable.

## Key Features

- **Type-Safe Query Building**: Build SELECT, INSERT, UPDATE, DELETE, and UPSERT statements using structured classes
- **Flexible Query Execution**: Execute queries and get results as maps or mapped to your own data models
- **Raw SQL Support**: When you need it, execute raw SQL queries with parameter substitution
- **Rich SQL Features**: Support for joins, aggregations, filtering, sorting, grouping, and more
- **Connection Pooling**: Built-in support for connection pooling via `PgPoolPostgresBuilder`
- **Extensible**: Create your own builder implementations by extending `PostgresBuilder`

## Quick Example

```dart
// Create a builder instance
final builder = PgPoolPostgresBuilder(
  endpoint: Endpoint(...),
);

// Build and execute a query
final users = await builder.query(
  Select(
    [Column('id'), Column('name'), Column('email')],
    from: 'users',
    where: Column('active').equals(true),
    order: [Sort(Column('name'))],
  ),
);
```

## Learn More

For detailed documentation, API reference, and examples, check out the full documentation (coming soon).

To get started right away, visit the [package on pub.dev](https://pub.dev/packages/postgres_builder) or check out the [README](https://github.com/mtwichel/dart_postgres_builder) for installation and usage instructions.
