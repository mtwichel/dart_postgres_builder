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
