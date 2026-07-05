import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/training/training_checklist_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: TrainingChecklistPage,
)
Widget trainingChecklistPageDefaultUseCase(BuildContext context) {
  return const TrainingChecklistPage();
}
