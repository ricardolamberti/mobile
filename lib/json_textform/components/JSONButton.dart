
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONIcon.dart';

typedef void OnChange(bool value);

class JSONButton extends StatelessWidget {
  final AstorComponente schema;
  final OnChange onSaved;
  final OnPressed onPressed;

  JSONButton({
    @required this.schema,
    @required this.onPressed,
    this.onSaved,
  });

  ButtonStyle getResponsiveBoxButtonStyle() {
    String pos = "";
    Color fore = Colors.blue;
    Color fill = null;
    Color border = null;
    pos = schema.classResponsive;
    if (pos == "") return null;
    List<String> commands = pos.split(" ");
    for (String command in commands) {
      if (command.indexOf("btn-") == -1)
        continue;
      if (command.indexOf("-outline") != -1) {
        fore = Colors.blue;
        fill=null;
        border=Colors.blue;
      }
      if (command.indexOf("-primary") != -1) {
        fill = Colors.blue;
        fore = Colors.white;
        border=Colors.blue;
      }
      else if (command.indexOf("-default") != -1) {
        fill = Colors.white;
        fore = Colors.black87;
        border=Colors.black45;
      } else if (command.indexOf("-danger") != -1){
        fill = Colors.red;
        border=Colors.red;
        fore = Colors.white;
      } else if (command.indexOf("-warning") != -1){
        fill = Colors.yellow;
        border=Colors.yellow;
        fore = Colors.white;
      } else if (command.indexOf("-success") != -1){
        fill = Colors.green;
        border=Colors.green;
        fore = Colors.white;
      } else if (command.indexOf("-info") != -1){
        fill = Colors.lightBlueAccent;
        border=Colors.lightBlueAccent;
        fore = Colors.white;
      }
    }
    if (fill!=null)
      return ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(schema.modeButton=='button'?30.0:5.0),
                  side: BorderSide(color: border),
              ),
          ),
          backgroundColor: MaterialStateProperty.all(fill),
          foregroundColor: MaterialStateProperty.all(fore),
      );
    if (border==true)
      return ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(schema.modeButton=='button'?30.0:5.0),
                  side: BorderSide(color: border),
              )
          ),
          foregroundColor: MaterialStateProperty.all(fore),
    );
   return ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),

    );
  }


  @override
  Widget build(BuildContext context) {
      return  addButton(context);
  }
  Widget addButton(BuildContext context) {
    if (schema.isGroupButtonWithIcon||schema.isCollapsableButtonWithIcon||schema.isButtonWithIcon) {
      return Center( child:TextButton.icon(
          icon: JSONIcon(schema: schema),
          label: Text("${schema.label}",
               style: TextStyle(fontSize: 15)),
          style: getResponsiveBoxButtonStyle(),
          onPressed: () {
            onPressed(schema,context);
          }
      ));
    }
    if (schema.isGroupButtonWithinIcon||schema.isCollapsableButtonWithinIcon||schema.isButtonWithinIcon) {
      return TextButton(
          child: Text("${schema.label}",
          style: TextStyle(fontSize: 15)),
          style: getResponsiveBoxButtonStyle(),
          onPressed: () {
            onPressed(schema,context);
          }
      );
    }
    return TextButton(
        child: Text("${schema.label}",style: TextStyle(fontSize: 15)),
        onPressed: () {
          onPressed(schema,context);
        }
    );

  }



}

