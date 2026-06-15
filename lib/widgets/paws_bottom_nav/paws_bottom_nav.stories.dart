import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'paws_bottom_nav.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: PawsBottomNav,
)
Widget defaultBottomNav(BuildContext context) {
  return const _BottomNavWrapper();
}

class _BottomNavWrapper extends StatefulWidget {
  const _BottomNavWrapper();

  @override
  State<_BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<_BottomNavWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Page Content')),
      bottomNavigationBar: SafeArea(
        child: PawsBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

