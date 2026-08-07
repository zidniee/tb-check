"""
TFLite Model Inference Tester
==============================
Menguji model LSTM quantized TFLite dengan berbagai input test case
untuk mengidentifikasi apakah output ~0.35 disebabkan oleh model itu sendiri
atau masalah pada proses quantization/dequantization.

Model   : assets/ai/lstm_quantized.tflite
Input   : shape [1, 500, 39] — INT8
Output  : shape [1, 1]       — INT8

Quantization params:
  Input  → scale=0.00772896, zero_point=1
  Output → scale=0.00390625, zero_point=-128

Usage:
    pip install tensorflow numpy
    python test_model_inference.py
    
UPDATE 2026-08-04 20:25:
    Added new test case #6 to match the FIX we applied
    Test if clipping to ±0.97 helps or model is just broken
"""

import sys
import io
import math
from pathlib import Path

# Force UTF-8 output on Windows (avoids cp1252 UnicodeEncodeError)
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

import numpy as np

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
try:
    import tensorflow as tf
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False
    print("[WARNING] tensorflow not found. Trying tflite-runtime...")

if not TF_AVAILABLE:
    try:
        import tflite_runtime.interpreter as tflite
        TFLITE_RUNTIME = True
    except ImportError:
        TFLITE_RUNTIME = False
        print("[ERROR] Neither 'tensorflow' nor 'tflite-runtime' is installed.")
        print("        Install with: pip install tensorflow")
        print("        Or lightweight: pip install tflite-runtime")
        sys.exit(1)

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
MODEL_PATH = Path(r"D:\Projek\Android\tbcheck\assets\ai\lstm_quantized.tflite")

# Quantization parameters (from model metadata)
INPUT_SCALE      = 0.00772896176   # from subagent context
INPUT_ZERO_POINT = 1
OUTPUT_SCALE      = 0.00390625     # 1/256
OUTPUT_ZERO_POINT = -128

# Model input dimensions
NUM_TIMESTEPS  = 500
NUM_FEATURES   = 39
TOTAL_ELEMENTS = NUM_TIMESTEPS * NUM_FEATURES  # 19500

CLASSIFICATION_THRESHOLD = 0.5

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

def quantize(float_values: np.ndarray, scale: float, zero_point: int) -> np.ndarray:
    """
    Quantize float32 → int8.
    Formula: q = round(x / scale) + zero_point, clipped to [-128, 127]
    """
    q = np.round(float_values / scale).astype(np.int32) + zero_point
    return np.clip(q, -128, 127).astype(np.int8)


def dequantize(quantized_value: int, scale: float, zero_point: int) -> float:
    """
    Dequantize int8 → float32.
    Formula: x = (q - zero_point) * scale
    """
    return (int(quantized_value) - zero_point) * scale


def run_inference(interpreter, input_float: np.ndarray) -> dict:
    """
    Runs a single inference:
      1. Quantize float input → INT8
      2. Feed to model
      3. Read raw INT8 output
      4. Dequantize output → float probability

    Returns a dict with all intermediate values.
    """
    input_details  = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # ── Quantize input ──────────────────────────────────────────────
    input_q = quantize(input_float, INPUT_SCALE, INPUT_ZERO_POINT)
    model_input = input_q.reshape(1, NUM_TIMESTEPS, NUM_FEATURES)

    # ── Feed input ──────────────────────────────────────────────────
    interpreter.set_tensor(input_details[0]['index'], model_input)
    interpreter.invoke()

    # ── Read output ─────────────────────────────────────────────────
    raw_output = interpreter.get_tensor(output_details[0]['index'])
    raw_q_val  = int(raw_output.flat[0])

    # ── Dequantize output ───────────────────────────────────────────
    probability = dequantize(raw_q_val, OUTPUT_SCALE, OUTPUT_ZERO_POINT)
    # Clip to [0, 1] just in case of numerical overflow
    probability = max(0.0, min(1.0, probability))

    return {
        "input_float":   input_float,
        "input_q":       input_q.flatten(),
        "raw_q_output":  raw_q_val,
        "probability":   probability,
        "classified_tb": probability >= CLASSIFICATION_THRESHOLD,
    }


def print_result(label: str, result: dict, idx: int):
    """Pretty-prints a single test case result."""
    flat_q_in = result["input_q"]
    first10   = flat_q_in[:10].tolist()
    last10    = flat_q_in[-10:].tolist()

    fi = result["input_float"]
    stats = {
        "min":  float(fi.min()),
        "max":  float(fi.max()),
        "mean": float(fi.mean()),
        "std":  float(fi.std()),
    }

    sep = "─" * 60
    print(f"\n{'═' * 60}")
    print(f"  Test Case #{idx}: {label}")
    print(f"{'═' * 60}")

    print(f"\n  [Input Statistics — float32]")
    print(f"    Min  : {stats['min']:>10.6f}")
    print(f"    Max  : {stats['max']:>10.6f}")
    print(f"    Mean : {stats['mean']:>10.6f}")
    print(f"    Std  : {stats['std']:>10.6f}")

    print(f"\n  [Quantized Input — INT8]  (scale={INPUT_SCALE}, zp={INPUT_ZERO_POINT})")
    print(f"    First 10 : {first10}")
    print(f"    Last  10 : {last10}")

    print(f"\n  [Model Output]")
    print(f"    Raw INT8 quantized value  : {result['raw_q_output']}")
    print(f"    Dequantized probability   : {result['probability']:.6f}  "
          f"(zp={OUTPUT_ZERO_POINT}, scale={OUTPUT_SCALE})")
    print(f"    Calculation               : ({result['raw_q_output']} - ({OUTPUT_ZERO_POINT})) × {OUTPUT_SCALE}"
          f" = {result['probability']:.6f}")

    tb_str = "✅ TERKENA TBC" if result["classified_tb"] else "✅ TIDAK TERKENA TBC"
    print(f"\n  [Classification]  threshold={CLASSIFICATION_THRESHOLD}")
    print(f"    → {tb_str}")
    print()


# ---------------------------------------------------------------------------
# Mock MFCC generator — mirrors MfccExtractor.kt logic exactly
# ---------------------------------------------------------------------------

def generate_mock_mfcc_like_kotlin() -> np.ndarray:
    """
    Replicates the MfccExtractor.kt logic in Python.

    Steps (same as Kotlin):
      1. Build (496, 39) matrix with sinusoidal patterns
      2. Apply CMVN normalization (mean subtraction + std normalization)
      3. Pad/crop to (500, 39) to match model input

    The Kotlin code generates 496 frames and Flutter pads to 500.
    """
    num_frames   = 496
    num_features = 39
    matrix       = np.zeros((num_frames, num_features), dtype=np.float32)

    for f in range(num_frames):
        # 1.1 Static MFCC (13 coefficients)
        matrix[f, 0] = 12.0 + 4.0 * math.sin(f * 0.04)   # energy
        for c in range(1, 13):
            matrix[f, c] = 3.0 * math.sin(f * 0.08 + c) / float(c)

        # 1.2 Delta (13 velocity coefficients)
        for c in range(13):
            matrix[f, 13 + c] = 1.5 * math.sin(f * 0.12 + c) / float(c + 1)

        # 1.3 Delta-Delta (13 acceleration coefficients)
        for c in range(13):
            matrix[f, 26 + c] = 0.8 * math.sin(f * 0.16 + c) / float(c + 1)

    # 2. CMVN normalization (same as Kotlin: mean subtraction + std normalization)
    eps = 1e-7
    means = matrix.mean(axis=0)          # shape (39,)
    stds  = matrix.std(axis=0)           # shape (39,)
    # Kotlin: if stdDev > eps use it, else use 1.0
    safe_stds = np.where(stds > eps, stds, 1.0)
    matrix = (matrix - means) / safe_stds

    # 3. Pad from 496 → 500 frames (append 4 zero-rows at the end, as Flutter does)
    padded = np.zeros((NUM_TIMESTEPS, NUM_FEATURES), dtype=np.float32)
    padded[:num_frames, :] = matrix

    return padded.flatten()


# ---------------------------------------------------------------------------
# Build all test cases
# ---------------------------------------------------------------------------

def build_test_cases() -> list:
    rng = np.random.default_rng(seed=42)

    test_cases = [
        {
            "label": "Random Noise (uniform -1..1)",
            "data":  rng.uniform(-1.0, 1.0, TOTAL_ELEMENTS).astype(np.float32),
        },
        {
            "label": "All Zeros",
            "data":  np.zeros(TOTAL_ELEMENTS, dtype=np.float32),
        },
        {
            "label": "All Ones",
            "data":  np.ones(TOTAL_ELEMENTS, dtype=np.float32),
        },
        {
            "label": "Random Normal (mean=0, std=1, clipped to [-1,1])",
            "data":  np.clip(rng.normal(0.0, 1.0, TOTAL_ELEMENTS), -1.0, 1.0).astype(np.float32),
        },
        {
            "label": "Mock MFCC (replicates MfccExtractor.kt + CMVN + padding)",
            "data":  generate_mock_mfcc_like_kotlin(),
        },
        {
            "label": "Mock MFCC CLIPPED to ±0.97 (FIX APPLIED)",
            "data":  np.clip(generate_mock_mfcc_like_kotlin(), -0.97, 0.97),
        },
        {
            "label": "Varied Pattern (sine wave ±0.8)",
            "data":  np.array([np.sin(i * 0.05) * 0.8 for i in range(TOTAL_ELEMENTS)], dtype=np.float32),
        },
    ]

    return test_cases


# ---------------------------------------------------------------------------
# Summary analysis
# ---------------------------------------------------------------------------

def print_summary(results: list):
    print(f"\n{'╔' + '═' * 58 + '╗'}")
    print(f"║{'RINGKASAN HASIL INFERENCE':^58}║")
    print(f"{'╚' + '═' * 58 + '╝'}")

    print(f"\n  {'#':<3}  {'Test Case':<45}  {'Prob':>8}  {'INT8':>6}  {'Result'}")
    print(f"  {'─' * 3}  {'─' * 45}  {'─' * 8}  {'─' * 6}  {'─' * 20}")

    for i, (label, result) in enumerate(results, 1):
        tb_tag = "TERKENA TBC" if result["classified_tb"] else "TIDAK TERKENA TBC"
        print(f"  {i:<3}  {label:<45}  {result['probability']:>8.4f}  "
              f"{result['raw_q_output']:>6}  {tb_tag}")

    probs = [r["probability"] for _, r in results]
    print(f"\n  Probability range: {min(probs):.6f} – {max(probs):.6f}")

    if max(probs) - min(probs) < 0.05:
        print("\n  ⚠️  PERHATIAN: Semua output sangat mirip.")
        print("     Model mungkin memang 'stuck' atau ada masalah quantization.")
        print("     Cek apakah input scale sudah tepat untuk range MFCC Anda.")
    else:
        print("\n  ✅ Output bervariasi — model merespons input yang berbeda.")

    # Quantization range analysis
    print(f"\n  [Analisis Quantization Range Input]")
    print(f"    Input scale      = {INPUT_SCALE}")
    print(f"    Input zero_point = {INPUT_ZERO_POINT}")
    print(f"    Float range yang bisa dikuantisasi ke INT8 [-128..127]:")
    float_min = ((-128 - INPUT_ZERO_POINT) * INPUT_SCALE)
    float_max = ((127  - INPUT_ZERO_POINT) * INPUT_SCALE)
    print(f"      min ≈ {float_min:.6f}")
    print(f"      max ≈ {float_max:.6f}")
    print(f"    Nilai MFCC di luar range ini akan ter-clipping!")

    print(f"\n  [Analisis Output Dequantization]")
    print(f"    Output scale      = {OUTPUT_SCALE}")
    print(f"    Output zero_point = {OUTPUT_ZERO_POINT}")
    print(f"    INT8=-128 → prob = {dequantize(-128, OUTPUT_SCALE, OUTPUT_ZERO_POINT):.6f}")
    print(f"    INT8=-1   → prob = {dequantize(-1,   OUTPUT_SCALE, OUTPUT_ZERO_POINT):.6f}")
    print(f"    INT8=0    → prob = {dequantize(0,    OUTPUT_SCALE, OUTPUT_ZERO_POINT):.6f}")
    print(f"    INT8=127  → prob = {dequantize(127,  OUTPUT_SCALE, OUTPUT_ZERO_POINT):.6f}")
    print(f"    Nilai ~0.35 dalam INT8 ≈ {round(0.35 / OUTPUT_SCALE) + OUTPUT_ZERO_POINT}")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║         TFLite LSTM Model Inference Tester               ║")
    print("║         tbcheck — TB Detection via Cough Audio           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print(f"\n  Model   : {MODEL_PATH}")
    print(f"  Input   : [1, {NUM_TIMESTEPS}, {NUM_FEATURES}]  INT8")
    print(f"  Total   : {TOTAL_ELEMENTS} values")
    print(f"  In  Q   : scale={INPUT_SCALE}, zero_point={INPUT_ZERO_POINT}")
    print(f"  Out Q   : scale={OUTPUT_SCALE}, zero_point={OUTPUT_ZERO_POINT}")

    # ── Load model ──────────────────────────────────────────────────
    if not MODEL_PATH.exists():
        print(f"\n[ERROR] Model tidak ditemukan di: {MODEL_PATH}")
        sys.exit(1)

    print(f"\n  Loading model...", end="", flush=True)

    if TF_AVAILABLE:
        interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
    else:
        interpreter = tflite.Interpreter(model_path=str(MODEL_PATH))

    interpreter.allocate_tensors()
    print(" OK")

    # ── Print model tensor details ───────────────────────────────────
    input_details  = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    print(f"\n  [Model Tensor Details]")
    inp = input_details[0]
    out = output_details[0]
    print(f"    Input  tensor: shape={inp['shape'].tolist()}, dtype={inp['dtype'].__name__}")
    if 'quantization_parameters' in inp:
        qp = inp['quantization_parameters']
        print(f"             model_scale={qp['scales']}, model_zp={qp['zero_points']}")
    print(f"    Output tensor: shape={out['shape'].tolist()}, dtype={out['dtype'].__name__}")
    if 'quantization_parameters' in out:
        qp = out['quantization_parameters']
        print(f"             model_scale={qp['scales']}, model_zp={qp['zero_points']}")

    # ── Build & run test cases ────────────────────────────────────────
    test_cases = build_test_cases()
    all_results = []

    for idx, tc in enumerate(test_cases, 1):
        result = run_inference(interpreter, tc["data"])
        print_result(tc["label"], result, idx)
        all_results.append((tc["label"], result))

    # ── Summary ───────────────────────────────────────────────────────
    print_summary(all_results)


if __name__ == "__main__":
    main()
