import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import '../JSONForm.dart';

class JSONSubForm extends StatelessWidget implements InterfaceProvider {
  final AstorComponente schema;

  final Widget? loadingDialog;
  final OnFetchingSchema? onFetchingSchema;
  final OnFetchforeignKeyChoices? onFetchforeignKeyChoices;
  final OnUpdateforeignKeyField? onUpdateforeignKeyField;
  final OnAddforeignKeyField? onAddforeignKeyField;
  final OnFileUpload? onFileUpload;
  final OnDeleteforeignKeyField? onDeleteforeignKeyField;
  final OnSearch? onSearch;
  final JSONSchemaController? controller;
  final String? schemaName;
  final Map<String, dynamic>? values;
  final OnSubmit? onSubmit;
  final OnBuildBody onBuildBody;
  final bool useBootstrap;
  final bool inline;

  const JSONSubForm({
    Key? key,
    required this.schema,
    required this.onBuildBody,
    this.values,
    this.schemaName,
    this.controller,
    this.loadingDialog,
    this.onSearch,
    this.onSubmit,
    this.onFetchingSchema,
    this.onFetchforeignKeyChoices,
    this.onUpdateforeignKeyField,
    this.onAddforeignKeyField,
    this.onFileUpload,
    this.onDeleteforeignKeyField,
    this.useBootstrap = true,
    this.inline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schemaList = schema.components;
    if (useBootstrap) {
      return BootstrapRow(
        height: 60,
        children: [
          for (final schema in schemaList.where(
            (element) =>
                element.widget != WidgetType.unknown && element.widget != null,
          ))
            BootstrapCol(
              sizes: schema.sizeResponsive,
              child: onBuildBody(schema),
            )
        ],
      );
    } else if (inline) {
      return ButtonBar(
        children: [
          for (final schema in schemaList.where(
            (element) =>
                element.widget != WidgetType.unknown && element.widget != null,
          ))
            onBuildBody(schema)
        ],
      );
    } else {
      return Column(
        children: [
          for (final schema in schemaList.where(
            (element) =>
                element.widget != WidgetType.unknown && element.widget != null,
          ))
            onBuildBody(schema)
        ],
      );
    }
  }

  @override
  bool getClearSelection() {
    return false;
  }

  @override
  String? getCurrentActionOwner() {
    return schema.actionOwner;
  }

  @override
  String? getCurrentActionOwnerFromSelect() {
    return schema.actionOwner;
  }

  @override
  String? getMultipleActionOwnerList() {
    return '';
  }

  @override
  String? getMultipleCurrentActionOwnerDest() {
    return null;
  }

  @override
  String? getSelectedCell() {
    return '';
  }

  @override
  String? getSelectedRow() {
    return '';
  }

  @override
  String? getSelection() {
    return '';
  }

  @override
  String? getSelectionSpecial(String specialselector) {
    return '';
  }

  @override
  bool hasMoreSelections() {
    return false;
  }

  @override
  bool hasMultipleSelect() {
    return false;
  }

  @override
  bool hasMultipleSelectSpecial(String specialselector) {
    return false;
  }
}
