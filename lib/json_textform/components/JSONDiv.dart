
// import 'package:file_picker/file_picker.dart';
import 'package:astor_mobile/json_textform/models/Controller.dart';
import 'package:astor_mobile/json_textform/models/components/AvaliableWidgetTypes.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../models/components/FileFieldValue.dart';

import '../JSONForm.dart';

typedef OnChange = void Function(FileFieldValue value);

class JSONDiv extends StatelessWidget {
  final AstorComponente schema;

  final Widget? loadingDialog;
  final OnFileUpload? onFileUpload;
  final OnSearch? onSearch;
  final JSONSchemaController? controller;
  final String? schemaName;
  final Map<String, dynamic>? values;
  final OnSubmit? onSubmit;
  final OnBuildBody onBuildBody;
  final bool useBootstrap;
  final bool actionBar;

  const JSONDiv({
    super.key,
    required this.schema,
    required this.onBuildBody,
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

  BoxDecoration? getResponsiveBoxDecoration() {
    String pos = "";
    Color? border;
    Color? fill;
    pos = schema.classResponsive;
    if (pos == "") return null;
    List<String> commands = pos.split(" ");
    for (String command in commands) {
      if (!command.contains("panel-")) {
        continue;
      } else if (command.contains("-heading"))
        fill = Colors.black12;
      else if (command.contains("-footer"))
        fill = Colors.black12;
      else if (command.contains("-primary"))
        border = Colors.blue;
      else if (command.contains("-default"))
        border = Colors.black12;
      else if (command.contains("-danger"))
        border = Colors.red;
      else if (command.contains("-warning"))
        border = Colors.yellow;
      else if (command.contains("-success"))
        border = Colors.green;
      else if (command.contains("-info")) border = Colors.lightBlueAccent;
    }
    if (border != null && fill != null) {
      return BoxDecoration(color: fill, border: Border.all(color: border));
    }
    if (border != null) {
      return BoxDecoration(border: Border.all(color: border));
    }
    if (fill != null) {
      return BoxDecoration(
        color: fill,
      );
    }
    return const BoxDecoration(color: Colors.white);
  }

  String getResponsiveSize(AstorComponente comp) {
    String pos = "";
    String out = "";
    pos = comp.fullClassResponsive;
    if (pos == "") return "";
    List<String> commands = pos.split(" ");
    for (String command in commands) {
      if (command.contains("col-") && !command.contains("offset")) {
        if (command.contains("col-xs-")) {
          out += "$command col-${command.replaceAll(new RegExp(r'[^0-9]'), '')} ";
        } else {
          out += "$command ";
        }
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
      if (!command.contains("offset")) continue;
      out += " offset-";
      if (command.contains("-xs-")) {
        out += "xs-";
      } else if (command.contains("-sm-"))
        out += "sm-";
      else if (command.contains("-md-"))
        out += "md-";
      else if (command.contains("-lg-"))
        out += "lg-";
      else if (command.contains("-xl-")) out += "xl-";
      out += command.replaceAll(RegExp(r'[^0-9]'), '');
    }
    return out;
  }

  bool isAlignRight(AstorComponente comp) {
    if ((comp.classResponsive.contains("text-right"))) {
      return true;
    }
    if ((comp.classResponsive.contains("one-line-right"))) {
      return true;
    }
    if ((comp.classResponsive.contains("pull-right"))) {
      return true;
    }
    return false;
  }

  bool isAlignLeft(AstorComponente comp) {
     if ((comp.classResponsive.contains("text-left"))) {
       return true;
     }
    if ((comp.classResponsive.contains("pull-left"))) {
      return true;
    }
    return false;
  }

  bool isFull(AstorComponente comp) {
    if (comp is AstorList) return true;
    if (comp is AstorTabPanel) return true;
    if ((comp.classResponsive.contains("btn-block"))) {
      return true;
    }
    if ((comp.classTableResponsive.contains("table"))) {
      return true;
    }
    if ((comp.classResponsive.contains("pagination"))) {
      return true;

    }

    return false;
  }
  bool isFormFilter(AstorComponente comp) {
    if ((comp.classResponsive.contains("form-filter"))) {
      return true;
    }
    return false;
  }

  Color? getColorBorder(AstorComponente comp) {
    if ((!comp.classResponsive.contains("btn"))&&(!comp.classResponsive.contains("border"))) {
      return null;
    }
    if (comp.classResponsive.contains("btn-primary") || comp.classResponsive.contains("border-primary")) {
      return Colors.blue;
    }
    if (comp.classResponsive.contains("btn-default") || comp.classResponsive.contains("border-default")) {
      return Colors.black45;
    }
    if (comp.classResponsive.contains("btn-danger") || comp.classResponsive.contains("border-danger")) {
      return Colors.red;
    }
    if (comp.classResponsive.contains("btn-warning") || comp.classResponsive.contains("border-warning")) {
      return Colors.yellow;
    }
    if (comp.classResponsive.contains("btn-success") || comp.classResponsive.contains("border-success")) {
      return Colors.green;
    }
    if (comp.classResponsive.contains("btn-info") || comp.classResponsive.contains("border-info")) {
      return Colors.lightBlueAccent;
    }
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
    Color? color =getColorBorder(schema);
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
    if (isAlignRight(schema)) {
      return Align(
        alignment: Alignment.topRight,
        child: addDiv(context,true,WrapAlignment.end,MainAxisAlignment.end),
      );
    }
    if (isAlignLeft(schema)) {
      return Align(
        alignment: Alignment.topLeft,
        child: addDiv(context,true,WrapAlignment.start,MainAxisAlignment.start),
      );
    }
    if (isFull(schema)) {
      return Padding(padding: const EdgeInsets.only(left: 20, right: 20,),
          child: addDiv(context,false,null,MainAxisAlignment.spaceEvenly));
    }
    return addDiv(context,false,WrapAlignment.center,MainAxisAlignment.center);

  }


  Widget addDiv(BuildContext context,bool forceNoBootstrap,WrapAlignment? aligment,MainAxisAlignment aligmentBar) {
    List<AstorComponente> schemaList = schema.components;
    bool skipBootstrap = forceNoBootstrap;
    if (isFormFilter(schema)) {
      skipBootstrap=true;
    }
    if (useBootstrap && !skipBootstrap) {
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
    } else if (actionBar) return OverflowBar(
        alignment: aligmentBar,
        children: [
          for (AstorComponente schema in schemaList.where((element) =>
          !(!element.isVisibleInContext(context) || element.widget == WidgetType.unknown || element.widget == null)))
            addAlignComponentInternal(schema, context)
        ],
      );
    else return Wrap(
        alignment: aligment ?? WrapAlignment.center,
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
        constraints: const BoxConstraints(minHeight: 80, minWidth: 300,maxHeight: 80, maxWidth: 300),
        child: addComponentInternal(comp,context),
      );
    }
    return addComponentInternal(comp,context);
  }
  Widget addAlignComponentInternal(AstorComponente comp, BuildContext context) {
    if (isAlignRight(comp)) {
      return Align(
        alignment: Alignment.topRight,
        child: addWidthComponentInternal(comp,context),
      );
    }
    if (isAlignLeft(comp)) {
      return Align(
        alignment: Alignment.topLeft,
        child: addWidthComponentInternal(comp,context),
      );
    }
    if (isFull(comp)) {
      return Padding(padding: const EdgeInsets.only(left: 20, right: 20,),
          child: addWidthComponentInternal(comp,context));
    }
    return addWidthComponentInternal(comp, context);

  }

  Widget addComponentInternal(AstorComponente comp, BuildContext context) {
    return onBuildBody(comp);
  }

}
