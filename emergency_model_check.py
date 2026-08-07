#!/usr/bin/env python3
"""
Emergency Diagnostic: Check if model is stuck at output=-38

This script directly tests if the TFLite model always outputs INT8=-38
regardless of input, which would explain the stuck 35% probability.

Run: python emergency_model_check.py
"""

import sys
from pathlib import Path
import numpy as np

# Try importing TensorFlow
try:
    import tensorflow as tf
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False
    print("[WARNING] TensorFlow not found. Trying tflite-runtime...")

if not TF_AVAILABLE:
    try:
        import tflite_runtime.interpreter as tflite
        TFLITE_RUNTIME = True
    except ImportError:
        print("[ERROR] Neither 'tensorflow' nor 'tflite-runtime' is installed.")
        print("        Install: pip install tensorflow")
        sys.exit(1)

# Model path
MODEL_PATH = Path("assets/ai/lstm_quantized.tflite")

# Quantization parameters
INPUT_SCALE = 0.00772896176
INPUT_ZERO_POINT = 1
OUTPUT_SCALE = 0.00390625
OUTPUT_ZERO_POINT = -128

def quantize_input(float_data, scale, zero_point):
    """Quantize float32 to int8"""
    q = np.round(float_data / scale).astype(np.int32) + zero_point
    q = np.clip(q, -128, 127).astype(np.int8)
    return q

def dequantize_output(q_value, scale, zero_point):
    """Dequantize int8 to float32"""
    return (q_value - zero_point) * scale

def test_model_with_pattern(interpreter, pattern_name, data):
    """Test model with given input pattern"""
    # Clip to ±0.97 (simulating the fix)
    clipped_data = np.clip(data, -0.97, 0.97)
    
    # Quantize
    quantized = quantize_input(clipped_data, INPUT_SCALE, INPUT_ZERO_POINT)
    quantized_reshaped = quantized.reshape(1, 500, 39).astype(np.int8)
    
    # Run inference
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    interpreter.set_tensor(input_details[0]['index'], quantized_reshaped)
    interpreter.invoke()
    
    output = interpreter.get_tensor(output_details[0]['index'])
    raw_int8 = output[0][0]
    
    # Dequantize
    probability = dequantize_output(raw_int8, OUTPUT_SCALE, OUTPUT_ZERO_POINT)
    probability = np.clip(probability, 0.0, 1.0)
    
    return {
        'pattern': pattern_name,
        'raw_int8': int(raw_int8),
        'probability': float(probability),
        'quantized_sample': quantized[:10].tolist(),
        'input_min': float(clipped_data.min()),
        'input_max': float(clipped_data.max()),
        'input_mean': float(clipped_data.mean()),
    }

def main():
    print("="*60)
    print("  EMERGENCY MODEL DIAGNOSTIC")
    print("  Testing if model is stuck at INT8=-38 (probability 0.35)")
    print("="*60)
    
    # Check model exists
    if not MODEL_PATH.exists():
        print(f"\n[ERROR] Model not found: {MODEL_PATH}")
        sys.exit(1)
    
    # Load model
    print(f"\nLoading model: {MODEL_PATH}")
    if TF_AVAILABLE:
        interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
    else:
        interpreter = tflite.Interpreter(model_path=str(MODEL_PATH))
    
    interpreter.allocate_tensors()
    print("[OK] Model loaded")
    
    # Create test patterns
    print("\nGenerating 5 different test patterns...")
    
    patterns = [
        ("Pattern A: Mostly Negative (-0.7)", 
         np.full(19500, -0.7, dtype=np.float32)),
        
        ("Pattern B: Mostly Positive (+0.7)", 
         np.full(19500, 0.7, dtype=np.float32)),
        
        ("Pattern C: Random Uniform [-0.9, +0.9]", 
         np.random.uniform(-0.9, 0.9, 19500).astype(np.float32)),
        
        ("Pattern D: Sine Wave (±0.8)", 
         np.array([np.sin(i * 0.01) * 0.8 for i in range(19500)], dtype=np.float32)),
        
        ("Pattern E: CMVN-like (mean=0, std=1, clipped)", 
         np.clip(np.random.normal(0, 1.0, 19500), -0.97, 0.97).astype(np.float32)),
    ]
    
    # Test each pattern
    results = []
    print("\nRunning inference...\n")
    
    for pattern_name, data in patterns:
        result = test_model_with_pattern(interpreter, pattern_name, data)
        results.append(result)
        
        print(f"[{len(results)}] {pattern_name}")
        print(f"    Input: min={result['input_min']:.3f}, max={result['input_max']:.3f}, mean={result['input_mean']:.3f}")
        print(f"    Quantized sample: {result['quantized_sample']}")
        print(f"    OUTPUT: rawINT8={result['raw_int8']}, probability={result['probability']:.4f}")
        
        if result['probability'] >= 0.5:
            print(f"    → TERKENA TBC")
        else:
            print(f"    → TIDAK TERKENA TBC")
        print()
    
    # Analysis
    print("="*60)
    print("  ANALYSIS")
    print("="*60)
    
    raw_outputs = [r['raw_int8'] for r in results]
    probabilities = [r['probability'] for r in results]
    
    print(f"\nRaw INT8 outputs: {raw_outputs}")
    print(f"Probabilities: {[f'{p:.4f}' for p in probabilities]}")
    print(f"\nProbability range: {min(probabilities):.4f} - {max(probabilities):.4f}")
    print(f"Probability std: {np.std(probabilities):.4f}")
    
    # Check if stuck
    all_same = len(set(raw_outputs)) == 1
    all_near_35 = all(0.30 < p < 0.40 for p in probabilities)
    low_variance = np.std(probabilities) < 0.05
    
    print("\n" + "="*60)
    if all_same and raw_outputs[0] == -38:
        print("  🔴 CRITICAL: MODEL IS STUCK AT INT8=-38")
        print("="*60)
        print("\n  All 5 different inputs produce the SAME output: INT8=-38")
        print("  This corresponds to probability ≈ 0.35 (35%)")
        print("\n  ROOT CAUSE:")
        print("  ❌ Model was trained with the SAME BUG (min-max scaling)")
        print("  ❌ Or model failed to learn properly (overfitting)")
        print("  ❌ Or preprocessing mismatch between training and inference")
        print("\n  SOLUTION REQUIRED:")
        print("  🔧 Model needs to be RETRAINED with:")
        print("     1. Correct preprocessing (no min-max scaling per-audio)")
        print("     2. Proper quantization-aware training")
        print("     3. Consistent CMVN normalization")
        print("     4. Balanced dataset")
        print("\n  The app-side fix is correct, but model is fundamentally broken.")
        
    elif all_near_35:
        print("  🟡 WARNING: MODEL OUTPUTS NEAR 0.35")
        print("="*60)
        print("\n  All outputs are in range 0.30-0.40")
        print("  Model may be biased or poorly trained")
        print("\n  Possible causes:")
        print("  - Class imbalance (dataset mostly 'negative' class)")
        print("  - Model collapse (always predicts safe value)")
        print("  - Training not converged")
        
    elif low_variance:
        print("  🟡 WARNING: LOW OUTPUT VARIANCE")
        print("="*60)
        print("\n  Different inputs produce very similar outputs")
        print(f"  Standard deviation: {np.std(probabilities):.4f} (should be > 0.15)")
        print("\n  Model may not be learning meaningful patterns")
        
    else:
        print("  ✅ MODEL APPEARS TO WORK")
        print("="*60)
        print("\n  Different inputs produce different outputs")
        print("  The stuck-at-35% issue may be due to:")
        print("  - App not properly rebuilt")
        print("  - Real audio MFCC extraction issues")
        print("  - Native code not applied")
    
    print("\n" + "="*60)
    print()

if __name__ == "__main__":
    main()
