# 💊 Panduan Integrasi Modul Perawatan (Care Module) — Flutter Client

Panduan ini mendefinisikan langkah-langkah integrasi untuk menghubungkan aplikasi mobile Flutter dengan endpoint **Care Module (Modul Perawatan)** yang telah diimplementasikan di Backend.

---

## 1. Spesifikasi Endpoint API (Care Module)

Semua request memerlukan header `Authorization: Bearer <access_token>` (role `PATIENT`).

| Fitur | Method | Path | Request Body / Query Params | Response |
|---|---|---|---|---|
| **Buat Terapi** | `POST` | `/api/v1/care` | `CreateTreatmentRequest` | `TreatmentResponse` (201) |
| **Ambil Terapi** | `GET` | `/api/v1/care` | - | `TreatmentResponse` (200) |
| **Update Terapi** | `PUT` | `/api/v1/care` | `UpdateTreatmentRequest` | `TreatmentResponse` (200) |
| **Hapus Terapi** | `DELETE` | `/api/v1/care` | - | `{"message": "..."}` (200) |
| **Tambah Jadwal** | `POST` | `/api/v1/care/schedules` | `{"reminder_time": "08:00"}` | `ScheduleResponse` (210) |
| **Ambil Jadwal** | `GET` | `/api/v1/care/schedules` | - | `List<ScheduleResponse>` (200) |
| **Update Jadwal** | `PUT` | `/api/v1/care/schedules/:id` | `UpdateScheduleRequest` | `ScheduleResponse` (200) |
| **Hapus Jadwal** | `DELETE` | `/api/v1/care/schedules/:id` | - | `{"message": "..."}` (200) |
| **Sudah Minum Obat** | `POST` | `/api/v1/care/logs` | `{"schedule_id": "uuid", "date": "YYYY-MM-DD"}` | `LogResponse` (200) |
| **Riwayat Minum Obat** | `GET` | `/api/v1/care/history` | Query: `start_date`, `end_date`, `month`, `year` | `List<LogResponse>` (200) |
| **Statistik Kepatuhan** | `GET` | `/api/v1/care/statistics` | - | `StatisticsResponse` (200) |

---

## 2. Layer Data & Model (Dart)

### A. Model Data Perawatan

Buat berkas `lib/feature/patient/data/models/care_models.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'care_models.g.dart';

@JsonSerializable()
class TreatmentResponse {
  @JsonKey(name: 'treatment_id')
  final String treatmentId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'estimated_end_date')
  final String? estimatedEndDate;
  @JsonKey(name: 'timezone')
  final String timezone;
  @JsonKey(name: 'reminder_enabled')
  final bool reminderEnabled;

  TreatmentResponse({
    required this.treatmentId,
    required this.userId,
    required this.isActive,
    required this.startDate,
    this.estimatedEndDate,
    required this.timezone,
    required this.reminderEnabled,
  });

  factory TreatmentResponse.fromJson(Map<String, dynamic> json) =>
      _$TreatmentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentResponseToJson(this);
}

@JsonSerializable()
class ScheduleResponse {
  @JsonKey(name: 'schedule_id')
  final String scheduleId;
  @JsonKey(name: 'treatment_id')
  final String treatmentId;
  @JsonKey(name: 'reminder_time')
  final String reminderTime; // format "HH:MM"
  @JsonKey(name: 'is_active')
  final bool isActive;

  ScheduleResponse({
    required this.scheduleId,
    required this.treatmentId,
    required this.reminderTime,
    required this.isActive,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleResponseToJson(this);
}

@JsonSerializable()
class LogResponse {
  @JsonKey(name: 'log_id')
  final String logId;
  @JsonKey(name: 'schedule_id')
  final String scheduleId;
  @JsonKey(name: 'reminder_date')
  final String reminderDate; // "YYYY-MM-DD"
  @JsonKey(name: 'reminder_time')
  final String reminderTime; // "HH:MM"
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @JsonKey(name: 'status')
  final String status; // PENDING, TAKEN, MISSED

  LogResponse({
    required this.logId,
    required this.scheduleId,
    required this.reminderDate,
    required this.reminderTime,
    this.confirmedAt,
    required this.status,
  });

  factory LogResponse.fromJson(Map<String, dynamic> json) =>
      _$LogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LogResponseToJson(this);
}

@JsonSerializable()
class StatisticsResponse {
  @JsonKey(name: 'total_scheduled')
  final int totalScheduled;
  @JsonKey(name: 'total_taken')
  final int totalTaken;
  @JsonKey(name: 'total_missed')
  final int totalMissed;
  @JsonKey(name: 'total_pending')
  final int totalPending;
  @JsonKey(name: 'compliance_rate')
  final double complianceRate;

  StatisticsResponse({
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalPending,
    required this.complianceRate,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatisticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsResponseToJson(this);
}
```

---

## 3. Layer Riverpod State Management

### A. Care API Service & Repository
Buat service di `lib/feature/patient/data/datasources/care_remote_data_source.dart` untuk memanggil endpoint menggunakan `Dio`:

```dart
import 'package:dio/dio.dart';
import '../models/care_models.dart';

class CareRemoteDataSource {
  final Dio _dio;
  CareRemoteDataSource(this._dio);

  Future<TreatmentResponse> getTreatment() async {
    final response = await _dio.get('/api/v1/care');
    return TreatmentResponse.fromJson(response.data);
  }

  Future<TreatmentResponse> createTreatment(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/care', data: data);
    return TreatmentResponse.fromJson(response.data);
  }

  Future<TreatmentResponse> updateTreatment(Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/care', data: data);
    return TreatmentResponse.fromJson(response.data);
  }

  Future<List<ScheduleResponse>> getSchedules() async {
    final response = await _dio.get('/api/v1/care/schedules');
    return (response.data as List)
        .map((e) => ScheduleResponse.fromJson(e))
        .toList();
  }

  Future<ScheduleResponse> addSchedule(String reminderTime) async {
    final response = await _dio.post('/api/v1/care/schedules', data: {
      'reminder_time': reminderTime,
    });
    return ScheduleResponse.fromJson(response.data);
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _dio.delete('/api/v1/care/schedules/$scheduleId');
  }

  Future<LogResponse> confirmMedication(String scheduleId, String date) async {
    final response = await _dio.post('/api/v1/care/logs', data: {
      'schedule_id': scheduleId,
      'date': date,
    });
    return LogResponse.fromJson(response.data);
  }

  Future<StatisticsResponse> getStatistics() async {
    final response = await _dio.get('/api/v1/care/statistics');
    return StatisticsResponse.fromJson(response.data);
  }
}
```

### B. Riverpod State Provider
Buat state notifier / notifier class untuk mengelola status terapi dan kepatuhan pasien di `lib/feature/patient/presentation/providers/care_provider.dart`:

```dart
import 'package:flutter_riverpod/riverpod.dart';
import '../../data/models/care_models.dart';
import '../../data/datasources/care_remote_data_source.dart';
import '../../../../core/network/api_service.dart'; // import Dio client Anda

final careDataSourceProvider = Provider<CareRemoteDataSource>((ref) {
  return CareRemoteDataSource(ApiService().dio); // Sesuaikan dengan dio instance Anda
});

class CareState {
  final AsyncValue<TreatmentResponse?> treatment;
  final AsyncValue<List<ScheduleResponse>> schedules;
  final AsyncValue<StatisticsResponse?> statistics;

  CareState({
    required this.treatment,
    required this.schedules,
    required this.statistics,
  });

  CareState copyWith({
    AsyncValue<TreatmentResponse?>? treatment,
    AsyncValue<List<ScheduleResponse>>? schedules,
    AsyncValue<StatisticsResponse?>? statistics,
  }) {
    return CareState(
      treatment: treatment ?? this.treatment,
      schedules: schedules ?? this.schedules,
      statistics: statistics ?? this.statistics,
    );
  }
}

class CareNotifier extends StateNotifier<CareState> {
  final CareRemoteDataSource _dataSource;

  CareNotifier(this._dataSource)
      : super(CareState(
          treatment: const AsyncValue.loading(),
          schedules: const AsyncValue.loading(),
          statistics: const AsyncValue.loading(),
        ));

  Future<void> loadCareData() async {
    state = state.copyWith(
      treatment: const AsyncValue.loading(),
      schedules: const AsyncValue.loading(),
      statistics: const AsyncValue.loading(),
    );

    try {
      final treatment = await _dataSource.getTreatment();
      final schedules = await _dataSource.getSchedules();
      final stats = await _dataSource.getStatistics();

      state = CareState(
        treatment: AsyncValue.data(treatment),
        schedules: AsyncValue.data(schedules),
        statistics: AsyncValue.data(stats),
      );
    } catch (e, stack) {
      // Jika error 404/not found karena belum memiliki terapi, buat data state null
      state = CareState(
        treatment: const AsyncValue.data(null),
        schedules: const AsyncValue.data([]),
        statistics: const AsyncValue.data(null),
      );
    }
  }

  Future<void> setupTreatment(String timezone, String startDate) async {
    try {
      final t = await _dataSource.createTreatment({
        'start_date': startDate,
        'timezone': timezone,
        'reminder_enabled': true,
      });
      state = state.copyWith(treatment: AsyncValue.data(t));
      await loadCareData();
    } catch (e, stack) {
      state = state.copyWith(treatment: AsyncValue.error(e, stack));
    }
  }

  Future<void> addSchedule(String reminderTime) async {
    try {
      await _dataSource.addSchedule(reminderTime);
      await loadCareData();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> confirmMedication(String scheduleId, String date) async {
    try {
      await _dataSource.confirmMedication(scheduleId, date);
      await loadCareData();
    } catch (e) {
      // Handle error
    }
  }
}

final careProvider = StateNotifierProvider<CareNotifier, CareState>((ref) {
  final dataSource = ref.watch(careDataSourceProvider);
  return CareNotifier(dataSource)..loadCareData();
});
```

---

## 4. FCM Custom Routing (`CARE_REMINDER`)

Saat notifikasi reminder masuk dari Firebase Cloud Messaging, data payload memiliki data:
```json
{
  "notification_type": "CARE_REMINDER",
  "schedule_id": "<uuid-schedule>",
  "treatment_id": "<uuid-treatment>"
}
```

Perbarui router notifikasi di [notification_router.dart](file:///d:/Projek/Android/tbcheck/lib/core/service/notification_router.dart) agar menangani navigasi khusus:

```dart
import 'package:flutter/material.dart';
import '../../feature/notification/presentation/pages/notifikasi_page.dart';
// Import halaman pengingat terapi / home dialog konfirmasi obat
// import '../../feature/patient/presentation/pages/medication_confirm_page.dart';

class NotificationRouter {
  static void navigate(BuildContext context, String notificationType, {String? relatedId}) {
    if (notificationType == 'CARE_REMINDER') {
      // Arahkan langsung ke halaman konfirmasi minum obat / Log harian
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => MedicationConfirmPage(scheduleId: relatedId),
      //   ),
      // );
      return;
    }

    // Default route
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotifikasiPage(),
      ),
    );
  }
}
```

---

## 5. UI & UX Mockup Components (Rekomendasi Alur)

### A. Dashboard Card "Jadwal Minum Obat Hari Ini"
Letakkan card interaktif di Home Page Pasien:
- Menampilkan daftar jam yang dijadwalkan (diambil dari `schedules`).
- Menandai centang hijau (`TAKEN`) jika log hari ini berstatus TAKEN.
- Tombol **"Sudah Minum Obat"** jika statusnya `PENDING` atau belum tercatat untuk jam tersebut.

### B. Halaman Pengaturan & Alarm
- Menyediakan Time Picker untuk menambah waktu alarm.
- Kirim `timezone` menggunakan package `flutter_timezone` atau `DateTime.now().timeZoneName` secara otomatis agar server mengirim push notification tepat waktu.
