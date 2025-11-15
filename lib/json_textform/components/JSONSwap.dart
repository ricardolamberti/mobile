
import 'package:astor_mobile/json_textform/utils-components/OutlineButtonContainer.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import '../JSONForm.dart';

typedef OnChange = void Function(bool value);

class JSONSwap extends StatefulWidget implements InterfaceProvider {
  final AstorSwap schema;
  final OnChange? onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  final bool isMultiple;
  final bool clearSelection;

  const JSONSwap({
    Key? key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.onSaved,
    this.isMultiple = false,
    this.clearSelection = false,
  }) : super(key: key);
  @override
  _JSONSwapState createState() => _JSONSwapState();

  @override
  bool getClearSelection() {
    return clearSelection;
  }

  @override
  String? getCurrentActionOwner() {
     return getMultipleCurrentActionOwner();

  }

  @override
  String? getCurrentActionOwnerFromSelect() {
    for (AstorItem schemaRows in schema.destino) {
      return schemaRows.id;
    }
    return null;
  }

  @override
  String? getMultipleActionOwnerList() {
    String output="";
    for (AstorItem schemaRows in schema.destino) {
      output+= schemaRows.id+";";
    }
    return output;
  }

  String? getMultipleCurrentActionOwner() {
    return schema.actionOwner;
  }

  @override
  String? getMultipleCurrentActionOwnerDest() {
    return schema.actionOwnerDest;
  }

  @override
  String? getSelectedCell() {

    return null;
  }

  @override
  String? getSelectedRow() {

    return null;
  }

  @override
  String? getSelection() {
    return getMultipleActionOwnerList();
  }

  @override
  String? getSelectionSpecial(String specialselector) {

    return '';
  }

  @override
  bool hasMoreSelections() {
    return schema.hasMoreSelection;
  }

  @override
  bool hasMultipleSelect() {
    return true;
  }

  @override
  bool hasMultipleSelectSpecial(String specialselector) {
    return true;
  }

}

class _JSONSwapState extends State<JSONSwap> {
  @override
  void initState() {
    super.initState();
    //updateActions(false);
  }



  void toLeft(List<AstorItem> schemaRow) {
    widget.schema.toLeft(schemaRow);
  }
  void toRight(List<AstorItem> schemaRow) {
    widget.schema.toRight(schemaRow);
  }


  @override
  Widget build(BuildContext context) {
    final left = widget.schema.origen
        .where((element) => element.visible)
        .toList(growable: true);
    final right = widget.schema.destino
        .where((element) => element.visible)
        .toList(growable: true);
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: OutlineButtonContainer(
            isOutlined: true,
            isFilled: false,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: TextField(
                    enabled: true,
                    key: const Key('search_left'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'search..',
                    ),
                    onChanged: (value) {
                      setState(() {
                        widget.schema.filterLeft(value);
                      });
                    },
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 500,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: left.length,
                    itemBuilder: (context, index) {
                      final item = left[index];
                      return ListTile(
                        title: Text('->${item.descripcion}'),
                        selected: item.selected,
                        selectedTileColor: Colors.blue,
                        onTap: () {
                          setState(() {
                            item.selected = !item.selected;
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            item.selected = true;
                            toRight(
                              widget.schema.origen
                                  .where((element) => element.selected)
                                  .toList(),
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          ),
        ),
        Expanded(
          flex: 1,
          child: OutlineButtonContainer(
            isOutlined: true,
            isFilled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        toRight(widget.schema.origen
                            .where((element) => element.visible)
                            .toList());
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(15),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('>>')),
                const Divider(),
                TextButton(
                    onPressed: () {
                      setState(() {
                        toRight(
                          widget.schema.origen
                              .where((element) => element.selected && element.visible)
                              .toList(),
                        );
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(15),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('->')),
                const Divider(),
                TextButton(
                    onPressed: () {
                      setState(() {
                        toLeft(
                          widget.schema.destino
                              .where((element) => element.selected && element.visible)
                              .toList(),
                        );
                      });

                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(15),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('<-')),
                const Divider(),
                TextButton(
                    onPressed: () {
                      setState(() {
                        toLeft(widget.schema.destino
                            .where((element) => element.visible)
                            .toList());
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(15),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('<<')),
              ],
            ),
          ),
        ),
        Expanded(
            flex: 4,
            child: OutlineButtonContainer(
              isOutlined: true,
              isFilled: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TextField(
                      enabled: true,
                      key: const Key('search_right'),
                      onChanged: (value) {
                        setState(() {
                          widget.schema.filterRight(value);
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search..',
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 500,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: right.length,
                      itemBuilder: (context, index) {
                        final item = right[index];

                        return ListTile(
                          selected: item.selected,
                          title: Text('->${item.descripcion}'),
                          onTap: () {
                            setState(() {
                              item.selected = !item.selected;
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              item.selected = true;
                              toLeft(
                                widget.schema.destino
                                    .where((element) => element.selected)
                                    .toList(),
                              );
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )


        )
      ]
    );
  }



}

