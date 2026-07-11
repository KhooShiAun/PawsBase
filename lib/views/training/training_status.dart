import 'package:flutter/material.dart';

enum TrainingStatus {
  pending('pending', 'Pending', Color(0xFFBA1A1A)), // Muted red
  inProgress('in_progress', 'In Progress', Color(0xFFE6A123)), // Amber
  mastered('mastered', 'Mastered', Color(0xFF4CAF50)); // Vibrant Green

  final String value;
  final String label;
  final Color color;

  const TrainingStatus(this.value, this.label, this.color);

  static TrainingStatus fromString(String val) {
    return TrainingStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TrainingStatus.pending,
    );
  }

  TrainingStatus get next {
    switch (this) {
      case TrainingStatus.pending:
        return TrainingStatus.inProgress;
      case TrainingStatus.inProgress:
        return TrainingStatus.mastered;
      case TrainingStatus.mastered:
        return TrainingStatus.pending;
    }
  }
}
