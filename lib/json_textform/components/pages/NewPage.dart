import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import '../JSONDiv.dart';
import '/json_textform/JSONForm.dart';

class NewPage extends StatefulWidget {
  final AstorCombo schema;
  final OnBuildBody onBuildBody;
  final String title;

  const NewPage({
    Key? key,
    required this.title,
    required this.schema,
    required this.onBuildBody,
  }) : super(key: key);

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
      title: Text(widget.title),
      content: SizedBox(
        width: 600,
        child: JSONDiv(
          schema: widget.schema,
          onBuildBody: widget.onBuildBody,
        ),
      ),
      actions: [
        TextButton(
          key: const Key("Back"),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        // Si en algún momento querés reactivar el OK:
        // TextButton(
        //   onPressed: () {
        //     _onDone(context);
        //   },
        //   child: const Text("Ok"),
        // )
      ],
    );
  }

  // void _onDone(BuildContext context) {
  //   Navigator.pop(context);
  // }
}
