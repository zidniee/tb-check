# 🔴 URGENT DIAGNOSTIC - Output Masih 35% Setelah Rebuild

**Tanggal:** 4 Agustus 2026, 20:38 WIB  
**Status:** CRITICAL - Perlu investigasi logs

---

## 📊 REPORTED SYMPTOMS

**After rebuild:**
- ✅ Inference time: 0.2 detik (200ms) - Normal
- ❌ Probability: 35.0% - STUCK!
- ❌ Different audio → Same result

---

## 🔍 NEXT DIAGNOSTIC STEPS

### Step 1: Capture Logs LENGKAP

Silakan jalankan app dan **capture logs** untuk analisis:

#### Windows CMD:
```cmd
cd D:\Projek\Android\tbcheck
flutter logs > screening_logs.txt
```

#### Atau PowerShell:
```powershell
cd D:\Projek\Android\tbcheck
flutter logs | Tee-Object -FilePath screening_logs.txt
```

**Lalu:**
1. Lakukan screening (record batuk 5 detik)
2. Tunggu sampai result page muncul
3. Stop logs (Ctrl+C)
4. Buka `screening_logs.txt`
5. **Copy bagian yang ada `[TfliteService]`**

### Step 2: Cari Pattern Ini di Logs

**Pattern 1: Model Loading**
```
[TfliteService] TFLite Model loaded successfully.
ATAU
[TfliteService] Running on non-mobile platform. TfliteService loaded in MOCK mode.
```

**Pattern 2: Input Statistics**
```
[TfliteService] Input MFCC statistics: min=..., max=..., mean=...
```

**Pattern 3: Clipping Info**
```
[TfliteService] Clipping X values (Y%) to range ±0.97
```

**Pattern 4: Quantized Sample**
```
[TfliteService] Quantized first frame (first 10 features): [...]
```

**Pattern 5: Inference Result**
```
[TfliteService] Inference complete: rawINT8=..., probability=..., ...
```

---

## 🎯 KEMUNGKINAN PENYEBAB

### Scenario A: Logs Tidak Muncul ❌

**Jika logs `[TfliteService]` TIDAK ADA:**

**Diagnosis:** Fix belum ter-apply / app masih pakai kode lama

**Solution:**
```bash
# Force complete rebuild
cd D:\Projek\Android\tbcheck

# Delete build cache
flutter clean
rm -rf build/
rm -rf .dart_tool/

# Rebuild
flutter pub get
flutter run --no-hot
```

### Scenario B: Logs Muncul Tapi rawINT8 = -38 🔴

**Jika logs menunjukkan:**
```
[TfliteService] Inference complete: rawINT8=-38, probability=0.3516, ...
```

**Diagnosis:** Model MEMANG selalu output INT8=-38

**Possible causes:**
1. **Model trained dengan bug yang sama** (min-max scaling)
2. **Model overfit** ke kelas "Tidak Terkena TBC"
3. **Preprocessing mismatch** antara training vs inference

**Evidence to check:**
- Apakah `rawINT8` SELALU -38 untuk audio berbeda?
- Apakah `Quantized first frame` BERVARIASI antar audio?

**If quantized values vary BUT output always -38:**
→ **MODEL ISSUE** - Model tidak belajar dengan baik

### Scenario C: Mock Mode Active 🟡

**Jika logs menunjukkan:**
```
[TfliteService] Running on non-mobile platform. TfliteService loaded in MOCK mode.
```

**Diagnosis:** App running di Windows/Web, bukan Android device

**Mock mode calculation:**
```dart
// Mock probability calculation (lines 70-80)
final probability = 0.1 + (avg % 0.8);
```

**Check:** Apakah Anda test di Android device atau emulator Windows?

### Scenario D: MFCC Data Bermasalah ⚠️

**Jika logs menunjukkan:**
```
[TfliteService] Input MFCC statistics: min=0.000, max=0.000, mean=0.000
ATAU
[TfliteService] Input MFCC statistics: min=1.234, max=1.234, mean=1.234
```

**Diagnosis:** MFCC extraction tidak bekerja dengan benar

**Possible causes:**
- Native MfccExtractor.kt tidak ter-compile
- Audio file corrupt atau empty
- CMVN normalization tidak applied

---

## 🔬 ADVANCED DIAGNOSTIC

### Test Script untuk Verify Model

Create file: `test/verify_model_output.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbcheck/core/ai/tflite_service.dart';
import 'dart:typed_data';
import 'dart:math' as math;

void main() {
  test('Verify model produces different outputs', () async {
    final tfliteService = TfliteService();
    await tfliteService.loadModel();

    // Test 1: Pattern A (mostly negative)
    final input1 = Float32List(19500);
    for (int i = 0; i < input1.length; i++) {
      input1[i] = -0.5 + (i % 100) * 0.01;
    }
    final result1 = await tfliteService.runInference(input1);
    
    // Test 2: Pattern B (mostly positive)
    final input2 = Float32List(19500);
    for (int i = 0; i < input2.length; i++) {
      input2[i] = 0.5 + (i % 100) * 0.01;
    }
    final result2 = await tfliteService.runInference(input2);
    
    // Test 3: Pattern C (sine wave)
    final input3 = Float32List(19500);
    for (int i = 0; i < input3.length; i++) {
      input3[i] = math.sin(i * 0.01) * 0.6;
    }
    final result3 = await tfliteService.runInference(input3);

    print('Result 1: ${result1.probabilityScore}');
    print('Result 2: ${result2.probabilityScore}');
    print('Result 3: ${result3.probabilityScore}');

    // Calculate variance
    final probs = [
      result1.probabilityScore,
      result2.probabilityScore,
      result3.probabilityScore,
    ];
    final mean = probs.reduce((a, b) => a + b) / 3;
    final variance = probs.map((p) => (p - mean) * (p - mean)).reduce((a, b) => a + b) / 3;
    final std = math.sqrt(variance);

    print('Mean: $mean');
    print('Std: $std');

    // CRITICAL CHECK
    if (std < 0.05) {
      print('⚠️  CRITICAL: Output variance too low!');
      print('   All outputs: ${probs.map((p) => p.toStringAsFixed(4)).join(", ")}');
      print('   Model may be stuck or broken.');
      fail('Model produces nearly identical outputs for different inputs');
    } else {
      print('✅ Output variance OK: $std');
    }

    // Check if all outputs are ~0.35
    if (probs.every((p) => (p - 0.35).abs() < 0.05)) {
      print('⚠️  CRITICAL: All outputs around 0.35!');
      fail('Model stuck at 0.35 output');
    }
  });
}
```

**Run:**
```bash
flutter test test/verify_model_output.dart
```

---

## 📋 CHECKLIST DIAGNOSTIK

Silakan check dan report:

### 1. App Environment
- [ ] Running di: Android device / Emulator / Windows?
- [ ] Flutter version: `flutter --version`
- [ ] Rebuild sudah dilakukan: `flutter clean` + `flutter run`?

### 2. Logs Check
- [ ] Logs `[TfliteService] TFLite Model loaded successfully.` muncul?
- [ ] Logs `[TfliteService] Input MFCC statistics` muncul?
- [ ] Logs `[TfliteService] Clipping X values` muncul?
- [ ] Logs `[TfliteService] Quantized first frame` muncul?
- [ ] Logs `[TfliteService] Inference complete` muncul?

### 3. Data Analysis (from logs)
- [ ] Input MFCC min: ____
- [ ] Input MFCC max: ____
- [ ] Input MFCC mean: ____
- [ ] Clipping percentage: ____%
- [ ] Quantized first 10 values: [___, ___, ___, ...]
- [ ] Raw INT8 output: ____
- [ ] Probability: ____

### 4. Multi-Sample Test
- [ ] Sample 1 (batuk kering): Probability = ____%
- [ ] Sample 2 (batuk basah): Probability = ____%
- [ ] Sample 3 (background noise): Probability = ____%
- [ ] Are all three DIFFERENT? YES / NO

---

## 🎯 KEMUNGKINAN KESIMPULAN

### If Logs Tidak Muncul:
→ **Fix belum ter-apply** → Perlu rebuild yang benar

### If Logs Muncul + rawINT8 Vary + Probability Vary:
→ **✅ FIX BERHASIL!**

### If Logs Muncul + rawINT8 = -38 Always + Probability = 0.35 Always:
→ **🔴 MODEL ISSUE** - Model trained poorly atau preprocessing mismatch

### If Running di Windows/Web (Mock Mode):
→ Test di Android device untuk hasil real

---

## 🚨 IMMEDIATE ACTIONS REQUIRED

**Mohon provide:**

1. **Logs lengkap** (copy paste section dengan `[TfliteService]`)
2. **Environment info:**
   - Running di device apa? (Android / Emulator / Windows)
   - Flutter version
3. **Test results:**
   - 3 screening dengan audio berbeda
   - Masing-masing probability berapa?

Dengan informasi ini, saya bisa diagnose dengan pasti apakah:
- Fix belum ter-apply
- Model memang broken
- Ada issue lain

---

**Created:** 4 Agustus 2026, 20:38 WIB  
**Status:** WAITING FOR LOGS  
**Priority:** CRITICAL
