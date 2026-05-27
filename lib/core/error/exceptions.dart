abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code == null ? message : '$code: $message';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class BadRequestException extends ServerException {
  const BadRequestException(super.message, {super.code});
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException(super.message, {super.code});
}

class ForbiddenException extends ServerException {
  const ForbiddenException(super.message, {super.code});
}

class NotFoundException extends ServerException {
  const NotFoundException(super.message, {super.code});
}

class RateLimitException extends ServerException {
  const RateLimitException(
    super.message, {
    super.code,
    this.retryAfter,
  });

  final Duration? retryAfter;
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}
