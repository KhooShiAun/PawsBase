import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class HealthLogPage extends StatelessWidget {
  const HealthLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      body: Center(
        child: Text(
          'Health Log',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: PawsBaseTokens.onSurface,
          ),
        ),
      ),
    );
  }
}
