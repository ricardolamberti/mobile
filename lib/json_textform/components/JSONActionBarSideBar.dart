
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';
import 'JSONNavigationBar.dart';

typedef OnChange = void Function(bool value);

class JSONActionBarSideBar extends StatelessWidget {
  final AstorComponente schema;
  final OnChange? onSaved;
  final OnPressed onPressed;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   JSONActionBarSideBar({
    Key? key,
    required this.schema,
    required this.onPressed,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<AstorComponente> schemaList = schema.components.first.options;

    return Drawer(
      key: _formKey,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            DataPopUp(schemaList[index], onPressed, context),
        itemCount: schemaList.length,
      ),
    );
  }



}

