
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

typedef OnChange = void Function(bool value);

class JSONLine extends StatelessWidget {
  final AstorComponente schema;

  const JSONLine({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Colors.black);
  }
}

