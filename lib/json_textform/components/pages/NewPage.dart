// @dart=2.9
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import '../JSONDiv.dart';
import '/json_textform/JSONForm.dart';

class NewPage extends StatefulWidget {
  final AstorCombo schema;
  final OnBuildBody onBuildBody;
  final String title;


  NewPage({
    this.title,
    this.schema,
    this.onBuildBody,

  });

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  bool isLoading = false;
  dynamic error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${widget.title}"),
      content: Container(
        width: 600,
        child: JSONDiv(
          schema: widget.schema,
          onBuildBody: widget.onBuildBody,
        ),
      ),
      actions: [
        FlatButton(
          key: Key("Back"),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        // FlatButton(
        //   onPressed: () {
        //     _onDone(context);
        //   },
        //   child: Text("Ok"),
        // )
      ],
    );
  }


  // void _onDone(BuildContext context) {
  //  Navigator.pop(context);
  // }
}
