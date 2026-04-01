import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_arch_reso/core/error/failure.dart';
import 'package:tdd_arch_reso/core/usecases/usecase.dart';
import 'package:tdd_arch_reso/core/util/input_converter.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_arch_reso/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import '../../../domain/entities/number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;
  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Empty());

      emit(Loading());
      final result = await getRandomNumberTrivia(NoParams());

      result.fold(
        (l) {
          emit(Error(message: _mapFailureToMessage(l)));
        },
        (r) {
          emit(Loaded(trivia: r));
        },
      );
    });

    on<GetTriviaForConcreteNumber>((event, emit) async {
      emit(Empty());

      final inputEither = inputConverter.stringToUnsignedInteger(
        event.numberString,
      );

      // Usar pattern matching para separar lógica síncrona da assíncrona
      if (inputEither case Right(:final value)) {
        emit(Loading());
        final result = await getConcreteNumberTrivia(Params(number: value));
        result.fold(
          (l) => emit(Error(message: _mapFailureToMessage(l))),
          (trivia) => emit(Loaded(trivia: trivia)),
        );
      } else {
        emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      }
    });
  }

  String _mapFailureToMessage(Failure failure) {
    // Instead of a regular 'if (failure is ServerFailure)...'
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
