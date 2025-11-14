
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/json_textform/components/JSONDropDownButton.dart';
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

class JSONWinListFlat extends StatefulWidget implements InterfaceProvider {
  final AstorList schema;
  final OnChange onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  bool isMultiple = false;
  bool clearSelection = false;

  JSONWinListFlat({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
    this.onSaved,
  });
  @override
  _JSONWinListFlatState createState() => _JSONWinListFlatState();

  @override
  bool getClearSelection() {
    return clearSelection;
  }

  @override
  String getCurrentActionOwner() {
    if (isMultiple)
      return getSingleActionOwnerList();
    return getMultipleActionOwnerList();
  }

  @override
  String getCurrentActionOwnerFromSelect() {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      return schemaRows.id;
    }
    return null;
  }

  String getSingleActionOwnerList() {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      return schemaRows.id;
    }
    return '';
  }
  @override
  String getMultipleActionOwnerList() {
    String output="";
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      output+= schemaRows.id+';';
    }
    return output;
  }


  @override
  String getMultipleCurrentActionOwnerDest() {
    return '';
  }

  @override
  String getSelectedCell() {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      return schemaRows.cells.values.first.axis; // no soportado aun
    }
    return null;
  }

  @override
  String getSelectedRow() {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      return schemaRows.rowpos;
    }
    return null;
  }

  @override
  String getSelection() {
    return getMultipleActionOwnerList();
  }

  @override
  String getSelectionSpecial(String specialselector) {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selectedSpecial) continue;
      return schemaRows.id;
    }
    return '';
  }

  @override
  bool hasMoreSelections() {
    return schema.hasMoreSelection;
  }

  @override
  bool hasMultipleSelect() {
    int l=0;
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      l++;
    }
    return l>1;
  }

  @override
  bool hasMultipleSelectSpecial(String specialselector) {
    int l=0;
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selectedSpecial) continue;
      l++;
    }
    return l>1;
  }

}

class _JSONWinListFlatState extends State<JSONWinListFlat> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  _JSONWinListFlatState();

  List<AstorComponente> schemaList = [];

  @override
  void initState() {
    super.initState();
    updateActions(false);
  }

  updateActions(bool refresh) {

    widget.schema.updateActions(refresh,Provider.of<AstorProvider>(context,listen: false).astorApp);
    if (refresh)
      setState(() {});
  }

  void select(AstorRow schemaRow) {
    checkSelectAll=false;
    widget.schema.select(schemaRow);
    updateActions(true);
  }
  void selectAll(bool isSelected) {
    checkSelectAll = isSelected;
    widget.schema.selectAll(isSelected);
    updateActions(true);
  }


  List<DataColumn> fillColumn() {
    List<DataColumn> list=[];
    for (var schemaColumn in widget.schema.columns.values)
      list.add(DataColumn(
        label: Text(schemaColumn.title),
        numeric: false,
      ));

  return list;
  }
  bool checkSelectAll=false;

  @override
  Widget build(BuildContext context) {
    bool isMultiple = widget.schema.multiselect;
    double zheight =250;
    return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
      Padding(
          padding:  const EdgeInsets.all(2.0),
          child: IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex:1,
                  child:Container(
                  height:40,
                  width: 20,
                  child: CheckboxListTile(
                        value: checkSelectAll,
                        onChanged: (isSelected) {
                          selectAll(isSelected);
                      }
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    )
                  )
                ),
                for (var schemaColumn in widget.schema.columns.values)
                  (schemaColumn.type != "JWINFORM")?Expanded(
                      flex: 2,
                      child: Container(
                          height:40,
                          width: 20,
                          child: Text(schemaColumn.title),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          )
                      )
                  ):
                  Expanded(
                    flex: 9,
                    child: Container(
                      height:40,
                      width: double.maxFinite,
                      child:
                      JSONDiv(
                        schema: schemaColumn,
                        useBootstrap: true,
                        actionBar: false,
                        onBuildBody: widget.onBuildBody,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      )
                    )
                  ),
              ]
          ),
        )
      ),
      for (var schemaRows in widget.schema.rows.values)
        Padding(
          padding:  const EdgeInsets.all(2.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              key: ValueKey(schemaRows.rowpos),
              children: [
                Expanded(
                  flex: 1,
                  child:Container(
                    height: zheight,
                    width: 20,
                    child: CheckboxListTile(
                        value: schemaRows.selected,
                        onChanged: (value) {
                          select(schemaRows);
                        }
                    ),
                      decoration: BoxDecoration(
                        color: schemaRows.selected?Colors.blue: Colors.white,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      )
                  )
                ),
                for (AstorCell schemaCell in schemaRows.cells.values)
                  (schemaCell.type != "JWINFORM")? Expanded(
                      flex: 2,
                      child:
                      Container(
                          height: zheight, //bug, si lo saco explota, si no, no ajusta al contenido
                          width: 10,
                          child:
                          (schemaCell.type == "JICON") ?
                          JSONIcon(schema: schemaCell)
                              : (schemaCell.type == "JLINK") ?
                          JSONDropDownButton(
                            schema: schemaCell,
                            onBuildBody: widget.onBuildBody,
                            onPressed: widget.onPressed,
                          )
                              : Text(schemaCell.value),
                          decoration: BoxDecoration(
                            color:  schemaRows.selected?Colors.blue:Colors.white,

                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          )
                      )
                  ):
                  Expanded(
                    flex: 9,
                    child:
                    Container(
                      height: zheight, //bug, si lo saco explota, si no, no ajusta al contenido
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child:JSONDiv(
                          schema: schemaCell,
                          useBootstrap: true,
                          actionBar: false,
                          onBuildBody: widget.onBuildBody,
                        )
                      ),
                      decoration: BoxDecoration(
                        color:  schemaRows.selected?Colors.blue:Colors.white,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      )
                    )
                  )
              ],
            )
        )
      )
    ]
    );
  }

}

