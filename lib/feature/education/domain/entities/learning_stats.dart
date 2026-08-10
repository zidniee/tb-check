/// Represents aggregate learning statistics for a patient.
///
/// Maps to the response of `GET /education/progress/stats`.
class LearningStats {
  final int totalContents;
  final int totalStarted;
  final int totalCompleted;
  final int overallPercent;

  const LearningStats({
    required this.totalContents,
    required this.totalStarted,
    required this.totalCompleted,
    required this.overallPercent,
  });

  /// Number of contents not yet started.
  int get totalNotStarted => totalContents - totalStarted;

  /// Whether the patient has completed all available content.
  bool get isAllCompleted => totalCompleted == totalContents && totalContents > 0;

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      totalContents: (json['total_contents'] as num?)?.toInt() ?? 0,
      totalStarted: (json['total_started'] as num?)?.toInt() ?? 0,
      totalCompleted: (json['total_completed'] as num?)?.toInt() ?? 0,
      overallPercent: (json['overall_percent'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_contents': totalContents,
      'total_started': totalStarted,
      'total_completed': totalCompleted,
      'overall_percent': overallPercent,
    };
  }
}
