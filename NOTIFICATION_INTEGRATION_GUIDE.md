# 🔔 Panduan Integrasi Modul Notifikasi — Flutter Client

Panduan ini mendefinisikan langkah-langkah bagi Flutter developer untuk mengintegrasikan **Inbox Notifikasi**, **Halaman Detail Notifikasi**, dan **Custom Routing Push Notification (FCM)** menggunakan API Backend TBCheck terbaru.

---

## 1. Spesifikasi Endpoint API Notifikasi

Semua request memerlukan header `Authorization: Bearer <access_token>`.

| Fitur | Method | Path | Request Body / Query Params | Response |
|---|---|---|---|---|
| **Ambil Daftar Inbox** | `GET` | `/api/v1/notifications` | Query: `limit`, `page` | `List<NotificationResponse>` (200) |
| **Ambil Detail Tunggal** | `GET` | `/api/v1/notifications/:id` | - | `NotificationResponse` (200) |
| **Tandai Dibaca (Single)** | `PUT` | `/api/v1/notifications/:id/read` | - | `{"message": "..."}` (200) |
| **Tandai Semua Dibaca** | `PUT` | `/api/v1/notifications/read-all` | - | `{"message": "..."}` (200) |
| **Daftarkan Token Device** | `POST` | `/api/v1/notifications/device-token` | `{"fcm_token": "...", "device_id": "..."}` | `{"message": "..."}` (200) |

---

## 2. Layer Data & Model (Dart)

### A. Model Data Notifikasi
Buat berkas `lib/feature/notification/data/models/notification_model.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationResponse {
  @JsonKey(name: 'notification_id')
  final String notificationId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'summary')
  final String? summary;
  @JsonKey(name: 'message')
  final String message; // Dapat berupa Rich Text / Markdown HTML
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'action_type')
  final String? actionType; // "", "OPEN_URL", "OPEN_SCREEN"
  @JsonKey(name: 'action_value')
  final String? actionValue; // Link URL atau Nama Route Mobile
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'read_at')
  final String? readAt;
  @JsonKey(name: 'notification_type')
  final String notificationType; // "SYSTEM", "ANNOUNCEMENT", "REMINDER", etc.
  @JsonKey(name: 'created_at')
  final String createdAt;

  NotificationResponse({
    required this.notificationId,
    required this.userId,
    required this.title,
    this.summary,
    required this.message,
    this.imageUrl,
    this.actionType,
    this.actionValue,
    required this.isRead,
    this.readAt,
    required this.notificationType,
    required this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}
```

---

## 3. Layer Riverpod State Management

### A. Notification API Service
Buat di `lib/feature/notification/data/datasources/notification_remote_data_source.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final Dio _dio;
  NotificationRemoteDataSource(this._dio);

  Future<List<NotificationResponse>> getNotifications({int limit = 100, int page = 1}) async {
    final response = await _dio.get('/api/v1/notifications', queryParameters: {
      'limit': limit,
      'page': page,
    });
    return (response.data as List)
        .map((e) => NotificationResponse.fromJson(e))
        .toList();
  }

  Future<NotificationResponse> getNotificationDetail(String id) async {
    final response = await _dio.get('/api/v1/notifications/$id');
    return NotificationResponse.fromJson(response.data);
  }

  Future<void> markAsRead(String id) async {
    await _dio.put('/api/v1/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.put('/api/v1/notifications/read-all');
  }

  Future<void> registerDeviceToken(String fcmToken, String deviceId) async {
    await _dio.post('/api/v1/notifications/device-token', data: {
      'fcm_token': fcmToken,
      'device_id': deviceId,
    });
  }
}
```

### B. Provider & State Notifier
Buat di `lib/feature/notification/presentation/providers/notification_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../../../core/network/api_service.dart';

final notificationDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ApiService().dio);
});

class NotificationState {
  final AsyncValue<List<NotificationResponse>> notifications;
  final AsyncValue<NotificationResponse?> activeDetail;

  NotificationState({
    required this.notifications,
    required this.activeDetail,
  });

  NotificationState copyWith({
    AsyncValue<List<NotificationResponse>>? notifications,
    AsyncValue<NotificationResponse?>? activeDetail,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      activeDetail: activeDetail ?? this.activeDetail,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRemoteDataSource _dataSource;

  NotificationNotifier(this._dataSource)
      : super(NotificationState(
          notifications: const AsyncValue.loading(),
          activeDetail: const AsyncValue.data(null),
        ));

  Future<void> loadNotifications() async {
    state = state.copyWith(notifications: const AsyncValue.loading());
    try {
      final list = await _dataSource.getNotifications();
      state = state.copyWith(notifications: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(notifications: AsyncValue.error(e, stack));
    }
  }

  Future<void> loadDetail(String id) async {
    state = state.copyWith(activeDetail: const AsyncValue.loading());
    try {
      final detail = await _dataSource.getNotificationDetail(id);
      state = state.copyWith(activeDetail: AsyncValue.data(detail));
      
      // Auto mark as read di UI & Backend jika statusnya masih unread
      if (!detail.isRead) {
        await _dataSource.markAsRead(id);
        // Refresh local list untuk update badging/bolding
        loadNotifications();
      }
    } catch (e, stack) {
      state = state.copyWith(activeDetail: AsyncValue.error(e, stack));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      // Handle error
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final dataSource = ref.watch(notificationDataSourceProvider);
  return NotificationNotifier(dataSource)..loadNotifications();
});
```

---

## 4. UI Halaman Detail Notifikasi (`NotificationDetailPage`)

Halaman ini digunakan untuk merender visual notifikasi, termasuk gambar cover/banner dan detail pesan Rich Text/HTML (dari Admin).
Buat berkas `lib/feature/notification/presentation/pages/notification_detail_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/notification_provider.dart';

class NotificationDetailPage extends ConsumerStatefulWidget {
  final String notificationId;

  const NotificationDetailPage({super.key, required this.notificationId});

  @override
  ConsumerState<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends ConsumerState<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationProvider.notifier).loadDetail(widget.notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Notifikasi'),
      ),
      body: state.activeDetail.when(
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Notifikasi tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.imageUrl != null && detail.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      detail.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  detail.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Diterima: ${detail.createdAt}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Divider(height: 32),
                
                // Render detail isi pesan HTML/Markdown
                HtmlWidget(
                  detail.message,
                  textStyle: const TextStyle(fontSize: 15, height: 1.5),
                ),
                
                // Tampilkan tombol aksi jika dikonfigurasi oleh admin
                if (detail.actionType != null && detail.actionType!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleAction(detail.actionType!, detail.actionValue),
                      child: Text(_getActionLabel(detail.actionType!)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _getActionLabel(String type) {
    switch (type) {
      case 'OPEN_URL':
        return 'Buka Tautan Resmi';
      case 'OPEN_SCREEN':
        return 'Menuju Halaman';
      default:
        return 'Lihat';
    }
  }

  void _handleAction(String type, String? value) async {
    if (value == null || value.isEmpty) return;

    if (type == 'OPEN_URL') {
      final uri = Uri.parse(value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (type == 'OPEN_SCREEN') {
      // Navigasi ke halaman tertentu (sesuaikan dengan Router/Navigator Anda)
      // Navigator.pushNamed(context, value);
    }
  }
}
```

---

## 5. FCM Custom Routing & Aksi Klik (Click Action)

Perbarui `notification_router.dart` untuk mendukung aksi klik langsung ke detail notifikasi atau screen spesifik:

```dart
import 'package:flutter/material.dart';
import '../presentation/pages/notification_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationRouter {
  static void navigate(BuildContext context, String notificationType, {String? relatedId, String? actionType, String? actionValue}) {
    
    // 1. Jika bertipe reminder minum obat
    if (notificationType == 'CARE_REMINDER') {
      // Arahkan ke halaman log minum obat hari ini
      // Navigator.pushNamed(context, '/care/confirm');
      return;
    }

    // 2. Jika tipe aksinya adalah buka url langsung
    if (actionType == 'OPEN_URL' && actionValue != null && actionValue.isNotEmpty) {
      launchUrl(Uri.parse(actionValue), mode: LaunchMode.externalApplication);
      return;
    }

    // 3. Jika tipe aksinya buka screen langsung
    if (actionType == 'OPEN_SCREEN' && actionValue != null && actionValue.isNotEmpty) {
      Navigator.pushNamed(context, actionValue);
      return;
    }

    // 4. Default: Jika memiliki ID, buka halaman Detail Notifikasi
    if (relatedId != null && relatedId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationDetailPage(notificationId: relatedId),
        ),
      );
      return;
    }

    // 5. Fallback ke list Notifikasi
    Navigator.pushNamed(context, '/notifications');
  }
}
```
