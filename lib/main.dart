import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import '/json_schema_form.dart';
import '/json_textform/models/Controller.dart';
import 'astorScreen.dart';
import '/model/AstorProvider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'json_textform/components/LoadingDialog.dart';
import 'json_textform/utils-components/pushNotification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load(fileName: "assets/config.env");
  await getDeviceIdentifier();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ThemeData buildTheme() {
    final ThemeData base = ThemeData();
    return base.copyWith(
      iconTheme: const IconThemeData(color: Colors.black45),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: Colors.black45,
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AstorProvider(),
        )
      ],
      child: MaterialApp(
        theme: buildTheme(),
        title: 'Astor',
        home: const AstorPage(),
      ),
    );
  }
}


class AstorPage extends StatefulWidget {
  const AstorPage({Key? key}) : super(key: key);

  @override
  _AstorStatePage createState() => _AstorStatePage();
}

class _AstorStatePage extends State<AstorPage> {

  @override
  void initState() {
    bootstrapGridParameters(
      gutterSize: 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AstorProvider astorProvider = Provider.of<AstorProvider>(context);
    if (astorProvider.astorApp == null || astorProvider.redraw) {
      astorProvider.redraw = false;
      return FutureBuilder<AstorApp?>(
        future: astorProvider.futureAstorApp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingDialog();
          }
          if (snapshot.hasError) {
            return getMaterialError("${snapshot.error}");
          }
          final AstorApp? astorApp = snapshot.data;
          if (astorApp == null) {
            return getMaterialError("No se pudo obtener la configuración inicial");
          }
          astorProvider.astorApp = astorApp;
          astorProvider.checkUserLogin();
          return AstorScreen(astorApp: astorApp);
        },
      );
    } else {
      final AstorApp? astorApp = astorProvider.astorApp;
      if (astorApp == null) {
        return getMaterialError("No se pudo obtener la configuración inicial");
      }
      return AstorScreen(astorApp: astorApp);
    }
  }


  MaterialApp getMaterialError(String stringError) {
    return MaterialApp(
      title: "Astor",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Astor Error"),
        ),
        body: Center(
            child: Column(
              children: [
                Text("Error de conexión"),
                Divider(),
                Text(stringError),
                Divider(),
                TextButton(
                    onPressed: () =>
                        Provider.of<AstorProvider>(context, listen: false)
                            .reload(),
                    child: Text('Reintentar'))
              ],
            )
        ),
      ),
    );
  }
}


