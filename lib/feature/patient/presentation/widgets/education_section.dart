import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        'title': 'Tips Minum Obat',
        'subtitle': 'Atur alarm dan minum obat secara teratur.',
        'content': 'Minum obat TBC di waktu yang sama setiap hari. Cara terbaik adalah meminumnya di pagi hari sebelum sarapan agar penyerapan obat maksimal. Jika mengalami mual, konsultasikan dengan dokter untuk meminumnya sebelum tidur.',
        'icon': '⏰',
      },
      {
        'title': 'Nutrisi Selama Terapi',
        'subtitle': 'Makanan bergizi tinggi untuk imun tubuh.',
        'content': 'Konsumsi makanan kaya protein seperti telur, ikan, susu, dan kacang-kacangan untuk mempercepat regenerasi sel paru-paru. Penuhi juga kebutuhan vitamin C dan mineral dari sayur-sayuran hijau serta buah-buahan segar.',
        'icon': '🥗',
      },
      {
        'title': 'Efek Samping Obat',
        'subtitle': 'Kenali reaksi obat dan penanganannya.',
        'content': 'Reaksi umum obat TBC meliputi urin berwarna kemerahan (normal karena efek Rifampisin), mual ringan, atau nyeri sendi. Segera hubungi dokter jika Anda mengalami mata kuning, gatal-gatal parah, atau gangguan penglihatan.',
        'icon': '💊',
      },
      {
        'title': 'Jangan Putus Obat',
        'subtitle': 'Mengapa kepatuhan TBC sangat penting.',
        'content': 'Menghentikan pengobatan sebelum waktunya (minimal 6 bulan) dapat memicu bakteri TBC menjadi kebal obat (TBC MDR/Multi-Drug Resistant) yang memerlukan terapi lebih lama (sampai 2 tahun) dan obat yang lebih keras.',
        'icon': '🛡️',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edukasi Pendamping',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => _showDetailsSheet(context, item['title']!, item['content']!),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                            item['icon']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        item['title']!,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetailsSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                content,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.5,
                  fontSize: 14,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Mengerti',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
