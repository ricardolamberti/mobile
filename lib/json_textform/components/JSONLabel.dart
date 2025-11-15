
import 'package:astor_mobile/json_textform/components/JSONIcon.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';
import 'JSONDiv.dart';

class JSONLabel extends StatelessWidget {
  final AstorComponente schema;
  final OnBuildBody onBuildBody;

  const JSONLabel({
    Key? key,
    required this.schema,
    required this.onBuildBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? title;
    if (schema.type == "text_label_responsive") {
      title = schema.value;
    } else {
      title = schema.title;
    }
    final bool composite = schema.composite == true;
    final double? size = schema.sizeHResponsive;
    if (composite) {
      return Column(
        children: <Widget>[
          ListTile(
            leading: schema.hasIcon == true ? JSONIcon(schema: schema) : null,
            title: title == null
                ? Container()
                : Text(
                    title,
                    style: TextStyle(fontSize: size),
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
    return ListTile(
      leading: JSONIcon(schema: schema),
      title: title == null
          ? Container()
          : Text(
              title,
              style: TextStyle(fontSize: size),
            ),
    );
  }
}
