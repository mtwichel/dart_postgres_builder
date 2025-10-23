import 'dart:io';

import 'package:postgres_builder/postgres_builder.dart';

Future<void> main() async {
  final builder = PgPoolPostgresBuilder(
    endpoint: Endpoint(
      host: 'localhost',
      database: 'postgres',
    ),
  );

  final users = await builder.mappedQuery(
    Select(
      [
        const Column.star(),
      ],
      from: 'users',
      where: (const Column('name').equals('John') &
                  const Column('age').equals(20)) &
              const Column('age').between(18, 25) |
          (const Column('name').lessThan('Jane') &
              const Column('age').greaterThan(25)),
      order: [const Column('age').ascending()],
    ),
    fromJson: User.fromJson,
  );

  // use users
  stdout.writeln(users.map((e) => e.name));
}

class User {
  const User({required this.name});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String);

  final String name;
}
