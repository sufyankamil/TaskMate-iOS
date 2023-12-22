import 'package:fpdart/fpdart.dart';
import 'package:task_mate/provider/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = Future<Either<Failure, void>>;