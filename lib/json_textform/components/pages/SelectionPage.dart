
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import '/json_textform/JSONForm.dart';

class SelectionPage extends StatefulWidget {
  final AstorCombo schema;
  final OnSearch onSearch;
  final bool useDialog;
  final bool multiple;
  final String title;
  final List<AstorItem> selections;
  final Function onSelected;

  /// Current selected value
  final List<AstorItem> value;

  SelectionPage({
    @required this.onSearch,
    @required this.selections,
    @required this.multiple,
    this.onSelected,
    @required this.title,
    @required this.useDialog,
    this.schema,
    this.value,
  });

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final List<AstorItem> _selectedValues=[];
  List<AstorItem> selections = [];
  bool isLoading = false;
  dynamic error;

  @override
  void initState() {
    super.initState();

    if (widget.value!=null)
      _selectedValues.addAll(widget.value);
    selections = widget.selections;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useDialog) {
      return AlertDialog(
        title: Text("${widget.title}"),
        content: Container(
          width: 600,
          child: buildBody(),
        ),
        actions: [
          FlatButton(
            key: Key("Back"),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          FlatButton(
            onPressed: () {
              _onDone(_selectedValues, context);
            },
            child: Text("Ok"),
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
        leading: BackButton(
          key: Key("Back"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              _onDone(_selectedValues, context);
            },
          )
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        buildSelectedField(),
        buildTextField(),
        Expanded(
          child: Builder(builder: (context) {
            if (isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (error != null) {
              return Center(
                child: Text("$error"),
              );
            }
            return Scrollbar(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selections.length,
                itemBuilder: (ctx, index) {
                  AstorItem selection = selections[index];
                  bool checked = _selectedValues.contains(selection);
                  return ListTile(
                    key: Key("${selection.descripcion}-$checked"),
                   // groupValue: _selectedValue,
                    title: Text("${selection.descripcion}"),
                    onTap: () {
                      setState(() {
                        if (!widget.multiple)
                          _selectedValues.clear();
                        _selectedValues.add(selection);
                      });
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(labelText: "Search..."),
        onChanged: (value) async {
          if (widget.onSearch == null) {
            // use default filter
            setState(() {
              this.selections = _defaultSearch(value);
            });
          } else {
            try {
              setState(() {
                isLoading = true;
              });
              var results = await widget.onSearch(widget.schema, value);

              setState(() {
                if (results == null) {
                  this.selections = _defaultSearch(value);
                } else {
                  this.selections = results;
                }
              });
            } catch (err) {
              setState(() {
                error = err;
              });
            } finally {
              setState(() {
                isLoading = false;
              });
            }
          }
        },
      ),
    );
  }
  Widget buildSelectedField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: [
          for(AstorItem selected in _selectedValues)
            TextButton.icon(
              label: Text(selected==null?"":selected.descripcion),
              icon: Icon(Icons.highlight_remove_sharp),
              style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.blue)
                        )
                    )
                ),
              onPressed: () => removeSelected(selected),
            )

        ],
      ),
    );
  }
  List<AstorItem> _defaultSearch(String value) {
    return widget.selections
        .where((s) => value != "" ? s.descripcion.contains(value) : true)
        .toList();
  }

  void removeSelected(AstorItem select) {
    setState(() {
      _selectedValues.remove(select);
    });
  }
  void _onDone(List<AstorItem> _list, BuildContext context) {

    if (widget.onSelected != null) {
      widget.onSelected(
        _list
      );
    }
    Navigator.pop(context);
  }
}
