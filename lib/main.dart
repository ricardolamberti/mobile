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
   getDeviceIdentifier();

  runApp(MyApp());


}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData buildTheme() {
    // Color corporativo base (ajustalo a tu celeste/azul/etc)
    const primarySeed = Color(0xFF0050A0);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeed,
        brightness: Brightness.light,
      ),
    );
    final outline = base.colorScheme.outline;

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),

      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      iconTheme: IconThemeData(
        color: base.colorScheme.primary,
        size: 22,
      ),

     cardTheme: CardThemeData(
  color: Colors.white,
  elevation: 2,
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),


      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
       
borderSide: BorderSide(
  color: outline.withValues(alpha: 0.4),
),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
           color: outline.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: base.colorScheme.primary,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(
          color: outline.withValues(alpha: 0.4),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),

     dialogTheme: DialogThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),


      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AstorProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        title: 'Astor',
        home: const AstorPage(),
      ),
    );
  }
}



class AstorPage extends StatefulWidget {
  const AstorPage({super.key});



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
    AstorProvider astorProvider = Provider.of(context);
    if (astorProvider.astorApp==null || astorProvider.redraw) {
      astorProvider.redraw = false;
      return FutureBuilder<AstorApp?>(
      future: astorProvider.futureAstorApp,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          astorProvider.astorApp = snapshot.data;
          astorProvider.checkUserLogin();
          return AstorScreen(astorApp: astorProvider.astorApp!);
        } else if (snapshot.hasData) {
          astorProvider.astorApp = snapshot.data;
          astorProvider.checkUserLogin();
          return AstorScreen(astorApp: astorProvider.astorApp!);
        } else if (snapshot.hasError) {
          return AstorErrorScreen(stringError: "${snapshot.error}");
        }
        return const LoadingDialog();
      });
    }
    else {
      return AstorScreen(astorApp: astorProvider.astorApp!);
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
                  onPressed: () => Provider.of<AstorProvider>(context,listen: false).reload(),
                  child: Text('Reintentar'))
              ],
            )
        ),
      ),
    );
  }
}
class AstorErrorScreen extends StatelessWidget {
  final String stringError;

  const AstorErrorScreen({
    super.key,
    required this.stringError,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Astor - Error"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "Error de conexión",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Text(
                    stringError,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Provider.of<AstorProvider>(
                        context,
                        listen: false,
                      ).reload(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


