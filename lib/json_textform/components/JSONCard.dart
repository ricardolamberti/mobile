
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
import 'LoadingDialog.dart';

typedef void OnChange(bool value);

class JSONCard extends StatefulWidget {
  final AstorComponente schema;
  final OnBuildBody onBuildBody;

  const JSONCard({
    Key? key,
    required this.schema,
    required this.onBuildBody,
  }) : super(key: key);

  @override
  _JSONCardState createState() => _JSONCardState();
}

class _JSONCardState extends State<JSONCard> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  _JSONCardState();
  Future<AstorApp>? futureComponente;


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    if (widget.schema.diferido && widget.schema.components.isEmpty) {
      futureComponente = onDiferidoForm(widget.schema, context);
    }

    if (futureComponente == null)
      return JSONDiv(
        schema: widget.schema,
        useBootstrap: true,
        actionBar: false,
        onBuildBody: widget.onBuildBody,
      );
    return FutureBuilder<AstorApp>(
        future: futureComponente,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return JSONDiv(
              schema: widget.schema,
              useBootstrap: true,
              actionBar: false,
              onBuildBody: widget.onBuildBody,
            );;
          } else if (snapshot.hasError) {
            return Text('error');
          }
          return  CircularProgressIndicator();
        });


  }

  Future<AstorApp> onDiferidoForm(AstorComponente schema, [BuildContext? context]) async {
    if (context == null) {
      throw ArgumentError('context is required');
    }
    AstorProvider astorProvider = Provider.of(context, listen: false);
    return astorProvider.doDiferido(schema, context, schema.actionTarget);
  }
}


