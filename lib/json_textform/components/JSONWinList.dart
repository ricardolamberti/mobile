// @dart=2.9
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/json_textform/components/JSONDropDownButton.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONColor.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

typedef void OnChange(bool value);

class JSONWinList extends StatefulWidget implements InterfaceProvider {
  final AstorList schema;
  final OnChange onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  bool isMultiple = false;
  bool clearSelection = false;

  JSONWinList({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
    this.onSaved,
  });
  @override
  _JSONWinListState createState() => _JSONWinListState();

  @override
  bool getClearSelection() {
    return clearSelection;
  }

  @override
  String getCurrentActionOwner() {
    if (!isMultiple)
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

class _JSONWinListState extends State<JSONWinList> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  _JSONWinListState();

  List<AstorComponente> schemaList = [];

  @override
  void initState() {
    super.initState();
    updateActions(false);

  }

  List<DataColumn> fillColumn() {
    List<DataColumn> list=[];
    for (var schemaColumn in widget.schema.columns.values) {
      String title = schemaColumn.title;
      list.add(DataColumn(
          label: Text(title),
          numeric: false,
          tooltip: title,
          )
      );
    }
    return list;
  }
  updateActions(bool refresh) {

    widget.schema.updateActions(refresh,Provider.of<AstorProvider>(context,listen: false).astorApp);
    if (refresh)
      setState(() {});
  }
  void forceSelect(AstorRow schemaRow) {
    widget.schema.forceSelect(schemaRow);
   updateActions(false);
  }
  void select(AstorRow schemaRow) {
    widget.schema.select(schemaRow);
    updateActions(true);
  }
  void selectAll(bool isSelected) {
    widget.schema.selectAll(isSelected);
    updateActions(true);
  }


  List<DataRow> fillRows() {
    bool isMultiple = widget.schema.multiselect;
    List<DataRow> rows = [];
    for (var schemaRows in widget.schema.rows.values){
      rows.add(
        DataRow(
          // index: item.id, // for DataRow.byIndex
        key: ValueKey(schemaRows.rowpos),
        selected: schemaRows.selected,

        onSelectChanged: (bool isSelected) {
          select(schemaRows);
        },
        color: MaterialStateColor.resolveWith((Set<MaterialState> states) => states.contains(MaterialState.selected)
            ? Colors.lightBlue
            : Color.fromARGB(100, 215, 217, 219)
        ),
        cells: [
          for (AstorCell schemaCell in schemaRows.cells.values)
            DataCell(
              (schemaCell.type=="JLINK") ?
              JSONDropDownButton(
                schema: schemaCell,
                onBuildBody: widget.onBuildBody,
                onPressed: widget.onPressed,
                everyVisible: true,
              )
                  :(schemaCell.composite==true) ?
              OverflowBox( child:
                JSONDiv(
                  schema: schemaCell,
                  useBootstrap: false,
                  actionBar: true,
                  onBuildBody: widget.onBuildBody,
                ),
               ): (schemaCell.type=="JCOLOUR") ?
              JSONColorField(schema: schemaCell,inList: true)
                  : (schemaCell.type=="JIMAGE") ?
              JSONIcon(schema: schemaCell)
                  : (schemaCell.type=="JICON") ?
             JSONIcon(schema: schemaCell)
                 :(schemaCell.type=="JBOOLEAN") ?
              JSONIcon(schema: schemaCell)
                  :Text(schemaCell.value),
              placeholder: false,
              showEditIcon: false,
              onTap: () {
                  select(schemaRows);
              },
              onDoubleTap: () {
                forceSelect(schemaRows);
                widget.onPressed(widget.schema,context);
              },
              onLongPress: () {
                forceSelect(schemaRows);
                widget.onPressed(widget.schema,context);
              },

            )

          ],
       )
      );
    }

    return rows;

  }
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width<700||MediaQuery.of(context).size.width<widget.schema.columns.length*50) // trucho, por no poder calcular cuanto va a medir la tabla a priori
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:addDataTable(context),
       );
    else
      return addDataTable(context);
  }

  Widget addDataTable(BuildContext context) {
    bool isMultiple = widget.schema.multiselect;
    if (widget.schema.columns.isEmpty) {
      return Container();
    }
    return DataTable(
      // sortColumnIndex: _sortColumnIndex,
      // sortAscending: _sortAscending,
      columnSpacing: 0,
      dividerThickness: 5,
      onSelectAll: (bool isSelected) {
        selectAll(isSelected);
      },
      decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 1)),
      dataRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => states.contains(MaterialState.selected)
          ? Colors.blue
          : Color.fromARGB(100, 215, 217, 219)
      ),
      dataRowHeight: 40,
      dataTextStyle: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
      headingRowHeight: 40,
      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      horizontalMargin: 10,
      showBottomBorder: true,
      showCheckboxColumn: true,
      columns: fillColumn(),
      rows: fillRows(),
    );
  }


}

