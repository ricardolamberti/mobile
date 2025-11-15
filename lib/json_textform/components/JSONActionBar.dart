import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

// Puedes dejar el typedef así, sigue siendo válido con null-safety
typedef OnChange = void Function(bool value);

class JSONActionBar extends StatelessWidget {
  final AstorComponente schema;
  final OnChange? onSaved;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;

  const JSONActionBar({
    Key? key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        JSONDiv(
          schema: schema,
          useBootstrap: false,
          actionBar: true,
          onBuildBody: onBuildBody,
        ),
      ],
    );
  }
}
