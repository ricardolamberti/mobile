import 'package:flutter/material.dart';
import 'package:astor_mobile/model/astorSchema.dart';

InputDecoration buildAstorInputDecoration(
    BuildContext context,
    AstorComponente schema, {
      String? labelOverride,
    }) {
  final theme = Theme.of(context);
  const radius = 24.0;

  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  final baseTheme = theme.inputDecorationTheme;

  final enabledColor =
  (baseTheme.enabledBorder is OutlineInputBorder)
      ? (baseTheme.enabledBorder as OutlineInputBorder).borderSide.color
      : theme.dividerColor;

  final label = labelOverride ?? schema.label;

  return InputDecoration(
    // textos
    labelText: label.isEmpty ? null : label,
    helperText: schema.help.isEmpty ? null : schema.help,

    // padding y relleno
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    filled: baseTheme.filled ?? true,
    fillColor: baseTheme.fillColor,

    // bordes “pastilla”
    border: border(enabledColor),
    enabledBorder: border(enabledColor),
    focusedBorder: border(theme.colorScheme.primary, 2),
  );
}
