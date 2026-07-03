import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart';

class AudioChannel {
  static const MethodChannel _channel = MethodChannel('com.tbcheck.tbcheck/audio');

  /// Triggers native MFCC extraction for the WAV file at [filePath].
  /// Returns a [Float32List] of size 19500 (500 frames * 39 features).
  Future<Float32List> extractMfcc(String filePath) async {
    const int numFrames = 500;
    const int numFeatures = 39;
    const int targetLength = numFrames * numFeatures;

    // Fallback: If we are not on Android (e.g. testing on Windows/macOS/Web),
    // return mock MFCC+Delta+Delta-Delta data directly from Dart to prevent MissingPluginException.
    if (!Platform.isAndroid) {
      final result = Float32List(targetLength);
      for (var f = 0; f < numFrames; f++) {
        // 1. Static coefficients (13)
        result[f * numFeatures] = 12.0 + 4.0 * math.sin(f * 0.04);
        for (var c = 1; c < 13; c++) {
          result[f * numFeatures + c] = 3.0 * math.sin(f * 0.08 + c) / c;
        }
        
        // 2. Delta coefficients (13)
        for (var c = 0; c < 13; c++) {
          result[f * numFeatures + 13 + c] = 1.5 * math.sin(f * 0.12 + c) / (c + 1);
        }
        
        // 3. Delta-Delta coefficients (13)
        for (var c = 0; c < 13; c++) {
          result[f * numFeatures + 26 + c] = 0.8 * math.sin(f * 0.16 + c) / (c + 1);
        }
      }
      
      // Simulate native processing latency
      await Future.delayed(const Duration(milliseconds: 600));
      return result;
    }

    // Call native platform channel expecting a ByteArray (Uint8List in Dart)
    final Uint8List? resultBytes = await _channel.invokeMethod<Uint8List>(
      'extractMfcc',
      {'path': filePath},
    );
    
    if (resultBytes == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'Platform returned a null byte array.',
      );
    }

    // If the byte offset is not aligned to 4 bytes (Float32 size), 
    // copy to a new aligned buffer to avoid RangeError.
    final Uint8List alignedBytes = resultBytes.offsetInBytes % 4 == 0
        ? resultBytes
        : Uint8List.fromList(resultBytes);

    // Zero-copy: View the aligned byte buffer as Float32List directly
    final flatFloats = Float32List.view(
      alignedBytes.buffer,
      alignedBytes.offsetInBytes,
      alignedBytes.lengthInBytes ~/ 4,
    );

    // Dynamic sequence alignment (Feature-level padding & cropping)
    final alignedFeatures = Float32List(targetLength);
    final int copyLength = flatFloats.length < targetLength ? flatFloats.length : targetLength;
    for (var i = 0; i < copyLength; i++) {
      alignedFeatures[i] = flatFloats[i];
    }

    return alignedFeatures;
  }
}
