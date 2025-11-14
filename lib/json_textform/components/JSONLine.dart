
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

class JSONLine extends StatelessWidget {
  final AstorComponente schema;

  JSONLine({
    @required this.schema,
 });

  @override
  Widget build(BuildContext context) {
    return  Divider(
        color: Colors.black
    );
  }



}

