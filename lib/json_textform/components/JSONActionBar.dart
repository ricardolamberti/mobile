import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';
import '../models/components/AvaliableWidgetTypes.dart';
import 'JSONButton.dart';
import 'JSONDropDownButton.dart';

typedef OnChange = void Function(bool value);

class JSONActionBar extends StatelessWidget {
  final AstorComponente schema;
  final OnChange? onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody; // lo dejamos por compatibilidad

  const JSONActionBar({
    super.key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    if (!schema.visible) {
      return const SizedBox.shrink();
    }

    // hijos reales del action bar (ignoro "end")
    final actions = schema.components
        .where((c) => c.type != 'end' && c.visible)
        .toList();

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool alignRight =
    schema.classResponsive.contains('pull-right');

    // construyo cada acción como botón / dropdown
    final children = actions.map((action) {
      // dropdown (tres puntos / “Acciones”)
      if (action.widget == WidgetType.dropdown ||
          action.type == 'dropdown') {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: JSONDropDownButton(
            schema: action,
            onPressed: onPressed,
            onBuildBody: onBuildBody,
          ),
        );
      }

      // botón normal (Aplica, Cancela, etc.)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: JSONButton(
          schema: action,
          onPressed: onPressed,
          onSaved: (v) {
            action.value = v;
            if (onSaved != null && v is bool) {
              onSaved!(v);
            }
          },
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
        alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: children,
      ),
    );
  }
}
