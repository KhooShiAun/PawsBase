import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'paws_header.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: PawsHeader,
)
Widget defaultHeader(BuildContext context) {
  return const Scaffold(
    appBar: PawsHeader(
      title: 'PawsBase',
    ),
    body: Center(child: Text('Page Content')),
  );
}

@widgetbook.UseCase(
  name: 'With Subtitle and Actions',
  type: PawsHeader,
)
Widget headerWithSubtitle(BuildContext context) {
  return Scaffold(
    appBar: PawsHeader(
      title: 'Luna\'s Profile',
      subtitle: 'Persian Cat • 3 years old',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ],
    ),
    body: const Center(child: Text('Page Content')),
  );
}
