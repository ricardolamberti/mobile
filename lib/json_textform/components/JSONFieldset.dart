
import 'dart:io';

// import 'package:file_picker/file_picker.dart';
import 'package:astor_mobile/json_textform/components/JSONButton.dart';
import 'package:astor_mobile/json_textform/components/JSONFieldset.dart';
import 'package:astor_mobile/json_textform/models/Controller.dart';
import 'package:astor_mobile/json_textform/models/components/Action.dart';
import 'package:astor_mobile/json_textform/models/components/AvaliableWidgetTypes.dart';
import 'package:astor_mobile/json_textform/models/components/Icon.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../models/components/FileFieldValue.dart';
import '../utils-components/OutlineButtonContainer.dart';

import '../JSONForm.dart';
import 'JSONDiv.dart';
import 'JSONInfoCard.dart';
import 'JSONWinList.dart';
import 'JSONNavigationBar.dart';

typedef void OnChange(bool value);

class JSONFieldset extends StatelessWidget {
  final AstorComponente schema;
  final bool filled;
  final bool rounded;
  final bool showSubmitButton;
  final bool useRadioButton;

  final Widget loadingDialog;
  final OnFetchingSchema onFetchingSchema;
  final OnFetchforeignKeyChoices onFetchforeignKeyChoices;
  final OnUpdateforeignKeyField onUpdateforeignKeyField;
  final OnAddforeignKeyField onAddforeignKeyField;
  final OnFileUpload onFileUpload;
  final OnDeleteforeignKeyField onDeleteforeignKeyField;

  final OnSearch onSearch;
  final bool useDialog;
  final JSONSchemaController controller;
  final String schemaName;
  final List<FieldAction> actions;
  final List<FieldIcon> icons;
  final Map<String, dynamic> values;
  final OnSubmit onSubmit;
  final bool useDropdownButton;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  JSONFieldset({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
    this.rounded = false,
    this.filled = false,
    this.icons,
    this.actions,
    this.values,
    this.schemaName,
    this.controller,
    this.useDropdownButton,
    this.useRadioButton,
    this.loadingDialog,
    this.showSubmitButton,
    this.onSearch,
    this.useDialog,
    this.onSubmit, this.onFetchingSchema, this.onFetchforeignKeyChoices, this.onUpdateforeignKeyField, this.onAddforeignKeyField, this.onFileUpload, this.onDeleteforeignKeyField,
  });

  @override
  Widget build(BuildContext context) {
    bool visible = schema.visible;
    return Visibility(
      visible: visible,
      child:addFieldset(context),
    );
  }


  Widget addFieldset(BuildContext context) {
    final String title = schema.title;
    final String subtitle = schema.labelRight;
    if (title==null) {
      return JSONDiv(
         onBuildBody: onBuildBody,
         schema: schema,
      );
    }
    return ExpansionTile(
      initiallyExpanded: schema.initiallyExpanded,
      onExpansionChanged: (value) => schema.initiallyExpanded=value,
      title: Text(
        title,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      ),
      subtitle: (subtitle==null)?Text(""):Text(
          subtitle,
          style: TextStyle(fontSize: 14.0),
        ),
      children: <Widget>[
        JSONDiv(
          onBuildBody: onBuildBody,
          schema: schema,
        )
      ],
    );
  }


}

