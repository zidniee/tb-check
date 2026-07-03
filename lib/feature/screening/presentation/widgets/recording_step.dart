import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/screening_provider.dart';

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
      case ScreeningState.success:
        return _buildSuccessState(context, widget.provider);
      case ScreeningState.error:
        return _buildErrorState(context, widget.provider);
    }
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

  Widget _buildSuccessState(BuildContext context, ScreeningProvider provider) {
    final mfcc = provider.mfccData;
    final firstCoeffs = mfcc != null && mfcc.length >= 5
        ? mfcc.take(5).map((e) => e.toStringAsFixed(3)).toList()
        : [];
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 56,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Ekstraksi Selesai!',
            style: AppTextStyles.labelMedium.copyWith(fontSize: 18, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Hasil pengisian kuesioner dan fitur akustik batuk siap diproses.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOKASI FILE AUDIO',
                        style: AppTextStyles.labelMedium.copyWith(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.recordedFilePath ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'METADATA FITUR MULTIMODAL',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 10,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Offline',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: AppColors.border),
                      _buildMetaRow('Usia Pengguna', '${provider.age} Tahun'),
                      _buildMetaRow('Kuesioner Terisi', '${provider.getEncodedAnswers().length} Fitur Biner'),
                      _buildMetaRow('Hasil Jawaban', provider.getEncodedAnswers().toString()),
                      _buildMetaRow('Dimensi MFCC', '500 x 39 Matrix (13 MFCC, 13 Delta, 13 Delta-Delta)'),
                      _buildMetaRow('Jumlah Nilai Data', mfcc != null ? '19.500 Nilai Float32' : '0 Nilai Float32'),
                      const SizedBox(height: 10),
                      Text(
                        '5 Koefisien Pertama Frame Ke-1:',
                        style: AppTextStyles.labelMedium.copyWith(fontSize: 11, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          firstCoeffs.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
