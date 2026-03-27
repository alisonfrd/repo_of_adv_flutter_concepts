import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_arch_reso/core/error/exception.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

const cachedNumberTrivia = 'CACHED_NUMBER_TRIVIA';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSource datasource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTRiviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_cached.json')),
    );
    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        // arrrange
        when(
          mockSharedPreferences.getString(any),
        ).thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await datasource.getLastNumberTrivia();
        // assert
        verify(mockSharedPreferences.getString(cachedNumberTrivia));
        expect(result, tNumberTRiviaModel);
      },
    );

    test('should throw a CachedExpetion when there is not a cached value', () {
      // arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      // act
      // Not calling the method here, just storing it inside a call variable
      final call = datasource.getLastNumberTrivia;
      // assert
      // Calling the method happens from a higher-ofer funcition passed
      // This is needed to test if calling a method throws an exception;
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cachedNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'test trivia',
    );

    test('should call SharedPreferences to cache the data', () async {
      // arrange
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) async => true);
      // act
      await datasource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(
        mockSharedPreferences.setString(cachedNumberTrivia, expectJsonString),
      ).called(1);
    });
  });
}
