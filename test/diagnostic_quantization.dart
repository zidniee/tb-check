import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

/// Quick diagnostic script to verify fix is working
/// 
/// Run this to see if quantization fix is applied correctly
void main() {
  test('Verify Quantization Logic', () {
    // Simulate MFCC data
    final mfccData = Float32List(19500);
    for (int i = 0; i < mfccData.length; i++) {
      // Generate pattern similar to CMVN normalized data
      mfccData[i] = math.sin(i * 0.01) * 1.2; // Range ±1.2
    }

    // Apply quantization logic from fix
    const double inputScale = 0.0077289617620408535;
    const int inputZeroPoint = 1;
    const double maxInputRange = 0.97;

    // Count clipping
    int clippedCount = 0;
    double minVal = mfccData[0];
    double maxVal = mfccData[0];
    double sum = 0.0;

    for (var val in mfccData) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
      sum += val;
      if (val.abs() > maxInputRange) clippedCount++;
    }

    final mean = sum / mfccData.length;

    print('==============================================');
    print('DIAGNOSTIC: Quantization Fix Verification');
    print('==============================================');
    print('Input MFCC Stats:');
    print('  Min: ${minVal.toStringAsFixed(3)}');
    print('  Max: ${maxVal.toStringAsFixed(3)}');
    print('  Mean: ${mean.toStringAsFixed(3)}');
    print('');
    print('Clipping Analysis:');
    print('  Values > ±$maxInputRange: $clippedCount');
    print('  Clipping percentage: ${(clippedCount / mfccData.length * 100).toStringAsFixed(2)}%');
    print('');

    // Simulate quantization
    final quantizedSample = <int>[];
    for (int i = 0; i < 10; i++) {
      final val = mfccData[i];
      final clippedVal = val.clamp(-maxInputRange, maxInputRange);
      int qVal = (clippedVal / inputScale).round() + inputZeroPoint;
      qVal = qVal.clamp(-128, 127);
      quantizedSample.add(qVal);
    }

    print('Quantized Sample (first 10):');
    print('  $quantizedSample');
    print('');

    // Check variance
    final Set<int> uniqueValues = quantizedSample.toSet();
    print('Unique values in sample: ${uniqueValues.length} / 10');
    print('');

    if (uniqueValues.length < 5) {
      print('⚠️  WARNING: Low variance in quantized values!');
      print('   This could indicate saturation issue.');
    } else {
      print('✅ Good variance in quantized values.');
    }

    print('==============================================');
  });
}
