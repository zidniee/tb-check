import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import '../../../../core/service/notification_router.dart';

class NotificationDetailPage extends StatefulWidget {
  final String notificationId;

  const NotificationDetailPage({super.key, required this.notificationId});

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotificationDetail(widget.notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Notifikasi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: provider.isDetailLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.detailErrorMessage != null
              ? _buildErrorState(provider.detailErrorMessage!)
              : provider.activeDetail == null
                  ? const Center(child: Text('Notifikasi tidak ditemukan'))
                  : _buildContent(provider.activeDetail!),
    );
  }

  Widget _buildContent(dynamic detail) {
    final hasImage = detail.imageUrl != null && detail.imageUrl!.isNotEmpty;
    final hasAction = detail.actionType != null && detail.actionType!.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  detail.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: AppColors.border.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryBadge(detail.notificationType),
                const SizedBox(height: 12),
                Text(
                  detail.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 22,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(detail.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (detail.readAt != null) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dibaca ${_formatDateTime(detail.readAt!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (detail.summary != null && detail.summary!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      detail.summary!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const Divider(height: 32, color: AppColors.border),
                HtmlWidget(
                  detail.message,
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                if (hasAction) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _handleAction(detail.actionType!, detail.actionValue),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _getActionLabel(detail.actionType!),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String type) {
    Color bg = AppColors.primaryLight;
    Color fg = AppColors.primary;
    String label = type.toUpperCase();

    switch (type.toLowerCase()) {
      case 'system':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = 'Sistem';
        break;
      case 'announcement':
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = 'Pengumuman';
        break;
      case 'reminder':
      case 'medication':
      case 'care_reminder':
        bg = AppColors.secondaryLight;
        fg = AppColors.secondary;
        label = 'Pengingat';
        break;
      case 'chat':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = 'Pesan Chat';
        break;
      case 'screening':
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = 'Skrining';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    }
  }

  String _getActionLabel(String type) {
    switch (type) {
      case 'OPEN_URL':
        return 'Buka Link Informasi';
      case 'OPEN_SCREEN':
        return 'Lihat Selengkapnya';
      default:
        return 'Tindak Lanjuti';
    }
  }

  void _handleAction(String type, String? value) async {
    if (value == null || value.isEmpty) return;

    if (type == 'OPEN_URL') {
      final uri = Uri.parse(value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka tautan')),
          );
        }
      }
    } else if (type == 'OPEN_SCREEN') {
      if (mounted) {
        NotificationRouter.navigate(
          context,
          'general',
          actionType: type,
          actionValue: value,
        );
      }
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Detail',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Provider.of<NotificationProvider>(context, listen: false)
                    .fetchNotificationDetail(widget.notificationId);
              },
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      ),
    );
  }
}
