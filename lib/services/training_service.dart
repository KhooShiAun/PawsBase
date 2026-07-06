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
  Future<TrainingCommand> addCommand(String name, String category) async {
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
          })
          .select()
          .single();

      return TrainingCommand.fromJson(response);
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
}
