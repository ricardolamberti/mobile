import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JSONForm.dart';
import 'JSONDiv.dart';

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

    if (futureComponente == null) {
      return JSONDiv(
        schema: widget.schema,
        useBootstrap: true,
        actionBar: false,
        onBuildBody: widget.onBuildBody,
      );
    }
    return FutureBuilder<AstorApp>(
      future: futureComponente,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return JSONDiv(
            schema: widget.schema,
            useBootstrap: true,
            actionBar: false,
            onBuildBody: widget.onBuildBody,
          );
        } else if (snapshot.hasError) {
          return const Text('error');
        }
        return const CircularProgressIndicator();
      },
    );


  }


  Future<AstorApp> onDiferidoForm(AstorComponente schema,
      [BuildContext? customContext]) async {
    final BuildContext effectiveContext = customContext ?? context;
    final AstorProvider astorProvider =
        Provider.of<AstorProvider>(effectiveContext, listen: false);
    return astorProvider.doDiferido(
      schema,
      effectiveContext,
      schema.actionTarget,
    );
  }
}


