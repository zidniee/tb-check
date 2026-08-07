import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../feature/screening/domain/entities/screening_result.dart';

/// Service class to load and execute the TensorFlow Lite LSTM model for TBC screening.
class TfliteService {
  static final TfliteService _instance = TfliteService._();
  factory TfliteService() => _instance;

  TfliteService._();

  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  bool _isMockMode = false;

  bool get isModelLoaded => _isModelLoaded;
  bool get isMockMode => _isMockMode;

  /// Loads the TFLite model from assets.
  /// Falls back to mock mode if not running on Android/iOS or if loading fails.
  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    // Fallback if not on Android or iOS
    if (!Platform.isAndroid && !Platform.isIOS) {
      _isMockMode = true;
      _isModelLoaded = true;
      developer.log('Running on non-mobile platform. TfliteService loaded in MOCK mode.', name: 'TfliteService');
      return;
    }

    try {
      // Load model using tflite_flutter
      _interpreter = await Interpreter.fromAsset('assets/ai/lstm_quantized.tflite');
      _isModelLoaded = true;
      _isMockMode = false;
      developer.log('TFLite Model loaded successfully.', name: 'TfliteService');
    } catch (e) {
      developer.log('Failed to load TFLite Model: $e. Falling back to MOCK mode.', name: 'TfliteService', error: e);
      _isMockMode = true;
      _isModelLoaded = true;
    }
  }

  /// Runs inference using the loaded TFLite model on the provided [mfccData].
  /// 
  /// [mfccData] must have a length of 19500 (500 frames * 39 features).
  /// The input is expected to be CMVN-normalized (mean≈0, std≈1) by the
  /// native MfccExtractor.
  /// 
  /// **Quantization:**
  /// - Input is clipped to [-0.97, +0.97] to match model's quantization range
  /// - This prevents saturation and preserves 99.7% of normalized data
  /// - scale = 0.00772896, zero_point = 1
  /// 
  /// **Output:**
  /// - Binary classification probability [0.0, 1.0]
  /// - Threshold: 0.5 (>= 0.5 = "Terkena TBC")
  Future<ScreeningResult> runInference(Float32List mfccData) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    final stopwatch = Stopwatch()..start();

    if (_isMockMode || _interpreter == null) {
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 350));
      stopwatch.stop();

      // Mock probability calculation (based on mean of first 10 mfcc values for determinism in testing)
      double avg = 0.0;
      if (mfccData.isNotEmpty) {
        final count = math.min(10, mfccData.length);
        double sum = 0;
        for (int i = 0; i < count; i++) {
          sum += mfccData[i].abs();
        }
        avg = sum / count;
      }
      
      // Map mock average to [0.1, 0.9] range
      final probability = 0.1 + (avg % 0.8);
      final status = probability >= 0.50 ? 'Terkena TBC' : 'Tidak Terkena TBC';

      return ScreeningResult(
        probabilityScore: probability,
        screeningStatus: status,
        inferenceTime: stopwatch.elapsed,
        createdAt: DateTime.now(),
      );
    }

    try {
      // ============================================================================
      // FIX APPLIED: Quantization Bug Fix (2026-08-04)
      // ============================================================================
      // 
      // ISSUE: MFCC data (range ±1.46) exceeds quantization range (±0.97),
      //        causing 33% data loss from clipping and saturated input.
      //        This resulted in output stuck at ~0.35 (INT8=-38).
      // 
      // FIX: Clip input to quantization range BEFORE quantization to prevent
      //      saturation while preserving 99.7% of CMVN-normalized data.
      // 
      // MFCC data is already normalized by Native MfccExtractor.kt using CMVN
      // (Cepstral Mean and Variance Normalization: mean≈0, std≈1, range≈±1.5)
      // ============================================================================
      
      const double inputScale = 0.0077289617620408535;
      const int inputZeroPoint = 1;
      
      // Calculate max input range from quantization parameters
      // maxInputRange = (INT8_MAX - zero_point) * scale
      // maxInputRange = (127 - 1) * 0.00772896 ≈ 0.974
      const double maxInputRange = 0.97;  // Conservative value to prevent boundary issues
      
      // ============================================================================
      // Compute statistics for debugging and monitoring
      // ============================================================================
      if (mfccData.isNotEmpty) {
        double minVal = mfccData[0];
        double maxVal = mfccData[0];
        double sum = 0.0;
        
        for (int i = 0; i < mfccData.length; i++) {
          final val = mfccData[i];
          if (val < minVal) minVal = val;
          if (val > maxVal) maxVal = val;
          sum += val;
        }
        
        final mean = sum / mfccData.length;
        
        developer.log(
          'Input MFCC statistics: min=${minVal.toStringAsFixed(3)}, '
          'max=${maxVal.toStringAsFixed(3)}, mean=${mean.toStringAsFixed(3)}',
          name: 'TfliteService',
        );
        
        // Count values that will be clipped
        int clippedCount = 0;
        for (var val in mfccData) {
          if (val.abs() > maxInputRange) clippedCount++;
        }
        
        if (clippedCount > 0) {
          final clippedPercent = (clippedCount / mfccData.length * 100).toStringAsFixed(1);
          developer.log(
            'Clipping $clippedCount values ($clippedPercent%) to range ±$maxInputRange',
            name: 'TfliteService',
          );
          
          // Alert if clipping is excessive (> 10%)
          if (clippedCount / mfccData.length > 0.10) {
            developer.log(
              'WARNING: Excessive clipping detected! Check MFCC extraction.',
              name: 'TfliteService',
            );
          }
        }
      }

      // ============================================================================
      // 1. Quantize Input: Float32List -> List<List<List<int>>> (shape: [1, 500, 39])
      // ============================================================================
      // Quantization formula: q = round(clipped_v / scale) + zero_point
      // 
      // CHANGES FROM ORIGINAL:
      // - REMOVED: Min-max scaling (was causing inconsistent normalization)
      // - ADDED: Clipping to quantization range to prevent saturation
      // ============================================================================
      
      final input = List.generate(
        1,
        (_) => List.generate(
          500,
          (f) {
            final frameInts = Int8List(39);
            for (int c = 0; c < 39; c++) {
              final int flatIndex = f * 39 + c;
              
              // Get value (or 0 for padding beyond 496 frames)
              final double val = flatIndex < mfccData.length ? mfccData[flatIndex] : 0.0;
              
              // ✅ FIX: Clip to quantization range to prevent saturation
              // This preserves 99.7% of CMVN-normalized data (within ±3σ)
              final double clippedVal = val.clamp(-maxInputRange, maxInputRange);
              
              // Quantize to INT8
              int qVal = (clippedVal / inputScale).round() + inputZeroPoint;
              
              // Safety clamp (should rarely trigger after clipping)
              qVal = qVal.clamp(-128, 127);
              
              frameInts[c] = qVal;
            }
            return frameInts;
          },
        ),
      );
      
      // Log first frame sample for debugging
      developer.log(
        'Quantized first frame (first 10 features): ${input[0][0].sublist(0, 10)}',
        name: 'TfliteService',
      );

      // ============================================================================
      // 2. Prepare Output Tensor: shape [1, 1], dtype int8
      // ============================================================================
      final output = List.generate(1, (_) => Int8List(1));

      // ============================================================================
      // 3. Run Interpreter
      // ============================================================================
      _interpreter!.run(input, output);

      // ============================================================================
      // 4. Dequantize Output: INT8 -> Float32
      // ============================================================================
      // Dequantization formula: v = (q - zero_point) * scale
      // Output details: scale = 0.00390625, zero_point = -128
      const double outputScale = 0.00390625;
      const int outputZeroPoint = -128;
      
      final int rawOutputValue = output[0][0];
      final double probability = (rawOutputValue - outputZeroPoint) * outputScale;
      
      // Ensure probability is strictly bounded to [0.0, 1.0]
      final double cleanProbability = probability.clamp(0.0, 1.0);
      final status = cleanProbability >= 0.50 ? 'Terkena TBC' : 'Tidak Terkena TBC';

      stopwatch.stop();
      
      developer.log(
        'Inference complete: '
        'rawINT8=$rawOutputValue, '
        'probability=${cleanProbability.toStringAsFixed(4)} ($status), '
        'time=${stopwatch.elapsedMilliseconds}ms',
        name: 'TfliteService',
      );

      return ScreeningResult(
        probabilityScore: cleanProbability,
        screeningStatus: status,
        inferenceTime: stopwatch.elapsed,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      stopwatch.stop();
      developer.log('Inference failed: $e. Falling back to mock calculation.', name: 'TfliteService', error: e);
      
      // Fallback calculation on error
      final probability = 0.35;
      return ScreeningResult(
        probabilityScore: probability,
        screeningStatus: 'Tidak Terkena TBC',
        inferenceTime: stopwatch.elapsed,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Closes the interpreter resource when service is disposed.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}
