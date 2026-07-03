import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/patient_progress_chart.dart';
import '../widgets/risk_distribution_chart.dart';

class DoctorDashboardPage extends StatelessWidget {
  final VoidCallback onPatientsTabTap;
  final VoidCallback onConsultationsTabTap;

  const DoctorDashboardPage({
    super.key,
    required this.onPatientsTabTap,
    required this.onConsultationsTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Bar Header
              _buildTopBar(context),
              const SizedBox(height: 24),

              // 2. Patient Progress Chart
              const PatientProgressChart(),
              const SizedBox(height: 16),

              // 3. Summary Row: Patients Needing Attention & Risk Trends
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAttentionCard(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: RiskDistributionChart(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Quick Access Section
              _buildSectionTitle('Akses Cepat'),
              const SizedBox(height: 12),
              _buildQuickAccessCard(
                title: 'Tinjau Hasil Skrining',
                subtitle: 'Ada 5 laporan risiko tinggi baru masuk',
                icon: Icons.assignment_late_rounded,
                iconColor: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEF2F2),
                onTap: onPatientsTabTap,
              ),
              const SizedBox(height: 10),
              _buildQuickAccessCard(
                title: 'Konsultasi Aktif',
                subtitle: '2 chat telemedisin menunggu respon Anda',
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF0D9488),
                bgColor: const Color(0xFFF0FDF4),
                onTap: onConsultationsTabTap,
              ),
              const SizedBox(height: 24),

              // 5. Latest Patients Log
              _buildSectionTitle('Pasien Terbaru'),
              const SizedBox(height: 12),
              _buildLatestPatientsList(context),
              const SizedBox(height: 100), // clearance bottom bar spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Styled premium doctor avatar (medical teal theme)
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: profileProvider.profilePicturePath != null && profileProvider.profilePicturePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(
                        File(profileProvider.profilePicturePath!),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Dokter',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  profileProvider.doctorName,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Notification Button with badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SnackBarUtils.showInfo(context, 'Tidak ada notifikasi baru.');
                },
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 20),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444), // Red alert badge
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttentionCard(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light red alert background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perlu Perhatian',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF991B1B),
                ),
              ),
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '5 Pasien',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF991B1B),
            ),
          ),
          Text(
            'Risiko tinggi / tidak mengisi skrining rutin',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: const Color(0xFFB91C1C).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildLatestPatientsList(BuildContext context) {
    // Simulated patient data
    final patients = [
      _PatientItem(
        name: 'Budi Santoso',
        score: '92%',
        riskLevel: 'Risiko Tinggi',
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        date: 'Hari ini, 10:14',
      ),
      _PatientItem(
        name: 'Siti Aminah',
        score: '48%',
        riskLevel: 'Risiko Sedang',
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        date: 'Hari ini, 08:32',
      ),
      _PatientItem(
        name: 'Joko Susilo',
        score: '12%',
        riskLevel: 'Risiko Rendah',
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFF0FDF4),
        date: 'Kemarin, 16:45',
      ),
      _PatientItem(
        name: 'Rina Herawati',
        score: '85%',
        riskLevel: 'Risiko Tinggi',
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        date: 'Kemarin, 14:15',
      ),
    ];

    return Column(
      children: patients.map((patient) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF112028).withOpacity(0.08),
              child: Text(
                patient.name.split(' ').map((e) => e[0]).join(),
                style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF112028)),
              ),
            ),
            title: Text(
              patient.name,
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              patient.date,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Risk Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: patient.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    patient.riskLevel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: patient.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  patient.score,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: patient.color,
                  ),
                ),
              ],
            ),
            onTap: () {
              SnackBarUtils.showInfo(context, 'Detail skrining ${patient.name} dibuka.');
            },
          ),
        );
      }).toList(),
    );
  }
}

class _PatientItem {
  final String name;
  final String score;
  final String riskLevel;
  final Color color;
  final Color bgColor;
  final String date;

  _PatientItem({
    required this.name,
    required this.score,
    required this.riskLevel,
    required this.color,
    required this.bgColor,
    required this.date,
  });
}
