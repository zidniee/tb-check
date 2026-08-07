import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_stats.dart';

/// Mock datasource providing hardcoded phytochemical herbal education data.
///
/// This will be replaced with real Dio HTTP calls once the backend API
/// is available. All response shapes match the REST API contract from
/// the education-modul specification.
class EducationMockDatasource {
  // ─────────────────────────────────────────────────────────
  // MOCK DATA STORE
  // ─────────────────────────────────────────────────────────

  static final List<EducationContent> _mockContents = [
    // ── Article 1: Kunyit / Kurkumin ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000001',
      title: 'Manfaat Kurkumin dari Kunyit untuk Kesehatan Paru-Paru',
      summary:
          'Kurkumin, senyawa polifenol aktif dalam kunyit (Curcuma longa), memiliki sifat antiinflamasi dan antimikroba yang telah diteliti secara luas dalam konteks pencegahan infeksi saluran pernapasan.',
      body: _kurkuminArticleBody,
      contentType: EducationContentType.article,
      imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=800',
      thumbnailUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400',
      durationSeconds: 300,
      tags: ['kurkumin', 'kunyit', 'polifenol', 'antiinflamasi', 'herbal'],
      sourceUrl: 'https://doi.org/10.1016/j.phymed.2020.153270',
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 7, 1),
    ),

    // ── Article 2: Jahe Merah / Gingerol ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000002',
      title: 'Gingerol dan Jahe Merah: Perlindungan Saluran Pernapasan',
      summary:
          'Jahe merah (Zingiber officinale var. rubrum) mengandung gingerol dan shogaol yang membantu melegakan saluran pernapasan serta meningkatkan respons imun tubuh.',
      body: _jaheArticleBody,
      contentType: EducationContentType.article,
      imageUrl: 'https://images.unsplash.com/photo-1573414716419-9dcb9ea1eb62?w=800',
      thumbnailUrl: 'https://images.unsplash.com/photo-1573414716419-9dcb9ea1eb62?w=400',
      durationSeconds: 240,
      tags: ['gingerol', 'jahe merah', 'terpenoid', 'imunomodulator'],
      sourceUrl: 'https://doi.org/10.3390/molecules25204294',
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 7, 2),
    ),

    // ── Article 3: Bawang Putih / Allicin ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000003',
      title: 'Allicin dalam Bawang Putih: Agen Antimikroba Alami',
      summary:
          'Bawang putih (Allium sativum) mengandung allicin, senyawa organosulfur yang telah terbukti memiliki aktivitas antimikroba terhadap berbagai patogen termasuk Mycobacterium tuberculosis.',
      body: _bawangPutihArticleBody,
      contentType: EducationContentType.article,
      imageUrl: 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=800',
      thumbnailUrl: 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=400',
      durationSeconds: 270,
      tags: ['allicin', 'bawang putih', 'organosulfur', 'antimikroba'],
      sourceUrl: 'https://doi.org/10.1016/j.jep.2019.112165',
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 7, 3),
    ),

    // ── Article 4: Meniran / Phyllanthus ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000004',
      title: 'Meniran (Phyllanthus niruri): Stimulasi Imunitas Paru',
      summary:
          'Tanaman meniran telah lama digunakan dalam pengobatan tradisional Indonesia untuk meningkatkan daya tahan tubuh. Senyawa flavonoid dan lignan di dalamnya memiliki efek imunostimulan.',
      body: _meniranArticleBody,
      contentType: EducationContentType.article,
      imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
      thumbnailUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
      durationSeconds: 210,
      tags: ['flavonoid', 'meniran', 'lignan', 'imunostimulan'],
      sourceUrl: 'https://doi.org/10.1016/j.jep.2017.11.020',
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 6, 28),
    ),

    // ── Video 1: Herbal untuk Paru ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000005',
      title: 'Video: Mengenal Tanaman Herbal Pelindung Paru-Paru',
      summary:
          'Video edukasi singkat mengenai berbagai tanaman herbal Indonesia yang memiliki potensi melindungi kesehatan paru-paru berdasarkan penelitian fitokimia terkini.',
      contentType: EducationContentType.video,
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      youtubeVideoId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=400',
      durationSeconds: 485,
      tags: ['herbal', 'paru-paru', 'fitokimia', 'video edukasi'],
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 6, 25),
    ),

    // ── Article 5: Temulawak / Xanthorrhizol ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000006',
      title: 'Xanthorrhizol dari Temulawak: Anti-TBC Potensial',
      summary:
          'Temulawak (Curcuma xanthorrhiza) mengandung xanthorrhizol, senyawa seskuiterpenoid yang menunjukkan aktivitas anti-tuberkulosis dalam studi in-vitro terhadap M. tuberculosis.',
      body: _temulawakArticleBody,
      contentType: EducationContentType.article,
      imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=800',
      thumbnailUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400',
      durationSeconds: 280,
      tags: ['xanthorrhizol', 'temulawak', 'seskuiterpenoid', 'anti-tuberkulosis'],
      sourceUrl: 'https://doi.org/10.1016/j.fitote.2020.104610',
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 7, 4),
    ),

    // ── Video 2: Cara Membuat Jamu ──
    EducationContent(
      contentId: 'c101a001-aaaa-4000-b001-000000000007',
      title: 'Video: Cara Aman Mengonsumsi Jamu Herbal Pencegah TBC',
      summary:
          'Panduan video tentang cara menyiapkan dan mengonsumsi jamu herbal yang aman untuk mendukung kesehatan paru-paru, termasuk dosis yang direkomendasikan.',
      contentType: EducationContentType.video,
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      youtubeVideoId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
      durationSeconds: 612,
      tags: ['jamu', 'cara membuat', 'dosis', 'keamanan'],
      authorName: 'Tim Medis TBCheck',
      publishedAt: DateTime(2026, 6, 30),
    ),
  ];

  /// Simulated user reading progress.
  final Map<String, ReadingProgress> _progressStore = {
    'c101a001-aaaa-4000-b001-000000000001': const ReadingProgress(
      isCompleted: true,
      progressPercent: 100,
      lastPosition: 1200,
      startedAt: null,
    ),
    'c101a001-aaaa-4000-b001-000000000002': const ReadingProgress(
      isCompleted: false,
      progressPercent: 45,
      lastPosition: 850,
      startedAt: null,
    ),
  };

  // ─────────────────────────────────────────────────────────
  // API-MIRRORING METHODS
  // ─────────────────────────────────────────────────────────

  /// Mirrors `GET /education/contents`
  Future<Map<String, dynamic>> getContents({
    String? contentType,
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var filtered = List<EducationContent>.from(_mockContents);

    if (contentType != null) {
      final type = contentType == 'article'
          ? EducationContentType.article
          : EducationContentType.video;
      filtered = filtered.where((c) => c.contentType == type).toList();
    }

    final total = filtered.length;
    final start = (page - 1) * pageSize;
    final end = start + pageSize > total ? total : start + pageSize;
    final paged = start < total ? filtered.sublist(start, end) : <EducationContent>[];

    // Attach progress if available
    final withProgress = paged.map((c) {
      final progress = _progressStore[c.contentId];
      return progress != null ? c.copyWith(userProgress: progress) : c;
    }).toList();

    return {
      'contents': withProgress,
      'page': page,
      'page_size': pageSize,
      'total': total,
    };
  }

  /// Mirrors `GET /education/contents/:id`
  Future<EducationContent> getContentById(String contentId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final content = _mockContents.firstWhere(
      (c) => c.contentId == contentId,
      orElse: () => throw Exception('Content not found: $contentId'),
    );

    final progress = _progressStore[contentId];
    return progress != null ? content.copyWith(userProgress: progress) : content;
  }

  /// Mirrors `GET /education/contents/search`
  Future<List<EducationContent>> searchContents(String keyword, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final lowerKeyword = keyword.toLowerCase();
    final results = _mockContents.where((c) {
      return c.title.toLowerCase().contains(lowerKeyword) ||
          c.summary.toLowerCase().contains(lowerKeyword) ||
          (c.body?.toLowerCase().contains(lowerKeyword) ?? false) ||
          c.tags.any((t) => t.toLowerCase().contains(lowerKeyword));
    }).take(limit).toList();

    return results;
  }

  /// Mirrors `POST /education/progress`
  Future<void> updateProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _progressStore[contentId] = ReadingProgress(
      isCompleted: isCompleted,
      progressPercent: progressPercent,
      lastPosition: lastPosition,
      startedAt: DateTime.now(),
    );
  }

  /// Mirrors `GET /education/progress/stats`
  Future<LearningStats> getLearningStats() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final totalStarted = _progressStore.length;
    final totalCompleted = _progressStore.values.where((p) => p.isCompleted).length;
    final totalPercent = _progressStore.isEmpty
        ? 0
        : _progressStore.values.fold<int>(0, (sum, p) => sum + p.progressPercent) ~/
            _mockContents.length;

    return LearningStats(
      totalContents: _mockContents.length,
      totalStarted: totalStarted,
      totalCompleted: totalCompleted,
      overallPercent: totalPercent,
    );
  }
}

// ─────────────────────────────────────────────────────────
// ARTICLE BODY CONTENT (Markdown format with Herbal Clause)
// ─────────────────────────────────────────────────────────

const String _kurkuminArticleBody = '''
> **⚠️ Klausul Herbal:** Informasi fitokimia herbal pencegahan ini murni bersifat preventif untuk menunjang imunitas paru, serta **TIDAK BOLEH** diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.
>
> Selalu konsultasikan dengan dokter spesialis paru sebelum mengonsumsi bahan herbal bersamaan dengan regimen obat TBC Anda.

---

## 🌿 Kunyit (Curcuma longa)

### Profil Tanaman
Kunyit adalah tanaman rimpang dari keluarga **Zingiberaceae** yang telah digunakan selama ribuan tahun dalam pengobatan tradisional Ayurveda dan Jamu Indonesia. Rimpang kunyit mengandung senyawa bioaktif utama bernama **kurkumin** (diferuloilmetana).

### Kandungan Fitokimia Aktif

| Senyawa | Golongan | Kadar |
|:--------|:---------|:------|
| **Kurkumin** | Polifenol (Kurkuminoid) | 2-5% berat kering |
| Demetoksikurkumin | Polifenol (Kurkuminoid) | 1-2% |
| Bisdemetoksikurkumin | Polifenol (Kurkuminoid) | 0.5-1% |
| Turmerone | Seskuiterpenoid | 3-5% |

### Mekanisme Aksi Anti-TBC

**1. Antiinflamasi:**
Kurkumin menghambat jalur sinyal **NF-κB** (Nuclear Factor kappa B), menurunkan produksi sitokin proinflamasi seperti TNF-α, IL-1β, dan IL-6 yang berperan dalam kerusakan jaringan paru akibat infeksi TB.

**2. Antimikroba:**
Studi in-vitro menunjukkan kurkumin memiliki aktivitas bakteriostatik terhadap *Mycobacterium tuberculosis* pada konsentrasi **MIC 50-100 μg/mL** melalui disrupsi membran sel bakteri.

**3. Imunomodulator:**
Kurkumin meningkatkan aktivitas makrofag alveolar dan sel NK (Natural Killer) yang menjadi lini pertahanan pertama paru-paru terhadap infeksi mikobakteri.

### Dosis Preventif yang Disarankan
- **Rimpang segar:** 2-4 gram/hari (diparut atau dijus)
- **Ekstrak standar:** 500-1000 mg kurkuminoid/hari
- **Catatan:** Bioavailabilitas meningkat 2000% bila dikonsumsi bersama piperin (lada hitam)

### Referensi Ilmiah
1. Gupta, S.C. et al. (2020). "Curcumin as a potential anti-tuberculosis agent." *Phytomedicine*, 71, 153270. DOI: 10.1016/j.phymed.2020.153270
2. Jahagirdar, P.B. et al. (2019). "Curcumin modulates inflammatory pathways in tuberculosis." *Frontiers in Immunology*, 10, 1322.
''';

const String _jaheArticleBody = '''
> **⚠️ Klausul Herbal:** Informasi fitokimia herbal pencegahan ini murni bersifat preventif untuk menunjang imunitas paru, serta **TIDAK BOLEH** diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.
>
> Selalu konsultasikan dengan dokter spesialis paru sebelum mengonsumsi bahan herbal bersamaan dengan regimen obat TBC Anda.

---

## 🌿 Jahe Merah (Zingiber officinale var. rubrum)

### Profil Tanaman
Jahe merah adalah varietas jahe dengan rimpang berwarna merah-oranye yang memiliki kandungan senyawa bioaktif lebih tinggi dibanding jahe putih biasa. Tanaman ini sudah lama menjadi bagian dari farmakopoeia tradisional Nusantara.

### Kandungan Fitokimia Aktif

| Senyawa | Golongan | Fungsi Utama |
|:--------|:---------|:-------------|
| **Gingerol (6-Gingerol)** | Fenolik | Antiinflamasi, Antioksidan |
| **Shogaol (6-Shogaol)** | Fenolik | Antimikroba, Antitusif |
| Zingerene | Terpenoid | Ekspektoran |
| Geraniol | Monoterpenoid | Antibakteri |

### Mekanisme Aksi terhadap Kesehatan Paru

**1. Efek Bronkodilator:**
Gingerol menunjukkan kemampuan merelaksasi otot polos bronkial melalui inhibisi fosfodiesterase (PDE), membantu membuka saluran napas.

**2. Efek Antimikroba:**
6-Shogaol menunjukkan aktivitas antimikroba terhadap bakteri gram-positif dan gram-negatif melalui gangguan integritas membran sel.

**3. Efek Imunomodulator:**
Meningkatkan produksi IFN-γ (Interferon Gamma) oleh sel T helper, memperkuat respons imun adaptif terhadap patogen intraseluler termasuk *M. tuberculosis*.

### Dosis Preventif
- **Rimpang segar:** 2-4 gram/hari (diseduh air hangat)
- **Ekstrak standar:** 250-500 mg/hari
- **Peringatan:** Hindari konsumsi berlebih pada pasien dengan gangguan pembekuan darah

### Referensi Ilmiah
1. Mao, Q.Q. et al. (2019). "Bioactive Compounds and Bioactivities of Ginger." *Foods*, 8(6), 185.
2. Rahmani, A.H. et al. (2020). "Active ingredients of ginger as potential candidates." *Molecules*, 25(19), 4294.
''';

const String _bawangPutihArticleBody = '''
> **⚠️ Klausul Herbal:** Informasi fitokimia herbal pencegahan ini murni bersifat preventif untuk menunjang imunitas paru, serta **TIDAK BOLEH** diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.
>
> Selalu konsultasikan dengan dokter spesialis paru sebelum mengonsumsi bahan herbal bersamaan dengan regimen obat TBC Anda.

---

## 🌿 Bawang Putih (Allium sativum)

### Profil Tanaman
Bawang putih telah digunakan sebagai rempah sekaligus obat tradisional selama lebih dari 5.000 tahun. Senyawa allicin yang dihasilkan saat umbi bawang dihancurkan menjadi agen antimikroba spektrum luas.

### Kandungan Fitokimia Aktif

| Senyawa | Golongan | Fungsi Utama |
|:--------|:---------|:-------------|
| **Allicin** | Organosulfur (Tiosulfinat) | Antimikroba luas |
| Ajoene | Organosulfur | Antitrombotik, Antimikroba |
| S-allyl cysteine | Organosulfur | Antioksidan |
| Quercetin | Flavonoid | Antiinflamasi |

### Mekanisme Aksi Anti-TBC

**1. Aktivitas Antimikroba Langsung:**
Allicin mengganggu enzim thiol-dependent *M. tuberculosis*, khususnya enzim **thioredoxin reductase**, yang esensial untuk kelangsungan hidup bakteri. MIC terhadap M.tb: **4-8 μg/mL**.

**2. Imunomodulasi:**
S-allyl cysteine meningkatkan proliferasi limfosit T CD4+ dan memperkuat sinyal Th1 yang krusial untuk respons imun melawan infeksi TB intraseluler.

**3. Proteksi Hepatoprotektif:**
Penting bagi pasien TBC yang menjalani terapi OAT, karena ajoene membantu melindungi sel hati dari hepatotoksisitas obat isoniazid dan rifampisin.

### Dosis Preventif
- **Umbi segar:** 2-4 siung/hari (dihancurkan, diamkan 10 menit sebelum konsumsi agar allicin terbentuk)
- **Ekstrak standar:** 600-1200 mg/hari (mengandung ≥ 3.6 mg allicin)

### Referensi Ilmiah
1. Dwivedi, V.P. et al. (2019). "Allicin enhances antimycobacterial activity." *J. Ethnopharmacology*, 244, 112165.
2. Viswanathan, V. et al. (2018). "Garlic supplementation in TB management." *Indian J. Tuberculosis*, 65(3), 215-220.
''';

const String _meniranArticleBody = '''
> **⚠️ Klausul Herbal:** Informasi fitokimia herbal pencegahan ini murni bersifat preventif untuk menunjang imunitas paru, serta **TIDAK BOLEH** diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.
>
> Selalu konsultasikan dengan dokter spesialis paru sebelum mengonsumsi bahan herbal bersamaan dengan regimen obat TBC Anda.

---

## 🌿 Meniran (Phyllanthus niruri)

### Profil Tanaman
Meniran adalah tanaman perdu kecil yang tumbuh liar di Indonesia dan telah diakui oleh **BPOM RI** sebagai herbal imunostimulan terstandar. Tanaman ini kerap digunakan dalam produk fitofarmaka Indonesia.

### Kandungan Fitokimia Aktif

| Senyawa | Golongan | Fungsi Utama |
|:--------|:---------|:-------------|
| **Phyllanthin** | Lignan | Imunostimulan |
| **Hypophyllanthin** | Lignan | Hepatoprotektif |
| Quercetin | Flavonoid | Antioksidan, Antiinflamasi |
| Gallic acid | Fenol | Antioksidan |
| Ellagic acid | Polifenol | Antimutagenik |

### Mekanisme Aksi Imunostimulan

**1. Stimulasi Makrofag:**
Phyllanthin meningkatkan kemampuan fagositosis makrofag alveolar hingga **40-60%** dalam studi in-vitro, memperkuat pertahanan paru terhadap infeksi awal.

**2. Aktivasi Sel NK:**
Ekstrak meniran meningkatkan aktivitas sel Natural Killer (NK) melalui peningkatan produksi perforin dan granzyme B.

**3. Keseimbangan Th1/Th2:**
Meniran mempromosikan respons imun Th1 (pro-inflamasi terkontrol) yang optimal untuk eliminasi patogen intraseluler seperti *M. tuberculosis*.

### Dosis Preventif
- **Herba kering:** 3-5 gram/hari (seduhan)
- **Ekstrak standar:** 100-250 mg/hari
- **Produk fitofarmaka:** Sesuai aturan pakai yang tertera

### Referensi Ilmiah
1. Bagalkotkar, G. et al. (2006). "Phytochemicals from Phyllanthus niruri and their pharmacological properties." *J. Pharmacy Pharmacol.*, 58(12), 1559-70.
2. Nworu, C.S. et al. (2017). "Immunomodulatory activities of Phyllanthus species." *J. Ethnopharmacology*, 208, 14-21.
''';

const String _temulawakArticleBody = '''
> **⚠️ Klausul Herbal:** Informasi fitokimia herbal pencegahan ini murni bersifat preventif untuk menunjang imunitas paru, serta **TIDAK BOLEH** diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.
>
> Selalu konsultasikan dengan dokter spesialis paru sebelum mengonsumsi bahan herbal bersamaan dengan regimen obat TBC Anda.

---

## 🌿 Temulawak (Curcuma xanthorrhiza)

### Profil Tanaman
Temulawak adalah tanaman rimpang asli Indonesia yang menjadi ikon jamu tradisional. Berbeda dengan kunyit biasa, temulawak mengandung senyawa unik **xanthorrhizol** yang menunjukkan potensi anti-tuberkulosis spesifik.

### Kandungan Fitokimia Aktif

| Senyawa | Golongan | Fungsi Utama |
|:--------|:---------|:-------------|
| **Xanthorrhizol** | Seskuiterpenoid | Anti-TB spesifik |
| Kurkumin | Polifenol (Kurkuminoid) | Antiinflamasi |
| ar-Curcumene | Seskuiterpen | Antimikroba |
| Germacrone | Seskuiterpen | Antibakteri |

### Mekanisme Aksi Anti-TBC

**1. Aktivitas Anti-Tuberkulosis Langsung:**
Xanthorrhizol menunjukkan MIC **3.13 μg/mL** terhadap *M. tuberculosis* H37Rv dalam studi in-vitro — salah satu nilai MIC terendah di antara senyawa fitokimia alami.

**2. Efek Sinergis dengan OAT:**
Kombinasi xanthorrhizol dengan isoniazid menunjukkan efek sinergis (FICI ≤ 0.5), berpotensi menurunkan dosis OAT yang diperlukan dan mengurangi efek samping.

**3. Hepatoprotektif:**
Melindungi sel hati dari kerusakan akibat terapi OAT jangka panjang, khususnya dari hepatotoksisitas rifampisin.

### Dosis Preventif
- **Rimpang segar:** 2-3 gram/hari
- **Ekstrak standar:** 250-500 mg/hari
- **Jamu tradisional:** Temulawak tanam campuran 1 rimpang/hari

### Referensi Ilmiah
1. Lim, C.S. et al. (2020). "Xanthorrhizol: A review of its pharmacological activities." *Fitoterapia*, 140, 104610.
2. Sukari, M.A. et al. (2016). "Antimycobacterial activity of xanthorrhizol." *Phytochemistry Letters*, 16, 53-58.
''';
