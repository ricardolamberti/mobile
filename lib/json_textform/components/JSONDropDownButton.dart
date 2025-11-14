// @dart=2.9
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/json_textform/models/components/AvaliableWidgetTypes.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONIcon.dart';

typedef void OnChange(bool value);

class JSONDropDownButton extends StatelessWidget {
  final AstorComponente schema;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  bool everyVisible=false;

  JSONDropDownButton({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
    this.everyVisible=false,
  });

  PopupMenuItem<AstorComponente> _buildTiles(AstorComponente root,BuildContext context) {
    String label = "";
    AstorComponente rootButton;
    if (root.widget==WidgetType.li) {
      rootButton = root.components.first;
    } else{
      rootButton = root;

    }
    label = rootButton.label;
    String action = root.name.substring(root.name.lastIndexOf("-")+1);

    bool visible = everyVisible?true:Provider.of<AstorProvider>(context,listen: false).astorApp.getObjAction(action);

    PopupMenuItem<AstorComponente> popup= PopupMenuItem(
        child: Text(label),
        value: rootButton,
        enabled: visible==null?true:visible,
      );

    if (visible==null && !everyVisible)  Provider.of<AstorProvider>(context,listen: false).astorApp.addObjAction(action,false);
    return popup;
  }

  @override
  Widget build(BuildContext context) {
    String label = schema.label;
    var items=schema.components.where((element) => (element.widget == WidgetType.li || element.widget == WidgetType.button)).toList();
    return items.isEmpty?Container(): PopupMenuButton<AstorComponente>(
        itemBuilder: (BuildContext bc) => [
              for (var option in items)
                _buildTiles(option,context)
          ],
          onSelected: (route) {
            onPressed(route,context);
          }
    );
  }



}

