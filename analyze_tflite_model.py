"""
TFLite Model Analyzer
=====================
Analyzes the LSTM quantized TFLite model for tbcheck project.
Model: assets/ai/lstm_quantized.tflite

Requirements:
    pip install tensorflow numpy

Usage:
    python analyze_tflite_model.py
"""

import os
import sys
import json
import struct
import numpy as np
from pathlib import Path

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
try:
    import tensorflow as tf
    TENSORFLOW_AVAILABLE = True
except ImportError:
    TENSORFLOW_AVAILABLE = False

try:
    import flatbuffers
    FLATBUFFERS_AVAILABLE = True
except ImportError:
    FLATBUFFERS_AVAILABLE = False

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
MODEL_PATH = Path(r"D:\Projek\Android\tbcheck\assets\ai\lstm_quantized.tflite")

DTYPE_MAP = {
    0:  "FLOAT32",
    1:  "FLOAT16",
    2:  "INT32",
    3:  "UINT8",
    4:  "INT64",
    5:  "STRING",
    6:  "BOOL",
    7:  "INT16",
    8:  "COMPLEX64",
    9:  "INT8",
    10: "FLOAT64",
    11: "COMPLEX128",
    16: "UINT64",
    17: "RESOURCE",
    18: "VARIANT",
    19: "UINT32",
    20: "UINT16",
}

BUILTIN_OPCODE_MAP = {
    0:  "ADD", 1: "AVERAGE_POOL_2D", 2: "CONCATENATION", 3: "CONV_2D",
    4:  "DEPTHWISE_CONV_2D", 5: "DEPTH_TO_SPACE", 6: "DEQUANTIZE",
    7:  "EMBEDDING_LOOKUP", 8: "FLOOR", 9: "FULLY_CONNECTED",
    10: "HASHTABLE_LOOKUP", 11: "L2_NORMALIZATION", 12: "L2_POOL_2D",
    13: "LOCAL_RESPONSE_NORMALIZATION", 14: "LOGISTIC", 15: "LSH_PROJECTION",
    16: "LSTM", 17: "MAX_POOL_2D", 18: "MUL", 19: "RELU", 20: "RELU_N1_TO_1",
    21: "RELU6", 22: "RESHAPE", 23: "RESIZE_BILINEAR", 24: "RNN",
    25: "SOFTMAX", 26: "SPACE_TO_DEPTH", 27: "SVDF", 28: "TANH",
    29: "CONCAT_EMBEDDINGS", 30: "SKIP_GRAM", 31: "CALL", 32: "CUSTOM",
    33: "EMBEDDING_LOOKUP_SPARSE", 34: "PAD", 35: "UNIDIRECTIONAL_SEQUENCE_RNN",
    36: "GATHER", 37: "BATCH_TO_SPACE_ND", 38: "SPACE_TO_BATCH_ND",
    39: "TRANSPOSE", 40: "MEAN", 41: "SUB", 42: "DIV", 43: "SQUEEZE",
    44: "UNIDIRECTIONAL_SEQUENCE_LSTM", 45: "STRIDED_SLICE", 46: "BIDIRECTIONAL_SEQUENCE_RNN",
    47: "EXP", 48: "TOPK_V2", 49: "SPLIT", 50: "LOG_SOFTMAX",
    51: "DELEGATE", 52: "BIDIRECTIONAL_SEQUENCE_LSTM", 53: "CAST",
    54: "PRELU", 55: "MAXIMUM", 56: "ARG_MAX", 57: "MINIMUM", 58: "LESS",
    59: "NEG", 60: "PADV2", 61: "GREATER", 62: "GREATER_EQUAL",
    63: "LESS_EQUAL", 64: "SELECT", 65: "SLICE", 66: "SIN",
    67: "TRANSPOSE_CONV", 68: "SPARSE_TO_DENSE", 69: "TILE", 70: "EXPAND_DIMS",
    71: "EQUAL", 72: "NOT_EQUAL", 73: "LOG", 74: "SUM", 75: "SQRT",
    76: "RSQRT", 77: "SHAPE", 78: "POW", 79: "ARG_MIN", 80: "FAKE_QUANT",
    81: "REDUCE_PROD", 82: "REDUCE_MAX", 83: "PACK", 84: "LOGICAL_OR",
    85: "ONE_HOT", 86: "LOGICAL_AND", 87: "LOGICAL_NOT", 88: "UNPACK",
    89: "REDUCE_MIN", 90: "FLOOR_DIV", 91: "REDUCE_ANY", 92: "SQUARE",
    93: "ZEROS_LIKE", 94: "FILL", 95: "FLOOR_MOD", 96: "RANGE",
    97: "RESIZE_NEAREST_NEIGHBOR", 98: "LEAKY_RELU", 99: "SQUARED_DIFFERENCE",
    100: "MIRROR_PAD", 101: "ABS", 102: "SPLIT_V", 103: "UNIQUE",
    104: "CEIL", 105: "REVERSE_V2", 106: "ADD_N", 107: "GATHER_ND",
    108: "COS", 109: "WHERE", 110: "RANK", 111: "ELU", 112: "REVERSE_SEQUENCE",
    113: "MATRIX_DIAG", 114: "QUANTIZE", 115: "MATRIX_SET_DIAG",
    116: "ROUND", 117: "HARD_SWISH", 118: "IF", 119: "WHILE",
    120: "NON_MAX_SUPPRESSION_V4", 121: "NON_MAX_SUPPRESSION_V5",
    122: "SCATTER_ND", 123: "SELECT_V2", 124: "DENSIFY", 125: "SEGMENT_SUM",
    126: "BATCH_MATMUL", 127: "PLACEHOLDER_FOR_GREATER_OP_CODES",
    128: "CUMSUM", 129: "CALL_ONCE", 130: "BROADCAST_TO",
    131: "RFFT2D", 132: "CONV_3D", 133: "IMAG", 134: "REAL",
    135: "COMPLEX_ABS", 136: "HASHTABLE", 137: "HASHTABLE_FIND",
    138: "HASHTABLE_IMPORT", 139: "HASHTABLE_SIZE", 140: "REDUCE_ALL",
    141: "CONV_3D_TRANSPOSE", 142: "VAR_HANDLE", 143: "READ_VARIABLE",
    144: "ASSIGN_VARIABLE", 145: "BROADCAST_ARGS", 146: "RANDOM_STANDARD_NORMAL",
    147: "BUCKETIZE", 148: "RANDOM_UNIFORM", 149: "MULTINOMIAL",
    150: "GELU", 151: "DYNAMIC_UPDATE_SLICE", 152: "RELU_0_TO_1",
    153: "UNSORTED_SEGMENT_PROD", 154: "UNSORTED_SEGMENT_MAX",
    155: "UNSORTED_SEGMENT_SUM", 156: "ATAN2", 157: "UNSORTED_SEGMENT_MIN",
    158: "SIGN",
}


# ---------------------------------------------------------------------------
# Print helpers
# ---------------------------------------------------------------------------

SEP = "=" * 70
SEP2 = "-" * 70

def section(title: str):
    print(f"\n{SEP}")
    print(f"  {title}")
    print(SEP)

def subsection(title: str):
    print(f"\n{SEP2}")
    print(f"  {title}")
    print(SEP2)

def kv(key: str, value, indent: int = 2):
    pad = " " * indent
    print(f"{pad}{key:<35} {value}")

# ---------------------------------------------------------------------------
# Quantization helpers
# ---------------------------------------------------------------------------

def describe_quantization(q: dict) -> str:
    """Return a human-readable description of a quantization parameter dict."""
    if not q:
        return "None"
    scale = q.get("scales", q.get("scale", []))
    zp    = q.get("zero_points", q.get("zero_point", []))
    if hasattr(scale, "__len__") and len(scale) == 0:
        return "None (float tensor)"
    if hasattr(scale, "__len__") and len(scale) == 1:
        return f"scale={scale[0]:.8f}, zero_point={zp[0] if hasattr(zp,'__len__') else zp}"
    if hasattr(scale, "__len__") and len(scale) > 1:
        return (f"per-channel ({len(scale)} channels), "
                f"scale min={min(scale):.8f}, max={max(scale):.8f}, "
                f"zp min={min(zp)}, max={max(zp)}")
    return str(q)

def infer_quantization_scheme(inputs: list, outputs: list) -> str:
    """Infer quantization scheme from tensor dtypes."""
    all_tensors = inputs + outputs
    dtypes = set(t.get("dtype_name", "") for t in all_tensors)
    if "INT8" in dtypes:
        return "Full Integer Quantization (INT8)"
    if "UINT8" in dtypes:
        return "Full Integer Quantization (UINT8)"
    if "FLOAT16" in dtypes:
        return "Float16 Quantization"
    if dtypes == {"FLOAT32"}:
        return "No quantization (FLOAT32 tensors)"
    return f"Mixed / Unknown ({', '.join(sorted(dtypes))})"

# ---------------------------------------------------------------------------
# Core analysis using TFLite Interpreter
# ---------------------------------------------------------------------------

def analyze_with_interpreter(model_path: Path) -> dict:
    """Load the model via the TFLite interpreter and extract tensor metadata."""
    print(f"\n[INFO] Loading model: {model_path}")
    print(f"[INFO] File size: {model_path.stat().st_size / 1_048_576:.2f} MB")

    interpreter = tf.lite.Interpreter(model_path=str(model_path))
    interpreter.allocate_tensors()

    input_details  = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    tensor_details = interpreter.get_tensor_details()

    results = {
        "inputs":  input_details,
        "outputs": output_details,
        "all_tensors": tensor_details,
    }
    return results, interpreter


def print_tensor_info(details: list, label: str):
    """Pretty-print a list of input or output tensor detail dicts."""
    section(f"{label} Tensor Details")
    for i, t in enumerate(details):
        subsection(f"{label} [{i}]  —  '{t.get('name', 'unknown')}'")
        kv("Index",        t.get("index"))
        kv("Name",         t.get("name"))
        kv("Shape",        t.get("shape").tolist() if hasattr(t.get("shape"), "tolist") else t.get("shape"))
        kv("Shape (dynamic)", t.get("shape_signature").tolist()
                               if hasattr(t.get("shape_signature"), "tolist")
                               else t.get("shape_signature", "N/A"))
        dtype_val = t.get("dtype")
        dtype_name = dtype_val.__name__ if hasattr(dtype_val, "__name__") else str(dtype_val)
        kv("dtype",        dtype_name)

        q = t.get("quantization_parameters", {})
        kv("Quantization", describe_quantization(q))
        if q:
            scales = q.get("scales", [])
            zps    = q.get("zero_points", [])
            quant_dim = q.get("quantized_dimension", "N/A")
            if hasattr(scales, "__len__") and len(scales) > 0:
                kv("  scales",              list(scales[:5]) if len(scales) > 5 else list(scales))
                kv("  zero_points",         list(zps[:5])    if len(zps)    > 5 else list(zps))
                kv("  quantized_dimension", quant_dim)


def print_all_tensors(tensor_details: list):
    """Print a summary table of all tensors in the model."""
    section("All Tensors Summary")
    header = f"  {'Idx':>4}  {'Name':<45}  {'Shape':<25}  {'dtype':<10}  {'Quantized'}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for t in tensor_details:
        idx   = t.get("index", "?")
        name  = (t.get("name") or "")[:44]
        shape = t.get("shape")
        shape_str = str(shape.tolist() if hasattr(shape, "tolist") else shape)[:24]
        dtype_val  = t.get("dtype")
        dtype_name = (dtype_val.__name__ if hasattr(dtype_val, "__name__") else str(dtype_val))[:9]
        q = t.get("quantization_parameters", {})
        scales = q.get("scales", []) if q else []
        is_q = "Yes" if (hasattr(scales, "__len__") and len(scales) > 0) else "No"
        print(f"  {idx:>4}  {name:<45}  {shape_str:<25}  {dtype_name:<10}  {is_q}")


# ---------------------------------------------------------------------------
# Flatbuffer raw parsing (operator / layer info without flatbuffers library)
# ---------------------------------------------------------------------------

# TFLite flatbuffer schema offsets (little-endian)
# We do a best-effort parse; for a full parse use the tflite schema.

def read_uint32_le(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]

def read_int32_le(data: bytes, offset: int) -> int:
    return struct.unpack_from("<i", data, offset)[0]

def follow_offset(data: bytes, pos: int) -> int:
    """Follow a flatbuffer relative offset from position `pos`."""
    rel = read_int32_le(data, pos)
    if rel == 0:
        return 0
    return pos + rel

def read_string_from_fb(data: bytes, offset: int) -> str:
    """Read a flatbuffer string (4-byte length prefix + utf-8 bytes)."""
    try:
        length = read_uint32_le(data, offset)
        return data[offset + 4: offset + 4 + length].decode("utf-8", errors="replace")
    except Exception:
        return "<unreadable>"

def read_vector(data: bytes, vec_offset: int):
    """Return (count, data_start) for a flatbuffer vector."""
    try:
        count = read_uint32_le(data, vec_offset)
        return count, vec_offset + 4
    except Exception:
        return 0, 0


def analyze_operators_raw(model_path: Path) -> dict:
    """
    Parse the TFLite flatbuffer binary to extract operator codes and
    subgraph operator list without relying on the flatbuffers Python package.
    Returns a summary dict.
    """
    data = model_path.read_bytes()

    # TFLite file starts with a 4-byte root offset
    root_offset = follow_offset(data, 0)

    results = {
        "operator_codes": [],
        "subgraphs": [],
    }

    try:
        # Read the Model table vtable
        vtable_start = root_offset - read_int32_le(data, root_offset)
        vtable_size  = struct.unpack_from("<H", data, vtable_start)[0]
        # Model fields:
        #   field 0 (offset 4):  version      (uint32)
        #   field 1 (offset 6):  operator_codes (vector of OperatorCode tables)
        #   field 2 (offset 8):  subgraphs     (vector of SubGraph tables)
        #   field 3 (offset 10): description   (string)
        #   field 4 (offset 12): buffers       (vector of Buffer tables)
        #   field 5 (offset 14): metadata_buffer (vector)
        #   field 6 (offset 16): metadata       (vector)

        def get_field_offset(field_id: int) -> int:
            vtable_field_offset = 4 + field_id * 2
            if vtable_field_offset + 2 > vtable_size:
                return 0
            f = struct.unpack_from("<H", data, vtable_start + vtable_field_offset)[0]
            if f == 0:
                return 0
            return root_offset + f

        # --- operator_codes ---
        opcodes_field = get_field_offset(1)
        if opcodes_field:
            vec_offset = follow_offset(data, opcodes_field)
            count, items_start = read_vector(data, vec_offset)
            for i in range(count):
                item_ref_pos = items_start + i * 4
                item_offset  = follow_offset(data, item_ref_pos)
                # OperatorCode table fields:
                #   0: builtin_code (int8/int32), field 0 at vtable offset 4
                #   1: custom_code  (string),     field 1 at vtable offset 6
                #   2: version      (int32),       field 2 at vtable offset 8
                #   3: deprecated_builtin_code (int32), field 3 at vtable offset 10
                try:
                    oc_vtable_start = item_offset - read_int32_le(data, item_offset)
                    oc_vtable_size  = struct.unpack_from("<H", data, oc_vtable_start)[0]

                    def oc_field(fid):
                        vf = 4 + fid * 2
                        if vf + 2 > oc_vtable_size:
                            return 0
                        f = struct.unpack_from("<H", data, oc_vtable_start + vf)[0]
                        return (item_offset + f) if f else 0

                    builtin_code_pos = oc_field(0)
                    deprecated_pos   = oc_field(3)
                    custom_pos       = oc_field(1)

                    builtin_code = 0
                    if deprecated_pos:
                        builtin_code = read_int32_le(data, deprecated_pos)
                    if builtin_code == 127 or builtin_code == 0:
                        if builtin_code_pos:
                            builtin_code = read_int32_le(data, builtin_code_pos)

                    custom_name = ""
                    if custom_pos:
                        str_offset = follow_offset(data, custom_pos)
                        if str_offset:
                            custom_name = read_string_from_fb(data, str_offset)

                    op_name = BUILTIN_OPCODE_MAP.get(builtin_code, f"UNKNOWN_{builtin_code}")
                    if custom_name:
                        op_name = f"CUSTOM:{custom_name}"

                    results["operator_codes"].append({
                        "index":        i,
                        "builtin_code": builtin_code,
                        "name":         op_name,
                        "custom_code":  custom_name,
                    })
                except Exception:
                    results["operator_codes"].append({"index": i, "name": "PARSE_ERROR"})

        # --- subgraph operator counts (lightweight) ---
        subgraphs_field = get_field_offset(2)
        if subgraphs_field:
            vec_offset = follow_offset(data, subgraphs_field)
            count, items_start = read_vector(data, vec_offset)
            for sg_i in range(count):
                item_ref_pos = items_start + sg_i * 4
                item_offset  = follow_offset(data, item_ref_pos)
                try:
                    sg_vtable_start = item_offset - read_int32_le(data, item_offset)
                    sg_vtable_size  = struct.unpack_from("<H", data, sg_vtable_start)[0]

                    def sg_field(fid):
                        vf = 4 + fid * 2
                        if vf + 2 > sg_vtable_size:
                            return 0
                        f = struct.unpack_from("<H", data, sg_vtable_start + vf)[0]
                        return (item_offset + f) if f else 0

                    # SubGraph fields: 0=tensors, 1=inputs, 2=outputs, 3=operators, 4=name
                    ops_field = sg_field(3)
                    name_field = sg_field(4)

                    ops_count = 0
                    op_code_indices = []
                    if ops_field:
                        ops_vec = follow_offset(data, ops_field)
                        ops_count, ops_items = read_vector(data, ops_vec)
                        # Each Operator: field 0=opcode_index
                        for oi in range(min(ops_count, 500)):
                            op_ref_pos = ops_items + oi * 4
                            op_off = follow_offset(data, op_ref_pos)
                            try:
                                op_vt_start = op_off - read_int32_le(data, op_off)
                                op_vt_size  = struct.unpack_from("<H", data, op_vt_start)[0]
                                vf = 4   # field 0
                                if vf + 2 <= op_vt_size:
                                    f = struct.unpack_from("<H", data, op_vt_start + vf)[0]
                                    if f:
                                        opcode_idx = read_int32_le(data, op_off + f)
                                        op_code_indices.append(opcode_idx)
                            except Exception:
                                pass

                    sg_name = ""
                    if name_field:
                        str_offset = follow_offset(data, name_field)
                        if str_offset:
                            sg_name = read_string_from_fb(data, str_offset)

                    results["subgraphs"].append({
                        "index":            sg_i,
                        "name":             sg_name or f"subgraph_{sg_i}",
                        "op_count":         ops_count,
                        "op_code_indices":  op_code_indices,
                    })
                except Exception:
                    results["subgraphs"].append({
                        "index": sg_i, "name": f"subgraph_{sg_i}",
                        "op_count": 0, "op_code_indices": []
                    })

    except Exception as e:
        results["parse_error"] = str(e)

    return results


def print_operator_info(raw: dict):
    """Print operator codes and per-subgraph operator usage."""
    section("Model Operator Codes")
    codes = raw.get("operator_codes", [])
    if not codes:
        print("  (no operator codes found — raw parse may have failed)")
    else:
        print(f"  Total distinct operator types: {len(codes)}\n")
        for oc in codes:
            builtin = oc.get("builtin_code", "?")
            name    = oc.get("name", "?")
            custom  = oc.get("custom_code", "")
            custom_str = f"  [custom_code={custom}]" if custom else ""
            print(f"  [{oc['index']:>3}] builtin_code={builtin:<4}  {name}{custom_str}")

    section("Subgraph / Layer Information")
    subgraphs = raw.get("subgraphs", [])
    if not subgraphs:
        print("  (no subgraph data found)")
        return

    op_codes = raw.get("operator_codes", [])
    opcode_name = {oc["index"]: oc["name"] for oc in op_codes}

    for sg in subgraphs:
        subsection(f"Subgraph [{sg['index']}]: '{sg['name']}'")
        kv("Total operators", sg["op_count"])
        indices = sg.get("op_code_indices", [])
        if indices:
            # frequency count
            from collections import Counter
            freq = Counter(indices)
            print(f"\n  Operator breakdown:")
            for code_idx, cnt in sorted(freq.items()):
                name = opcode_name.get(code_idx, f"OPCODE_{code_idx}")
                print(f"    {name:<45}  x{cnt}")
            print(f"\n  Operator sequence (first 60):")
            for i, ci in enumerate(indices[:60]):
                name = opcode_name.get(ci, f"OPCODE_{ci}")
                print(f"    [{i:>3}] {name}")
            if len(indices) > 60:
                print(f"    ... ({len(indices) - 60} more operators)")


# ---------------------------------------------------------------------------
# Quantization scheme analysis
# ---------------------------------------------------------------------------

def print_quantization_scheme(input_details: list, output_details: list,
                               all_tensors: list):
    section("Quantization Scheme Analysis")

    all_dtypes = set()
    quantized_count   = 0
    unquantized_count = 0
    per_channel_count = 0
    per_tensor_count  = 0

    for t in all_tensors:
        dtype_val  = t.get("dtype")
        dtype_name = dtype_val.__name__ if hasattr(dtype_val, "__name__") else str(dtype_val)
        all_dtypes.add(dtype_name)

        q      = t.get("quantization_parameters", {})
        scales = q.get("scales", []) if q else []
        if hasattr(scales, "__len__") and len(scales) > 0:
            quantized_count += 1
            if len(scales) > 1:
                per_channel_count += 1
            else:
                per_tensor_count += 1
        else:
            unquantized_count += 1

    scheme = infer_quantization_scheme(
        [{"dtype_name": (t["dtype"].__name__ if hasattr(t["dtype"], "__name__") else str(t["dtype"]))} for t in input_details],
        [{"dtype_name": (t["dtype"].__name__ if hasattr(t["dtype"], "__name__") else str(t["dtype"]))} for t in output_details],
    )

    kv("Inferred scheme",             scheme)
    kv("All tensor dtypes present",   ", ".join(sorted(all_dtypes)))
    kv("Total tensors",               len(all_tensors))
    kv("Quantized tensors",           quantized_count)
    kv("  -> per-tensor quantized",    per_tensor_count)
    kv("  -> per-channel quantized",   per_channel_count)
    kv("Non-quantized tensors",       unquantized_count)

    print(f"\n  Input  dtype: ", end="")
    for t in input_details:
        dtype_val = t.get("dtype")
        print(dtype_val.__name__ if hasattr(dtype_val, "__name__") else str(dtype_val), end="  ")
    print()
    print(f"  Output dtype: ", end="")
    for t in output_details:
        dtype_val = t.get("dtype")
        print(dtype_val.__name__ if hasattr(dtype_val, "__name__") else str(dtype_val), end="  ")
    print()

    # Inference on quantization boundaries
    inp_dtypes = [t["dtype"].__name__ if hasattr(t["dtype"], "__name__") else str(t["dtype"]) for t in input_details]
    out_dtypes = [t["dtype"].__name__ if hasattr(t["dtype"], "__name__") else str(t["dtype"]) for t in output_details]
    if "FLOAT32" in inp_dtypes and ("INT8" in str(all_dtypes) or "UINT8" in str(all_dtypes)):
        print("\n  NOTE: Float input/output with internal INT8/UINT8 weights ->")
        print("        This is a Hybrid / Dynamic-Range quantized model.")
    elif ("INT8" in inp_dtypes or "UINT8" in inp_dtypes):
        print("\n  NOTE: Integer input tensors -> Full integer quantization confirmed.")
    elif "FLOAT16" in str(all_dtypes):
        print("\n  NOTE: FLOAT16 weights detected -> Float16 quantization model.")


# ---------------------------------------------------------------------------
# Model size + metadata summary
# ---------------------------------------------------------------------------

def print_model_summary(model_path: Path, input_details: list,
                        output_details: list, all_tensors: list):
    section("Model File Summary")
    size_bytes = model_path.stat().st_size
    kv("Model path",          str(model_path))
    kv("File size",           f"{size_bytes:,} bytes  ({size_bytes / 1_048_576:.3f} MB)")
    kv("Total tensors",       len(all_tensors))
    kv("Input tensors",       len(input_details))
    kv("Output tensors",      len(output_details))

    # Expected shape note
    total_input_elements = 1
    for t in input_details:
        shape = t.get("shape")
        if shape is not None:
            for dim in (shape.tolist() if hasattr(shape, "tolist") else shape):
                if dim > 0:
                    total_input_elements *= dim
    kv("Input elements (approx)", total_input_elements)

    if total_input_elements == 19500:
        kv("  -> matches expected",  "500 frames x 39 MFCC features = 19500 OK")
    elif total_input_elements > 0:
        kv("  -> check vs expected", "500 frames x 39 MFCC features = 19500")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print(SEP)
    print("  TFLite Model Analyzer  -  tbcheck / lstm_quantized.tflite")
    print(SEP)

    # 1. Validate file
    if not MODEL_PATH.exists():
        print(f"\n[ERROR] Model file not found: {MODEL_PATH}")
        sys.exit(1)

    # 2. Raw flatbuffer parse (operators / layers) — no TF dependency
    print("\n[STEP 1] Parsing flatbuffer binary for operator/layer info …")
    raw = analyze_operators_raw(MODEL_PATH)
    if "parse_error" in raw:
        print(f"  [WARN] Raw parse encountered an error: {raw['parse_error']}")

    # 3. TFLite Interpreter analysis
    if not TENSORFLOW_AVAILABLE:
        print("\n[WARN] TensorFlow not installed. Tensor details unavailable.")
        print("       Install with:  pip install tensorflow")
        print_operator_info(raw)
        return

    print("[STEP 2] Loading model via TFLite Interpreter …")
    results, interpreter = analyze_with_interpreter(MODEL_PATH)

    input_details  = results["inputs"]
    output_details = results["outputs"]
    all_tensors    = results["all_tensors"]

    # 4. Print all sections
    print_model_summary(MODEL_PATH, input_details, output_details, all_tensors)
    print_tensor_info(input_details, "Input")
    print_tensor_info(output_details, "Output")
    print_all_tensors(all_tensors)
    print_operator_info(raw)
    print_quantization_scheme(input_details, output_details, all_tensors)

    # 5. Done
    print(f"\n{SEP}")
    print("  Analysis complete.")
    print(SEP)

    # 6. Optionally save JSON report
    report_path = MODEL_PATH.parent.parent.parent / "tflite_model_report.json"
    try:
        def serializable(obj):
            if isinstance(obj, np.ndarray):
                return obj.tolist()
            if isinstance(obj, np.integer):
                return int(obj)
            if isinstance(obj, np.floating):
                return float(obj)
            if isinstance(obj, type):
                return obj.__name__
            return str(obj)

        report = {
            "model_path":   str(MODEL_PATH),
            "file_size_mb": round(MODEL_PATH.stat().st_size / 1_048_576, 3),
            "inputs":       [
                {
                    "index": int(t["index"]),
                    "name":  t["name"],
                    "shape": t["shape"].tolist() if hasattr(t["shape"], "tolist") else list(t["shape"]),
                    "dtype": t["dtype"].__name__ if hasattr(t["dtype"], "__name__") else str(t["dtype"]),
                    "quantization": {
                        "scales":      (t["quantization_parameters"]["scales"].tolist()
                                        if hasattr(t["quantization_parameters"].get("scales", []), "tolist")
                                        else list(t["quantization_parameters"].get("scales", []))),
                        "zero_points": (t["quantization_parameters"]["zero_points"].tolist()
                                        if hasattr(t["quantization_parameters"].get("zero_points", []), "tolist")
                                        else list(t["quantization_parameters"].get("zero_points", []))),
                        "quantized_dimension": t["quantization_parameters"].get("quantized_dimension", 0),
                    } if t.get("quantization_parameters") else {},
                }
                for t in input_details
            ],
            "outputs": [
                {
                    "index": int(t["index"]),
                    "name":  t["name"],
                    "shape": t["shape"].tolist() if hasattr(t["shape"], "tolist") else list(t["shape"]),
                    "dtype": t["dtype"].__name__ if hasattr(t["dtype"], "__name__") else str(t["dtype"]),
                    "quantization": {
                        "scales":      (t["quantization_parameters"]["scales"].tolist()
                                        if hasattr(t["quantization_parameters"].get("scales", []), "tolist")
                                        else list(t["quantization_parameters"].get("scales", []))),
                        "zero_points": (t["quantization_parameters"]["zero_points"].tolist()
                                        if hasattr(t["quantization_parameters"].get("zero_points", []), "tolist")
                                        else list(t["quantization_parameters"].get("zero_points", []))),
                        "quantized_dimension": t["quantization_parameters"].get("quantized_dimension", 0),
                    } if t.get("quantization_parameters") else {},
                }
                for t in output_details
            ],
            "operator_codes": raw.get("operator_codes", []),
            "subgraphs":      raw.get("subgraphs", []),
        }

        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, default=serializable)
        print(f"\n  JSON report saved: {report_path}")
    except Exception as e:
        print(f"\n  [WARN] Could not save JSON report: {e}")


if __name__ == "__main__":
    main()
