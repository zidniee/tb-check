import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import 'notification_detail_page.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
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
        title: Text(
          'Notifikasi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                'Tandai dibaca',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.fetchNotifications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = provider.notifications[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: item.isRead ? Colors.white : AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: item.isRead ? AppColors.background : AppColors.primaryLight,
                            child: Icon(
                              _getIconForType(item.notificationType),
                              color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatTimestamp(item.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationDetailPage(
                                  notificationId: item.notificationId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'consultation':
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'screening':
        return Icons.medical_services_outlined;
      case 'medication':
        return Icons.medication_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j yang lalu';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 72, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Pemberitahuan konsultasi dan rekomendasi medis akan muncul di sini',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
