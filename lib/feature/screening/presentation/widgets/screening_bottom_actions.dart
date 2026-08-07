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

    // Actions on Step 2: Recording (Processing / Analyzing / ResultReady state)
    final isLoading = provider.state == ScreeningState.processing ||
        provider.state == ScreeningState.analyzing ||
        provider.state == ScreeningState.resultReady;

    if (isLoading) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Kembali',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: provider.state == ScreeningState.processing ? 'Mengekstrak...' : 'Menganalisis...',
              onPressed: null,
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

    // Actions on Step 2: Recording (Idle / Error state)
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
            onPressed: () => provider.startRecording(),
          ),
        ),
      ],
    );
  }
}
