import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import '/json_textform/JSONForm.dart';

class SelectionPage extends StatefulWidget {
  final AstorCombo schema;
  final OnSearch? onSearch;
  final bool useDialog;
  final bool multiple;
  final String title;
  final List<AstorItem> selections;
  final void Function(List<AstorItem>)? onSelected;

  /// Current selected value
  final List<AstorItem>? value;

  const SelectionPage({
    super.key,
    required this.onSearch,
    required this.selections,
    required this.multiple,
    this.onSelected,
    required this.title,
    required this.useDialog,
    required this.schema,
    this.value,
  });

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final List<AstorItem> _selectedValues = [];
  List<AstorItem> selections = [];
  bool isLoading = false;
  dynamic error;

  @override
  void initState() {
    super.initState();

    if (widget.value != null) {
      _selectedValues.addAll(widget.value!);
    }
    selections = widget.selections;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useDialog) {
      return AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: 600,
          child: buildBody(),
        ),
        actions: [
          TextButton(
            key: const Key("Back"),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _onDone(_selectedValues, context);
            },
            child: const Text("Ok"),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: const BackButton(
          key: Key("Back"),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              _onDone(_selectedValues, context);
            },
          ),
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
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
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
                    final selection = selections[index];
                    final checked = _selectedValues.contains(selection);
                    return ListTile(
                      key: Key("${selection.descripcion}-$checked"),
                      title: Text(selection.descripcion),
                      onTap: () {
                        setState(() {
                          if (!widget.multiple) {
                            _selectedValues.clear();
                          }
                          _selectedValues.add(selection);
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(labelText: "Search..."),
        onChanged: (value) async {
          if (widget.onSearch == null) {
            // use default filter
            setState(() {
              selections = _defaultSearch(value);
            });
          } else {
            try {
              setState(() {
                isLoading = true;
              });

              final results = await widget.onSearch!(widget.schema, value);

              setState(() {
                if (results == null) {
                  selections = _defaultSearch(value);
                } else {
                  selections = results;
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
          for (final selected in _selectedValues)
            TextButton.icon(
              label: Text(selected.descripcion),
              icon: const Icon(Icons.highlight_remove_sharp),
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.all(15),
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              onPressed: () => removeSelected(selected),
            ),
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

  void _onDone(List<AstorItem> list, BuildContext context) {
    widget.onSelected?.call(list);
    Navigator.pop(context);
  }
}
