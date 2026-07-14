import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/settings/profile_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: ProfilePage,
)
Widget profilePageDefaultUseCase(BuildContext context) {
  return const ProfilePage();
}
