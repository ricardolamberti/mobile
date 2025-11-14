
import 'dart:io';

// import 'package:file_picker/file_picker.dart';
import 'package:astor_mobile/json_textform/components/JSONActionBar.dart';
import 'package:astor_mobile/json_textform/components/JSONActionBarSideBar.dart';
import 'package:astor_mobile/json_textform/components/JSONButton.dart';
import 'package:astor_mobile/json_textform/components/JSONFieldset.dart';
import 'package:astor_mobile/json_textform/models/Controller.dart';
import 'package:astor_mobile/json_textform/models/components/Action.dart';
import 'package:astor_mobile/json_textform/models/components/AvaliableWidgetTypes.dart';
import 'package:astor_mobile/json_textform/models/components/Icon.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../models/components/FileFieldValue.dart';
import '../utils-components/OutlineButtonContainer.dart';

import '../JSONForm.dart';
import '../utils.dart';
import '/json_textform/components/JSONCheckboxField.dart';
import '/json_textform/components/JSONDateTimeField.dart';
import '/json_textform/components/JSONFileField.dart';
import '/json_textform/components/JSONSelectField.dart';
import '/json_textform/components/JSONTextFormField.dart';
import 'JSONDropDownButton.dart';
import 'JSONIcon.dart';
import 'JSONInfoCard.dart';
import 'JSONLabel.dart';
import 'JSONWinList.dart';
import 'JSONNavigationBar.dart';

typedef void OnChange(FileFieldValue value);

class JSONDiv extends StatelessWidget {
  final AstorComponente schema;

  final Widget loadingDialog;
  final OnFileUpload onFileUpload;
  final OnSearch onSearch;
  final JSONSchemaController controller;
  final String schemaName;
  final Map<String, dynamic> values;
  final OnSubmit onSubmit;
  final OnBuildBody onBuildBody;
  bool useBootstrap = true;
  bool actionBar = true;

  JSONDiv({
    @required this.schema,
    @required this.onBuildBody,
    this.values,
    this.schemaName,
    this.controller,
    this.loadingDialog,
    this.onSearch,
    this.onSubmit,
    this.onFileUpload,
    this.useBootstrap = true,
    this.actionBar = false,
  });

  BoxDecoration getResponsiveBoxDecoration() {
    String pos = "";
    Color border = null;
    Color fill = null;
    pos = schema.classResponsive;
    if (pos == "") return null;
    List<String> commands = pos.split(" ");
    for (String command in commands) {
      if (command.indexOf("panel-") == -1)
        continue;
      else if (command.indexOf("-heading") != -1)
        fill = Colors.black12;
      else if (command.indexOf("-footer") != -1)
        fill = Colors.black12;
      else if (command.indexOf("-primary") != -1)
        border = Colors.blue;
      else if (command.indexOf("-default") != -1)
        border = Colors.black12;
      else if (command.indexOf("-danger") != -1)
        border = Colors.red;
      else if (command.indexOf("-warning") != -1)
        border = Colors.yellow;
      else if (command.indexOf("-success") != -1)
        border = Colors.green;
      else if (command.indexOf("-info") != -1) border = Colors.lightBlueAccent;
    }
    if (border != null && fill != null)
      return BoxDecoration(
          color: fill,
          border: Border.all(color: border)
      );
    if (border != null)
      return BoxDecoration(
          border: Border.all(color: border)
      );
    if (fill != null)
      return BoxDecoration(
        color: fill,
      );
    return BoxDecoration(color: Colors.white);
  }

  String getResponsiveSize(AstorComponente comp) {
    String pos = "";
    String out = "";
    pos = comp.fullClassResponsive;
    if (pos == "") return "";
    List<String> commands = pos.split(" ");
    for (String command in commands) {
      if (command.indexOf("col-") != -1 && command.indexOf("offset") == -1) {
        if (command.indexOf("col-xs-")!=-1) {
          out += command + " col-"+command.replaceAll(new RegExp(r'[^0-9]'), '')+" ";
        } else
          out += command + " ";
      }
    }
    return out;
  }

  String getResponsiveOffset(AstorComponente comp) {
    String pos = "";
    String out = "";
    pos = comp.fullClassResponsive;
    if (pos == "") return "";
    List<String> commands = pos.split(" ");
    for (String command in commands) {
      if (command.indexOf("offset") == -1) continue;
      out += " offset-";
      if (command.indexOf("-xs-") != -1)
        out += "xs-";
      else if (command.indexOf("-sm-") != -1)
        out += "sm-";
      else if (command.indexOf("-md-") != -1)
        out += "md-";
      else if (command.indexOf("-lg-") != -1)
        out += "lg-";
      else if (command.indexOf("-xl-") != -1) out += "xl-";
      out += command.replaceAll(new RegExp(r'[^0-9]'), '');
    }
    return out;
  }

  bool isAlignRight(AstorComponente comp) {
    if ((comp.classResponsive.indexOf("text-right") != -1))
      return true;
    if ((comp.classResponsive.indexOf("one-line-right") != -1))
      return true;
    if ((comp.classResponsive.indexOf("pull-right") != -1))
      return true;
    return false;
  }

  bool isAlignLeft(AstorComponente comp) {
     if ((comp.classResponsive.indexOf("text-left") != -1))
      return true;
    if ((comp.classResponsive.indexOf("pull-left") != -1))
      return true;
    return false;
  }

  bool isFull(AstorComponente comp) {
    if (comp is AstorList) return true;
    if (comp is AstorTabPanel) return true;
    if ((comp.classResponsive.indexOf("btn-block") != -1))
      return true;
    if ((comp.classTableResponsive.indexOf("table") != -1))
      return true;
    if ((comp.classResponsive.indexOf("pagination") != -1)) {
      return true;

    }

    return false;
  }
  bool isFormFilter(AstorComponente comp) {
    if ((comp.classResponsive.indexOf("form-filter") != -1)) {
      return true;
    }
    return false;
  }

  Color getColorBorder(AstorComponente comp) {
    if ((comp.classResponsive.indexOf("btn") == -1)&&(comp.classResponsive.indexOf("border") == -1)) {
      return null;
    }
    if (comp.classResponsive.indexOf("btn-primary") != -1 || comp.classResponsive.indexOf("border-primary") != -1)
      return Colors.blue;
    if (comp.classResponsive.indexOf("btn-default") != -1 || comp.classResponsive.indexOf("border-default") != -1)
      return Colors.black45;
    if (comp.classResponsive.indexOf("btn-danger") != -1 || comp.classResponsive.indexOf("border-danger") != -1)
      return Colors.red;
    if (comp.classResponsive.indexOf("btn-warning") != -1 || comp.classResponsive.indexOf("border-warning") != -1)
     return Colors.yellow;
    if (comp.classResponsive.indexOf("btn-success") != -1 || comp.classResponsive.indexOf("border-success") != -1)
     return Colors.green;
    if (comp.classResponsive.indexOf("btn-info") != -1 || comp.classResponsive.indexOf("border-info") != -1)
      return Colors.lightBlueAccent;
    return null;
  }


  @override
  Widget build(BuildContext context) {
    bool visible = schema.isVisibleInContext(context);
    return Visibility(
        visible: visible,
        child: addBorder(context),
    );
  }

  Widget addBorder(BuildContext context) {
    Color color =getColorBorder(schema);
    if (color!=null) {
      return Container(
        decoration:  BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),

        ),
        child: addAlignDiv(context),
      );
    }
    return addAlignDiv(context);
  }
  Widget addAlignDiv(BuildContext context) {
    if (isAlignRight(schema))
      return Align(
        alignment: Alignment.topRight,
        child: addDiv(context,true,WrapAlignment.end,MainAxisAlignment.end),
      );
    if (isAlignLeft(schema))
      return Align(
        alignment: Alignment.topLeft,
        child: addDiv(context,true,WrapAlignment.start,MainAxisAlignment.start),
      );
    if (isFull(schema))
      return Padding(padding: EdgeInsets.only(left: 20, right: 20,),
          child: addDiv(context,false,null,MainAxisAlignment.spaceEvenly));
    return addDiv(context,false,WrapAlignment.center,MainAxisAlignment.center);

  }


  Widget addDiv(BuildContext context,bool forceNoBootstrap,WrapAlignment aligment,MainAxisAlignment aligmentBar) {
    List<AstorComponente> schemaList = schema.components;
    if (isFormFilter(schema)) {
      forceNoBootstrap=true;
    }
    if (useBootstrap && !forceNoBootstrap) {
      return BootstrapRow(
        height: 60,
        decoration: getResponsiveBoxDecoration(),
        children: [
          for (AstorComponente schema in schemaList.where((element) =>
          !(!element.isVisibleInContext(context) || element.widget == WidgetType.unknown || element.widget == null)))
            BootstrapCol(
              sizes: getResponsiveSize(schema),
              offsets: getResponsiveOffset(schema),
              child: addAlignComponentInternal(schema, context),
            )
        ],
      );
    } else if (actionBar) return ButtonBar(
        alignment: aligmentBar,
        children: [
          for (AstorComponente schema in schemaList.where((element) =>
          !(!element.isVisibleInContext(context) || element.widget == WidgetType.unknown || element.widget == null)))
            addAlignComponentInternal(schema, context)
        ],
      );
    else return Wrap(
        alignment: aligment,
        children: [
          for (AstorComponente schema in schemaList.where((element) =>
          !(!element.isVisibleInContext(context) || element.widget == WidgetType.unknown || element.widget == null)))
            addAlignComponentInternal(schema, context)
        ],
      );
  }
  Widget addWidthComponentInternal(AstorComponente comp, BuildContext context) {
    if (comp.inline && comp.visible) {
      return Container(
        padding: const EdgeInsets.all(0),
        constraints: BoxConstraints(minHeight: 80, minWidth: 300,maxHeight: 80, maxWidth: 300),
        child: addComponentInternal(comp,context),
      );
    }
    return addComponentInternal(comp,context);
  }
  Widget addAlignComponentInternal(AstorComponente comp, BuildContext context) {
    if (isAlignRight(comp))
      return Align(
        alignment: Alignment.topRight,
        child: addWidthComponentInternal(comp,context),
      );
    if (isAlignLeft(comp))
      return Align(
        alignment: Alignment.topLeft,
        child: addWidthComponentInternal(comp,context),
      );
    if (isFull(comp))
      return Padding(padding: EdgeInsets.only(left: 20, right: 20,),
          child: addWidthComponentInternal(comp,context));
    return addWidthComponentInternal(comp, context);

  }

  Widget addComponentInternal(AstorComponente comp, BuildContext context) {
    return onBuildBody(comp);
  }

}
