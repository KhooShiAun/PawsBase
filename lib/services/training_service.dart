import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/training/training_command.dart';
import '../views/training/training_status.dart';

class TrainingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all training commands for the logged-in user
  Future<List<TrainingCommand>> fetchCommands() async {
    try {
      final response = await _supabase
          .from('training_commands')
          .select()
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => TrainingCommand.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add a new training command
  Future<TrainingCommand> addCommand(String name, String category, {String? petId, int sessionsNeeded = 1}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User must be logged in to add a command.");
      }

      final response = await _supabase
          .from('training_commands')
          .insert({
            'name': name,
            'category': category,
            'status': TrainingStatus.pending.value,
            'description': category,
            'user_id': userId,
            'pet_id': petId,
            'sessions_needed': sessionsNeeded,
            'completed_sessions': 0,
          })
          .select()
          .single();

      return TrainingCommand.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Complete a session for a command
  Future<void> completeTrainingSession(String id, int currentCompleted, int totalSessions, {String? petId, String? commandName}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User must be logged in.");
      }

      final newCompleted = currentCompleted + 1;
      final newStatus = newCompleted >= totalSessions ? TrainingStatus.mastered : TrainingStatus.inProgress;

      // Increment completed_sessions in training_commands
      await _supabase
          .from('training_commands')
          .update({
            'completed_sessions': newCompleted,
            'status': newStatus.value,
          })
          .eq('id', id);
      
      // Optionally log to a health_logs / training_logs table if required
      try {
        await _supabase.from('health_logs').insert({
          'user_id': userId,
          'pet_id': petId,
          'log_title': 'Training Completed',
          'subtitle': commandName ?? 'Training Session',
          'description': 'Completed session ${currentCompleted + 1} for $commandName.',
          'type': 'training',
          'record_date': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle if table doesn't exist
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update command status
  Future<void> updateCommandStatus(String id, TrainingStatus status) async {
    try {
      await _supabase
          .from('training_commands')
          .update({
            'status': status.value,
          })
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a training command
  Future<void> deleteCommand(String id) async {
    try {
      await _supabase
          .from('training_commands')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Update a training command details
  Future<void> updateCommand(String id, String petId, String name, int sessionsNeeded) async {
    try {
      await _supabase
          .from('training_commands')
          .update({
            'pet_id': petId,
            'name': name,
            'sessions_needed': sessionsNeeded,
          })
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
