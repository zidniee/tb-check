import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/screening_provider.dart';

class ScreeningBottomActions extends StatelessWidget {
  final ScreeningProvider provider;

  const ScreeningBottomActions({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Actions on Step 1: Questionnaire
    if (provider.currentStep == 0) {
      return CustomButton(
        text: 'Lanjutkan ke Perekaman',
        onPressed: () {
          if (provider.validateQuestionnaire()) {
            provider.setStep(1);
          } else {
            SnackBarUtils.showError(context, provider.errorMessage ?? 'Isi kuesioner secara lengkap.');
          }
        },
      );
    }

    // Actions on Step 2: Recording (Success state)
    if (provider.state == ScreeningState.success) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => provider.reset(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Mulai Baru',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Kirim Skrining',
              onPressed: () {
                final encodedAnswers = provider.getEncodedAnswers();
                final age = provider.age;

                SnackBarUtils.showSuccess(
                  context,
                  'Skrining terkirim!\nJawaban: $encodedAnswers | Usia: $age\nMFCC size: ${provider.mfccData?.length ?? 0}',
                );
              },
            ),
          ),
        ],
      );
    }
    
    // Actions on Step 2: Recording (Recording state)
    if (provider.state == ScreeningState.recording) {
      return CustomButton(
        text: 'Hentikan Rekaman',
        backgroundColor: Colors.redAccent,
        onPressed: () => provider.stopAndProcessRecording(),
      );
    }

    // Actions on Step 2: Recording (Idle / Error / Processing state)
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              provider.setStep(0);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Kembali',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Mulai Rekam Batuk',
            onPressed: provider.state == ScreeningState.processing ? null : () => provider.startRecording(),
          ),
        ),
      ],
    );
  }
}
