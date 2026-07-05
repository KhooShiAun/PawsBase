import 'package:flutter/material.dart';
import 'package:pawsbase/services/auth_service.dart';
import 'package:pawsbase/views/auth/login_page.dart';
import 'package:pawsbase/views/main/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService().onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading state while waiting for the stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.data?.session;
        
        // If there's a valid session, show the main page
        if (session != null) {
          return const MainPage();
        }

        // Otherwise, show the login page
        return const LoginPage();
      },
    );
  }
}
