# 🔍 DEBUGGING: Output Masih 35%

**Tanggal:** 4 Agustus 2026, 20:23 WIB  
**Issue:** Setelah fix diaplikasikan, output masih menunjukkan ~35%

---

## ❓ POSSIBLE CAUSES

### 1. App Belum Di-Rebuild ⚠️

**Kemungkinan:** Changes belum ter-compile

**Check:**
```bash
cd D:\Projek\Android\tbcheck

# Clean & rebuild
flutter clean
flutter pub get
flutter run

# Pastikan app ter-rebuild complete
```

**Indikator app sudah rebuild:**
- Logs menunjukkan "Input MFCC statistics: ..." 
- Logs menunjukkan "Clipping X values ..."
- Logs menunjukkan "Quantized first frame ..."

---

### 2. Model Di-Train dengan Bug yang Sama 🔴 CRITICAL

**Kemungkinan:** Model di-train dengan min-max scaling yang salah

**Penjelasan:**
- Jika model di-train dengan input yang ter-scale berbeda (min-max per audio)
- Tapi inference menggunakan clipping ke ±0.97
- Hasilnya: distribusi input berbeda → model tidak recognize pattern

**Check:**
- Apakah training script menggunakan min-max scaling?
- Apakah training menggunakan quantization yang sama?
- Apakah MFCC training ter-normalize dengan CMVN?

**Solution:**
- Perlu retrain model dengan preprocessing yang konsisten
- ATAU: Adjust inference preprocessing untuk match training

---

### 3. Model Overfit ke Kelas "Tidak Terkena TBC" 🔴

**Kemungkinan:** Class imbalance ekstrim saat training

**Penjelasan:**
- Jika dataset 99% "Tidak Terkena TBC"
- Model belajar untuk selalu predict ~35% (safe zone)
- Output stuck bukan karena quantization, tapi model memang begitu

**Check:**
- Berapa ratio positive:negative di dataset?
- Apakah ada data augmentation?
- Berapa validation accuracy saat training?

---

### 4. MFCC Extraction Bermasalah ⚠️

**Kemungkinan:** Native MfccExtractor.kt tidak benar

**Check Logs:**
```
[TfliteService] Input MFCC statistics: min=X, max=Y, mean=Z

Expected:
- min: -3 to -0.5
- max: +0.5 to +3
- mean: close to 0 (±0.2)

If all values are constant or very narrow range → MFCC bug
```

**Possible issues:**
- CMVN tidak applied
- All frames identical
- Audio file corrupted

---

### 5. Fallback Mode Active 🟡

**Kemungkinan:** Model tidak load, menggunakan mock mode

**Check Logs:**
```
[TfliteService] Running on non-mobile platform. TfliteService loaded in MOCK mode.
OR
[TfliteService] Failed to load TFLite Model: ...
```

**If mock mode:**
- Mock probability calculation tidak realistis
- Bisa stuck di nilai tertentu

---

## 🔍 DIAGNOSTIC STEPS

### Step 1: Check Logs

```bash
flutter logs | grep "TfliteService"
flutter logs | grep "ScreeningProvider"
```

**Look for:**
1. ✅ Model loading message
2. ✅ Input MFCC statistics
3. ✅ Clipping information
4. ✅ Quantized sample
5. ✅ Raw INT8 output
6. ✅ Probability calculation

### Step 2: Analyze MFCC Stats

**From logs, check:**
```
Input MFCC statistics: min=?, max=?, mean=?
```

**Expected (CMVN normalized):**
- Min: -2.5 to -0.5
- Max: +0.5 to +2.5
- Mean: -0.2 to +0.2

**If suspicious:**
- Min = Max (all same value → bug!)
- Mean far from 0 (not normalized)
- Range too narrow (< 0.5)
- Range too wide (> 5)

### Step 3: Check Quantized Values

**From logs:**
```
Quantized first frame (first 10 features): [?, ?, ?, ...]
```

**Expected:**
- Values vary (not all same)
- Mix of positive and negative
- Range: -120 to +120

**If suspicious:**
- All values same (127 or -128 → saturated!)
- All positive or all negative
- Very narrow range

### Step 4: Check Raw Output

**From logs:**
```
Inference complete: rawINT8=?, probability=?, ...
```

**Expected:**
- rawINT8 varies across different audio
- Not always -38 (which gives 0.35)

**If stuck at -38:**
- Model memang output -38
- Possible causes:
  1. Model trained poorly
  2. Input preprocessing mismatch
  3. Model overfit

---

## 🔧 IMMEDIATE ACTIONS

### Action 1: Get Logs

```bash
cd D:\Projek\Android\tbcheck

# Run app dengan logging
flutter run > app_log.txt 2>&1

# Atau real-time
flutter logs | tee flutter_logs.txt
```

**Record 3 different audio samples:**
1. Batuk kering
2. Batuk basah
3. Silence / background noise

**For each sample, capture:**
- MFCC statistics
- Clipping percentage
- Quantized sample
- Raw INT8 output
- Probability

### Action 2: Verify Fix Applied

**Check if logs contain:**
```
[TfliteService] Input MFCC statistics: ...
[TfliteService] Clipping X values ...
```

**If NOT present:**
- Fix tidak ter-apply
- Perlu rebuild: `flutter clean && flutter pub get && flutter run`

**If present but output still 35%:**
- Fix ter-apply, tapi masalah di tempat lain (model/training)

### Action 3: Test with Mock Data

**Create test in `test/` folder:**
```dart
test('Model with extreme inputs', () async {
  final tfliteService = TfliteService();
  await tfliteService.loadModel();

  // Test 1: All very negative
  final input1 = Float32List(19500);
  for (int i = 0; i < input1.length; i++) {
    input1[i] = -0.9;  // Near min range
  }
  final result1 = await tfliteService.runInference(input1);
  print('All negative: ${result1.probabilityScore}');

  // Test 2: All very positive
  final input2 = Float32List(19500);
  for (int i = 0; i < input2.length; i++) {
    input2[i] = 0.9;  // Near max range
  }
  final result2 = await tfliteService.runInference(input2);
  print('All positive: ${result2.probabilityScore}');

  // If both give ~0.35 → Model issue!
});
```

---

## 🎯 DIAGNOSIS TREE

```
Output = 35%
    ↓
Logs show "Input MFCC statistics"?
    ├─ NO → Fix tidak ter-apply → Rebuild app
    ↓
    YES → Fix ter-apply, check next
    ↓
MFCC stats normal (mean≈0, range ±1.5)?
    ├─ NO → MFCC extraction bug → Check MfccExtractor.kt
    ↓
    YES → MFCC OK, check next
    ↓
Quantized values vary?
    ├─ NO → Still saturating → Adjust maxInputRange
    ↓
    YES → Quantization OK, check next
    ↓
Raw INT8 output varies across samples?
    ├─ NO → Model issue! → Need retrain
    ↓
    YES → Output varies but probability calculation wrong
    ↓
Check dequantization formula
```

---

## 📊 EXPECTED VS ACTUAL

### If Fix Working Correctly:

**Sample 1 (dry cough):**
```
[TfliteService] Input MFCC statistics: min=-1.234, max=1.456, mean=-0.012
[TfliteService] Clipping 234 values (1.2%) to range ±0.97
[TfliteService] Quantized first frame: [12, -45, 67, -89, 34, -21, 56, -78, 90, -12]
[TfliteService] Inference complete: rawINT8=-87, probability=0.1602, time=342ms
```

**Sample 2 (wet cough):**
```
[TfliteService] Input MFCC statistics: min=-1.567, max=1.234, mean=0.023
[TfliteService] Clipping 456 values (2.3%) to range ±0.97
[TfliteService] Quantized first frame: [34, -67, 12, -90, 45, -23, 78, -56, 23, -89]
[TfliteService] Inference complete: rawINT8=52, probability=0.7031, time=356ms
```

**Key differences:**
- ✅ MFCC stats different
- ✅ Quantized values different
- ✅ Raw INT8 different (-87 vs 52)
- ✅ Probability different (0.16 vs 0.70)

### If Model Issue:

**Sample 1:**
```
[TfliteService] Input MFCC statistics: min=-1.234, max=1.456, mean=-0.012
[TfliteService] Clipping 234 values (1.2%) to range ±0.97
[TfliteService] Quantized first frame: [12, -45, 67, -89, 34, -21, 56, -78, 90, -12]
[TfliteService] Inference complete: rawINT8=-38, probability=0.3516, time=342ms
```

**Sample 2:**
```
[TfliteService] Input MFCC statistics: min=-1.567, max=1.234, mean=0.023
[TfliteService] Clipping 456 values (2.3%) to range ±0.97
[TfliteService] Quantized first frame: [34, -67, 12, -90, 45, -23, 78, -56, 23, -89]
[TfliteService] Inference complete: rawINT8=-38, probability=0.3516, time=356ms
```

**Problem:**
- ✅ MFCC stats different
- ✅ Quantized values different
- ❌ Raw INT8 SAME (-38 both times!)
- ❌ Probability SAME (0.35 both times!)

**Diagnosis:** Model selalu output INT8=-38, terlepas dari input → **Model trained poorly atau preprocessing mismatch**

---

## 🚨 NEXT STEPS

1. **Immediate:** Capture logs dari 3 screening berbeda
2. **Share logs** untuk analisis
3. **If model issue confirmed:** Need to contact ML team untuk retrain
4. **Alternative:** Adjust preprocessing untuk match training (perlu training script)

---

**Created:** 4 Agustus 2026, 20:23 WIB  
**Status:** Investigating  
**Priority:** HIGH
