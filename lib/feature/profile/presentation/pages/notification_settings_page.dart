import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/data/models/notification_preferences_dto.dart';
import '../../../patient/presentation/providers/care_notifier.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      legacy.Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotificationPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final careState = ref.watch(careNotifierProvider);
    final treatment = careState.treatment.value;
    final legacyNotifyProvider = legacy.Provider.of<NotificationProvider>(context);

    final prefs = legacyNotifyProvider.preferences;
    final isLoading = legacyNotifyProvider.isPrefsLoading;
    final hasError = legacyNotifyProvider.prefsErrorMessage != null;

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
          'Pengaturan Notifikasi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? _buildErrorWidget(context, legacyNotifyProvider)
              : prefs == null
                  ? _buildEmptyOrRetryWidget(context, legacyNotifyProvider)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Server-Side Push Notification Settings (Daily Screening, Education, Appointments)
                          _buildSectionTitle('Preferensi Akun (Push Notification)'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                // Daily Screening Toggle
                                _buildSwitchTile(
                                  title: 'Pengingat Skrining Harian',
                                  subtitle: 'Ingatkan saya untuk skrining gejala TBC harian',
                                  value: prefs.dailyScreeningEnabled,
                                  icon: Icons.checklist_rtl_rounded,
                                  iconColor: AppColors.primary,
                                  iconBgColor: AppColors.primaryLight,
                                  onChanged: (val) async {
                                    final newPrefs = prefs.copyWith(dailyScreeningEnabled: val);
                                    final success = await legacyNotifyProvider.updateNotificationPreferences(newPrefs);
                                    if (success && mounted) {
                                      SnackBarUtils.showSuccess(
                                        context,
                                        val ? 'Pengingat skrining diaktifkan' : 'Pengingat skrining dinonaktifkan',
                                      );
                                    }
                                  },
                                ),
                                if (prefs.dailyScreeningEnabled) ...[
                                  const Divider(height: 1, indent: 64),
                                  // Daily Screening Time Selector
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 20),
                                    ),
                                    title: Text(
                                      'Waktu Pengingat',
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Jam pengingat dikirim: ${prefs.dailyScreeningTime}',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => _pickScreeningTime(context, legacyNotifyProvider, prefs),
                                      child: Text(
                                        'Ubah',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const Divider(height: 1, indent: 64),
                                // Education Toggle
                                _buildSwitchTile(
                                  title: 'Edukasi & Tips Kesehatan',
                                  subtitle: 'Notifikasi tips pola hidup sehat & pencegahan TBC',
                                  value: prefs.educationNotificationsEnabled,
                                  icon: Icons.lightbulb_outline_rounded,
                                  iconColor: Colors.orange,
                                  iconBgColor: const Color(0xFFFFF3E0),
                                  onChanged: (val) async {
                                    final newPrefs = prefs.copyWith(educationNotificationsEnabled: val);
                                    final success = await legacyNotifyProvider.updateNotificationPreferences(newPrefs);
                                    if (success && mounted) {
                                      SnackBarUtils.showSuccess(
                                        context,
                                        val ? 'Notifikasi edukasi diaktifkan' : 'Notifikasi edukasi dinonaktifkan',
                                      );
                                    }
                                  },
                                ),
                                const Divider(height: 1, indent: 64),
                                // Appointment Toggle
                                _buildSwitchTile(
                                  title: 'Pengingat Janji Temu',
                                  subtitle: 'Alarm konsultasi dokter & kontrol rumah sakit',
                                  value: prefs.appointmentRemindersEnabled,
                                  icon: Icons.calendar_month_rounded,
                                  iconColor: Colors.blueGrey,
                                  iconBgColor: Colors.blueGrey.shade50,
                                  onChanged: (val) async {
                                    final newPrefs = prefs.copyWith(appointmentRemindersEnabled: val);
                                    final success = await legacyNotifyProvider.updateNotificationPreferences(newPrefs);
                                    if (success && mounted) {
                                      SnackBarUtils.showSuccess(
                                        context,
                                        val ? 'Pengingat janji temu diaktifkan' : 'Pengingat janji temu dinonaktifkan',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Server Medication Reminders (Syncs with treatment)
                          _buildSectionTitle('Program Terapi (Koneksi Server)'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: treatment == null
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Terapi minum obat belum aktif. Daftarkan terapi Anda di menu pendamping perawatan untuk mengaktifkan sinkronisasi pengingat obat.',
                                            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _buildSwitchTile(
                                    title: 'Pengingat Minum Obat',
                                    subtitle: 'Kirim notifikasi untuk setiap jadwal alarm terapi Anda',
                                    value: treatment.reminderEnabled,
                                    icon: Icons.medication_rounded,
                                    iconColor: AppColors.success,
                                    iconBgColor: AppColors.successLight,
                                    onChanged: (val) async {
                                      final success = await ref
                                          .read(careNotifierProvider.notifier)
                                          .updateTreatmentReminder(val);
                                      if (success && mounted) {
                                        SnackBarUtils.showSuccess(
                                          context,
                                          val ? 'Pengingat obat diaktifkan' : 'Pengingat obat dinonaktifkan',
                                        );
                                      }
                                    },
                                  ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  void _pickScreeningTime(
    BuildContext context,
    NotificationProvider provider,
    NotificationPreferencesDTO prefs,
  ) async {
    final parts = prefs.dailyScreeningTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final timeStr = "$hour:$minute";

      final newPrefs = prefs.copyWith(dailyScreeningTime: timeStr);
      final success = await provider.updateNotificationPreferences(newPrefs);
      if (success && mounted) {
        SnackBarUtils.showSuccess(context, 'Waktu pengingat skrining diubah menjadi $timeStr');
      }
    }
  }

  Widget _buildErrorWidget(BuildContext context, NotificationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat pengaturan',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.prefsErrorMessage ?? 'Terjadi kesalahan tidak dikenal.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.fetchNotificationPreferences(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrRetryWidget(BuildContext context, NotificationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Pengaturan tidak tersedia',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.fetchNotificationPreferences(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Muat Pengaturan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
