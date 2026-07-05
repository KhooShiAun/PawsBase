import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/settings/settings_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: SettingsPage,
)
Widget settingsPageDefaultUseCase(BuildContext context) {
  return const SettingsPage();
}
