import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
