import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/health_log/health_log_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: HealthLogPage,
)
Widget healthLogPageDefaultUseCase(BuildContext context) {
  return const HealthLogPage();
}
