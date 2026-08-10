import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

typedef LogoutCallback = void Function();

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;
  final LogoutCallback? onLogoutRequired;
  Future<bool>? _refreshFuture;

  AuthInterceptor({
    required this.dio,
    required this.storage,
    this.onLogoutRequired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Request-ID'] = DateTime.now().millisecondsSinceEpoch.toString();
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      // Prevent loop if the failed request was login, refresh token, or logout itself
      if (path.contains('/auth/refresh') || path.contains('/auth/login') || path.contains('/auth/logout')) {
        return handler.next(err);
      }

      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final token = await storage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (fetchError) {
          return handler.next(fetchError);
        }
      } else {
        await storage.clearAll();
        onLogoutRequired?.call();
      }
    }
    return handler.next(err);
  }

  Future<bool> _attemptTokenRefresh() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _performTokenRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _performTokenRefresh() async {
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final response = await refreshDio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await storage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
