import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_arch_reso/core/error/exception.dart';
import 'package:tdd_arch_reso/core/error/failure.dart';
import 'package:tdd_arch_reso/core/platform/network_info.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([
  NumberTriviaRemoteDataSource,
  NumberTriviaLocalDataSource,
  NetworkInfo,
])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  //DATA FOR THE MOCKS AND ASSERTIONS
  // We'll uise these three varibles throghout all the tests

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      numberTriviaRemoteDataSource: mockRemoteDataSource,
      numberTriviaLocalDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
    });

    body();
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      number: tNumber,
      text: 'test trivia',
    );

    final tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
      ).thenAnswer((_) async => tNumberTriviaModel);

      //act
      await repository.getConcreteNumberTrivia(tNumber);

      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successfull',
        () async {
          //arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
          ).thenAnswer((_) async => tNumberTriviaModel);

          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          //arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
          ).thenAnswer((_) async => tNumberTriviaModel);
          //act
          await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia));
        },
      );
      test(
        'should return server failure when the call to remote data source is unseccessful',
        () async {
          //arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
          ).thenThrow(ServerException());
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          //arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return ChaceFailure when there is no cached data present ',
        () async {
          // arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException());
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(
      number: 123,
      text: 'test trivia',
    );
    final tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDataSource.getRandomNumberTrivia(),
      ).thenAnswer((_) async => tNumberTriviaModel);
      // act
      await repository.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return data when the call to remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia));
        },
      );
      test(
        'should return server failure when the call to remote data source in unsuccessful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verifyNoMoreInteractions(mockRemoteDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          //arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should return CachedFailure when there is no cached data present',
        () async {
          // arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
