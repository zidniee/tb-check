import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/env_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: SecureStorageService(),
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  // Audio Upload (Multipart)
  Future<Response> uploadAudio(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return await dio.post('/api/v1/files', data: formData);
  }

  // Google Login Mobile SDK
  Future<Response> loginWithGoogleMobile(String idToken) async {
    return await dio.post(
      '/auth/google/mobile-login',
      data: {'id_token': idToken},
    );
  }
}