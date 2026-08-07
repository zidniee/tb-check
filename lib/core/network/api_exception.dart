abstract class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic errorBody;

  ApiException({
    this.statusCode,
    required this.message,
    this.errorBody,
  });

  @override
  String toString() => message;
}

class ValidationException extends ApiException {
  ValidationException({super.message = 'Parameter request tidak valid.', super.errorBody})
      : super(statusCode: 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Sesi tidak valid atau telah berakhir.', super.errorBody})
      : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({super.message = 'Akses ditolak.', super.errorBody})
      : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({super.message = 'Data tidak ditemukan.', super.errorBody})
      : super(statusCode: 404);
}

class ConflictException extends ApiException {
  ConflictException({super.message = 'Terjadi konflik data.', super.errorBody})
      : super(statusCode: 409);
}

class UnprocessableEntityException extends ApiException {
  UnprocessableEntityException({super.message = 'Permintaan tidak dapat diproses.', super.errorBody})
      : super(statusCode: 422);
}

class RateLimitException extends ApiException {
  RateLimitException({super.message = 'Terlalu banyak permintaan. Silakan tunggu beberapa saat.', super.errorBody})
      : super(statusCode: 429);
}

class ServerException extends ApiException {
  ServerException({super.statusCode = 500, super.message = 'Terjadi kesalahan pada server.', super.errorBody});
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Gagal terhubung ke jaringan. Periksa koneksi internet Anda.'})
      : super(statusCode: null);
}
