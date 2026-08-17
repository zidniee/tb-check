import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../screening/presentation/providers/screening_provider.dart';
import '../../../screening/data/models/screening_report_dto.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScreeningProvider>(
      create: (_) => ScreeningProvider()..loadMyReports(),
      child: Consumer<ScreeningProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Riwayat Medis & Skrining'),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 0.5,
            ),
            body: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScreeningProvider provider) {
    if (provider.isLoadingReports) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat riwayat medis: ${provider.errorMessage}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadMyReports(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final reports = provider.myReports;

    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined, size: 48, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Riwayat Medis',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Lakukan skrining mandiri batuk Anda terlebih dahulu untuk melihat log riwayat kesehatan.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(ScreeningReportDTO report) {
    final isTbc = report.predictionStatus.toLowerCase().contains('terkena tbc') ||
        report.predictionStatus.toLowerCase().contains('tbc');
    final percentage = (report.probabilityScore * 100).toStringAsFixed(1);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(report.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTbc ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTbc ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
              color: isTbc ? Colors.red : Colors.green,
              size: 24,
            ),
          ),
          title: Text(
            report.predictionStatus,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isTbc ? Colors.red : Colors.green,
            ),
          ),
          subtitle: Text(
            '$formattedDate • Indikasi $percentage%',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          children: [
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Gejala Klinis yang Dilaporkan:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSymptomsGrid(report.clinicalAnswers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsGrid(Map<String, dynamic> answers) {
    final Map<String, String> symptomLabels = {
      'batuk_lama': 'Batuk > 2 Minggu',
      'batuk_berdarah': 'Batuk Berdarah',
      'demam': 'Demam',
      'berat_badan_turun': 'Berat Badan Turun',
      'keringat_malam': 'Keringat Malam',
      'nyeri_dada': 'Nyeri Dada',
      'nafsu_makan_turun': 'Nafsu Makan Turun',
      'malaise': 'Lemas/Malaise',
      'kontak_tbc': 'Kontak Erat TBC',
      'riwayat_merokok': 'Riwayat Merokok',
    };

    final List<Widget> list = [];

    // Add age if present
    if (answers.containsKey('age') && answers['age'] != null) {
      list.add(_buildSymptomItem('Usia', '${answers['age']} Tahun', true));
    }

    symptomLabels.forEach((key, label) {
      final val = answers[key];
      final isPositive = val == true || val == 1 || val == 'true';
      list.add(_buildSymptomItem(label, isPositive ? 'Ya' : 'Tidak', isPositive));
    });

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: list,
    );
  }

  Widget _buildSymptomItem(String label, String value, bool isPositive) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPositive ? AppColors.primaryLight.withOpacity(0.2) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPositive ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? Icons.check_box_outlined : Icons.check_box_outline_blank,
              size: 14,
              color: isPositive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '$label: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isPositive ? AppColors.primary : AppColors.textPrimary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
