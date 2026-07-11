import 'training_status.dart';

class TrainingCommand {
  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime createdAt;
  final String? petId;
  final int sessionsNeeded;
  final int completedSessions;

  TrainingStatus get status {
    if (completedSessions == 0) return TrainingStatus.pending;
    if (completedSessions >= sessionsNeeded) return TrainingStatus.mastered;
    return TrainingStatus.inProgress;
  }

  TrainingCommand({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
    this.petId,
    this.sessionsNeeded = 1,
    this.completedSessions = 0,
  });

  factory TrainingCommand.fromJson(Map<String, dynamic> json) {
    return TrainingCommand(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General training',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      petId: json['pet_id'] as String?,
      sessionsNeeded: json['sessions_needed'] as int? ?? 1,
      completedSessions: json['completed_sessions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'status': status.value,
      'category': category,
      'pet_id': petId,
      'sessions_needed': sessionsNeeded,
      'completed_sessions': completedSessions,
    };
  }
}
