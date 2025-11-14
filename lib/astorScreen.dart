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
  primary: Colors.white,
  minimumSize: Size(88, 44),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
  backgroundColor: Colors.blue,
);

class AstorScreen extends StatefulWidget {
  final AstorApp astorApp;

  AstorScreen({
    required this.astorApp,
  });
  @override
  _AstorScreenState createState() => _AstorScreenState();

}

class _AstorScreenState extends State<AstorScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffolKey = GlobalKey<ScaffoldState>();
  bool exit=false;
  _AstorScreenState();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    JSONSchemaController controller = JSONSchemaController();
    return WillPopScope(
        onWillPop:  ()async {
          if (exit) return true;
          onBack(context);
          return false;
        } ,
        child:Scaffold(
      key: scaffolKey,
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        leadingWidth: 100,
        automaticallyImplyLeading: false, // Don't show the leading button
        leading:  Row(

            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => onBack(context),
              ),
              if ( widget.astorApp.hasDrawer())IconButton(

                icon:Icon(Icons.more_vert,),
                onPressed: () =>  scaffolKey.currentState!.openDrawer(),
              ),
            ]
        ),
        title: Text( widget.astorApp.application_name),
        actions: <Widget>[
          IconButton(
              onPressed:() {
                exit=true;
               SystemNavigator.pop();
              },
         icon: Icon(Icons.power_settings_new)),
          widget.astorApp.hasMenuPrincipal()? IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  JSONNavigationBar(schema:widget.astorApp.menuPrincipal,
                      onPressed: onPressMenuButton,
                    )),
              );
            },
          ):Container(),
          widget.astorApp.hasNavBar()? IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Opciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  JSONNavigationBar(schema:widget.astorApp.navBar , onPressed: onPressMenuButton,)),
              );
            },
          ):Container(),
        ],
      ),
      drawer: JSONActionBarSideBar(schema:widget.astorApp.drawer, onPressed: onPressMenuButton),
      body: Stack(
          children: <Widget>[
            JSONSchemaForm(
              schema:  widget.astorApp.application_views.first,
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
            if (isLoading)
              LoadingDialog()
            // MenuButton(),
          ],
        ),

    ),
    );
  }

  void onPressMenuButton(AstorComponente schema, [BuildContext? context]) async {
    if (isLoading) {
      return null;
    }
    setState(() {
         isLoading = true;
    });
    try {

      Navigator.pop(context!);
      AstorProvider astorProvider = Provider.of(context,listen: false);
      String action = schema.actionTarget==''?'do-menuPanelsAction':schema.actionTarget;

      await astorProvider.doAction(schema,context,action,null,false);

      setState(() {
        isLoading = false;
      });

      return ;
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }
  void onBack( [BuildContext? context]) async {
    if (isLoading) {
      return null;
    }
    setState(() {
      isLoading = true;
    });
    try {
      AstorComponente dummy = AstorComponente(type: 'dummy', name: 'dummy', components: [], attributes: {"action_ajax_container":"view_area_and_title"}, value: '');

      AstorProvider astorProvider = Provider.of(context,listen: false);
      astorProvider.doAction(dummy,context,'do-BackAction',null,true);

      setState(() {
        isLoading = false;
      });

      return ;
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }
}


