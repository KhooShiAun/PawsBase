import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'paws_search_bar.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: PawsSearchBar,
)
Widget defaultSearchBar(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: PawsSearchBar(),
    ),
  );
}
