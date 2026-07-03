import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/screening_provider.dart';

class QuestionnaireStep extends StatelessWidget {
  final ScreeningProvider provider;
  final TextEditingController ageController;
  final List<String> questions;

  const QuestionnaireStep({
    super.key,
    required this.provider,
    required this.ageController,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kuesioner Gejala Medis',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Isi kuesioner berdasarkan panduan WHO/Kemenkes RI.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        
        // Form Fields Scrollable
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Age Input Field
                Text(
                  'Usia Anda (Tahun)',
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan usia saat ini',
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  style: AppTextStyles.bodyLarge,
                  onChanged: (val) {
                    final ageVal = int.tryParse(val);
                    provider.setAge(ageVal);
                  },
                ),
                const SizedBox(height: 24),
                
                // Questions List header
                Text(
                  'Daftar Gejala & Faktor Risiko',
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                
                // Questions
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  separatorBuilder: (context, index) => const Divider(height: 20, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final isYes = provider.answers[index] ?? false;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            questions[index],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildPillButton(
                                label: 'Tidak',
                                isSelected: !isYes,
                                activeColor: AppColors.textSecondary.withOpacity(0.15),
                                activeTextColor: AppColors.textPrimary,
                                onTap: () => provider.setAnswer(index, false),
                              ),
                              const SizedBox(width: 12),
                              _buildPillButton(
                                label: 'Ya',
                                isSelected: isYes,
                                activeColor: AppColors.primary,
                                activeTextColor: Colors.white,
                                onTap: () => provider.setAnswer(index, true),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color activeTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            color: isSelected ? activeTextColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
