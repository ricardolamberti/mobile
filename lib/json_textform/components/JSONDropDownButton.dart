
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
    Key? key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.everyVisible = false,
  }) : super(key: key);

  PopupMenuItem<AstorComponente> _buildTiles(AstorComponente root, BuildContext context) {
    AstorComponente rootButton;
    if (root.widget == WidgetType.li) {
      rootButton = root.components.first;
    } else {
      rootButton = root;
    }
    String label = rootButton.label;
    String action = root.name.substring(root.name.lastIndexOf("-") + 1);

    bool? visible = everyVisible
        ? true
        : Provider.of<AstorProvider>(context, listen: false)
            .astorApp
            .getObjAction(action);

    PopupMenuItem<AstorComponente> popup = PopupMenuItem(
      child: Text(label),
      value: rootButton,
      enabled: visible ?? true,
    );

    if (visible == null && !everyVisible) {
      Provider.of<AstorProvider>(context, listen: false)
          .astorApp
          .addObjAction(action, false);
    }
    return popup;
  }

  @override
  Widget build(BuildContext context) {
    var items = schema.components
        .where((element) =>
            (element.widget == WidgetType.li || element.widget == WidgetType.button))
        .toList();
    return items.isEmpty
        ? const SizedBox.shrink()
        : PopupMenuButton<AstorComponente>(
            itemBuilder: (BuildContext bc) => [
              for (var option in items) _buildTiles(option, context)
            ],
            onSelected: (route) {
              onPressed(route, context);
            },
          );
  }



}

