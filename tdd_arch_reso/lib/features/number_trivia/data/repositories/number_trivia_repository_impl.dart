import 'package:dartz/dartz.dart';
import 'package:tdd_arch_reso/core/error/exception.dart';

import 'package:tdd_arch_reso/core/error/failure.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';

import 'package:tdd_arch_reso/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../core/platform/network_info.dart';
import '../../domain/repositories/number_trivia_repository.dart';

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource numberTriviaRemoteDataSource;
  final NumberTriviaLocalDataSource numberTriviaLocalDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.numberTriviaRemoteDataSource,
    required this.numberTriviaLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
    int number,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await numberTriviaRemoteDataSource
            .getConcreteNumberTrivia(number);
        numberTriviaLocalDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await numberTriviaLocalDataSource
            .getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() {
    // TODO: implement getRandomNumberTrivia
    throw UnimplementedError();
  }
}
