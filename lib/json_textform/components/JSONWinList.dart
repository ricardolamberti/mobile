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

typedef OnChange = void Function(bool value);

class JSONWinList extends StatefulWidget implements InterfaceProvider {
  final AstorList schema;
  final OnChange? onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;

  /// controla si se trata como selección múltiple
  final bool isMultiple;

  /// indica si hay que limpiar la selección actual
  final bool clearSelection;

  JSONWinList({
    Key? key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.onSaved,
    this.isMultiple = false,
    this.clearSelection = false,
  }) : super(key: key);

  @override
  _JSONWinListState createState() => _JSONWinListState();

  @override
  bool getClearSelection() {
    return clearSelection;
  }

  @override
  String getCurrentActionOwner() {
    if (!isMultiple) {
      return getSingleActionOwnerList();
    }
    return getMultipleActionOwnerList();
  }

  @override
  String getCurrentActionOwnerFromSelect() {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      return schemaRows.id;
    }
    return '';
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
    String output = "";
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      output += '${schemaRows.id};';
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

      final cells = schemaRows.cells;
      if (cells == null || cells.values.isEmpty) {
        return '';
      }

      final firstCell = cells.values.first;
      // axis es String? -> devolvemos '' si es null
      return firstCell.axis ?? '';
    }
    return '';
  }

  @override
  String getSelectedRow() {
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      // rowpos es String? -> devolvemos '' si es null
      return schemaRows.rowpos ?? '';
    }
    return '';
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
    int l = 0;
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selected) continue;
      l++;
    }
    return l > 1;
  }

  @override
  bool hasMultipleSelectSpecial(String specialselector) {
    int l = 0;
    for (AstorRow schemaRows in schema.rows.values) {
      if (!schemaRows.selectedSpecial) continue;
      l++;
    }
    return l > 1;
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
    List<DataColumn> list = [];
    for (var schemaColumn in widget.schema.columns.values) {
      String title = schemaColumn.title;
      list.add(
        DataColumn(
          label: Text(title),
          numeric: false,
          tooltip: title,
        ),
      );
    }
    return list;
  }

  void updateActions(bool refresh) {
    final astorProvider = Provider.of<AstorProvider>(context, listen: false);
    final astorApp = astorProvider.astorApp;

    // astorApp puede ser null en null-safety
    if (astorApp == null) {
      if (refresh) {
        setState(() {});
      }
      return;
    }

    widget.schema.updateActions(refresh, astorApp);
    if (refresh) {
      setState(() {});
    }
  }

  void forceSelect(AstorRow schemaRow) {
    widget.schema.forceSelect(schemaRow);
    updateActions(false);
  }

  void select(AstorRow schemaRow) {
    widget.schema.select(schemaRow);
    updateActions(true);
  }

  void selectAll(bool? isSelected) {
    final value = isSelected ?? false;
    widget.schema.selectAll(value);
    updateActions(true);
  }

  List<DataRow> fillRows() {
    final List<DataRow> rows = [];
    for (var schemaRows in widget.schema.rows.values) {
      rows.add(
        DataRow(
          key: ValueKey(schemaRows.rowpos),
          selected: schemaRows.selected,
          onSelectChanged: (bool? isSelected) {
            select(schemaRows);
          },
          color: MaterialStateColor.resolveWith(
            (Set<MaterialState> states) => states.contains(MaterialState.selected)
                ? Colors.lightBlue
                : const Color.fromARGB(100, 215, 217, 219),
          ),
          cells: [
            for (AstorCell schemaCell in (schemaRows.cells?.values ?? <AstorCell>[]))
              DataCell(
                (schemaCell.type == "JLINK")
                    ? JSONDropDownButton(
                        schema: schemaCell,
                        onBuildBody: widget.onBuildBody,
                        onPressed: widget.onPressed,
                        everyVisible: true,
                      )
                    : (schemaCell.composite == true)
                        ? OverflowBox(
                            child: JSONDiv(
                              schema: schemaCell,
                              useBootstrap: false,
                              actionBar: true,
                              onBuildBody: widget.onBuildBody,
                            ),
                          )
                        : (schemaCell.type == "JCOLOUR")
                            ? JSONColorField(schema: schemaCell, inList: true)
                            : (schemaCell.type == "JIMAGE")
                                ? JSONIcon(schema: schemaCell)
                                : (schemaCell.type == "JICON")
                                    ? JSONIcon(schema: schemaCell)
                                    : (schemaCell.type == "JBOOLEAN")
                                        ? JSONIcon(schema: schemaCell)
                                        : Text(schemaCell.value),
                placeholder: false,
                showEditIcon: false,
                onTap: () {
                  select(schemaRows);
                },
                onDoubleTap: () {
                  forceSelect(schemaRows);
                  widget.onPressed(widget.schema, context);
                },
                onLongPress: () {
                  forceSelect(schemaRows);
                  widget.onPressed(widget.schema, context);
                },
              ),
          ],
        ),
      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    // trucho, por no poder calcular cuánto va a medir la tabla a priori
    if (MediaQuery.of(context).size.width < 700 ||
        MediaQuery.of(context).size.width <
            widget.schema.columns.length * 50) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: addDataTable(context),
      );
    } else {
      return addDataTable(context);
    }
  }

  Widget addDataTable(BuildContext context) {
    if (widget.schema.columns.isEmpty) {
      return Container();
    }
    return DataTable(
      columnSpacing: 0,
      dividerThickness: 5,
      onSelectAll: selectAll,
      decoration:
          BoxDecoration(border: Border.all(color: Colors.blue, width: 1)),
      dataRowColor: MaterialStateColor.resolveWith(
        (Set<MaterialState> states) => states.contains(MaterialState.selected)
            ? Colors.blue
            : const Color.fromARGB(100, 215, 217, 219),
      ),
      dataRowHeight: 40,
      dataTextStyle: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.black,
      ),
      headingRowColor:
          MaterialStateColor.resolveWith((states) => Colors.blue),
      headingRowHeight: 40,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      horizontalMargin: 10,
      showBottomBorder: true,
      showCheckboxColumn: true,
      columns: fillColumn(),
      rows: fillRows(),
    );
  }
}
