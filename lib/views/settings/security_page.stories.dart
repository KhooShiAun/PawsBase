import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/settings/security_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: SecurityPage,
)
Widget securityPageDefaultUseCase(BuildContext context) {
  return const SecurityPage();
}
