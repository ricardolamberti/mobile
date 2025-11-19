
import 'package:flutter/material.dart';

import '/json_textform/JSONForm.dart';
import '/json_textform/models/Controller.dart';
import '/json_textform/models/components/Action.dart';
import '/json_textform/models/components/Icon.dart';
import 'package:astor_mobile/model/astorSchema.dart';

/// A JSON Schema Form Widget
/// Which will take a schema input
/// and generate a form
class JSONSchemaForm extends StatelessWidget {
  /// will show this when user try to submit the form
  final Widget? loadingDialog;

  /// Custom Search function. If you want to customize the search results
  /// for your selection page.
  ///
  /// [path] the related model name. Null if it is Select field
  /// [keyword] search keyword by user
  final OnSearch? onSearch;

  /// Whenever user click the button inside filefield,
  /// this function callback will be called
  final OnFileUpload? onFileUpload;

  /// schema controller to control the form
  final JSONSchemaController? controller;

  /// Schema's name
  /// Use this to identify the actions and icons
  /// if foreignkey text field has the same name as the home screen's field.
  /// Default is null
  final String? schemaName;

  /// Schema you want to have. This is a JSON object
  /// Using dart's map data structure
  final AstorComponente schema;

  /// List of actions. Each field will only have one action.
  /// If not, the last one will replace the first one.
  final List<FieldAction>? actions;

  /// List of icons. Each field will only have one icon.
  /// If not, the last one will replace the first one.
  final List<FieldIcon>? icons;

  /// Default values for each field
  final Map<String, dynamic>? values;

  /// Will call this function after user
  /// clicked the submit button
  ///
  /// * [json] A map. keys represent fields' name
  /// and values represent fields' value
  final OnSubmit? onSubmit;

  /// URL for foreignkey
  /// foreignkey field will use this to get editing data
  /// Default is http://0.0.0.0
  final String url;

  const JSONSchemaForm({
    super.key,
    required this.schema,
    this.onSubmit,
    this.icons,
    this.actions,
    this.values,
    this.schemaName,
    this.controller,
    this.url = "http://0.0.0.0",
    this.onFileUpload,
    this.onSearch,
    this.loadingDialog,
  });

  @override
  Widget build(BuildContext context) {
    return JSONForm(
      onSearch: onSearch,
      schema: schema,
      schemaName: schemaName,
      onSubmit: onSubmit,
      icons: icons,
      actions: actions,
      values: values,
      controller: controller,
      onFileUpload: onFileUpload,
      loadingDialog: loadingDialog,
    );
  }
}
