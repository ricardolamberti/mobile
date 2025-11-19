
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef OnChange = void Function(bool value);

class JSONMessage extends StatelessWidget {
  final AstorComponente schema;
  // final OnPressed onPressed;

  const JSONMessage({
    super.key,
    required this.schema,
    // required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return showAlertDialog(context);
  }

  Widget showAlertDialog(BuildContext context) {
    final okButton = TextButton(
      child: const Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        Provider.of<AstorProvider>(context, listen: false).reload();
      },
    );

    final alert = AlertDialog(
      title: Text(schema.title),
      content: Text(schema.text),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return alert;
  }
}

