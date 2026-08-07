# SOFTWARE REQUIREMENTS SPECIFICATION (SRS) - TBCheck (V1.0)

**Nama Dokumen:** Spesifikasi Kebutuhan Perangkat Lunak (SRS) - TBCheck V1.0  
**Tanggal:** 16 Juni 2026  
**Status:** Approved  
**Penulis:** Muhammad Zidni Khoirul Rizqi & Antigravity AI  

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen Spesifikasi Kebutuhan Perangkat Lunak (SRS) ini bertujuan untuk mendefinisikan secara lengkap dan terperinci mengenai kebutuhan fungsional, non-fungsional, antarmuka eksternal, arsitektur deep learning, dan arsitektur database untuk pengembangan aplikasi **TBCheck V1.0 (MVP)**. 

> [!IMPORTANT]
> **Prinsip Utama:** TBCheck murni merupakan aplikasi skrining awal (*screening*) dan penilaian risiko (*risk assessment*), **BUKAN** alat diagnosis medis final. Dokumen ini dirancang khusus untuk memastikan bahwa semua modul teknis dan database mematuhi batasan hukum dan medis tersebut.

### 1.2 Target Audiens
* **Tim Rekayasa Perangkat Lunak (Engineering):** Untuk mengimplementasikan backend, mobile frontend (Flutter), dan konfigurasi database.
* **Tim AI & Data Science:** Untuk mengintegrasikan model TFLite LSTM, algoritma ekstraksi MFCC secara native, dan modul simulasi populasi SVIR.
* **UI/UX Designer:** Untuk memastikan keselarasan desain antarmuka, dark mode, dan alur interaksi pengguna.
* **Quality Assurance (QA):** Sebagai panduan pembuatan *test case*, pengujian otomasi, dan validasi fungsional (BDD Gherkin).
* **Tim Legal & Kepatuhan:** Untuk mengaudit kepatuhan UU Perlindungan Data Pribadi (UU PDP) Republik Indonesia.

### 1.3 Tujuan Penggunaan
Aplikasi TBCheck dirancang sebagai instrumen skrining awal (*screening*) non-invasif penyakit Tuberkulosis (TBC) berbasis suara batuk dan kuesioner medis, yang terintegrasi secara hibrida dengan fitur pencarian dokter paru terdekat (telemedicine) pasca-skrining "Terkena TBC", pemodelan simulasi epidemiologi populasi berbasis SVIR, serta media edukasi pencegahan berbasis fitokimia herbal.

### 1.4 Ruang Lingkup Produk
Sistem TBCheck V1.0 terdiri atas komponen-komponen berikut:
1. **Aplikasi Mobile Pasien (Flutter):** Modul perekaman suara, pengisian kuesioner, modul inferensi AI lokal (100% offline TFLite), peta dokter terdekat, modul chat konsultasi, edukasi herbal, dan modul edukasi terpisah **SVIR Epidemiological Risk Simulator**.
2. **Aplikasi Dashboard Dokter (Flutter):** Panel monitoring grafik pasien (fluktuasi skor AI & kuesioner), riwayat laporan medis, follow-up status, dan panel chat real-time. (Tidak ada pelabelan S/V/I/R pasien secara individual).
3. **Cloud Backend (FastAPI / Go):** Layanan perutean chat (WebSockets), sinkronisasi laporan pasien, kueri database spasial (PostGIS) untuk radius dokter terdekat, kalkulasi statistik agregat regional untuk Community Risk Dashboard, dan otorisasi persetujuan (PDP Consent).
4. **Database & Storage Layer:** Database PostgreSQL dengan ekstensi PostGIS (spasial) dan pgcrypto (UUID & enkripsi kolom).

### 1.5 Definisi dan Akronim
* **mHealth:** *Mobile Health*, pemanfaatan ponsel pintar untuk pelayanan kesehatan.
* **MFCC:** *Mel-Frequency Cepstral Coefficients*, representasi spektral dari karakteristik suara audio.
* **SVIR (Epidemiologi):** *Susceptible-Vaccinated-Infected-Recovered*, model kompartemen epidemiologi matematika tingkat populasi untuk menyimulasikan proyeksi risiko penularan.
* **TFLite:** *TensorFlow Lite*, format model AI teroptimasi untuk eksekusi offline di smartphone.
* **UU PDP:** Undang-Undang Nomor 27 Tahun 2022 tentang Perlindungan Data Pribadi di Indonesia.
* **PostGIS:** Ekstensi database spasial untuk PostgreSQL yang mendukung tipe data geografis dan kueri radius.

---

## 2. Deskripsi Umum

### 2.1 Kebutuhan Pengguna
* **Pengguna Umum (Pasien Mandiri):** Membutuhkan alat skrining awal TBC yang cepat, berbiaya rendah, menjaga privasi data medis (100% pemrosesan lokal), serta memberikan rujukan dokter spesialis paru terdekat secara instan jika hasil skrining "Terkena TBC".
* **Dokter Spesialis Paru (Mitra Faskes):** Membutuhkan dashboard telemonitoring untuk melacak kepatuhan pasien rawat jalan melalui tren kesehatan harian (AI probability & kuesioner), melihat grafik perkembangan klinis, dan memantau status tindak lanjut pasien rujukan.

### 2.2 Asumsi dan Ketergantungan
* **Izin Perangkat (Permissions):** Pengguna memberikan izin akses mikrofon (untuk merekam batuk) dan GPS (untuk pencarian dokter/RS terdekat serta visualisasi peta risiko komunitas).
* **Kondisi Lingkungan:** Perekaman audio batuk dilakukan di lingkungan dengan bising latar belakang yang rendah ($< 60\text{ dB}$).
* **Ketergantungan Internet:** Skrining AI dan pengisian kuesioner bekerja secara 100% offline. Sinkronisasi data ke cloud backend, visualisasi sebaran peta risiko, chat WebSocket, dan pemrosesan peta dokter membutuhkan koneksi internet (Edge/3G/4G/5G).

---

## 3. Fitur dan Persyaratan Sistem

### 3.1 Persyaratan Fungsional

#### 3.1.1 Penomoran dan Deskripsi
Kebutuhan fungsional diidentifikasi dengan kode unik **FR-XXX**.

#### 3.1.2 Format EARS (Easy Approach to Requirements Syntax)
Kebutuhan dituliskan dengan format: **"Ketika [Kejadian/Kondisi], sistem harus [Respons Sistem]"**.

#### 3.1.3 Spesifikasi BDD (Behavior-Driven Development) dengan Gherkin

---

### PERSYARATAN DETIL FUNGSIONAL:

#### FR-001: Perekaman Audio Suara Batuk Terstandar
* **Deskripsi:** Sistem memfasilitasi perekaman audio suara batuk pengguna dengan spesifikasi durasi yang seragam.
* **EARS:** Ketika pengguna menekan tombol rekam pada antarmuka skrining, sistem harus merekam audio melalui mikrofon dengan spesifikasi: **Format WAV, Sample Rate 16 kHz, Channel Mono, Durasi Tepat 5 Detik**.
* **Gherkin (BDD):**
```gherkin
Skenario: Perekaman suara batuk dengan durasi terstandar 5 detik
  Given Pengguna membuka layar skrining kesehatan
  And Pengguna memberikan izin akses mikrofon
  When Pengguna menekan tombol "Mulai Rekam Batuk"
  Then Sistem harus merekam audio selama tepat 5.0 detik
  And Sistem harus mengunci parameter audio pada 16kHz Mono WAV
  And Sistem harus menyimpan rekaman ke direktori cache lokal
```

#### FR-002: Ekstraksi Fitur Audio Native (MFCC)
* **Deskripsi:** Sistem mengekstrak parameter spektral suara batuk secara lokal sebelum inferensi AI.
* **EARS:** Ketika perekaman audio batuk selesai disimpan di cache lokal, sistem harus memicu fungsi pemrosesan native (C++/Kotlin) untuk mengekstrak 13 koefisien MFCC menjadi matriks berdimensi `[500][13]`.
* **Gherkin (BDD):**
```gherkin
Skenario: Ekstraksi fitur audio MFCC di layer native pasca-rekam
  Given File rekaman batuk berformat .wav tersimpan di cache lokal
  When Algoritma native C++ memproses sinyal audio tersebut
  Then Sistem harus menghasilkan matriks berdimensi [500][13] yang berisi 13 dimensi MFCC
  And Sistem harus melempar matriks tersebut ke mesin inferensi TFLite lokal
```

#### FR-003: Pengisian Kuesioner Klinis Mandiri
* **Deskripsi:** Pengguna wajib menjawab kuesioner gejala klinis standar WHO/Kemenkes RI sebagai salah satu input multimodal model AI.
* **EARS:** Ketika pengguna memulai proses skrining baru, sistem harus menampilkan 10 pertanyaan klinis wajib (Ya/Tidak) dan satu input usia numerik, kemudian mengonversinya menjadi representasi biner terenkoding (Ya=1, Tidak=0, usia ternormalisasi min-max), serta mengaktifkan tombol lanjut hanya apabila seluruh 11 item telah diisi.
* **Butir Pertanyaan Kuesioner (WHO/Kemenkes RI):**
  1. Apakah Anda mengalami batuk berdahak ≥ 2 minggu?
  2. Apakah Anda pernah batuk berdarah (*haemoptysis*)?
  3. Apakah Anda mengalami demam berkepanjangan (> 2 minggu) yang tidak diketahui penyebabnya?
  4. Apakah Anda mengalami keringat malam berlebih tanpa aktivitas fisik?
  5. Apakah Anda mengalami penurunan berat badan signifikan tanpa sebab jelas?
  6. Apakah Anda mengalami kelelahan atau lemas berkepanjangan?
  7. Apakah Anda mengalami sesak napas atau nyeri dada?
  8. Apakah Anda pernah didiagnosis atau pernah kontak erat dengan penderita TBC?
  9. Apakah Anda memiliki riwayat imunokompromis (HIV, DM, penggunaan imunosupresan)?
  10. Apakah Anda belum pernah atau tidak lengkap mendapatkan vaksinasi BCG?
* **Gherkin (BDD):**
```gherkin
Skenario: Pengisian kuesioner klinis oleh pasien secara lengkap
  Given Pengguna berada di form kuesioner medis
  When Pengguna mencentang "Ya" pada gejala batuk berdarah
  And Pengguna mencentang "Tidak" pada gejala demam lama
  And Pengguna memasukkan usia "28" tahun
  Then Sistem harus menghasilkan payload clinical_answers JSON terenkoding biner

Skenario: Validasi kuesioner — pengguna mencoba lanjut sebelum semua item terisi
  Given Pengguna berada di form kuesioner medis
  And Pengguna baru mengisi 6 dari 11 item
  When Pengguna menekan tombol "Lanjut ke Perekaman"
  Then Sistem harus menolak perpindahan halaman
  And Sistem harus menandai item yang belum diisi dengan indikator warna merah
  And Sistem harus menampilkan pesan "Harap lengkapi semua pertanyaan sebelum melanjutkan"
```

#### FR-004: Inferensi Klasifikasi Biner Offline (TFLite LSTM)
* **Deskripsi:** Pemrosesan klasifikasi biner TBC menggunakan arsitektur model AI multimodal secara offline.
* **EARS:** Ketika data fitur audio dan kuesioner klinis lengkap, sistem harus menjalankan inferensi model LSTM TFLite secara offline, dan menetapkan kategori skrining (`screening_status`) menjadi `Terkena TBC` jika skor probabilitas model AI multimodal $\ge 0.50$. Jika di bawah threshold, sistem menetapkan status `Tidak Terkena TBC`.
* **Gherkin (BDD):**
```gherkin
Skenario: Klasifikasi prediksi AI menetapkan hasil "Terkena TBC"
  Given Matriks fitur audio dan vektor kuesioner telah diekstrak
  And Model LSTM offline menghasilkan probability_score 0.65
  When Inferensi AI selesai dijalankan di lokal HP
  Then Sistem harus menetapkan screening_status sebagai "Terkena TBC"
  And Sistem harus menampilkan hasil skrining beserta halaman Medical Disclaimer
```

#### FR-005: Persetujuan PDP Consent & Pembagian Data Medis
* **Deskripsi:** Sistem menjaga kepatuhan hukum UU PDP dengan membatasi akses rekam medis.
* **EARS:** Ketika pengguna memilih dokter paru dari daftar rujukan telemedicine, sistem harus menampilkan pop-up persetujuan (*consent*) UU PDP, dan hanya jika pengguna menekan tombol "Setuju", sistem harus mengirimkan data laporan skrining (`tbc_reports`) ke server pusat untuk dibuka aksesnya kepada dokter terkait.
* **Gherkin (BDD):**
```gherkin
Skenario: Pemberian izin akses rekam medis oleh pasien
  Given Pengguna mendapatkan hasil skrining "Terkena TBC"
  And Pengguna memilih dr. Dian Sp.P dari daftar rujukan dokter terdekat
  When Sistem menampilkan pop-up consent UU PDP
  And Pengguna menekan tombol "Setuju"
  Then Sistem harus mengubah status consent_granted menjadi TRUE di database consultations
  And Sistem harus memunculkan ruang chat konsultasi real-time
```

#### FR-006: Pencarian Dokter Terdekat Spasial PostGIS
* **Deskripsi:** Backend melakukan pencarian dokter spesialis berdasarkan radius lokasi geografi terdekat.
* **EARS:** Ketika koordinat GPS pasien dikirimkan ke cloud backend, sistem harus mengeksekusi kueri spasial PostGIS pada tabel `doctors` dan `hospitals` untuk menghasilkan daftar dokter terdekat dalam radius maksimal 50 km terurut berdasarkan jarak terdekat.
* **Gherkin (BDD):**
```gherkin
Skenario: Kueri PostGIS mencari rumah sakit mitra dan dokter spesialis paru terdekat
  Given Pengguna mengizinkan akses GPS di aplikasi
  And Koordinat pengguna berada di (-7.5684, 110.8215)
  When API request dikirim ke backend /doctors/nearby
  Then Server harus melakukan kueri ST_Distance pada koordinat dokter
  And Server harus mengembalikan JSON daftar dokter paru terdekat di bawah radius 50.000 meter
```

#### FR-007: Dashboard Grafik Telemonitoring Dokter (Klinis Saja)
* **Deskripsi:** Dokter memantau perkembangan kesehatan pernapasan pasien secara visual tanpa pelabelan SVIR individu.
* **EARS:** Ketika dokter membuka halaman profil pemantauan pasien di dashboard web/mobile, sistem harus menampilkan grafik AI Probability Trend, Questionnaire Trend (tabel komparatif gejala), riwayat konsultasi, dan follow-up status pasien tanpa menampilkan status S/V/I/R individual.
* **Gherkin (BDD):**
```gherkin
Skenario: Merender grafik pemantauan klinis pasien di dashboard dokter
  Given Dokter berhasil masuk ke dashboard dokter
  When Dokter mengklik nama pasien "Ahmad"
  Then Sistem harus mengambil riwayat laporan klinis dari tabel tbc_reports
  And Sistem harus merender visualisasi grafik AI Probability Trend dan Questionnaire Trend
  And Sistem tidak menampilkan label status SVIR individu pada pasien
```

#### FR-008: Sistem Peringatan Ketidakaktifan 3 Hari
* **Deskripsi:** Sistem mendeteksi jika pasien mengabaikan kewajiban telemonitoring harian.
* **EARS:** Ketika sistem mendeteksi bahwa seorang pasien dalam sesi konsultasi aktif tidak melakukan skrining atau memperbarui laporan klinis selama 3 hari berturut-turut, sistem harus memicu indikator peringatan (*alert*) berwarna merah pada dashboard dokter.
* **Gherkin (BDD):**
```gherkin
Skenario: Sistem memicu alert merah karena pasien tidak update data 3 hari
  Given Sesi konsultasi berstatus "active"
  And Tanggal laporan terakhir pasien adalah 13 Juni 2026
  When Tanggal hari ini menunjukkan 16 Juni 2026 (selisih 3 hari)
  Then Sistem harus memicu indikator peringatan merah pada row konsultasi pasien tersebut di dashboard dokter
```

#### FR-009: SVIR Epidemiological Risk Simulator
* **Deskripsi:** Modul terpisah setelah skrining selesai untuk visualisasi risiko populasi dan simulasi penyebaran penyakit secara edukatif.
* **EARS:** Ketika pengguna membuka menu simulator epidemiologi, sistem harus mengizinkan pengguna menginput parameter laju vaksinasi/kontak sosial dan merender visualisasi proyeksi populasi SVIR serta visualisasi hotspot risiko wilayah (Community Risk Dashboard) menggunakan kepadatan agregat `screening_status` regional.
* **Gherkin (BDD):**
```gherkin
Skenario: Simulasi sebaran epidemiologi SVIR tingkat komunitas
  Given Pengguna membuka peta sebaran risiko epidemiologi (Community Risk Dashboard)
  When Sistem melakukan kueri agregasi spasial PostGIS untuk menghitung rasio 'Terkena TBC' dan 'Tidak Terkena TBC' dalam radius 10km
  Then Sistem harus memproyeksikan visualisasi hotspot wilayah risiko tinggi
  And Sistem tidak mengklasifikasikan pengguna secara individual sebagai S, V, I, atau R
```

#### FR-010: Sinkronisasi Data Laporan Skrining Asinkron (Background Sync)
* **Deskripsi:** Sistem mengunggah laporan hasil skrining (`tbc_reports` dan `screening_status`) yang disimpan secara lokal ke cloud server secara otomatis setelah terhubung ke internet.
* **EARS:** Ketika sistem mendeteksi adanya koneksi internet aktif, sistem harus memicu proses latar belakang (*background worker*) untuk menyinkronkan data laporan skrining yang belum terkirim dari database lokal ke database cloud PostgreSQL.
* **Gherkin (BDD):**
```gherkin
Skenario: Sinkronisasi otomatis data laporan offline ke cloud server
  Given Perangkat menyelesaikan skrining dalam kondisi offline
  And Data skrining tersimpan di database lokal dengan status sinkronisasi "pending"
  When Koneksi internet aktif kembali pada perangkat
  Then Sistem harus memicu background sync worker untuk mengunggah laporan
  And Sistem harus memperbarui status sinkronisasi laporan menjadi "synced" di database lokal
```

---

### PERSYARATAN DETIL FUNGSIONAL — ALUR SKRINING LENGKAP:

> **Konteks Alur:** Bagian ini mendefinisikan alur *end-to-end* fitur skrining mulai dari pemilihan menu hingga percabangan hasil akhir: **Telemedicine** (jika AI memprediksi `Terkena TBC`) atau **Edukasi Fitokimia** (jika AI memprediksi `Tidak Terkena TBC`).
>
> **Catatan Referensi:** FR-011 dan FR-012 adalah persyaratan **baru** yang melengkapi alur ini. Langkah-langkah teknis di dalam alur (kuesioner, perekaman, ekstraksi, inferensi, dan telemedicine) **telah terdefinisi** di FR-001 s/d FR-006 dan **tidak diduplikasi** di sini.

```
[Pengguna Memilih Menu Skrining di Halaman Utama]
         │
         ▼
[FR-011: Onboarding Skrining — Panduan Proses & Disclaimer]
         │
         ▼
[FR-003: Pengisian Kuesioner Klinis Standar WHO/Kemenkes]
         │
         ▼
[FR-001: Perekaman Suara Batuk Terstandar (WAV 16kHz Mono 5 Detik)]
         │
         ▼
[FR-002: Ekstraksi Fitur Audio Native MFCC → Matriks [500][13]]
         │
         ▼
[FR-004: Inferensi AI Klasifikasi Biner Offline (TFLite LSTM)]
         │
    ┌────┴────────┐
   IYA (≥ 0.50)  TIDAK (< 0.50)
    │                  │
    ▼                  ▼
[FR-006 + FR-005:  [FR-012:
Pencarian Dokter   Edukasi Fitokimia
Terdekat &         Herbal Pencegahan]
PDP Consent &
Chat Telemedicine]
```

#### FR-011: Navigasi Masuk Menu Skrining
* **Deskripsi:** Sistem menyediakan titik masuk menu skrining yang jelas di halaman utama dan menampilkan onboarding singkat sebelum alur dimulai.
* **EARS:** Ketika pengguna menekan menu **"Skrining TBC"** pada halaman utama aplikasi, sistem harus menampilkan halaman onboarding skrining yang berisi panduan singkat proses (kuesioner → rekam batuk → hasil AI), informasi disclaimer medis ringkas, dan tombol **"Mulai Skrining"** untuk melanjutkan ke langkah kuesioner.
* **Gherkin (BDD):**
```gherkin
Skenario: Pengguna mengakses menu skrining dari halaman utama
  Given Pengguna berada di halaman utama aplikasi TBCheck
  When Pengguna menekan tombol "Skrining TBC"
  Then Sistem harus menampilkan halaman onboarding skrining
  And Halaman onboarding harus memuat ringkasan 3 langkah proses (Kuesioner, Rekam Batuk, Hasil)
  And Halaman onboarding harus menampilkan klausul disclaimer medis ringkas
  And Halaman onboarding harus menyediakan tombol "Mulai Skrining" untuk lanjut ke kuesioner
```

#### FR-012: Modul Ensiklopedia Fitokimia Herbal Pencegahan TBC
* **Deskripsi:** Ketika hasil skrining AI menetapkan `screening_status = "Tidak Terkena TBC"`, sistem menyediakan modul edukasi berbasis bukti ilmiah berupa Ensiklopedia Fitokimia Herbal sebagai media pencegahan mandiri.
* **EARS:** Ketika pengguna menekan tombol **"Lihat Edukasi Pencegahan Herbal"** pada halaman hasil skrining, sistem harus menampilkan Ensiklopedia Fitokimia Herbal yang memuat daftar tanaman herbal terkurasi dengan detail kandungan fitokimia aktif (nama senyawa, golongan, mekanisme aksi antimikroba/imunomodulator, dan referensi ilmiah), menyediakan fitur pencarian teks berdasarkan nama tanaman atau nama senyawa, serta menyediakan filter berdasarkan golongan senyawa fitokimia (alkaloid, flavonoid, terpenoid, fenol, dll.), dan menampilkan **Klausul Herbal** yang menegaskan bahwa informasi ini bukan pengganti Obat Anti Tuberkulosis (OAT) resmi secara prominan di bagian atas halaman.
* **Gherkin (BDD):**
```gherkin
Skenario: Pengguna diarahkan ke modul Edukasi Fitokimia setelah hasil skrining negatif
  Given Mesin inferensi AI telah menetapkan screening_status sebagai "Tidak Terkena TBC"
  And Pengguna berada di halaman hasil skrining
  When Pengguna menekan tombol "Lihat Edukasi Pencegahan Herbal"
  Then Sistem harus membuka halaman Ensiklopedia Fitokimia Herbal
  And Sistem harus menampilkan Klausul Herbal "Informasi ini bukan pengganti OAT resmi" secara prominan di bagian atas
  And Sistem harus menampilkan daftar tanaman herbal terkurasi

Skenario: Pengguna menelusuri detail tanaman herbal di ensiklopedia
  Given Pengguna berada di halaman Ensiklopedia Fitokimia Herbal
  When Pengguna memilih entri tanaman "Kunyit"
  Then Sistem harus menampilkan nama ilmiah "Curcuma longa"
  And Sistem harus menampilkan senyawa fitokimia aktif "Kurkumin" beserta golongan senyawa "Polifenol"
  And Sistem harus menampilkan deskripsi mekanisme aksi antimikroba kurkumin terhadap Mycobacterium tuberculosis
  And Sistem harus menampilkan minimal 1 referensi ilmiah valid (nama jurnal, tahun, DOI) untuk setiap klaim fitokimia

Skenario: Pengguna mencari tanaman herbal menggunakan fitur pencarian
  Given Pengguna berada di halaman Ensiklopedia Fitokimia Herbal
  When Pengguna mengetikkan "Bawang Putih" pada kolom pencarian
  Then Sistem harus menampilkan hasil pencarian yang mengandung entri "Allium sativum"
  And Sistem harus menampilkan senyawa aktif "Allicin" beserta mekanisme imunomodulatornya

Skenario: Pengguna memfilter tanaman berdasarkan golongan senyawa
  Given Pengguna berada di halaman Ensiklopedia Fitokimia Herbal
  When Pengguna memilih filter golongan senyawa "Flavonoid"
  Then Sistem harus menampilkan hanya tanaman yang mengandung senyawa golongan flavonoid
  And Sistem harus menyembunyikan entri tanaman yang tidak mengandung senyawa golongan flavonoid
```

---

### 3.2 Persyaratan Non-Fungsional

#### 3.2.1 Kinerja (Performance)
* **NF-PERF-001:** Ekstraksi audio native dan inferensi model TFLite di perangkat dengan RAM 3GB harus selesai dalam waktu kurang dari 4 detik ($< 4\text{ s}$).
* **NF-PERF-002:** Latensi kueri spasial PostGIS untuk pencarian dokter terdekat dan kalkulasi agregasi spasial regional harus kurang dari 300 milidetik ($< 300\text{ ms}$) pada beban puncak 1000 request per detik.

#### 3.2.2 Keamanan (Security)
* **NF-SEC-001:** Seluruh lalu lintas data medis wajib terenkripsi menggunakan protokol **TLS 1.3**.
* **NF-SEC-002:** Database lokal di perangkat smartphone wajib terenkripsi menggunakan modul enkripsi **AES-256** (SQLCipher / Hive).
* **NF-SEC-003:** Data rekam medis sensitif (`tbc_reports`) harus dipisahkan secara fisik di tingkat tabel dari data kredensial/identitas utama (`users`).

#### 3.2.3 Kegunaan (Usability), Keandalan (Reliability), Kepatuhan (Compliance)
* **Kepatuhan (NF-COM-001):** Seluruh arsitektur data harus mematuhi **UU Pelindungan Data Pribadi (UU PDP) Indonesia**. Server basis data utama penampung rekam medis wajib berlokasi fisik di dalam wilayah kedaulatan Negara Republik Indonesia.
* **Aksesibilitas (NF-USA-001):** Desain antarmuka aplikasi menerapkan kontras warna minimal 4.5:1, mendukung Dark Mode, dan tipografi font *Plus Jakarta Sans* atau *Poppins*.

---

### 3.3 Persyaratan Antarmuka Eksternal

#### 3.3.1 Persyaratan Keselamatan (Safety Requirements)
* **Disclaimer Medis:** Aplikasi wajib menyertakan halaman *Medical Disclaimer* yang tegas sebelum menyajikan hasil prediksi biner kepada pasien: *"Aplikasi TBCheck murni merupakan instrumen skrining awal preventif, BUKAN keputusan diagnosis medis final. Diagnosis medis resmi hanya diterbitkan oleh dokter paru melalui uji TCM laboratorium."*
* **Klausul Herbal:** Informasi fitokimia herbal pencegahan tidak boleh diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.

#### 3.3.2 Persyaratan Keamanan Antarmuka (Interface Security)
* Autentikasi API backend wajib menggunakan standar token **OAuth2 JWT (JSON Web Token)** dengan masa kedaluwarsa maksimal 15 menit.

---

## 4. AI Architecture & Metrics Specification

### 4.1 AI Architecture Specification
TBCheck menggunakan arsitektur deep learning multimodal yang menggabungkan fitur akustik batuk dan data kuesioner klinis:

```text
  [ Audio Input (5s WAV, 16kHz, Mono) ]       [ Questionnaire Input (11 Features) ]
                 │                                              │
                 ▼                                              ▼
    [ MFCC Feature Vector (500, 13) ]                  [ Dense Layer (16) ]
                 │                                              │
                 ▼                                              ▼
        [ LSTM Layer (64) ]                      [ Questionnaire Embedding (16) ]
                 │                                              │
                 ▼                                              │
       [ Audio Embedding (32) ]                                 │
                 │                                              │
                 └──────────────────────► ◄─────────────────────┘
                                         │
                                         ▼ (Concatenate)
                                 [ Fusion Layer (48) ]
                                         │
                                         ▼
                                [ Dense Layer (16) ]
                                         │
                                         ▼ (Sigmoid)
                            [ Probability Score (0 - 1) ]
```

* **Audio Branch:** 13 koefisien MFCC diekstrak dari rekaman suara batuk berdurasi **tepat 5 detik** (16 kHz, Mono) menghasilkan matriks berdimensi `[500, 13]`. Matriks ini diproses oleh LSTM layer (64 units) menghasilkan Audio Embedding (Dense 32 units).
* **Questionnaire Branch:** 11 data kuesioner (10 checklist + 1 usia ternormalisasi) diproses Dense layer (16 units) menghasilkan Questionnaire Embedding (Dense 16 units).
* **Fusion Layer:** Menggabungkan Audio Embedding (32) dan Questionnaire Embedding (16) melalui Concatenate layer menjadi representasi terpadu (48).
* **Classifier:** Fused vector diproses melalui Dense layer (16 units) dan output layer dengan aktivasi Sigmoid untuk menghasilkan Probability Score (0-1).

### 4.2 Target Performance Metrics
Model dievaluasi menggunakan metrik performa berikut:
* **Recall:** $> 85\%$ (Prioritas utama)
* **Precision:** $> 70\%$
* **F1 Score:** $> 75\%$
* **ROC-AUC:** $> 0.80$

> [!NOTE]
> **Rasionalisasi Prioritas Recall:**  
> TBCheck merupakan aplikasi skrining awal, di mana tujuan utamanya adalah meminimalkan timbulnya *False Negative* (pasien TBC yang terlewat tidak terdeteksi). Model dioptimasi untuk mendeteksi sensitivitas maksimal agar penderita TBC berisiko tinggi mendapatkan penanganan laboratorium (TCM) lebih cepat.

---

## 5. Dataset Requirement & Model Governance

### 5.1 Dataset Requirement
Dataset minimum yang dibutuhkan untuk melatih model sebelum kuantisasi:
* **TB Audio:** $\ge 500$ rekaman audio batuk berlabel TBC positif.
* **Non-TB Audio:** $\ge 500$ rekaman audio batuk berlabel TBC negatif (batuk biasa/sehat).
* **Dataset Split:**
  * **Train Split:** 70%
  * **Validation Split:** 15%
  * **Test Split:** 15%
* **Rekomendasi Sumber Dataset:** Coswara, Respiratory Sound Database, Kaggle TB Cough Dataset.

### 5.2 Model Governance
* **Versioning:** Pelacakan model menggunakan MLflow/Git LFS, dan versi dataset menggunakan DVC (Data Version Control).
* **Retraining Schedule:** Retraining terjadwal setiap **6 bulan sekali** or ketika performa model operasional drop di bawah threshold minimal (Recall $< 85\%$).
* **Performance & Model Drift Monitoring:** Melacak pergeseran data masukan secara berkala untuk menjaga keandalan model menghadapi kebisingan latar belakang dan mic baru smartphone.

---

## 6. MVP Scope (Version 1.0) vs. Version 2.0

### 6.1 Fokus Fitur MVP (Version 1.0)
* **Perekaman Batuk Terstandar:** Perekaman WAV 16kHz Mono 5 Detik.
* **Form Kuesioner Klinis:** Pengisian 10 gejala standar medis + Usia.
* **Ekstraksi MFCC Native:** Konversi ke matriks `[500][13]` secara lokal.
* **Multimodal AI Engine:** Klasifikasi biner strictly 2 parameter (`Terkena TBC`, `Tidak Terkena TBC`) secara offline.
* **Rujukan Dokter (PostGIS):** Pencarian rs/dokter paru terdekat berbasis radius.
* **Basic Telemedicine:** Chat real-time berbasis WebSockets.
* **Edukasi Fitokimia:** Ensiklopedia fitokimia herbal pencegah.
* **SVIR Epidemiological Risk Simulator:** Simulasi visualisasi penyebaran populasi & peta risiko komunitas (Community Risk Dashboard).

### 6.2 Dipindahkan ke Version 2.0 (Out of MVP Scope)
* **Federated Learning:** Pelatihan model kolaboratif lokal smartphone.
* **SMPC (Secure Multiparty Computation):** Protokol enkripsi federated learning.
* **Advanced Epidemiology Dashboard:** Dashboard epidemiologi terintegrasi multi-rumah sakit faskes nasional.
* **Multi-Hospital MLOps:** Orkestrasi MLOps terpusat antar server internal rumah sakit.

---

## 7. Lampiran

### 7.1 Glosarium
1. **BCG Vaccination:** Bacillus Calmette–Guérin, vaksin untuk pencegahan TBC.
2. **Community Risk Dashboard:** Visualisasi spasial kepadatan sebaran risiko masyarakat berdasarkan agregasi data skrining wilayah.

### 7.2 Kasus Penggunaan (Use Case)
* **Kasus Penggunaan 1: Skrening Mandiri & Rujukan (Pasien)**
  * **Alur Utama:** Pengguna mengisi kuesioner -> merekam batuk 5 detik -> sistem melacak probabilitas -> menetapkan screening_status -> menampilkan disclaimer medis -> merekomendasikan dokter paru terdekat.
* **Kasus Penggunaan 2: Simulasi Epidemiologi Populasi (Pasien/Dokter)**
  * **Alur Utama:** Pengguna membuka simulator -> input parameter simulasi (laju vaksinasi/durasi infeksi) -> sistem merender visualisasi sebaran kompartemen populasi secara virtual dan interaktif.
* **Kasus Penggunaan 3: Telemonitoring Pasien (Dokter)**
  * **Alur Utama:** Dokter membuka dashboard -> memilih nama pasien -> sistem merender grafik AI Probability Trend dan Questionnaire Trend pasien tanpa menampilkan label status SVIR individu.
* **Kasus Penggunaan 4: Alur Skrining Lengkap → Edukasi Fitokimia / Telemedicine (Pasien)**
  * **Alur Utama:** Pengguna menekan menu **"Skrining TBC"** → Sistem menampilkan onboarding skrining beserta panduan 3 langkah dan disclaimer ringkas **(FR-011)** → Pengguna mengisi 10 pertanyaan klinis WHO + usia **(FR-003)** → Pengguna menekan "Mulai Rekam Batuk", sistem merekam audio WAV 5 detik **(FR-001)** → Sistem mengekstrak MFCC native secara otomatis **(FR-002)** → Mesin inferensi LSTM TFLite offline menghasilkan prediksi biner **(FR-004)** →
    * **Cabang IYA** (`Terkena TBC`, skor ≥ 0.50): Sistem menampilkan tombol **"Temukan Dokter Terdekat"** → Backend PostGIS mengembalikan daftar dokter paru terdekat ≤ 50 km **(FR-006)** → Pengguna memilih dokter → Sistem meminta persetujuan PDP Consent **(FR-005)** → Sesi chat telemedicine WebSocket aktif.
    * **Cabang TIDAK** (`Tidak Terkena TBC`, skor < 0.50): Sistem menampilkan tombol **"Lihat Edukasi Pencegahan Herbal"** → Pengguna diarahkan ke Ensiklopedia Fitokimia Herbal **(FR-012)** → Pengguna dapat menjelajah tanaman herbal, detail senyawa fitokimia aktif, mekanisme aksi, dan referensi ilmiah pencegahan TBC.
