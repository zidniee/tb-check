import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://your-api-url.com",
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Response> uploadAudio(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return await dio.post('/analyze', data: formData);
  }
}