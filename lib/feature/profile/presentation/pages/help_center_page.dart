import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<Map<String, String>> _faqData = [
    {
      'category': 'Umum',
      'question': 'Apa itu TBCheck?',
      'answer': 'TBCheck adalah aplikasi asisten kesehatan digital yang dirancang untuk membantu dalam skrining mandiri gejala Tuberkulosis (TBC), pelacakan kepatuhan minum obat (terapi Care), pengaturan janji temu dokter, serta visualisasi pemodelan SVIR penyebaran infeksi TBC di masyarakat.'
    },
    {
      'category': 'Umum',
      'question': 'Apakah TBCheck dapat menggantikan diagnosis dokter?',
      'answer': 'Tidak. Hasil skrining dan analisis AI di TBCheck bersifat informatif untuk membantu deteksi dini dan meningkatkan kesadaran kesehatan. Diagnosis resmi dan penanganan medis tetap harus ditegakkan oleh dokter profesional.'
    },
    {
      'category': 'Janji Temu',
      'question': 'Bagaimana cara membuat janji temu dengan dokter?',
      'answer': 'Masuk ke halaman Utama, pilih menu "Cari Dokter" pada Aksi Cepat, tentukan tanggal serta waktu kunjungan kustom yang Anda inginkan, lalu ajukan permohonan. Anda akan menerima notifikasi jika dokter telah mengonfirmasi.'
    },
    {
      'category': 'Janji Temu',
      'question': 'Mengapa pengajuan reschedule (ubah jadwal) saya masih pending?',
      'answer': 'Setiap perubahan jadwal memerlukan konfirmasi manual dari dokter atau pihak klinik. Anda akan menerima pemberitahuan push segera setelah status janji temu Anda diperbarui.'
    },
    {
      'category': 'Pemantauan Care',
      'question': 'Bagaimana cara kerja pengingat minum obat (Care)?',
      'answer': 'Setelah dokter membuatkan rencana terapi obat, aplikasi akan mengirimkan notifikasi pengingat minum obat pada interval H-1 jam, H-30 menit, H-15 menit, dan tepat pada waktu minum obat. Anda dapat menandai obat telah diminum (Taken) langsung dari kartu jadwal di halaman Utama.'
    },
    {
      'category': 'Pemantauan Care',
      'question': 'Apa yang terjadi jika saya lupa menandai obat sebagai "Diminum"?',
      'answer': 'Jika status log obat masih PENDING hingga 2 jam melewati waktu yang dijadwalkan, sistem secara otomatis akan menandainya sebagai MISSED (Terlewat) untuk memantau kepatuhan terapi Anda secara akurat.'
    },
    {
      'category': 'Skrining & AI',
      'question': 'Bagaimana cara melakukan skrining batuk?',
      'answer': 'Anda dapat menekan menu Skrining pada navigasi bawah, lalu merekam suara batuk Anda sesuai panduan di layar. Model AI kami akan menganalisis tanda-tanda akustik untuk mengidentifikasi kemungkinan gejala terkait TBC.'
    },
    {
      'category': 'Skrining & AI',
      'question': 'Apa fungsi simulasi SVIR di TBCheck?',
      'answer': 'Simulasi SVIR memvisualisasikan dinamika penyebaran tuberkulosis di lingkungan sekitar berdasarkan parameter Susceptible (Rentan), Vaccinated (Tervaksinasi), Infected (Terinfeksi), dan Recovered (Sembuh) untuk tujuan edukasi.'
    },
  ];

  final List<String> _categories = ['Semua', 'Umum', 'Janji Temu', 'Pemantauan Care', 'Skrining & AI'];

  @override
  Widget build(BuildContext context) {
    // Filter FAQ list based on search query and selected category
    final filteredFaqs = _faqData.where((faq) {
      final matchesCategory = _selectedCategory == 'Semua' || faq['category'] == _selectedCategory;
      final matchesSearch = faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pusat Bantuan & FAQ'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan atau bantuan...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categories Chips horizontal list
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primaryLight.withOpacity(0.3),
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // FAQ List view
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Tidak ditemukan jawaban yang cocok dengan pencarian Anda.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        textAlign: Center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredFaqs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.help_center_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              faq['question']!,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
                                child: Text(
                                  faq['answer']!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
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
      ),
    );
  }
}
