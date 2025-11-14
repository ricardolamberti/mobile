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
import 'JSONNavigationBar.dart';

typedef void OnChange(bool value);

class JSONActionBarSideBar extends StatelessWidget {
  final AstorComponente schema;
  final OnChange onSaved;
  final OnPressed onPressed;
  final _formKey = GlobalKey<FormState>();

  JSONActionBarSideBar({
    @required this.schema,
    @required this.onPressed,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    List<AstorComponente> schemaList = schema.components.first.options;

    return  Drawer(
      key: _formKey,
      child: ListView.builder(

        itemBuilder: (BuildContext context, int index) =>
            DataPopUp(schemaList[index],onPressed,context),
        itemCount: schemaList.length,

      )
    );
  }



}

