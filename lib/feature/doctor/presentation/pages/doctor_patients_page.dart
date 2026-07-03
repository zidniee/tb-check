import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';

class DoctorPatientsPage extends StatelessWidget {
  const DoctorPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated patient monitoring list from `patient_monitoring` DB module
    final monitoredPatients = [
      _MonitorItem(
        name: 'Budi Santoso',
        status: 'Rujukan TCM',
        statusColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        lastScreened: 'Hari ini',
        notes: 'Gejala batuk berdahak + demam. Dirujuk untuk Tes Cepat Molekuler (TCM).',
      ),
      _MonitorItem(
        name: 'Siti Aminah',
        status: 'Dalam Pengobatan',
        statusColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        lastScreened: '3 hari yang lalu',
        notes: 'Menjalani rejimen OAT bulan ke-2. Kepatuhan minum obat terpantau baik.',
      ),
      _MonitorItem(
        name: 'Joko Susilo',
        status: 'Sembuh (Cured)',
        statusColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFF0FDF4),
        lastScreened: '10 hari yang lalu',
        notes: 'Hasil TCM ulang negatif. Pengobatan selesai dengan sukses.',
      ),
      _MonitorItem(
        name: 'Rina Herawati',
        status: 'Rujukan TCM',
        statusColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        lastScreened: 'Kemarin',
        notes: 'Hasil AI batuk menunjukkan probabilitas tinggi (85%). Menunggu hasil TCM.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Monitoring Pasien',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
          itemCount: monitoredPatients.length,
          itemBuilder: (context, index) {
            final patient = monitoredPatients[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        patient.name,
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: patient.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          patient.status,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: patient.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Skrining terakhir: ${patient.lastScreened}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan Klinis:',
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.notes,
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          SnackBarUtils.showInfo(context, 'Membuka rekam medis ${patient.name}.');
                        },
                        child: Text(
                          'Lihat Rekam Medis',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MonitorItem {
  final String name;
  final String status;
  final Color statusColor;
  final Color bgColor;
  final String lastScreened;
  final String notes;

  _MonitorItem({
    required this.name,
    required this.status,
    required this.statusColor,
    required this.bgColor,
    required this.lastScreened,
    required this.notes,
  });
}
