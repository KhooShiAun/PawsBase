import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pawsbase/views/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawsBase',

      // light theme setup
      theme: ThemeData(
        colorScheme: pawsBaseColorScheme,
        fontFamily: PawsBaseTokens.fontFamily,
        useMaterial3: true,
      ),

      // dark theme setup
      darkTheme: ThemeData(
        colorScheme: pawsBaseDarkColorScheme,
        fontFamily: PawsBaseTokens.fontFamily,
        useMaterial3: true,
      ),

      // system theme
      themeMode: ThemeMode.light,

      home: const AuthGate(),
    );
  }
}
