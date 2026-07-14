import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/settings/about_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: AboutPage,
)
Widget aboutPageDefaultUseCase(BuildContext context) {
  return const AboutPage();
}
