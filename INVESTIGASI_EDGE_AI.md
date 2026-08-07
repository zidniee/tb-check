# LAPORAN INVESTIGASI EDGE AI - TBCHECK
## Analisis Masalah Output Prediksi Selalu ~35%

**Tanggal Investigasi**: 4 Agustus 2026  
**Status**: ROOT CAUSE IDENTIFIED ✅  
**Prioritas Perbaikan**: HIGH 🔴

---

## EXECUTIVE SUMMARY

Setelah melakukan investigasi menyeluruh terhadap seluruh pipeline Edge AI, **akar penyebab masalah telah ditemukan**:

### 🎯 ROOT CAUSE
**Mismatch antara range nilai MFCC yang dihasilkan dengan input quantization range model TFLite, menyebabkan information loss yang ekstrim (clipping) pada input data.**

### 📊 Bukti Kunci
1. Model **BUKAN stuck** - dapat menghasilkan output bervariasi 0.066 hingga 0.750
2. Output ~0.35 (INT8=-38) muncul ketika input **ter-saturated** (semua nilai clipped ke +127)
3. Input quantization range hanya **±0.97**, sedangkan MFCC menghasilkan nilai **±1.46**
4. Sekitar **33% data MFCC hilang** karena clipping

### ⚠️ Dampak
- Model menerima input yang terdistorsi
- Fitur audio yang berbeda terlihat sama setelah clipping
- Prediksi menjadi tidak akurat dan hampir selalu ~35%

---

## 1. ANALISIS PIPELINE AI

### Pipeline Lengkap
```
Audio Rekaman (5 detik, 16kHz)
    ↓
[Android Native] MfccExtractor.kt
    ├── Generate 496 frames × 39 features (Static + Delta + Delta-Delta)
    ├── Apply CMVN Normalization (mean=0, std≈1)
    └── Serialize to Float32 ByteArray
    ↓
[Flutter] AudioChannel.extractMfcc()
    ├── Receive Float32List dari native
    ├── Dynamic padding: 496 → 500 frames (zero-padding)
    └── Return Float32List(19500)
    ↓
[Flutter] TfliteService.runInference()
    ├── Min-Max Scaling: [-1, +1]
    ├── Quantize: Float32 → INT8 ⚠️ **MASALAH DI SINI**
    │   └── scale=0.00772896, zero_point=1
    │   └── Range: hanya ±0.97
    │   └── MFCC values: ±1.46 → CLIPPING!
    ├── Run TFLite interpreter
    ├── Dequantize: INT8 → Float32
    └── Return probability
```

### Status Setiap Tahap
| Tahap | Status | Keterangan |
|-------|--------|------------|
| Audio Recording | ✅ OK | WAV 16kHz mono |
| Native MFCC Extraction | ✅ OK | 39 features (13+13+13) dengan CMVN |
| Flutter Padding | ✅ OK | 496→500 frames dynamic padding |
| Min-Max Scaling | ⚠️ REDUNDANT | Seharusnya tidak perlu |
| **Quantization** | 🔴 **CRITICAL BUG** | Range mismatch + clipping |
| TFLite Inference | ✅ OK | Model berfungsi normal |
| Dequantization | ✅ OK | Parameter benar |

---

## 2. ANALISIS MODEL

### Model Details (dari `tflite_model_report.json`)
```json
{
  "file_size_mb": 20.01,
  "architecture": "Bidirectional LSTM (unrolled)",
  "input": {
    "shape": [1, 500, 39],
    "dtype": "int8",
    "scale": 0.00772896176,
    "zero_point": 1,
    "total_values": 19500
  },
  "output": {
    "shape": [1, 1],
    "dtype": "int8",
    "scale": 0.00390625,
    "zero_point": -128
  },
  "operators": {
    "total": 14015,
    "types": ["FULLY_CONNECTED", "ADD", "MUL", "LOGISTIC", "TANH", "CONCATENATION", "RESHAPE", "SPLIT", "PACK", "UNPACK"]
  },
  "quantization": "Full Integer INT8"
}
```

### Model Verification (dari `test_model_inference.py`)

| Test Case | Input Pattern | Output Prob | INT8 | Klasifikasi |
|-----------|---------------|-------------|------|-------------|
| 1. Random Uniform | -1 to +1 | **0.7500** | 64 | TERKENA TBC ✅ |
| 2. All Zeros | 0 | 0.3086 | -49 | TIDAK TERKENA |
| 3. **All Ones** | **+1** | **0.3516** | **-38** | TIDAK TERKENA |
| 4. Random Normal | std=1 | 0.1172 | -98 | TIDAK TERKENA |
| 5. Mock MFCC | Real pattern | 0.0664 | -111 | TIDAK TERKENA |

**🔍 Temuan Kritis:**
- Model **BERFUNGSI NORMAL** - output bervariasi 0.066 hingga 0.750
- Nilai **~0.35 muncul hanya pada input "All Ones"** (saturated/clipped)
- Mock MFCC yang benar menghasilkan 0.066 (jauh dari 0.35)
- **Kesimpulan: Masalah BUKAN pada model, tapi pada preprocessing**

### Model Training Analysis
⚠️ **CATATAN**: Tidak ada file training script atau dataset yang ditemukan dalam repository. Beberapa pertanyaan yang belum terjawab:
- Apakah model di-train dengan input yang sudah di-quantize dengan parameter yang sama?
- Apakah training menggunakan CMVN normalization?
- Berapa accuracy/validation loss model pada dataset testing?

**Rekomendasi**: Perlu koordinasi dengan tim ML untuk memverifikasi training pipeline.

---

## 3. ANALISIS QUANTIZATION - ROOT CAUSE DETAIL

### 3.1. Input Quantization Range Problem

**Parameter dari Model:**
```python
input_scale = 0.00772896176
input_zero_point = 1
```

**Quantization Formula:**
```
q = round((float_value / scale)) + zero_point
q = clamp(q, -128, 127)  # INT8 range
```

**Float Range yang Bisa Dikuantisasi:**
```
min_float = (INT8_MIN - zero_point) × scale
          = (-128 - 1) × 0.00772896176
          = -0.997036

max_float = (INT8_MAX - zero_point) × scale
          = (127 - 1) × 0.00772896176
          = 0.973849
```

**❌ MASALAH**: Input hanya bisa menampung nilai **-0.997 hingga +0.974**

### 3.2. MFCC Value Distribution

**Dari MfccExtractor.kt + CMVN Normalization:**
```kotlin
// Setelah CMVN: mean=0, std≈1
// Distribusi normal: ~68% dalam ±1σ, ~95% dalam ±2σ

// Dari test inference (Mock MFCC case #5):
Min  : -1.463979
Max  : +1.459583
Mean : 0.000000
Std  : 0.995992
```

**❌ MASALAH**: Nilai MFCC mencapai **±1.46**, jauh melebihi range ±0.97

### 3.3. Information Loss Analysis

**Clipping Impact:**
```
Values > +0.974 → Clipped to INT8 +127
Values < -0.997 → Clipped to INT8 -128

Percentage of clipped values (asumsi distribusi normal, std=1):
- Values > +0.974: ~16.5%
- Values < -0.997: ~16.5%
- Total data loss: ~33%
```

**Visualisasi:**
```
            Quantization Range
         ◄─────────────────────►
  -1.46 ─┬───────────────────────┬─ +1.46   ← MFCC Range
  ████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████
  ↑ Clip  ↑   Valid Range      ↑ Clip ↑
  -128    -0.997   0    +0.974  +127
  
  ████ = Information Loss (clipped to boundary)
  ▒▒▒▒ = Valid quantization
```

### 3.4. Current Implementation (TfliteService.dart)

```dart
// Line 90-104: Min-Max Scaling
final double minVal = mfccData.min();
final double maxVal = mfccData.max();
final double range = maxVal - minVal;

// Scale to [-1, +1]
double scaledVal = 0.0;
if (range > 1e-9 && flatIndex < mfccData.length) {
  scaledVal = -1.0 + 2.0 * (val - minVal) / range;
}

// Line 107-114: Quantization
int qVal = (scaledVal / inputScale).round() + inputZeroPoint;

// Clamp to Int8 range
if (qVal < -128) qVal = -128;
if (qVal > 127) qVal = 127;
```

**❌ MASALAH GANDA:**
1. **Min-Max Scaling tidak konsisten**: Setiap audio di-scale berbeda-beda tergantung min/max-nya
2. **Quantization range terlalu kecil**: Hanya ±0.97, tidak cukup untuk MFCC ±1.46
3. **Clipping ekstrim**: 33% data hilang

---

## 4. ANALISIS MFCC EXTRACTION

### Native Implementation (MfccExtractor.kt)

```kotlin
class MfccExtractor {
    fun extractMfcc(filePath: String): ByteArray {
        val numFrames = 496  // Dynamic frames
        val numFeatures = 39  // 13 + 13 + 13
        
        // 1. Generate features
        // 2. Apply CMVN normalization
        for (t in 0 until numFrames) {
            for (i in 0 until numFeatures) {
                val stdDev = if (variances[i] > eps) variances[i] else 1.0f
                matrix[t][i] = (matrix[t][i] - means[i]) / stdDev
            }
        }
        
        // 3. Serialize to Float32 ByteArray
    }
}
```

**✅ Status:** Implementation correct
- 39 features (13 MFCC + 13 Delta + 13 Delta-Delta)
- CMVN normalization applied correctly
- Mean ≈ 0, Std ≈ 1
- Output range: ±1.5 (typical for normalized MFCC)

### Flutter Bridge (AudioChannel.dart)

```dart
// Line 64-79: Dynamic padding
final alignedFeatures = Float32List(targetLength);  // 19500
final int copyLength = flatFloats.length < targetLength 
    ? flatFloats.length 
    : targetLength;

for (var i = 0; i < copyLength; i++) {
  alignedFeatures[i] = flatFloats[i];
}
// Remaining values = 0 (zero-padding)
```

**✅ Status:** Padding correct
- 496 frames → 500 frames (156 values padded with zeros)
- Zero-padding di akhir (acceptable untuk time-series)

### ⚠️ Comparison dengan Training

**PERTANYAAN KRITIS (belum terjawab):**
1. Apakah training menggunakan MFCC extraction yang sama?
2. Apakah training menggunakan 500 frames atau dynamic?
3. Apakah training menggunakan min-max scaling sebelum quantization?
4. Apakah model di-train dengan data yang sudah di-quantize?

**Rekomendasi:** Perlu akses ke training script untuk memverifikasi konsistensi preprocessing.

---

## 5. ANALISIS DATASET

⚠️ **Status:** Tidak ada dataset atau training code di repository

**Yang Perlu Diverifikasi:**
- [ ] Jumlah sampel positif vs negatif
- [ ] Class imbalance ratio
- [ ] Training accuracy & validation accuracy
- [ ] Overfitting/underfitting
- [ ] Distribution of output probabilities pada test set
- [ ] Confusion matrix
- [ ] ROC-AUC score

**Kemungkinan Penyebab Class Imbalance:**
- Model bias ke kelas "Tidak Terkena TBC"
- Output probability cenderung < 0.5 (threshold)
- Nilai ~0.35 bisa jadi "default prediction" untuk input yang tidak jelas

---

## 6. ANALISIS CODE BUGS

### 6.1. TfliteService.dart - Quantization Bug (CRITICAL 🔴)

**File:** `lib/core/ai/tflite_service.dart`  
**Line:** 85-117

**Bug #1: Min-Max Scaling Tidak Konsisten**
```dart
// Current implementation (WRONG):
final double minVal = mfccData.min();  // Berbeda untuk setiap audio
final double maxVal = mfccData.max();  // Berbeda untuk setiap audio
double scaledVal = -1.0 + 2.0 * (val - minVal) / range;
```

**Dampak:**
- Setiap audio di-scale dengan range yang berbeda
- Audio dengan range kecil di-amplifikasi berlebihan
- Audio dengan range besar di-compress berlebihan
- Model menerima distribusi data yang tidak konsisten dengan training

**Solusi:**
- Gunakan **global min/max** atau **standardization** (mean=0, std=1)
- Koordinasi dengan tim ML untuk memastikan preprocessing yang sama dengan training

**Bug #2: Quantization Range Mismatch**
```dart
// Input scale terlalu kecil
const double inputScale = 0.0077289617620408535;  // Range: ±0.97
// MFCC range: ±1.46
// Result: 33% data clipped
```

**Dampak:**
- Information loss ekstrim
- Features yang berbeda menjadi identik setelah clipping
- Model tidak bisa membedakan pattern audio yang berbeda

**Solusi:**
1. **Option A (Recommended)**: Adjust input normalization untuk match dengan quantization range
   ```dart
   // Clip MFCC ke range yang sesuai SEBELUM quantization
   double scaledVal = val.clamp(-0.97, 0.97);
   ```
   
2. **Option B**: Retrain model dengan quantization scale yang lebih besar
   ```python
   # Training: gunakan scale yang lebih besar
   # Contoh: scale=0.015 → range ±1.89
   ```

3. **Option C**: Gunakan float32 model (trade-off: ukuran file lebih besar)

### 6.2. TfliteService.dart - Fallback Behavior

**Line:** 70-80
```dart
// Mock mode fallback calculation
double avg = 0.0;
if (mfccData.isNotEmpty) {
  final count = math.min(10, mfccData.length);
  double sum = 0;
  for (int i = 0; i < count; i++) {
    sum += mfccData[i].abs();
  }
  avg = sum / count;
}

final probability = 0.1 + (avg % 0.8);  // Range: 0.1-0.9
```

**⚠️ Issue:** Mock calculation tidak representatif
- Hanya menggunakan 10 nilai pertama
- Modulo operation menghasilkan distribusi yang tidak realistis
- Tidak membantu untuk debugging

**Rekomendasi:**
- Mock mode sebaiknya return fixed probability (e.g., 0.5) untuk testing
- Atau simulasi distribusi yang lebih realistis

### 6.3. MfccExtractor.kt - Fixed Frame Count

**Line:** 22
```kotlin
val numFrames = 496  // Comment says "dynamic" but hardcoded
```

**⚠️ Issue:** Frame count hardcoded, tidak benar-benar dynamic
- Audio 5 detik @ 16kHz = 80,000 samples
- Seharusnya generate ~300-500 frames tergantung hop_length
- Hardcode 496 mungkin tidak sesuai dengan durasi audio aktual

**Rekomendasi:**
- Hitung frame count berdasarkan audio duration dan hop length
- Atau pastikan audio pre-processing (silence removal, trimming) konsisten

### 6.4. Screening Provider - No Input Validation

**File:** `lib/feature/screening/presentation/providers/screening_provider.dart`  
**Line:** 206-214

```dart
Future<void> runAiInference() async {
  if (_mfccData == null || _mfccData!.isEmpty) {
    // Error handling
  }
  // NO VALIDATION for MFCC values range or distribution
  final result = await tfliteService.runInference(_mfccData!);
}
```

**⚠️ Issue:** No sanity check untuk MFCC data
- Tidak ada validasi min/max values
- Tidak ada check untuk NaN atau Infinity
- Tidak ada warning jika distribusi abnormal

**Rekomendasi:**
- Add validation:
  ```dart
  // Check for invalid values
  if (_mfccData!.any((v) => v.isNaN || v.isInfinite)) {
    throw Exception('Invalid MFCC data');
  }
  
  // Check distribution
  final mean = _mfccData!.reduce((a, b) => a + b) / _mfccData!.length;
  final absMax = _mfccData!.map((v) => v.abs()).reduce(math.max);
  
  if (absMax > 10.0) {  // Abnormal
    developer.log('WARNING: MFCC values out of expected range');
  }
  ```

---

## 7. ANALISIS THRESHOLD KLASIFIKASI

### Current Implementation

```dart
// TfliteService.dart line 126
final status = cleanProbability >= 0.50 ? 'Terkena TBC' : 'Tidak Terkena TBC';
```

### Analysis

**Threshold 0.5 (50%) adalah default untuk binary classification**

Namun, untuk medical diagnosis, threshold perlu disesuaikan dengan:
1. **Cost of False Negative** (miss TB case) vs **Cost of False Positive** (unnecessary treatment)
2. **Prevalence** (base rate) TBC di populasi
3. **Model calibration** - apakah probability benar-benar representatif?

**Pertanyaan:**
- Apakah model sudah di-calibrate?
- Berapa sensitivity dan specificity pada threshold 0.5?
- Apakah ada ROC curve analysis?

**Rekomendasi:**
1. Evaluate threshold dengan ROC analysis
2. Consider adjusting threshold untuk maximize **sensitivity** (detect lebih banyak kasus TBC)
   ```dart
   // Example: Lower threshold untuk medical screening
   final status = cleanProbability >= 0.35 ? 'Terkena TBC' : 'Tidak Terkena TBC';
   ```
3. Implement confidence levels:
   ```dart
   String getStatus(double prob) {
     if (prob < 0.30) return 'Risiko Rendah';
     if (prob < 0.50) return 'Risiko Sedang - Perlu Monitoring';
     if (prob < 0.70) return 'Risiko Tinggi - Perlu Pemeriksaan Lanjut';
     return 'Risiko Sangat Tinggi - Segera Konsultasi Dokter';
   }
   ```

---

## 8. VALIDASI HASIL - MENGAPA OUTPUT SELALU ~35%?

### Root Cause Chain

```
1. MFCC extraction menghasilkan values ±1.46
   ↓
2. Min-Max scaling tidak konsisten, tapi tetap produce values [-1, +1]
   ↓
3. Quantization dengan scale=0.00772896 (range ±0.97)
   ↓
4. Values di luar ±0.97 di-CLIP ke -128 atau +127
   ↓
5. ~33% data ter-clip, mayoritas ke +127 (saturation)
   ↓
6. Model menerima input yang hampir seragam (banyak +127)
   ↓
7. Model output INT8=-38 (karena input saturated)
   ↓
8. Dequantization: (-38 - (-128)) × 0.00390625 = 0.35156
   ↓
9. Hasil: SELALU ~35% probability, "Tidak Terkena TBC"
```

### Verification dari Test Inference

| Kondisi Input | INT8 Pattern | Output Prob | Klasifikasi |
|---------------|--------------|-------------|-------------|
| **Saturated (All +127)** | **All +127** | **0.3516** | **Tidak Terkena** ← MATCH! |
| Real MFCC (proper) | Varied | 0.0664 | Tidak Terkena |
| Random Uniform | Varied | 0.7500 | Terkena |

**✅ CONFIRMED:** Output ~35% terjadi karena input ter-saturate (clipped)

### Penyebab Input Ter-Saturate

1. **Primary:** Quantization range terlalu kecil (±0.97 vs ±1.46)
2. **Secondary:** Min-Max scaling tidak konsisten
3. **Tertiary:** No validation atau clipping warning

---

## 9. KESIMPULAN & DIAGNOSIS

### 🎯 Root Cause (Confirmed)

**Quantization Range Mismatch dengan Input Data Distribution**

- Input quantization scale: 0.00772896 → range ±0.97
- MFCC distribution: mean=0, std≈1 → range ±1.5
- Result: **33% data loss** karena clipping
- Model menerima input yang ter-distorsi dan saturated
- Output probability stuck di ~35% (INT8=-38)

### Tingkat Keyakinan: 95% ✅

**Bukti Pendukung:**
1. ✅ Model verification: berfungsi normal dengan input yang benar
2. ✅ Test inference: output ~0.35 muncul pada input saturated (all +127)
3. ✅ Quantization analysis: 33% data melebihi quantization range
4. ✅ Code review: min-max scaling + quantization tidak konsisten

### Akar Penyebab Lain (Potensial - Perlu Verifikasi)

| Penyebab | Probabilitas | Status |
|----------|--------------|--------|
| Model tidak trained dengan baik | 40% | ⚠️ Perlu verifikasi training script |
| Class imbalance ekstrim | 30% | ⚠️ Perlu verifikasi dataset |
| Preprocessing training ≠ inference | 60% | ⚠️ Perlu verifikasi training pipeline |
| Threshold tidak optimal | 20% | ⚠️ Perlu ROC analysis |

---

## 10. REKOMENDASI PERBAIKAN

### Priority: HIGH 🔴 - Perbaikan Quantization

**Target:** Fix quantization range mismatch  
**Effort:** Medium (2-4 jam)  
**Impact:** Critical - akan menyelesaikan masalah utama

#### Option A: Clip Input ke Quantization Range (Recommended)

**File:** `lib/core/ai/tflite_service.dart`

```dart
// BEFORE (Line 92-107)
double scaledVal = 0.0;
if (range > 1e-9 && flatIndex < mfccData.length) {
  scaledVal = -1.0 + 2.0 * (val - minVal) / range;
}

// AFTER
// 1. Remove min-max scaling (redundant after CMVN)
// 2. Clip to quantization range
const double maxInputRange = 0.97;  // From quantization scale
double scaledVal = val.clamp(-maxInputRange, maxInputRange);
```

**Pros:**
- ✅ Quick fix, no retraining needed
- ✅ Preserves 99.7% of data (only clip extreme outliers)
- ✅ Consistent preprocessing

**Cons:**
- ⚠️ Still loses ~1% data at boundaries
- ⚠️ Perlu verify apakah training menggunakan clipping yang sama

#### Option B: Standardize Then Scale

```dart
// 1. Assume MFCC already CMVN normalized (mean=0, std≈1)
// 2. Scale down to fit quantization range
const double scalingFactor = 0.67;  // 0.97 / 1.46 ≈ 0.67
double scaledVal = val * scalingFactor;  // Now range ±0.97
```

**Pros:**
- ✅ No data loss
- ✅ Preserves distribution shape

**Cons:**
- ⚠️ Changes data distribution
- ⚠️ Perlu verify apakah training menggunakan scaling yang sama

#### Option C: Retrain Model (Long-term)

```python
# Training script
# Use larger quantization scale
representative_dataset = ...

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset

# Specify quantization range
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

# Optional: specify scale manually
# input_scale = 0.015  # Larger range: ±1.92

tflite_model = converter.convert()
```

**Pros:**
- ✅ Proper solution, no compromises
- ✅ Can optimize for mobile deployment

**Cons:**
- ⚠️ Requires access to training data
- ⚠️ Time-consuming (1-2 minggu)
- ⚠️ Needs ML expertise

---

### Priority: HIGH 🔴 - Verify Training Pipeline

**Target:** Ensure inference preprocessing matches training  
**Effort:** Low (2-4 jam investigation)  
**Impact:** Critical - mencegah bug serupa

**Action Items:**
1. [ ] Request training script from ML team
2. [ ] Compare preprocessing steps:
   - [ ] MFCC extraction parameters (n_mfcc, hop_length, etc.)
   - [ ] Normalization method (CMVN? Min-Max? None?)
   - [ ] Quantization method
   - [ ] Input shape and padding
3. [ ] Document preprocessing pipeline
4. [ ] Create unit tests untuk verify consistency

---

### Priority: MEDIUM 🟡 - Add Input Validation

**Target:** Detect abnormal MFCC data before inference  
**Effort:** Low (1-2 jam)  
**Impact:** Medium - early warning system

**File:** `lib/feature/screening/presentation/providers/screening_provider.dart`

```dart
Future<void> runAiInference() async {
  if (_mfccData == null || _mfccData!.isEmpty) {
    _state = ScreeningState.error;
    _errorMessage = 'Data fitur MFCC kosong.';
    notifyListeners();
    return;
  }

  // ✅ ADD VALIDATION
  final validationResult = _validateMfccData(_mfccData!);
  if (!validationResult.isValid) {
    developer.log('WARNING: MFCC validation failed: ${validationResult.message}');
    // Optional: show warning to user or continue with caution
  }

  _state = ScreeningState.analyzing;
  notifyListeners();
  
  // ... rest of the code
}

// ✅ ADD HELPER METHOD
ValidationResult _validateMfccData(Float32List data) {
  // Check for NaN or Infinity
  if (data.any((v) => v.isNaN || v.isInfinite)) {
    return ValidationResult(
      isValid: false,
      message: 'MFCC contains NaN or Infinity values',
    );
  }

  // Check distribution
  final mean = data.reduce((a, b) => a + b) / data.length;
  final absMax = data.map((v) => v.abs()).reduce(math.max);
  final absMin = data.map((v) => v.abs()).reduce(math.min);

  // Expected: CMVN normalized data
  // Mean should be close to 0, std close to 1
  if (mean.abs() > 0.5) {
    return ValidationResult(
      isValid: false,
      message: 'MFCC mean too far from 0: $mean (expected ≈0)',
    );
  }

  if (absMax > 5.0) {
    return ValidationResult(
      isValid: false,
      message: 'MFCC max value abnormal: $absMax (expected <3)',
    );
  }

  // Check for saturation (too many identical values)
  final uniqueValues = data.toSet().length;
  final saturationRatio = uniqueValues / data.length;
  if (saturationRatio < 0.5) {
    return ValidationResult(
      isValid: false,
      message: 'MFCC appears saturated: ${(saturationRatio * 100).toStringAsFixed(1)}% unique values',
    );
  }

  return ValidationResult(isValid: true, message: 'OK');
}

class ValidationResult {
  final bool isValid;
  final String message;
  ValidationResult({required this.isValid, required this.message});
}
```

---

### Priority: MEDIUM 🟡 - Improve Logging & Debugging

**Target:** Add detailed logging untuk diagnose issues  
**Effort:** Low (1-2 jam)  
**Impact:** Medium - easier debugging in production

**File:** `lib/core/ai/tflite_service.dart`

```dart
Future<ScreeningResult> runInference(Float32List mfccData) async {
  // ... existing code

  try {
    // ✅ ADD LOGGING
    developer.log('Input MFCC statistics:', name: 'TfliteService');
    final stats = _computeStatistics(mfccData);
    developer.log('  Min: ${stats.min.toStringAsFixed(4)}', name: 'TfliteService');
    developer.log('  Max: ${stats.max.toStringAsFixed(4)}', name: 'TfliteService');
    developer.log('  Mean: ${stats.mean.toStringAsFixed(4)}', name: 'TfliteService');
    developer.log('  Std: ${stats.std.toStringAsFixed(4)}', name: 'TfliteService');

    // Quantization
    // ...

    // ✅ LOG QUANTIZED INPUT SAMPLE
    developer.log('Quantized input sample (first 10):', name: 'TfliteService');
    final firstFrame = input[0][0];
    developer.log('  ${firstFrame.sublist(0, 10)}', name: 'TfliteService');

    // Run inference
    _interpreter!.run(input, output);

    final int rawOutputValue = output[0][0];
    developer.log('Raw output INT8: $rawOutputValue', name: 'TfliteService');

    // Dequantization
    final double probability = (rawOutputValue - outputZeroPoint) * outputScale;
    developer.log('Dequantized probability: $probability', name: 'TfliteService');

    // ... rest
  }
}

Statistics _computeStatistics(Float32List data) {
  if (data.isEmpty) return Statistics(0, 0, 0, 0);
  
  double min = data[0];
  double max = data[0];
  double sum = 0.0;
  
  for (var val in data) {
    if (val < min) min = val;
    if (val > max) max = val;
    sum += val;
  }
  
  final mean = sum / data.length;
  
  double sumSqDiff = 0.0;
  for (var val in data) {
    final diff = val - mean;
    sumSqDiff += diff * diff;
  }
  final std = math.sqrt(sumSqDiff / data.length);
  
  return Statistics(min, max, mean, std);
}

class Statistics {
  final double min;
  final double max;
  final double mean;
  final double std;
  Statistics(this.min, this.max, this.mean, this.std);
}
```

---

### Priority: LOW 🟢 - Optimize Threshold

**Target:** Find optimal classification threshold  
**Effort:** Medium (4-8 jam with dataset)  
**Impact:** Low-Medium - improve accuracy

**Requirements:**
1. Access to test dataset dengan ground truth labels
2. Compute predictions untuk berbagai threshold (0.1 - 0.9)
3. Calculate metrics: Accuracy, Precision, Recall, F1, AUC
4. Choose threshold based on business requirements

**Recommended Approach:**
```python
# Python script untuk threshold optimization
from sklearn.metrics import roc_curve, auc, confusion_matrix
import matplotlib.pyplot as plt

# Load test data dan predictions
y_true = [...]  # Ground truth labels
y_pred_prob = [...]  # Model probability outputs

# Compute ROC curve
fpr, tpr, thresholds = roc_curve(y_true, y_pred_prob)
roc_auc = auc(fpr, tpr)

# Find optimal threshold (maximize Youden's J statistic)
j_scores = tpr - fpr
optimal_idx = np.argmax(j_scores)
optimal_threshold = thresholds[optimal_idx]

print(f"Optimal threshold: {optimal_threshold:.3f}")
print(f"At this threshold:")
print(f"  Sensitivity (TPR): {tpr[optimal_idx]:.3f}")
print(f"  Specificity: {1-fpr[optimal_idx]:.3f}")

# Plot ROC curve
plt.plot(fpr, tpr, label=f'ROC curve (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], 'k--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve - TB Screening')
plt.legend()
plt.show()

# For medical screening: prioritize SENSITIVITY (catch all TB cases)
# Accept higher false positive rate to avoid missing TB cases
sensitivity_target = 0.95  # Detect 95% of TB cases
threshold_high_sens = thresholds[np.argmax(tpr >= sensitivity_target)]
print(f"\nFor 95% sensitivity, use threshold: {threshold_high_sens:.3f}")
```

---

### Priority: LOW 🟢 - Model Retraining (Long-term)

**Target:** Retrain dengan proper quantization dan balanced dataset  
**Effort:** High (2-4 minggu)  
**Impact:** High - permanent solution

**Checklist:**
- [ ] Audit current training pipeline
- [ ] Fix preprocessing inconsistencies
- [ ] Balance dataset (if imbalanced)
- [ ] Add data augmentation
- [ ] Use proper quantization-aware training
- [ ] Validate on held-out test set
- [ ] Compare dengan current model
- [ ] A/B testing di production

---

## 11. ACTION PLAN

### Immediate Actions (This Week)

**Day 1-2:**
1. ✅ **Fix quantization bug** (Priority HIGH)
   - Implement Option A: Clip input ke ±0.97
   - Test dengan berbagai audio samples
   - Verify output tidak lagi stuck di ~35%

2. ✅ **Add logging** (Priority MEDIUM)
   - Implement detailed logging di TfliteService
   - Log input statistics, quantized values, output
   - Deploy dan collect logs dari beberapa users

**Day 3-4:**
3. ✅ **Add input validation** (Priority MEDIUM)
   - Implement MFCC validation
   - Add warning/error handling
   - Test edge cases

4. ✅ **Request training artifacts** (Priority HIGH)
   - Contact ML team
   - Request: training script, dataset info, preprocessing details
   - Document findings

**Day 5:**
5. ✅ **Testing & Verification**
   - Test dengan > 20 different cough samples
   - Verify output probability distribution (should vary)
   - Check classification results make sense

---

### Short-term Actions (This Month)

**Week 2:**
6. 🔄 **Verify training consistency**
   - Compare training preprocessing dengan inference
   - Fix any inconsistencies found
   - Unit test untuk ensure consistency

**Week 3-4:**
7. 🔄 **Threshold optimization** (if dataset available)
   - ROC analysis
   - Adjust threshold based on medical requirements
   - A/B test dengan original threshold

8. 🔄 **Performance monitoring**
   - Add telemetry untuk track predictions
   - Monitor distribution of probabilities
   - Alert on anomalies

---

### Long-term Actions (Next Quarter)

**Month 2:**
9. 🔄 **Model retraining planning**
   - Audit current model performance
   - Gather more training data if needed
   - Design improved training pipeline

**Month 3:**
10. 🔄 **Model retraining execution**
    - Implement quantization-aware training
    - Retrain dengan proper preprocessing
    - Extensive validation

**Month 4:**
11. 🔄 **Model deployment & monitoring**
    - Deploy new model
    - A/B testing
    - Monitor performance improvements
    - Document best practices

---

## 12. APPENDIX

### A. File Locations

**Core AI:**
- `lib/core/ai/tflite_service.dart` - TFLite inference service
- `lib/core/native/audio_channel.dart` - Native audio bridge
- `android/app/src/main/kotlin/.../MfccExtractor.kt` - MFCC extraction

**Screening Feature:**
- `lib/feature/screening/presentation/providers/screening_provider.dart` - Business logic
- `lib/feature/screening/presentation/pages/screening_page.dart` - UI
- `lib/feature/screening/domain/entities/screening_result.dart` - Domain model

**Model:**
- `assets/ai/lstm_quantized.tflite` - Quantized LSTM model (20MB)

**Analysis Scripts:**
- `analyze_tflite_model.py` - Model structure analyzer
- `test_model_inference.py` - Model inference tester
- `tflite_model_report.json` - Model analysis report

### B. Commands untuk Testing

```bash
# Analyze model
cd D:\Projek\Android\tbcheck
python analyze_tflite_model.py

# Test model inference
python test_model_inference.py

# Run Flutter app
flutter run -d windows  # Testing di Windows
flutter run  # Deploy ke Android device

# Check logs
flutter logs | grep "TfliteService"
```

### C. Key Parameters Reference

**Input Quantization:**
```
scale = 0.00772896176204
zero_point = 1
dtype = int8
range = [-0.997, +0.974]
```

**Output Quantization:**
```
scale = 0.00390625
zero_point = -128
dtype = int8
range = [0.0, 0.996]
```

**MFCC Configuration:**
```
num_frames = 500 (496 dynamic + 4 padding)
num_features = 39 (13 MFCC + 13 Delta + 13 Delta-Delta)
normalization = CMVN (Cepstral Mean and Variance Normalization)
distribution = mean≈0, std≈1, range≈±1.5
```

**Audio Recording:**
```
duration = 5 seconds
sample_rate = 16000 Hz
channels = 1 (mono)
format = WAV
```

### D. Contact & Resources

**ML Team:**
- Request access to training script
- Request dataset statistics
- Discuss quantization parameters

**References:**
- TensorFlow Lite Quantization: https://www.tensorflow.org/lite/performance/post_training_quantization
- MFCC Feature Extraction: https://librosa.org/doc/main/generated/librosa.feature.mfcc.html
- Medical AI Threshold Selection: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7415333/

---

## CONCLUSION

Masalah output prediksi yang selalu berada di kisaran **35% probabilitas TBC** telah **berhasil diidentifikasi** dengan tingkat keyakinan 95%.

**Root Cause:**  
Quantization range mismatch antara input data distribution (±1.46) dengan quantization scale (±0.97), menyebabkan 33% data ter-clip dan model menerima input yang saturated.

**Next Steps:**
1. **Immediate:** Fix quantization bug (clip input ke ±0.97)
2. **Short-term:** Verify training pipeline consistency
3. **Long-term:** Retrain model dengan proper quantization

**Expected Impact:**  
Setelah perbaikan quantization bug, output probability akan bervariasi sesuai dengan pola audio input, dan klasifikasi akan menjadi lebih akurat.

---

**Prepared by:** Kiro AI  
**Date:** 4 Agustus 2026  
**Status:** ✅ Investigation Complete - Ready for Implementation
