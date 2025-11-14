// @dart=2.9
import 'package:astor_mobile/json_textform/components/JSONIcon.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';
import 'JSONDiv.dart';

class JSONLabel extends StatelessWidget {
  final AstorComponente schema;
  final OnBuildBody onBuildBody;

  JSONLabel({
    @required this.schema,
    @required this.onBuildBody,
  });

  @override
  Widget build(BuildContext context) {
    String title ="";
    if (schema.type=="text_label_responsive")
      title=schema.value;
    else
      title = schema.title;
    bool composite = schema.composite;
    double size = schema.sizeHResponsive;
    if (composite) {
      return Column(
        children:  <Widget>[
          ListTile(

            leading: !schema.hasIcon?null:JSONIcon(schema:schema),
            title: title==null?Container():Text (
                title, style: TextStyle (
                fontSize: size
            )
            ),
        ),
            JSONDiv(
              schema: schema,
              useBootstrap: false,
              actionBar: false,
              onBuildBody: onBuildBody,
            )
        ],

      );
    }
    return   ListTile(
      leading: JSONIcon(schema:schema),
      title: title==null?Container():Text (
        title, style: TextStyle (
        fontSize: size
      )
      ),

    );
  }
}
