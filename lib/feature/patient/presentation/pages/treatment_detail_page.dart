import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/care_notifier.dart';
import 'care_settings_page.dart';

class TreatmentDetailPage extends ConsumerWidget {
  const TreatmentDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careNotifierProvider);
    final treatment = state.treatment.value;

    if (treatment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Terapi')),
        body: const Center(child: Text('Terapi tidak ditemukan.')),
      );
    }

    final start = DateTime.tryParse(treatment.startDate) ?? DateTime.now();
    final estimatedEndDate = start.add(const Duration(days: 180));

    final startStr = _formatDate(start);
    final endStr = _formatDate(estimatedEndDate);

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
          'Detail Terapi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status Pengobatan',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        'AKTIF',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Tanggal Mulai', startStr),
                  const SizedBox(height: 14),
                  _buildDetailRow('Tanggal Selesai (Est.)', endStr),
                  const SizedBox(height: 14),
                  _buildDetailRow('Zona Waktu', treatment.timezone),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reminders Settings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pengingat Alarm',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifikasi Pengingat',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      Switch(
                        value: treatment.reminderEnabled,
                        onChanged: (val) {
                          ref.read(careNotifierProvider.notifier).updateTreatmentReminder(val);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Jadwal Harian',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      state.schedules.when(
                        loading: () => const Text('--'),
                        error: (_, __) => const Text('Error'),
                        data: (schedules) => Text(
                          '${schedules.length} Alarm',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CareSettingsPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Ubah Terapi & Alarm',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showStopTreatmentDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Hentikan Terapi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showStopTreatmentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hentikan Terapi TBC?'),
          content: const Text(
            'Menghentikan terapi pengobatan TBC secara sepihak sebelum waktu selesai sangat berbahaya bagi kesehatan Anda.\n\nApakah Anda yakin ingin menghapus seluruh jadwal pengobatan Anda?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog
                final success = await ref.read(careNotifierProvider.notifier).deleteTreatment();
                if (success && context.mounted) {
                  Navigator.pop(context); // exit detail page back to dashboard
                }
              },
              child: const Text('Hentikan & Hapus', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(dt);
    }
  }
}
