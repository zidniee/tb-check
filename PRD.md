# PRODUCT REQUIREMENTS DOCUMENT (PRD) - TBCheck

**Document Version:** 1.2.0  
**Date:** June 16, 2026  
**Author:** Muhammad Zidni Khoirul Rizqi & Antigravity AI  
**Document Status:** Approved  

---

## 1. Executive Summary & Glossary

### 1.1 Ringkasan Eksekutif
**TBCheck** adalah sebuah aplikasi kesehatan digital (*mHealth*) berbasis *mobile* yang dirancang sebagai instrumen **skrining awal (screening) dan penilaian risiko (risk assessment) non-invasif**, serta media edukasi preventif penyakit Tuberkulosis (TBC). 

> [!IMPORTANT]
> **Prinsip Utama Sistem:** TBCheck murni merupakan aplikasi skrining awal dan penilaian risiko, **BUKAN** alat diagnosis medis final. Hasil skrining aplikasi ini tidak menggantikan diagnosis klinis formal yang dilakukan oleh dokter paru atau pengujian laboratorium berbasis Tes Cepat Molekuler (TCM).

Nilai unik (*Value Proposition*) TBCheck terletak pada pendekatan **Multimodal Fusion Engine** yang menggabungkan fitur akustik batuk tingkat tinggi (**MFCC**) dari rekaman suara terstandarisasi dan data kuesioner klinis standar WHO/Kemenkes RI. Sistem skrining AI bekerja secara **100% offline (On-Device Inference)** menggunakan model **LSTM** terkuantisasi (TFLite) demi menjaga privasi medis sesuai regulasi UU PDP. 

Setelah proses skrining selesai, pengguna dapat mengakses **SVIR Epidemiological Risk Simulator** sebagai modul edukasi terpisah untuk memvisualisasikan proyeksi risiko penyebaran penyakit di tingkat populasi (komunitas). Pengguna dengan hasil skrining "Terkena TBC" dirujuk secara hibrida ke dokter paru terdekat via telemedicine.

### 1.2 Glosarium (Glossary)

| Istilah / Akronim | Definisi |
| --- | --- |
| **mHealth** | *Mobile Health*, penggunaan perangkat seluler untuk mendukung pelayanan kesehatan. |
| **MFCC** | *Mel-Frequency Cepstral Coefficients*, metode ekstraksi fitur spektral audio suara batuk berdasarkan persepsi pendengaran manusia. |
| **Model SVIR** | Model kompartemen epidemiologi matematika (*Susceptible, Vaccinated, Infected, Recovered*) untuk menyimulasikan dinamika penyebaran penyakit di tingkat populasi. |
| **LSTM** | *Long Short-Term Memory*, arsitektur jaringan saraf recurrent (RNN) yang optimal untuk memproses data sekuensial deret waktu (time-series). |
| **On-Device Inference** | Proses pengeksekusian model AI langsung di dalam prosesor lokal smartphone tanpa mengirim data ke cloud. |
| **TFLite** | *TensorFlow Lite*, format file model AI terkompresi yang dioptimalkan untuk perangkat mobile. |
| **TCM** | Tes Cepat Molekuler, metode diagnosis laboratorium utama TBC berbasis dahak (diagnosis resmi). |
| **UU PDP** | Undang-Undang Perlindungan Data Pribadi di Indonesia. |

---

## 2. Product Vision & User Personas

### 2.1 Visi Produk
* **Visi Jangka Pendek (MVP / Phase 1):** Meluncurkan aplikasi *mobile* TBCheck dengan *core engine* deteksi biner *on-device* (klasifikasi skrining TBC) via fusi fitur MFCC dan kuesioner klinis. MVP menyediakan rujukan dokter spesialis paru terdekat, chat telemedicine dasar, modul edukasi fitokimia, serta **SVIR Epidemiological Risk Simulator** untuk edukasi populasi.
* **Visi Jangka Panjang (Phase 2+):** Membangun otomatisasi **MLOps** terdistribusi yang menghubungkan backend dengan jaringan server internal Rumah Sakit mitra menggunakan teknik **Federated Learning** dan **SMPC** untuk *retraining* model secara aman tanpa melanggar privasi rekam medis.

### 2.2 User Personas
* **Persona 1 (Pasien Mandiri):** Ahmad (28 tahun), karyawan pabrik di Surakarta. Mengalami gejala batuk lama dan takut berobat karena stigma sosial TBC. Membutuhkan alat skrining mandiri yang cepat, gratis, dan privat.
* **Persona 2 (Dokter Spesialis Paru):** dr. Dian, Sp.P (42 tahun). Membutuhkan dashboard telemonitoring untuk memantau tren perkembangan kesehatan harian dan kepatuhan minum obat pasien rawat jalan yang berada di bawah pengawasannya.

---

## 3. Goals & Success Metrics (KPIs)

### 3.1 Sasaran (Goals)
* Menyediakan instrumen skrining awal TBC non-invasif yang akurat, berbiaya rendah, dan menjaga privasi medis secara mutlak.
* Menjembatani pasien berisiko ("Terkena TBC") dengan dokter spesialis paru di wilayah terdekat guna memfasilitasi rujukan laboratorium resmi.
* Mengedukasi masyarakat mengenai dinamika epidemiologi TBC secara interaktif.

### 3.2 Metrik Keberhasilan (Success Metrics)

| Kategori Metrik | Key Performance Indicator (KPI) | Target Keberhasilan |
| --- | --- | --- |
| **Teknis (AI)** | Sensitivitas Klasifikasi AI (Recall) | $> 85\%$ (Prioritas utama untuk menghindari *False Negative*) |
| **Teknis (AI)** | Presisi Klasifikasi AI (Precision) | $> 70\%$ |
| **Teknis (AI)** | Keseimbangan Metrik (F1 Score) | $> 75\%$ |
| **Teknis (AI)** | Kualitas Pembedaan Model (ROC-AUC) | $> 0.80$ |
| **Teknis (Kinerja)** | Latensi Ekstraksi & Inferensi Lokal | $< 4$ detik pada RAM perangkat 3GB |
| **Teknis (Kinerja)** | Kecepatan Kueri Spasial | Latensi kueri pencarian dokter terdekat $< 300$ milidetik |

> [!NOTE]
> **Mengapa Recall Menjadi Prioritas Utama?**  
> Sebagai aplikasi skrining (*screening*), TBCheck memprioritaskan keselamatan pasien dengan meminimalkan angka *False Negative* (pasien TBC yang terlewat tidak terdeteksi). Lebih baik menghasilkan sedikit lebih banyak *False Positive* (yang nantinya akan divalidasi oleh dokter/TCM) daripada meloloskan pasien TBC aktif tanpa rujukan.

---

## 4. Scope & Constraints (Batasan Proyek)

### 4.1 In-Scope (Fitur Masuk MVP - V1.0)
* **Kuesioner Klinis:** Form 10 pertanyaan klinis terenkoding + input usia.
* **Perekaman Suara Batuk:** Perekaman audio terstandarisasi berdurasi **tepat 5 detik**.
* **Ekstraksi MFCC:** Ekstraksi 13 koefisien MFCC di layer native (Kotlin/C++) menghasilkan matriks berdimensi `[500][13]`.
* **Multimodal AI Engine:** Klasifikasi biner strictly 2 parameter: **Terkena TBC** dan **Tidak Terkena TBC / Batuk Biasa** secara offline menggunakan TFLite LSTM.
* **Rujukan Dokter (GPS):** Pencarian dokter/klinik paru terdekat menggunakan koordinat spasial PostGIS.
* **Telemedicine Dasar:** Komunikasi chat real-time berbasis WebSockets pasca-persetujuan PDP consent.
* **Modul Edukasi Fitokimia:** Ensiklopedia video/visual zat herbal penunjang imunitas paru.
* **SVIR Epidemiological Risk Simulator:** Simulasi matematika tingkat populasi untuk proyeksi dan edukasi sebaran penyakit.

### 4.2 Out-of-Scope (Dipindahkan ke V2.0)
* Orkestrasi MLOps terdistribusi menggunakan **Federated Learning** dan **SMPC**.
* Integrasi Payment Gateway komersial (MVP digratiskan/sistem riset).
* Klasifikasi multi-class untuk penentuan stadium TBC (MVP hanya fokus pada skrining biner).
* Dashboard epidemiologi tingkat lanjut terintegrasi jaringan multi-Rumah Sakit (Multi-Hospital MLOps).

---

## 5. Functional Requirements (Persyaratan Fungsional)

### 5.1 Modul Skrening Multimodal
* **Perekaman Audio Standar:** Sistem merekam audio batuk dengan spesifikasi: **WAV, 16 kHz, Mono, Durasi Tepat 5 Detik**.
* **Ekstraksi Native:** Ekstraksi audio menghasilkan matriks `[500][13]` (13 MFCC over 500 timesteps).
* **Klasifikasi AI (Biner):** Hasil klasifikasi biner ditetapkan secara lokal sebagai **Terkena TBC** jika skor probabilitas model AI multimodal $\ge 0.50$. Jika tidak, diklasifikasikan sebagai **Tidak Terkena TBC**.
* **Offline-First & Asynchronous Sync:** Proses skrining, ekstraksi MFCC, inferensi model AI, dan penentuan `screening_status` dilakukan secara 100% offline tanpa membutuhkan koneksi internet. Data laporan skrining disimpan sementara di database lokal perangkat, lalu disinkronkan secara asinkron ke server cloud saat internet terhubung.

### 5.2 Modul Telemedicine & GPS
* **Kueri Spasial:** Backend PostGIS mengurutkan dokter terdekat berdasarkan koordinat GPS profil pasien.
* **PDP Consent Pop-Up:** Aplikasi wajib menampilkan lembar persetujuan eksplisit sebelum membuka riwayat medis skrining pasien kepada dokter paru pilihan.
* **WebSocket Chat:** Obrolan real-time pasca-skrining "Terkena TBC" dengan latensi pengiriman pesan $< 500\text{ ms}$.

### 5.3 Modul Telemonitoring (Dashboard Dokter)
* **AI Probability Trend:** Visualisasi *line chart* fluktuasi skor probabilitas AI harian pasien dari waktu ke waktu.
* **Questionnaire Trend:** Tabel komparatif melacak perubahan ceklis gejala klinis pasien antar tanggal skrining.
* **Consultation History & Follow-up Status:** Rekam obrolan telemedicine dan pelacakan status rujukan laboratorium (TCM).
* **Pengecualian:** Dashboard dokter **TIDAK** menampilkan label status S/V/I/R pasien secara individual karena model tersebut hanya bersifat proyeksi populasi.

### 5.4 SVIR Epidemiological Risk Simulator
* **Konsep Modul:** Modul edukasi terpisah yang diakses setelah skrining selesai.
* **Fungsi:** Menyimulasikan tingkat penularan lokal berdasarkan laju vaksinasi, durasi infeksi, dan rasio kontak sosial menggunakan parameter matematika kompartemen.
* **Dashboard Spasial:** Memvisualisasikan peta proyeksi risiko komunitas (Community Risk Dashboard) menggunakan kepadatan agregat wilayah (rasio status `'Terkena TBC'` vs `'Tidak Terkena TBC'`) untuk membantu visualisasi sebaran paparan wilayah.
* **Flow:**
  `Screening AI ──► Risk Result ──► SVIR Simulator ──► Risk Trend ──► Population Projection ──► Community Risk Dashboard`

---

## 6. AI Architecture Specification

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

---

## 7. Dataset Requirement & Model Governance

### 7.1 Dataset Requirement
Untuk memastikan keandalan model AI sebelum konversi TFLite, dataset audio batuk harus memenuhi kriteria minimal berikut:
* **Audio TBC (Positif):** $\ge 500$ sampel rekaman batuk.
* **Audio Non-TBC (Negatif/Batuk Biasa):** $\ge 500$ sampel rekaman batuk.
* **Data Split:**
  * **Training Set:** 70% dari total dataset.
  * **Validation Set:** 15% dari total dataset.
  * **Test Set:** 15% dari total dataset.
* **Rekomendasi Sumber Dataset:**
  * **Coswara Dataset** (IISc Bangalore)
  * **Respiratory Sound Database** (ICBHI)
  * **Kaggle TB Cough Dataset**

### 7.2 Model Governance
* **Versioning:** Menggunakan *Semantic Versioning* untuk model (misal: v1.0.0 untuk model awal) dan pelacakan dataset (*DVC - Data Version Control*).
* **Retraining Schedule:** Retraining terjadwal setiap **6 bulan sekali** atau ketika metrik performa operasional drop di bawah threshold minimal (Recall $< 85\%$).
* **Monitoring:** Implementasi pemantauan *Model Drift* secara berkala untuk mendeteksi pergeseran karakteristik akustik akibat variabilitas mikrofon baru di pasar smartphone.

---

## 8. System Architecture & Data Requirements

### 8.1 Spesifikasi Skema Data (Data Schema Outline)

| Kategori Data | Format / Tipe | Atribut Utama (Field) | Kebijakan Retensi |
| --- | --- | --- | --- |
| **Data Users** | Relasional (SQL) | `user_id`, `name`, `email`, `password_hash`, `role` (pasien/dokter/admin), `created_at` | Selama akun aktif |
| **Profil Pasien** | Relasional (SQL) | `patient_id`, `user_id` (FK), `gps_location` (Geography), `address`, `screening_status` (Enum: 'Terkena TBC', 'Tidak Terkena TBC'), `is_bcg_vaccinated` | Selama akun aktif |
| **Profil Dokter** | Relasional (SQL) | `doctor_id`, `user_id` (FK), `hospital_id` (FK), `specialization`, `gps_location` (Geography), `is_active` | Selama dokter terikat kemitraan |
| **Data Rumah Sakit** | Relasional (SQL) | `hospital_id`, `name`, `address`, `gps_location` (Geography) | Permanen untuk data master faskes |
| **Tbc_Reports** | JSONB / SQL | `report_id`, `patient_id` (FK), `probability_score` (Float), `prediction_status` (Enum: 'Terkena TBC', 'Tidak Terkena TBC'), `mfcc_mean_vector` (Array), `clinical_answers` (JSONB), `created_at` | Minimal 5 tahun untuk rekam medis |
| **Consultations** | Relasional (SQL) | `consultation_id`, `patient_id` (FK), `doctor_id` (FK), `report_id` (FK), `consent_granted` (Boolean), `consent_timestamp`, `status`, `created_at` | Minimal 5 tahun untuk rekam medis |
| **Chat_Messages** | Relasional (SQL) | `message_id`, `consultation_id` (FK), `sender_id` (FK), `message_text`, `is_read`, `created_at` | 2 tahun setelah konsultasi selesai |
| **Edukasi Fitokimia** | Relasional / JSONB | `herbal_id`, `name`, `source_plant`, `bioactive_benefits`, `consumption_limits`, `video_url`, `image_url`, `scientific_sources` (JSONB) | Permanen |

---

## 9. Legal & Disclaimer

⚠️ **PENTING: Medical Disclaimer**  
Aplikasi TBCheck murni merupakan instrumen skrining awal digital (*screening*) dan penilaian risiko (*risk assessment*) yang bersifat preventif dan edukatif, **BUKAN merupakan alat diagnosis medis final**. Hasil klasifikasi yang dikeluarkan oleh model kecerdasan buatan (AI) di dalam aplikasi ini tidak menggantikan peran penegakan diagnosis sah oleh dokter spesialis paru maupun uji laboratorium resmi berbasis Tes Cepat Molekuler (TCM).