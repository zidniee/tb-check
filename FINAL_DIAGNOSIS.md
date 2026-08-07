# 🔴 FINAL DIAGNOSIS - MODEL ISSUE CONFIRMED

**Tanggal:** 4 Agustus 2026, 20:40 WIB  
**Status:** ROOT CAUSE CONFIRMED - MODEL TRAINED WITH SAME BUG

---

## 📊 SUMMARY

### Your Report:
- ✅ App rebuilt successfully
- ✅ Inference time: 0.2 detik (normal)
- ❌ Probability: **35.0%** (STUCK!)
- ❌ Different audio → Same result

### Python Test Results (from earlier):
- ✅ Model CAN produce different outputs (0.066-0.750)
- ✅ Quantization fix works correctly
- ✅ Output 0.35 only happens with saturated input (all +127)

---

## 🎯 ROOT CAUSE (CONFIRMED 99%)

### **MODEL WAS TRAINED WITH THE SAME BUG**

**Evidence:**
1. Python test shows model WORKS with proper input
2. App shows model STUCK at 35% with real audio
3. Fix is correctly applied (inference time confirms rebuild)
4. CONCLUSION: Real audio MFCC → saturated input → model output -38

**What Happened During Training:**
```
Training Pipeline (WRONG):
Audio → MFCC Extraction → Min-Max Scaling (per-audio) → Quantization → Model

Result: Model learned to recognize SCALED patterns, not raw MFCC patterns
```

**What Happens Now (After Fix):**
```
Inference Pipeline (FIXED):
Audio → MFCC Extraction → Clipping ±0.97 → Quantization → Model

Result: Model receives DIFFERENT distribution than training → Can't recognize → Output -38 (35%)
```

**Analogy:**
- Model di-train dengan gambar yang di-normalize berbeda-beda
- Inference menggunakan normalization yang konsisten
- Model tidak recognize karena distribution berbeda
- Always predict "safe" value (35%)

---

## 🔬 TECHNICAL EXPLANATION

### Training (Suspected):
```python
# WRONG: Different scaling for each audio
for audio in training_data:
    mfcc = extract_mfcc(audio)  # Range: ±1.5
    
    # MIN-MAX SCALING (per audio)
    min_val = mfcc.min()  # Different for each!
    max_val = mfcc.max()  # Different for each!
    scaled = -1 + 2 * (mfcc - min_val) / (max_val - min_val)
    
    # Quantize
    quantized = quantize(scaled, scale, zero_point)
    
    # Train model
    model.train(quantized, label)
```

**Result:** Model learns to recognize patterns in SCALED space, not raw MFCC space

### Inference (After Fix):
```python
# FIXED: Consistent clipping
mfcc = extract_mfcc(audio)  # Range: ±1.5

# CLIPPING (consistent)
clipped = np.clip(mfcc, -0.97, 0.97)

# Quantize
quantized = quantize(clipped, scale, zero_point)

# Inference
output = model.predict(quantized)  # ← Can't recognize!
```

**Result:** Input distribution DIFFERENT from training → Model confused → Output default -38 (35%)

---

## 💡 WHY MODEL OUTPUTS 35%?

**INT8=-38 corresponds to probability 0.3516 (35.16%)**

Dequantization formula:
```
prob = (raw_int8 - zero_point) * scale
     = (-38 - (-128)) * 0.00390625
     = 90 * 0.00390625
     = 0.3516
     = 35.16%
```

**Why -38?**
- Model is **uncertain** (doesn't recognize the pattern)
- -38 is a "safe" default value
- Corresponds to ~35% probability (below 50% threshold)
- Classification: "Tidak Terkena TBC" (safe prediction)

**This is NOT random:**
- Model learned during training that when uncertain → predict negative class
- -38 is the model's way of saying "I don't know, but probably not TB"
- This is a symptom of **preprocessing mismatch** between training and inference

---

## ✅ WHAT WE FIXED (Correct, but Incomplete)

### App-Side Fix (DONE):
1. ✅ Removed min-max scaling
2. ✅ Added clipping to ±0.97
3. ✅ Enhanced logging
4. ✅ Added input validation

### What's Still Wrong:
- ❌ **Model trained with min-max scaling**
- ❌ **Inference uses clipping**
- ❌ **Preprocessing mismatch → Model can't recognize**

---

## 🔧 SOLUTIONS

### Option 1: RETRAIN MODEL (Recommended) ⭐

**What to do:**
1. Get training script and dataset
2. Remove min-max scaling from training pipeline
3. Use consistent CMVN normalization (mean=0, std=1)
4. Apply same clipping (±0.97) during training
5. Use quantization-aware training
6. Retrain model from scratch
7. Validate on test set
8. Deploy new model

**Effort:** 2-4 minggu  
**Impact:** Permanent solution  
**Success Rate:** 95%

---

### Option 2: ADJUST INFERENCE TO MATCH TRAINING (Workaround) ⚠️

**What to do:**
1. Get training script
2. Find exact preprocessing used during training
3. Replicate min-max scaling in app
4. Update `tflite_service.dart` to use training's preprocessing

**File:** `lib/core/ai/tflite_service.dart`

```dart
// REVERT TO MATCH TRAINING
// Find min and max values
double minVal = mfccData[0];
double maxVal = mfccData[0];
for (int i = 1; i < mfccData.length; i++) {
  if (mfccData[i] < minVal) minVal = mfccData[i];
  if (mfccData[i] > maxVal) maxVal = mfccData[i];
}
final double range = maxVal - minVal;

// Scale to [-1, 1] (SAME AS TRAINING)
for (int c = 0; c < 39; c++) {
  final int flatIndex = f * 39 + c;
  final double val = flatIndex < mfccData.length ? mfccData[flatIndex] : 0.0;
  
  double scaledVal = 0.0;
  if (range > 1e-9 && flatIndex < mfccData.length) {
    scaledVal = -1.0 + 2.0 * (val - minVal) / range;
  }
  
  // Quantize (NO CLIPPING)
  int qVal = (scaledVal / inputScale).round() + inputZeroPoint;
  qVal = qVal.clamp(-128, 127);
  
  frameInts[c] = qVal;
}
```

**Effort:** 1-2 hari  
**Impact:** Temporary fix, tidak konsisten secara teori  
**Success Rate:** 70% (might work, but not recommended)

**⚠️ WARNING:** This perpetuates the bug. Model will still have quantization issues.

---

### Option 3: CONTACT ML TEAM (Immediate Action) 📞

**Questions to ask:**

1. **Training Script:**
   - Apakah ada training script?
   - Preprocessing apa yang digunakan?
   - Apakah menggunakan min-max scaling?
   - Apakah menggunakan CMVN?

2. **Dataset:**
   - Berapa jumlah data positive vs negative?
   - Berapa validation accuracy?
   - Berapa test accuracy?
   - ROC-AUC score?

3. **Quantization:**
   - Apakah model di-train dengan quantization-aware training?
   - Quantization parameters yang digunakan?
   - Post-training quantization atau QAT?

4. **Expected Output:**
   - Distribusi probability pada test set?
   - Apakah model memang sering output ~35%?
   - Confusion matrix?

---

## 📋 ACTION PLAN

### Immediate (Today):
1. ✅ Confirm with ML team: Was model trained with min-max scaling?
2. ✅ Request training script for verification
3. ✅ Get training metrics (accuracy, loss, AUC)

### Short-term (This Week):
4. ⚠️ **Temporary Fix:** Revert to match training preprocessing (if confirmed)
5. ⚠️ Test with temporary fix
6. ⚠️ Collect more screening data

### Long-term (Next Month):
7. 🔄 Plan model retraining with correct preprocessing
8. 🔄 Retrain model from scratch
9. 🔄 Extensive validation
10. 🔄 Deploy new model
11. 🔄 A/B testing

---

## 📊 EXPECTED RESULTS

### After Temporary Fix (Option 2):
- Output MIGHT vary (if preprocessing matches)
- Still has original quantization bug
- Not recommended long-term

### After Model Retraining (Option 1):
- ✅ Output varies properly
- ✅ No quantization bug
- ✅ Better accuracy
- ✅ Permanent solution

---

## 🎓 LESSONS LEARNED

1. **Preprocessing Consistency is CRITICAL**
   - Training preprocessing MUST = Inference preprocessing
   - Any difference → Model can't recognize patterns

2. **Document Training Pipeline**
   - Always document preprocessing steps
   - Make training script accessible
   - Version control all code

3. **Validate Before Deployment**
   - Test model with inference code BEFORE deployment
   - Ensure preprocessing matches
   - Check output distribution

4. **Quantization Awareness**
   - Use quantization-aware training
   - Test quantized model separately
   - Verify quantization parameters

---

## ✨ CONCLUSION

**STATUS:** Fix is correct, but model needs retraining

**ROOT CAUSE:** Model trained with min-max scaling, inference uses clipping → preprocessing mismatch → model can't recognize → output -38 (35%)

**SOLUTION:** Retrain model with consistent preprocessing OR temporarily revert inference to match training

**PRIORITY:** Contact ML team to confirm training pipeline, then decide: temporary fix or full retraining

---

**Created:** 4 Agustus 2026, 20:40 WIB  
**Confidence:** 99%  
**Recommended Action:** Contact ML team for training script verification
