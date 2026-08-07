import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../patient/presentation/pages/hospital_list_page.dart';
import '../../domain/entities/screening_result.dart';
import '../../../education/presentation/pages/education_list_page.dart';

class ScreeningResultPage extends StatelessWidget {
  final ScreeningResult result;
  final int age;
  final List<int> encodedAnswers;

  const ScreeningResultPage({
    super.key,
    required this.result,
    required this.age,
    required this.encodedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = result.isTbPositive;
    final primaryColor = isPositive ? const Color(0xFFD32F2F) : AppColors.success;
    final lightColor = isPositive ? const Color(0xFFFFEBEE) : AppColors.successLight;
    final darkColor = isPositive ? const Color(0xFFB71C1C) : AppColors.successDark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hasil Skrining AI',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Result Card (Vibrant colors, Harmonious palette, Dynamic feel)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Circular Gauge / Progress
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: result.probabilityScore,
                            strokeWidth: 10,
                            backgroundColor: AppColors.border.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            strokeCap: StrokeCap.round,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                result.probabilityPercentage,
                                style: AppTextStyles.h5.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Probabilitas',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Diagnostic Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: lightColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        result.screeningStatus.toUpperCase(),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      isPositive
                          ? 'Skor probabilitas menunjukkan indikasi TBC sedang/tinggi berdasarkan analisis akustik suara batuk Anda.'
                          : 'Analisis akustik menunjukkan pola suara batuk Anda normal / non-TBC.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Technical Details Accordion / Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'METADATA SKRINING',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    
                    _buildMetaRow('Usia Pengguna', '$age Tahun'),
                    _buildMetaRow('Laju Inferensi (On-Device)', result.inferenceTimeFormatted),
                    _buildMetaRow('Jumlah Gejala Terlapor', '${encodedAnswers.where((x) => x == 1).length} dari 10'),
                    _buildMetaRow('Penyimpanan Laporan', 'Tersimpan Lokal (Offline-First)'),
                    _buildMetaRow('Waktu Pengujian', '${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year} ${result.createdAt.hour.toString().padLeft(2, '0')}:${result.createdAt.minute.toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Prominent Medical Disclaimer Banner (MANDATORY per SRS)
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4), // Amber/Yellow light background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFBC02D).withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF57F17),
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENTING: Disclaimer Medis',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 13,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Aplikasi TBCheck murni merupakan instrumen skrining awal preventif, BUKAN keputusan diagnosis medis final. Diagnosis medis resmi hanya diterbitkan oleh dokter paru melalui uji TCM laboratorium.',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF5D4037),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. Action Buttons
              if (isPositive) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Hospital list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HospitalListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_hospital_rounded, size: 20, color: Colors.white),
                  label: const Text('Cari Rumah Sakit Mitra Terdekat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // FR-012: Education button for "Tidak Terkena TBC" branch
              if (!isPositive) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EducationListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_florist_rounded, size: 20, color: Colors.white),
                  label: const Text('Lihat Edukasi Pencegahan Herbal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tombol Sementara untuk Testing Navigasi Rumah Sakit Mitra
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HospitalListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_hospital_rounded, size: 20, color: AppColors.primary),
                  label: const Text('Cari Rumah Sakit Mitra (Test)'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
