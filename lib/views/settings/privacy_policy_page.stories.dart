import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/views/settings/privacy_policy_page.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: PrivacyPolicyPage,
)
Widget privacyPolicyPageDefaultUseCase(BuildContext context) {
  return const PrivacyPolicyPage();
}
