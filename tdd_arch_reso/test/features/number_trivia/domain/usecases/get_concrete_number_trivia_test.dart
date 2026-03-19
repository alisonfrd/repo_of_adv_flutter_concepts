import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  late GetConcreteNumberTrivia usecase;

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  group('GetConcreteNumberTrivia', () {
    test('should get trivia for the number from the repository', () async {
      // Arrange
      when(
        mockNumberTriviaRepository.getConcreteNumberTrivia(any),
      ).thenAnswer((_) async => const Right(tNumberTrivia));

      // Act
      final result = await usecase.execute(number: tNumber);

      // Assert
      expect(result, const Right(tNumberTrivia));
      verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    });
  });
}
