// @dart=2.9
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/json_textform/components/JSONDropDownButton.dart';
import 'package:astor_mobile/json_textform/utils-components/OutlineButtonContainer.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

typedef void OnChange(bool value);

class JSONSwap extends StatefulWidget implements InterfaceProvider {
  final AstorSwap schema;
  final OnChange onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  bool isMultiple = false;
  bool clearSelection = false;

  JSONSwap({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
    this.onSaved,
  });
  @override
  _JSONSwapState createState() => _JSONSwapState();

  @override
  bool getClearSelection() {
    return clearSelection;
  }

  @override
  String getCurrentActionOwner() {
     return getMultipleCurrentActionOwner();

  }

  @override
  String getCurrentActionOwnerFromSelect() {
    for (AstorItem schemaRows in schema.destino) {
      return schemaRows.id;
    }
    return null;
  }

  @override
  String getMultipleActionOwnerList() {
    String output="";
    for (AstorItem schemaRows in schema.destino) {
      output+= schemaRows.id+";";
    }
    return output;
  }

  String getMultipleCurrentActionOwner() {
    return schema.actionOwner;
  }

  @override
  String getMultipleCurrentActionOwnerDest() {
    return schema.actionOwnerDest;
  }

  @override
  String getSelectedCell() {

    return null;
  }

  @override
  String getSelectedRow() {

    return null;
  }

  @override
  String getSelection() {
    return getMultipleActionOwnerList();
  }

  @override
  String getSelectionSpecial(String specialselector) {

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
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  _JSONSwapState();

  List<AstorComponente> schemaList = [];

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
    List<AstorItem> left =  widget.schema.origen.where((element) => element.visible).toList(growable: true);
    List<AstorItem> right =  widget.schema.destino.where((element) => element.visible).toList(growable: true);
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: OutlineButtonContainer(
            isOutlined: true,
            isFilled: false,
            child: Column(
              children: [
                Container( height: 40,width: double.infinity,child:TextField(
                  enabled: true,
                  key: Key("search_left"),

                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'search..'
                  ),
                  onChanged: (value) {setState(() {
                    widget.schema.filterLeft(value);
                  });
                  },
                )),Divider(),
                Container (
                    height: 500,
                    width: double.infinity,
                    //   child: SingleChildScrollView(
                    child:  ListView.builder(
                          itemCount: left.length,
                          itemBuilder: (context, index) {
                            final item = left[index];
                            return ListTile(
                              title: Text("->"+item.descripcion),
                              selected: item.selected,
                              selectedTileColor: Colors.blue,
                              onTap: () {
                                setState(() {
                                  item.selected=!item.selected;
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  item.selected=true;
                                  toRight(widget.schema.origen.where((element) => element.selected==true).toList());
                                });
                              },
                            );
                          },
                        ),

                    )

                  //  ),


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
                        toRight(widget.schema.origen.where((element) => element.visible).toList());
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text('>>')),Divider(),
                TextButton(
                    onPressed: () {
                      setState(() {
                        toRight(widget.schema.origen.where((element) => element.selected==true&&element.visible).toList());
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text('->')),Divider(),
                TextButton(
                    onPressed: () {
                      setState(() {
                        toLeft(widget.schema.destino.where((element) => element.selected==true&&element.visible).toList());
                      });

                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text('<-')),Divider(),
                TextButton(
                    onPressed: () {
                      setState(() {
                        toLeft(widget.schema.destino.where((element) => element.visible).toList());
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text('<<')),
              ],
            ),
          ),
        ),
        Expanded(
            flex: 4,
            child: OutlineButtonContainer(
              isOutlined: true,
              isFilled: false,
              child:      Column(

                children: [
                  Container( height: 40,width: double.infinity,child:TextField(
                    enabled: true,
                    key: Key("search_right"),
                    onChanged: (value) {
                      setState(() {
                        widget.schema.filterRight(value);
                      });
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search..'
                    ),

                  )), Divider(),Container (
                      height: 500,
                      width: double.infinity,
                      // width:100,
                      // child: SingleChildScrollView(
                      child:ListView.builder(
                        itemCount: right.length,
                        itemBuilder: (context, index) {
                          final item = right[index];

                          return ListTile(
                            // selectedTileColor: Colors.blue,
                            selected: item.selected,
                            title: Text("->"+item.descripcion),
                            onTap: () {
                              setState(() {
                                item.selected=!item.selected;
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                item.selected=true;
                                toLeft(widget.schema.destino.where((element) => element.selected==true).toList());
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

