import 'package:dio/dio.dart';
import 'api_exception.dart';

class ErrorHandler {
  static ApiException handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final errorData = response.data;
      String message = 'Terjadi kesalahan.';

      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('error') && errorData['error'] is String) {
          message = errorData['error'];
        } else if (errorData.containsKey('message') && errorData['message'] is String) {
          message = errorData['message'];
        }
      }

      switch (statusCode) {
        case 400:
          return ValidationException(message: message, errorBody: errorData);
        case 401:
          return UnauthorizedException(message: message, errorBody: errorData);
        case 403:
          return ForbiddenException(message: message, errorBody: errorData);
        case 404:
          return NotFoundException(message: message, errorBody: errorData);
        case 409:
          return ConflictException(message: message, errorBody: errorData);
        case 422:
          return UnprocessableEntityException(message: message, errorBody: errorData);
        case 429:
          return RateLimitException(message: message, errorBody: errorData);
        case 500:
        case 502:
        case 503:
          return ServerException(statusCode: statusCode, message: message, errorBody: errorData);
        default:
          return ServerException(statusCode: statusCode, message: message, errorBody: errorData);
      }
    }

    return NetworkException(message: error.message ?? 'Terjadi kesalahan koneksi.');
  }
}
