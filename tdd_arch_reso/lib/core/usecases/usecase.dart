import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failure.dart';

// Parameters have to be put into a container object so that can be
// included in this abstract base class method definition.
abstract class Usecase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

// This will be used by the code calling the use case whenever the use case
// doesn't accept any params
class NoParams {}
