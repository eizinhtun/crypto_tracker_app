import 'package:equatable/equatable.dart';

enum FailureCategory {
  network,
  server,
  rateLimit,
  notFound,
  unauthorized,
  timeout,
  cacheUnavailable,
  unknown,
}

abstract class Failure extends Equatable {
  const Failure(
    this.message, {
    required this.category,
  });

  final String message;
  final FailureCategory category;

  @override
  List<Object?> get props => [message, category];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message)
      : super(category: FailureCategory.server);
}

class BadRequestFailure extends Failure {
  const BadRequestFailure(super.message)
      : super(category: FailureCategory.server);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message)
      : super(category: FailureCategory.unauthorized);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message)
      : super(category: FailureCategory.unauthorized);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message)
      : super(category: FailureCategory.notFound);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure(
    super.message, {
    this.retryAfter,
  }) : super(category: FailureCategory.rateLimit);

  final Duration? retryAfter;

  @override
  List<Object?> get props => [message, category, retryAfter];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message)
      : super(category: FailureCategory.cacheUnavailable);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    FailureCategory category = FailureCategory.network,
  }) : super(category: category);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message)
      : super(category: FailureCategory.unknown);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message)
      : super(category: FailureCategory.unknown);
}
