// @dart=2.9
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

typedef void OnChange(bool value);

class JSONMessage extends StatelessWidget {
  final AstorComponente schema;
  // final OnPressed onPressed;

  JSONMessage({
    @required this.schema,
    // @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return  showAlertDialog(context);
  }
  Widget showAlertDialog(BuildContext context) {

    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        Provider.of<AstorProvider>(context).reload();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(schema.title),
      content: Text(schema.text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return alert;
  }


}

