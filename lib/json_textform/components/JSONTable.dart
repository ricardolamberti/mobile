import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';
import 'JSONDiv.dart';

class JSONTable extends StatelessWidget {
  final AstorTable schema;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;

  const JSONTable({
    Key? key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    schema.hideAllRowsChilds('win_row_expand_responsive', schema.active);
    return JSONDiv(
      schema: schema,
      useBootstrap: true,
      actionBar: false,
      onBuildBody: onBuildBody,
    );
  }
}
