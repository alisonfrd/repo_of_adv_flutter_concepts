import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_arch_reso/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  group('fromJson', () {
    test('should be a subclass of NumberTrivia entity', () async {
      // Assert
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    });
    test(
      'should return a valid model when the JSON number is an integer',
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap = json.decode(
          fixture('trivia.json'),
        );

        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);

        // Assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      'should return a valid model when the json number is regarded as a  double',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(
          fixture('trivia_double.json'),
        );

        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);

        // Assert
        expect(result, tNumberTriviaModel);
      },
    );
  });
}
