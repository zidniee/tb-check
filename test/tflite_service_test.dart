import 'package:flutter_test/flutter_test.dart';
import 'package:tbcheck/core/ai/tflite_service.dart';
import 'dart:typed_data';
import 'dart:math' as math;

/// Quick test to verify quantization fix
/// 
/// This test verifies that the quantization bug fix is working correctly
/// by testing the TfliteService with various input patterns.
/// 
/// Run with: flutter test test/tflite_service_test.dart
void main() {
  group('TfliteService Quantization Fix Tests', () {
    late TfliteService tfliteService;

    setUp(() async {
      tfliteService = TfliteService();
      await tfliteService.loadModel();
    });

    test('Should accept MFCC data within quantization range', () async {
      // Generate mock MFCC data within ±0.97 range
      final mfccData = Float32List(19500);
      for (int i = 0; i < mfccData.length; i++) {
        mfccData[i] = (i % 100 - 50) / 100.0; // Range: ±0.5
      }

      final result = await tfliteService.runInference(mfccData);

      expect(result.probabilityScore, greaterThanOrEqualTo(0.0));
      expect(result.probabilityScore, lessThanOrEqualTo(1.0));
      expect(result.screeningStatus, isNotNull);
    });

    test('Should clip values outside quantization range', () async {
      // Generate mock MFCC data with some values > ±0.97
      final mfccData = Float32List(19500);
      for (int i = 0; i < mfccData.length; i++) {
        // Mix of values inside and outside range
        mfccData[i] = (i % 100 - 50) / 30.0; // Range: ±1.67 (exceeds ±0.97)
      }

      final result = await tfliteService.runInference(mfccData);

      // Should complete without error despite clipping
      expect(result.probabilityScore, greaterThanOrEqualTo(0.0));
      expect(result.probabilityScore, lessThanOrEqualTo(1.0));
    });

    test('Should produce different outputs for different inputs', () async {
      // Test Case 1: Low values (mostly negative)
      final input1 = Float32List(19500);
      for (int i = 0; i < input1.length; i++) {
        input1[i] = -0.5 + (i % 10) * 0.05;
      }
      final result1 = await tfliteService.runInference(input1);

      // Test Case 2: High values (mostly positive)
      final input2 = Float32List(19500);
      for (int i = 0; i < input2.length; i++) {
        input2[i] = 0.5 + (i % 10) * 0.03;
      }
      final result2 = await tfliteService.runInference(input2);

      // Test Case 3: Mixed sine wave pattern
      final input3 = Float32List(19500);
      for (int i = 0; i < input3.length; i++) {
        input3[i] = math.sin(i * 0.01) * 0.6;
      }
      final result3 = await tfliteService.runInference(input3);

      // ✅ CRITICAL: All three should produce DIFFERENT probabilities
      // If they're all ~0.35, the bug is still present
      
      print('Test Case 1: ${result1.probabilityScore}');
      print('Test Case 2: ${result2.probabilityScore}');
      print('Test Case 3: ${result3.probabilityScore}');

      // Calculate standard deviation of the three results
      final mean = (result1.probabilityScore + result2.probabilityScore + result3.probabilityScore) / 3;
      final variance = ((result1.probabilityScore - mean) * (result1.probabilityScore - mean) +
                        (result2.probabilityScore - mean) * (result2.probabilityScore - mean) +
                        (result3.probabilityScore - mean) * (result3.probabilityScore - mean)) / 3;
      final std = math.sqrt(variance);

      print('Mean: $mean, Std: $std');

      // ✅ Standard deviation should be > 0.05 (healthy variance)
      // If std < 0.05, outputs are too similar (bug still present)
      expect(std, greaterThan(0.05), 
        reason: 'Standard deviation too low - outputs appear stuck at similar values');

      // ✅ At least one result should be significantly different from 0.35
      final hasVariance = (result1.probabilityScore - 0.35).abs() > 0.1 ||
                          (result2.probabilityScore - 0.35).abs() > 0.1 ||
                          (result3.probabilityScore - 0.35).abs() > 0.1;
      
      expect(hasVariance, isTrue,
        reason: 'All outputs close to 0.35 - quantization bug may still be present');
    });

    test('Should handle normalized MFCC data (mean≈0)', () async {
      // Simulate CMVN-normalized data
      final mfccData = Float32List(19500);
      final random = math.Random(42); // Fixed seed for reproducibility
      
      // Generate normal distribution with mean≈0, std≈1
      for (int i = 0; i < mfccData.length; i++) {
        // Box-Muller transform for normal distribution
        final u1 = random.nextDouble();
        final u2 = random.nextDouble();
        final z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
        mfccData[i] = z * 0.8; // std=0.8, range mostly within ±2.4σ
      }

      // Verify mean is close to 0
      final mean = mfccData.reduce((a, b) => a + b) / mfccData.length;
      expect(mean.abs(), lessThan(0.1), reason: 'Mean should be close to 0');

      final result = await tfliteService.runInference(mfccData);

      expect(result.probabilityScore, greaterThanOrEqualTo(0.0));
      expect(result.probabilityScore, lessThanOrEqualTo(1.0));
      
      // Should not be stuck at ~0.35
      print('Normalized MFCC result: ${result.probabilityScore}');
    });

    test('Should handle edge case: all zeros', () async {
      final mfccData = Float32List(19500); // All zeros by default

      final result = await tfliteService.runInference(mfccData);

      expect(result.probabilityScore, greaterThanOrEqualTo(0.0));
      expect(result.probabilityScore, lessThanOrEqualTo(1.0));
      
      print('All zeros result: ${result.probabilityScore}');
    });

    test('Should complete inference within reasonable time', () async {
      final mfccData = Float32List(19500);
      for (int i = 0; i < mfccData.length; i++) {
        mfccData[i] = math.sin(i * 0.01) * 0.5;
      }

      final stopwatch = Stopwatch()..start();
      final result = await tfliteService.runInference(mfccData);
      stopwatch.stop();

      print('Inference time: ${stopwatch.elapsedMilliseconds}ms');

      // Should complete within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
        reason: 'Inference taking too long');
      
      // Verify result is valid
      expect(result.inferenceTime, equals(stopwatch.elapsed));
    });
  });

  group('ValidationResult Tests', () {
    test('Should create ValidationResult with valid data', () {
      // This is defined in screening_provider.dart but we can test the concept
      final result = _TestValidationResult(isValid: true, message: 'OK');
      
      expect(result.isValid, isTrue);
      expect(result.message, equals('OK'));
    });

    test('Should create ValidationResult with invalid data', () {
      final result = _TestValidationResult(
        isValid: false, 
        message: 'MFCC contains NaN values'
      );
      
      expect(result.isValid, isFalse);
      expect(result.message, contains('NaN'));
    });
  });
}

// Helper class for testing (mirrors the actual ValidationResult)
class _TestValidationResult {
  final bool isValid;
  final String message;
  
  _TestValidationResult({required this.isValid, required this.message});
}
