
import 'package:astor_mobile/json_textform/components/JSONIcon.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';

typedef OnChange = void Function(bool value);

class JSONCheckboxField extends StatelessWidget {
  final AstorComponente schema;
  final OnChange? onSaved;
  final bool showIcon;
  final bool visible;
  final bool edited;
  final OnRefereshForm? onRefreshForm;

  const JSONCheckboxField({
    super.key,
    required this.schema,
    this.onSaved,
    this.showIcon = true,
    this.onRefreshForm,
    required this.visible,
    required this.edited,
  });

  @override
  Widget build(BuildContext context) {
    final bool visible = schema.visible;
    final bool edited = schema.edited;
    final String mode = schema.mode;
    if (mode=='toggle') {
      return Visibility(
        visible: visible,
        child: SwitchListTile(
            value: schema.valueChecked,
            onChanged: (v) {
              final bool newValue = v;
              onSaved?.call(newValue);
              if (schema.refreshForm) {
                onRefreshForm?.call(schema, context);
              }
            },
            title: Text(schema.label),
            subtitle: Text(schema.help),
            secondary: !schema.hasIcon?null:JSONIcon(schema: schema)
        ),
      );
    }
    return Visibility(
      visible: visible,
      child: CheckboxListTile(
        value: schema.valueChecked,
        onChanged: (v) {
          final bool newValue = v ?? false;
          onSaved?.call(newValue);
          if (schema.refreshForm) {
            onRefreshForm?.call(schema, context);
          }
        },
        title: Text(schema.label),
        subtitle: Text(schema.help),
        secondary: JSONIcon(schema: schema)
      ),
    );
  }
}
