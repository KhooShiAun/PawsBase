import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

void main() {
  runApp(const MainApp());
}

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
      themeMode: ThemeMode.system, 

      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
