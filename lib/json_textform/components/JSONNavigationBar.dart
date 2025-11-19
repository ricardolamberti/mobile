
import 'package:astor_mobile/json_textform/models/Controller.dart';
import 'package:astor_mobile/json_textform/models/components/Action.dart';
import 'package:astor_mobile/json_textform/models/components/AvaliableWidgetTypes.dart';
import 'package:astor_mobile/json_textform/models/components/Icon.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';
import 'JSONIcon.dart';

class JSONNavigationBar extends StatefulWidget {
  final AstorComponente schema;
  final JSONSchemaController? controller;
  final String? schemaName;
  final List<FieldAction>? actions;
  final List<FieldIcon>? icons;
  final Map<String, dynamic>? values;
  final OnPressed onPressed;

  const JSONNavigationBar({
    super.key,
    required this.schema,
    required this.onPressed,
    this.icons,
    this.actions,
    this.values,
    this.schemaName,
    this.controller,
  });

  @override
  JSONNavigationBarState createState() => JSONNavigationBarState();
}

class JSONNavigationBarState extends State<JSONNavigationBar> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<AstorComponente> schemaList = [];

  JSONNavigationBarState();

  @override
  void initState() {
    super.initState();
    _init();
  }


  List<AstorComponente> _init() {
    schemaList = widget.schema.components.first.options;

    return schemaList;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.schema.value ?? ''}'),
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              DataPopUp(schemaList[index], widget.onPressed, context),
          itemCount: schemaList.length,
        ),
      ),
    );
  }
}



class DataPopUp extends StatelessWidget {
  const DataPopUp(this.popup, this.onPressed, this.context, {super.key});

  final AstorComponente popup;
  final OnPressed onPressed;
  final BuildContext context;

  Widget addMenuItem(AstorComponente root) {
    return TextButton(
      onPressed: () {
        onPressed(root, context);
      },
      child: ListTile(
        title: Text(root.label),
        leading: JSONIcon(schema: root),
      ),
    );
  }

  Widget _buildTiles(AstorComponente root) {
    if (root.widget == WidgetType.button) return addMenuItem(root);
    if (root.widget == WidgetType.url) return addMenuItem(root);
    if (root.widget == WidgetType.li) {
      return addMenuItem(root.components.first);
    }
    if (root.type == WidgetType.li) {
      return addMenuItem(root.components.first);
    }
    return ExpansionTile(
      key: PageStorageKey<AstorComponente>(root),
      title: Text(root.label),
      children: root.components.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(popup);
  }
}

