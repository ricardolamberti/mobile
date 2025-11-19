import 'dart:async';
import 'dart:convert';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/json_schema_form.dart';
import '/json_textform/components/LoadingDialog.dart';
import '/json_textform/models/Controller.dart';
import '/json_textform/utils-components/pushNotification.dart';
import '/model/AstorProvider.dart';
import 'astorScreen.dart';

class AstorSkin {
  final Color primaryColor;
  final Color backgroundColor;
  final double cardRadius;
  final double cardElevation;
  final Color inputFillColor;
  final double buttonRadius;
  final String? fontFamily;

  const AstorSkin({
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardRadius,
    required this.cardElevation,
    required this.inputFillColor,
    required this.buttonRadius,
    this.fontFamily,
  });

  factory AstorSkin.fromJson(Map<String, dynamic> json) {
    final defaults = AstorSkin.defaultSkin();
    final rawFont = json['fontFamily'] as String?;
    final trimmedFont = rawFont?.trim();
    return AstorSkin(
      primaryColor: _parseHexColor(json['primaryColor'] as String?) ?? defaults.primaryColor,
      backgroundColor: _parseHexColor(json['backgroundColor'] as String?) ?? defaults.backgroundColor,
      cardRadius: (json['cardRadius'] as num?)?.toDouble() ?? defaults.cardRadius,
      cardElevation: (json['cardElevation'] as num?)?.toDouble() ?? defaults.cardElevation,
      inputFillColor: _parseHexColor(json['inputFillColor'] as String?) ?? defaults.inputFillColor,
      buttonRadius: (json['buttonRadius'] as num?)?.toDouble() ?? defaults.buttonRadius,
      fontFamily: trimmedFont == null || trimmedFont.isEmpty ? defaults.fontFamily : trimmedFont,
    );
  }

  factory AstorSkin.defaultSkin() {
    return const AstorSkin(
      primaryColor: Color(0xFF0050A0),
      backgroundColor: Color(0xFFF3F4F6),
      cardRadius: 16,
      cardElevation: 2,
      inputFillColor: Colors.white,
      buttonRadius: 12,
      fontFamily: null,
    );
  }
}

Color? _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.length == 6) {
    cleaned = 'FF$cleaned';
  }
  if (cleaned.length != 8) return null;
  final intColor = int.tryParse(cleaned, radix: 16);
  if (intColor == null) return null;
  return Color(intColor);
}

ThemeData buildThemeFromSkin(AstorSkin skin) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: skin.primaryColor,
      brightness: Brightness.light,
    ),
    fontFamily: skin.fontFamily,
  );

  return base.copyWith(
    scaffoldBackgroundColor: skin.backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: skin.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: skin.cardElevation,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(skin.cardRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: skin.inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(skin.cardRadius),
        borderSide: BorderSide(
          color: base.colorScheme.outlineVariant,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(skin.cardRadius),
        borderSide: BorderSide(
          color: base.colorScheme.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(skin.cardRadius),
        borderSide: BorderSide(
          color: skin.primaryColor,
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

Future<AstorSkin> loadSkinFromBackend() async {
  final defaultSkin = AstorSkin.defaultSkin();
  final skinUrl = dotenv.env['SKIN_URL'];
  if (skinUrl == null || skinUrl.isEmpty) {
    return defaultSkin;
  }
  try {
    final response = await http.get(Uri.parse(skinUrl));
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AstorSkin.fromJson(jsonMap);
    }
  } catch (_) {
    // Ignore and fall back to defaults
  }
  return defaultSkin;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load(fileName: "assets/config.env");
  getDeviceIdentifier();

  final skin = await loadSkinFromBackend();
  runApp(MyApp(initialSkin: skin));
}

class MyApp extends StatelessWidget {
  final AstorSkin initialSkin;

  const MyApp({super.key, required this.initialSkin});

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
        theme: buildThemeFromSkin(initialSkin),
        title: 'Astor',
        home: const AstorPage(),
      ),
    );
  }
}

class AstorPage extends StatefulWidget {
  const AstorPage({super.key});

  @override
  State<AstorPage> createState() => _AstorStatePage();
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
    if (astorProvider.astorApp == null || astorProvider.redraw) {
      astorProvider.redraw = false;
      return FutureBuilder<AstorApp?>(
        future: astorProvider.futureAstorApp,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            astorProvider.astorApp = snapshot.data;
            astorProvider.checkUserLogin();
            return AstorScreen(astorApp: astorProvider.astorApp!);
          } else if (snapshot.hasError) {
            return AstorErrorScreen(stringError: "${snapshot.error}");
          }
          return const LoadingDialog();
        },
      );
    } else {
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
          title: const Text("Astor Error"),
        ),
        body: Center(
          child: Column(
            children: [
              const Text("Error de conexión"),
              const Divider(),
              Text(stringError),
              const Divider(),
              TextButton(
                onPressed: () =>
                    Provider.of<AstorProvider>(context, listen: false).reload(),
                child: const Text('Reintentar'),
              )
            ],
          ),
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
