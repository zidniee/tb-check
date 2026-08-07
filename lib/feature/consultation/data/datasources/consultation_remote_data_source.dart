import '../../../../core/network/api_service.dart';
import '../models/chat_message_dto.dart';
import '../models/consultation_dto.dart';

abstract class ConsultationRemoteDataSource {
  Future<ConsultationDTO> createConsultation({
    required String doctorId,
    required String reportId,
    required bool consentGranted,
  });
  Future<List<ConsultationDTO>> getMyConsultations({int limit = 100, int page = 1});
  Future<ConsultationDTO> getConsultationById(String consultationId);
  Future<List<ChatMessageDTO>> getChatHistory(String consultationId, {int limit = 100, int page = 1});
  Future<void> savePublicKey(String publicKeyPem);
  Future<String> getPublicKey(String targetUserId);
}

class ConsultationRemoteDataSourceImpl implements ConsultationRemoteDataSource {
  final ApiService apiService;

  ConsultationRemoteDataSourceImpl({required this.apiService});

  @override
  Future<ConsultationDTO> createConsultation({
    required String doctorId,
    required String reportId,
    required bool consentGranted,
  }) async {
    final response = await apiService.dio.post(
      '/api/v1/consultations',
      data: {
        'doctor_id': doctorId,
        'report_id': reportId,
        'consent_granted': consentGranted,
      },
    );
    return ConsultationDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ConsultationDTO>> getMyConsultations({int limit = 100, int page = 1}) async {
    final response = await apiService.dio.get(
      '/api/v1/consultations',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => ConsultationDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ConsultationDTO> getConsultationById(String consultationId) async {
    final response = await apiService.dio.get('/api/v1/consultations/$consultationId');
    return ConsultationDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ChatMessageDTO>> getChatHistory(String consultationId, {int limit = 100, int page = 1}) async {
    final response = await apiService.dio.get(
      '/api/v1/consultations/$consultationId/messages',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => ChatMessageDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> savePublicKey(String publicKeyPem) async {
    await apiService.dio.post(
      '/api/v1/consultations/keys',
      data: {
        'public_key': publicKeyPem,
      },
    );
  }

  @override
  Future<String> getPublicKey(String targetUserId) async {
    final response = await apiService.dio.get('/api/v1/consultations/keys/$targetUserId');
    final data = response.data as Map<String, dynamic>;
    return (data['public_key'] ?? '') as String;
  }
}
