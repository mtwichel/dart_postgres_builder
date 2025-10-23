import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:postgres_builder/postgres_builder.dart';
import 'package:test/test.dart';

class _MockConnection extends Mock implements Connection {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

class _MockServerException extends Mock implements ServerException {}

void main() {
  group('DirectPostgresBuilder', () {
    final endpoint = Endpoint(host: 'host', database: 'database');
    test('can be instantiated', () {
      expect(DirectPostgresBuilder(), isNotNull);
    });

    test('can be initialized', () async {
      final postgresBuilder = DirectPostgresBuilder();
      expect(
        postgresBuilder.initialize(
          connectionFactory: (_, {settings}) async => _MockConnection(),
          endpoint: endpoint,
        ),
        completes,
      );
    });

    test('close closes connection', () async {
      final connection = _MockConnection();
      when(connection.close).thenAnswer((_) async {});
      final postgresBuilder = DirectPostgresBuilder();
      await postgresBuilder.initialize(
        connectionFactory: (_, {settings}) async => connection,
        endpoint: endpoint,
      );
      await postgresBuilder.close();
      verify(connection.close).called(1);
    });

    group('runQuery', () {
      late Connection connection;
      late Result result;
      late DirectPostgresBuilder builder;
      const sql = ProcessedSql(query: '__query__', parameters: {});
      setUp(() async {
        connection = _MockConnection();
        result = _MockResult();
        builder = DirectPostgresBuilder();
        await builder.initialize(
          connectionFactory: (_, {settings}) async => connection,
          endpoint: endpoint,
        );
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => result);
      });

      test('returns empty list if results are empty', () {
        when(() => result.isEmpty).thenReturn(true);

        expect(builder.runQuery(sql), completion(equals([])));
      });
      test('returns the correct value', () {
        final row = _MockResultRow();
        final schema = ResultSchema([
          ResultSchemaColumn(
            typeOid: 0,
            type: Type.text,
            columnName: '__columnName__',
          ),
        ]);

        when(() => result.isEmpty).thenReturn(false);
        when(() => result[any()]).thenReturn(row);
        when(() => result.length).thenReturn(1);
        when(() => result.schema).thenReturn(schema);
        when(() => row[any()]).thenReturn('__value__');

        expect(
          builder.runQuery(sql),
          completion(
            equals([
              {'__columnName__': '__value__'},
            ]),
          ),
        );
      });
      test('throws a PostgresBuilderException on ServerException', () {
        final serverException = _MockServerException();
        when(() => serverException.message).thenReturn('__message__');
        when(() => serverException.severity).thenReturn(Severity.error);
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenThrow(serverException);

        expect(
          () => builder.runQuery(sql),
          throwsA(
            isA<PostgresBuilderException>().having(
              (exception) => exception.message,
              'message',
              equals('__message__'),
            ),
          ),
        );
      });
    });
  });
}
