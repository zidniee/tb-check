/// Represents the result of an on-device AI screening inference.
class ScreeningResult {
  /// The raw probability score from the model (0.0 - 1.0).
  final double probabilityScore;

  /// The binary screening status derived from the probability score.
  /// - 'Terkena TBC' if probability >= 0.50
  /// - 'Tidak Terkena TBC' if probability < 0.50
  final String screeningStatus;

  /// The time taken to run the AI inference.
  final Duration inferenceTime;

  /// The timestamp when the result was generated.
  final DateTime createdAt;

  const ScreeningResult({
    required this.probabilityScore,
    required this.screeningStatus,
    required this.inferenceTime,
    required this.createdAt,
  });

  /// Whether the screening indicates TB risk.
  bool get isTbPositive => screeningStatus == 'Terkena TBC';

  /// Probability as a percentage string (e.g., "65.2%").
  String get probabilityPercentage =>
      '${(probabilityScore * 100).toStringAsFixed(1)}%';

  /// Human-readable inference time (e.g., "1.2 detik").
  String get inferenceTimeFormatted =>
      '${(inferenceTime.inMilliseconds / 1000).toStringAsFixed(1)} detik';
}
