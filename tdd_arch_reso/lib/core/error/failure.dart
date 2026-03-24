import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

// Gernal failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
