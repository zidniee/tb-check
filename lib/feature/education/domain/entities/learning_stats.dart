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
}
