import 'dart:convert';

import 'package:tdd_arch_reso/core/error/exception.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    try {
      final url = 'https://numbersapi.com/$number?json';
      final result = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (result.statusCode == 200) {
        try {
          final model = NumberTriviaModel.fromJson(json.decode(result.body));
          return model;
        } catch (e) {
          throw ServerException();
        }
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    try {
      const url = 'https://numbersapi.com/random?json';
      final result = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (result.statusCode == 200) {
        try {
          final model = NumberTriviaModel.fromJson(json.decode(result.body));
          return model;
        } catch (e) {
          throw ServerException();
        }
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
