import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/settings/help_center_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: HelpCenterPage,
)
Widget helpCenterPageDefaultUseCase(BuildContext context) {
  return const HelpCenterPage();
}
