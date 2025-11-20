import 'package:astor_mobile/json_textform/components/JSONActionBarSideBar.dart';
import 'package:astor_mobile/json_textform/components/JSONIcon.dart';
import 'package:astor_mobile/json_textform/components/JSONNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/json_schema_form.dart';
import '/json_textform/JSONSchemaForm.dart';
import '/model/AstorProvider.dart';
import 'package:provider/provider.dart';
import 'json_textform/components/JSONMessage.dart';
import 'json_textform/components/LoadingDialog.dart';
import 'main.dart';
import 'model/astorSchema.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final ButtonStyle flatButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.white,
  minimumSize: Size(88, 44),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
  backgroundColor: Colors.blue,
);

class AstorScreen extends StatefulWidget {
  final AstorApp astorApp;

  const AstorScreen({
    super.key,
    required this.astorApp,
  });

  @override
  _AstorScreenState createState() => _AstorScreenState();
}

class _AstorScreenState extends State<AstorScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffolKey = GlobalKey<ScaffoldState>();
  bool exit = false;

  _AstorScreenState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    JSONSchemaController controller = JSONSchemaController();
    return WillPopScope(
      onWillPop: () async {
        if (exit) return true;
        onBack(context);
        return false;
      },
      child: Scaffold(
        key: scaffolKey,
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          leadingWidth: 100,
          automaticallyImplyLeading: false, // Don't show the leading button
          leading: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => onBack(context),
              ),
              if (widget.astorApp.hasDrawer())
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => scaffolKey.currentState!.openDrawer(),
                ),
            ],
          ),
          title: Text(widget.astorApp.application_name),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                exit = true;
                SystemNavigator.pop();
              },
              icon: Icon(Icons.power_settings_new),
            ),
            widget.astorApp.hasMenuPrincipal()
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: 'Menu',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JSONNavigationBar(
                            schema: widget.astorApp.menuPrincipal,
                            onPressed: onPressMenuButton,
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
            widget.astorApp.hasNavBar()
                ? IconButton(
                    icon: const Icon(Icons.menu_book),
                    tooltip: 'Opciones',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JSONNavigationBar(
                            schema: widget.astorApp.navBar,
                            onPressed: onPressMenuButton,
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
      IconButton(
        icon: const Icon(Icons.info_outline),
        tooltip: 'Acerca de',
        onPressed: () {
          final appVersion = AppVersionInfo().version;
          final buildNumber = AppVersionInfo().buildNumber;

          final backendVersion =
              widget.astorApp.application_version_info ?? '';
          final backendRelease =
              widget.astorApp.application_release_info ?? '';

          showAboutDialog(
            context: context,
            applicationName: widget.astorApp.application_name,
            applicationVersion: '$appVersion+$buildNumber',
            children: [
              if (backendVersion.isNotEmpty)
                Text(backendVersion),
              if (backendRelease.isNotEmpty)
                Text(backendRelease),
            ],
          );
        },)
          ],
        ),
        drawer: JSONActionBarSideBar(
          schema: widget.astorApp.drawer,
          onPressed: onPressMenuButton,
        ),
        body: Stack(
          children: <Widget>[
            JSONSchemaForm(
              schema: widget.astorApp.application_views.first,
              icons: [
                FieldIcon(
                  iconData: Icons.title,
                  schemaName: "description",
                ),
              ],
            ),
            if (widget.astorApp.application_views.first.msg.isNotEmpty)
              JSONMessage(
                schema: widget.astorApp.application_views.first.msg.first,
              ),
            if (isLoading) LoadingDialog(),
            // MenuButton(),
          ],
        ),
      ),
    );
  }

  /// context es opcional, pero siempre trabajamos con un BuildContext no nulo
  void onPressMenuButton(AstorComponente schema, [BuildContext? ctx]) async {
    if (isLoading) {
      return;
    }

    // Si no recibimos context por parámetro, usamos el context del State
    final BuildContext effectiveContext = ctx ?? context;

    setState(() {
      isLoading = true;
    });

    try {
      // Cerrar el drawer o pantalla de menú si corresponde
      Navigator.pop(effectiveContext);

      AstorProvider astorProvider =
          Provider.of<AstorProvider>(effectiveContext, listen: false);

      String action =
          schema.actionTarget == '' ? 'do-menuPanelsAction' : schema.actionTarget;

      await astorProvider.doAction(
        schema,
        effectiveContext,
        action,
        null,
        false,
      );

      setState(() {
        isLoading = false;
      });

      return;
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }

  void onBack([BuildContext? ctx]) async {
    if (isLoading) {
      return;
    }

    // Igual que arriba: siempre trabajar con un BuildContext no nulo
    final BuildContext effectiveContext = ctx ?? context;

    setState(() {
      isLoading = true;
    });

    try {
      AstorComponente dummy = AstorComponente(
        type: 'dummy',
        name: 'dummy',
        components: [],
        attributes: {"action_ajax_container": "view_area_and_title"},
        value: '',
      );

      AstorProvider astorProvider =
          Provider.of<AstorProvider>(effectiveContext, listen: false);

      await astorProvider.doAction(
        dummy,
        effectiveContext,
        'do-BackAction',
        null,
        true,
      );

      setState(() {
        isLoading = false;
      });

      return;
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }
}
