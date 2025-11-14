// @dart=2.9
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

typedef void OnChange(bool value);

class JSONTable extends StatelessWidget {
  final AstorTable schema;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;

  JSONTable({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    schema.hideAllRowsChilds("win_row_expand_responsive",schema.active);
    return JSONDiv(
          schema: schema,
          useBootstrap: true,
          actionBar: false,
          onBuildBody: onBuildBody,
        );

  }



}

