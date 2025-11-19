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
    super.key,
    required this.schema,
    required this.onBuildBody,
  });

  @override
  _JSONCardState createState() => _JSONCardState();
}

class _JSONCardState extends State<JSONCard> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  _JSONCardState();

  // El futuro puede ser null, y el AstorApp también puede ser null
  Future<AstorApp?>? futureComponente;

  @override
  void initState() {
    super.initState();

    // Si el schema es diferido y aún no tiene components, disparamos la carga una sola vez
    if (widget.schema.diferido && widget.schema.components.isEmpty) {
      futureComponente = onDiferidoForm(widget.schema);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay diferido, renderizamos directamente el JSONDiv
    if (futureComponente == null) {
      return JSONDiv(
        schema: widget.schema,
        useBootstrap: true,
        actionBar: false,
        onBuildBody: widget.onBuildBody,
      );
    }

    return FutureBuilder<AstorApp?>(
      future: futureComponente,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Text('error');
        }

        // Si el future terminó pero devolvió null, igual mostramos el schema actual
        // (suponiendo que doDiferido ya mutó widget.schema.components)
        return JSONDiv(
          schema: widget.schema,
          useBootstrap: true,
          actionBar: false,
          onBuildBody: widget.onBuildBody,
        );
      },
    );
  }

  Future<AstorApp?> onDiferidoForm(
    AstorComponente schema, [
    BuildContext? customContext,
  ]) async {
    final BuildContext effectiveContext = customContext ?? context;
    final AstorProvider astorProvider =
        Provider.of<AstorProvider>(effectiveContext, listen: false);

    // doDiferido devuelve Future<AstorApp?>? -> usamos !
    return await astorProvider.doDiferido(
      schema,
      effectiveContext,
      schema.actionTarget,
    );
  }
}
