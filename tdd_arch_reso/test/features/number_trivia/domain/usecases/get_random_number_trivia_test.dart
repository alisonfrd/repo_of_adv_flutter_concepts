import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_arch_reso/core/usecases/usecase.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import 'get_random_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  late GetRandomNumberTrivia usecase;

  const tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  group('GetRandomNumberTrivia', () {
    test('should get trivia from the repository', () async {
      // Arrange
      when(
        mockNumberTriviaRepository.getRandomNumberTrivia(),
      ).thenAnswer((_) async => const Right(tNumberTrivia));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Right(tNumberTrivia));
      verify(mockNumberTriviaRepository.getRandomNumberTrivia());
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    });
  });
}
