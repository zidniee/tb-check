import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/screening_provider.dart';
import '../pages/screening_result_page.dart';

class RecordingStep extends StatefulWidget {
  final ScreeningProvider provider;

  const RecordingStep({
    super.key,
    required this.provider,
  });

  @override
  State<RecordingStep> createState() => _RecordingStepState();
}

class _RecordingStepState extends State<RecordingStep> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.provider.state) {
      case ScreeningState.idle:
        return _buildIdleState(context, widget.provider);
      case ScreeningState.recording:
        return _buildRecordingState(context, widget.provider);
      case ScreeningState.processing:
        return _buildProcessingState(context);
      case ScreeningState.analyzing:
        return _buildAnalyzingState(context);
      case ScreeningState.resultReady:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.provider.screeningResult != null) {
            final result = widget.provider.screeningResult!;
            final age = widget.provider.age ?? 0;
            final answers = widget.provider.getEncodedAnswers();
            
            // Reset provider so the screening page returns to a clean state
            widget.provider.reset();
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ScreeningResultPage(
                  result: result,
                  age: age,
                  encodedAnswers: answers,
                ),
              ),
            );
          }
        });
        return _buildAnalyzingState(context);
      case ScreeningState.error:
        return _buildErrorState(context, widget.provider);
    }
  }

  Widget _buildAnalyzingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Menjalankan Inferensi AI...',
          style: AppTextStyles.labelMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Model LSTM terkuantisasi lokal sedang menganalisis sinyal akustik batuk Anda secara privat.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIdleState(BuildContext context, ScreeningProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => provider.startRecording(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withOpacity(0.5),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                ),
                child: const Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mulai Rekam Suara Batuk',
          style: AppTextStyles.labelMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Tekan tombol di atas untuk merekam suara batuk Anda. Pastikan lingkungan hening dan Anda batuk dengan keras sebanyak 3-4 kali dalam durasi 5 detik.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState(BuildContext context, ScreeningProvider provider) {
    final progressVal = provider.recordingProgress / 5.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90 + (25 * _pulseController.value),
                  height: 90 + (25 * _pulseController.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.12 * (1.0 - _pulseController.value)),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Silakan Batuk...',
          style: AppTextStyles.labelMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          '${provider.recordingProgress.toStringAsFixed(1)}s / 5.0s',
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 180,
            height: 6,
            child: LinearProgressIndicator(
              value: progressVal,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mengekstrak Fitur Audio...',
          style: AppTextStyles.labelMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Sinyal audio batuk Anda sedang dikonversi secara lokal menjadi parameter akustik MFCC.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }



  Widget _buildErrorState(BuildContext context, ScreeningProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 56,
        ),
        const SizedBox(height: 16),
        Text(
          'Terjadi Kesalahan',
          style: AppTextStyles.labelMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            provider.errorMessage ?? 'Gagal memproses audio batuk.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.red.shade800, height: 1.4, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => provider.reset(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba Lagi'),
        ),
      ],
    );
  }
}
