import 'training_status.dart';

class TrainingCommand {
  final String id;
  final String name;
  final String description;
  final TrainingStatus status;
  final String category;
  final DateTime createdAt;

  TrainingCommand({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.category,
    required this.createdAt,
  });

  factory TrainingCommand.fromJson(Map<String, dynamic> json) {
    return TrainingCommand(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: TrainingStatus.fromString(json['status'] as String? ?? ''),
      category: json['category'] as String? ?? 'General training',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'status': status.value,
      'category': category,
    };
  }
}
