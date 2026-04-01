import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:tdd_arch_reso/core/error/exception.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSource datasource;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    datasource = NumberTriviaRemoteDataSourceImpl(client: mockClient);
  });

  void setUpMockHtttpClientSuccess200() {
    when(
      mockClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHtttpClientFailure404() {
    when(
      mockClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;

    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia.json')),
    );

    test(
      'should preform a GET request on a URL with number being the endpoint and with application/json header',
      () async {
        // arrange
        setUpMockHtttpClientSuccess200();
        // act
        datasource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(
          mockClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        //arrange
        setUpMockHtttpClientSuccess200();
        //act
        final result = await datasource.getConcreteNumberTrivia(tNumber);

        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHtttpClientFailure404();
        // act
        final call = datasource.getConcreteNumberTrivia;

        // assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia.json')),
    );

    test(
      'should preform a GET request on a URL with random number being the endpoint and with application/json header',
      () async {
        // arrange
        setUpMockHtttpClientSuccess200();
        // act
        datasource.getRandomNumberTrivia();
        // assert
        verify(
          mockClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        //arrange
        setUpMockHtttpClientSuccess200();
        //act
        final result = await datasource.getRandomNumberTrivia();

        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHtttpClientFailure404();
        // act
        final call = datasource.getRandomNumberTrivia;

        // assert
        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
