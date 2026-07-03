import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';

class DoctorConsultationsPage extends StatelessWidget {
  const DoctorConsultationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated consultation rooms from `consultations` and `chat_messages` DB modules
    final activeChats = [
      _ChatItem(
        name: 'Budi Santoso',
        lastMessage: 'Dok, hasil rujukan TCM saya sudah keluar. Harus saya kirim kemana?',
        time: '10:14',
        unreadCount: 1,
        status: 'active',
      ),
      _ChatItem(
        name: 'Rina Herawati',
        lastMessage: 'Baik dok, saya akan rutin minum obatnya tepat waktu.',
        time: 'Kemarin',
        unreadCount: 0,
        status: 'active',
      ),
      _ChatItem(
        name: 'Ahmad Pasien',
        lastMessage: 'Halo dok, dada saya terasa agak sesak di malam hari.',
        time: '2 hari lalu',
        unreadCount: 0,
        status: 'completed',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Konsultasi Telemedisin',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
          itemCount: activeChats.length,
          itemBuilder: (context, index) {
            final chat = activeChats[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                  child: Text(
                    chat.name.split(' ').map((e) => e[0]).join(),
                    style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF0F766E), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chat.name,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      chat.time,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: chat.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2DD4BF),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                  SnackBarUtils.showInfo(context, 'Membuka ruang chat telemedisin ${chat.name}.');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String status;

  _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.status,
  });
}
