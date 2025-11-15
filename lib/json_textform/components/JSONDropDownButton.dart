import 'package:astor_mobile/json_textform/models/components/AvaliableWidgetTypes.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JSONForm.dart';

typedef OnChange = void Function(bool value);

class JSONDropDownButton extends StatelessWidget {
  final AstorComponente schema;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  final bool everyVisible;

  const JSONDropDownButton({
    super.key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.everyVisible = false,
  });

  PopupMenuItem<AstorComponente> _buildTiles(
    AstorComponente root,
    BuildContext context,
  ) {
    AstorComponente rootButton;
    if (root.widget == WidgetType.li) {
      rootButton = root.components.first;
    } else {
      rootButton = root;
    }
    final String label = rootButton.label;
    final String action = root.name.substring(root.name.lastIndexOf('-') + 1);

    final astorProvider = Provider.of<AstorProvider>(context, listen: false);
    final astorApp = astorProvider.astorApp;

    bool? visible;

    if (everyVisible) {
      visible = true;
    } else if (astorApp != null) {
      visible = astorApp.getObjAction(action);
    } else {
      // si no hay astorApp, asumimos visible por defecto
      visible = true;
    }

    final popup = PopupMenuItem<AstorComponente>(
      value: rootButton,
      enabled: visible ?? true,
      child: Text(label),
    );

    if (!everyVisible && astorApp != null && visible == null) {
      astorApp.addObjAction(action, false);
    }

    return popup;
  }

  @override
  Widget build(BuildContext context) {
    final items = schema.components
        .where(
          (element) =>
              element.widget == WidgetType.li ||
              element.widget == WidgetType.button,
        )
        .toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<AstorComponente>(
      itemBuilder: (BuildContext bc) => [
        for (final option in items) _buildTiles(option, context),
      ],
      onSelected: (route) {
        onPressed(route, context);
      },
    );
  }
}
