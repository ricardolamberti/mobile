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
import 'package:package_info_plus/package_info_plus.dart';

class AstorSkin {
  final Color primaryColor;
  final Color backgroundColor;
  final double cardRadius;
  final double cardElevation;
  final Color inputFillColor;
  final double buttonRadius;
  final String? fontFamily;

  // Extras del backend
  final String? basePath;
  final String? urlPrefix;

  const AstorSkin({
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardRadius,
    required this.cardElevation,
    required this.inputFillColor,
    required this.buttonRadius,
    this.fontFamily,
    this.basePath,
    this.urlPrefix,
  });

  factory AstorSkin.fromJson(Map<String, dynamic> json) {
    final defaults = AstorSkin.defaultSkin();

    // Si viene como {"skin": {...}} lo tomamos de ahí
    final Map<String, dynamic> skin =
    (json['skin'] is Map<String, dynamic>) ? json['skin'] as Map<String, dynamic> : json;

    // ---------- base_path y url_prefix ----------
    final String? basePath = skin['base_path'] as String?;
    final String? urlPrefix = skin['url_prefix'] as String?;

    // ---------- palettes ----------
    final palettesRaw = skin['palettes'];
    Map<String, dynamic> selectedPalette = {};

    if (palettesRaw is Map<String, dynamic> && palettesRaw.isNotEmpty) {
      selectedPalette =
          (palettesRaw['light'] as Map<String, dynamic>?) ??
              (palettesRaw['default'] as Map<String, dynamic>?) ??
              (palettesRaw.values.first as Map<String, dynamic>);
    }

    final String? primaryHex =
    _tryGetString(selectedPalette, ['primary', 'primaryColor', 'primary_color']);
    final String? backgroundHex =
    _tryGetString(selectedPalette, ['background', 'backgroundColor', 'surface']);
    final String? inputFillHex =
    _tryGetString(selectedPalette, ['surface', 'background']);

    // ---------- shapes ----------
    final shapesRaw = skin['shapes'];
    Map<String, dynamic>? cardShape;
    Map<String, dynamic>? buttonShape;
    if (shapesRaw is Map<String, dynamic>) {
      cardShape = shapesRaw['card'] as Map<String, dynamic>?;
      buttonShape = shapesRaw['button'] as Map<String, dynamic>?;
    }

    final double cardRadius =
        _tryParseDouble(cardShape?['cornerRadius']) ?? defaults.cardRadius;
    final double buttonRadius =
        _tryParseDouble(buttonShape?['cornerRadius']) ?? defaults.buttonRadius;

    // ---------- elevations ----------
    final elevationsRaw = skin['elevations'];
    final double cardElevation = _tryParseDouble(
      (elevationsRaw is Map<String, dynamic>)
          ? elevationsRaw['medium']
          : null,
    ) ??
        defaults.cardElevation;

    // ---------- typography / fontFamily ----------
    String? fontFamily;
    final typography = skin['typography'];
    if (typography is Map<String, dynamic>) {
      final fonts = typography['fonts'];
      if (fonts is List) {
        Map<String, dynamic>? defaultFont;

        for (final f in fonts) {
          if (f is Map<String, dynamic>) {
            final def = (f['default'] as String?)?.toLowerCase() == 'true';
            if (def) {
              defaultFont = f;
              break;
            }
          }
        }

        defaultFont ??= fonts.firstWhere(
              (f) => f is Map<String, dynamic>,
          orElse: () => null,
        ) as Map<String, dynamic>?;

        fontFamily = defaultFont?['name'] as String?;
      }
    }

    final cleanedFont =
    (fontFamily != null && fontFamily.trim().isNotEmpty) ? fontFamily.trim() : defaults.fontFamily;

    return AstorSkin(
      primaryColor: _parseHexColor(primaryHex) ?? defaults.primaryColor,
      backgroundColor: _parseHexColor(backgroundHex) ?? defaults.backgroundColor,
      cardRadius: cardRadius,
      cardElevation: cardElevation,
      inputFillColor: _parseHexColor(inputFillHex) ?? defaults.inputFillColor,
      buttonRadius: buttonRadius,
      fontFamily: cleanedFont,
      basePath: basePath,
      urlPrefix: urlPrefix,
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
      basePath: null,
      urlPrefix: null,
    );
  }
}
/// Helper para leer una string probando varias keys posibles
String? _tryGetString(Map<String, dynamic> map, List<String> keys) {
  for (final k in keys) {
    final v = map[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}
/// Helper para leer una string probando varias keys posibles
String _buildSkinUrl() {
  final baseUrl = dotenv.env['URL'] ?? '';
  if (baseUrl.isEmpty) return '';

  final normalizedBase =
  baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  // Este path tiene que matchear el <map:match pattern="..."> del sitemap
  return '$normalizedBase/mobile-skin';
}

double? _tryParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Acepta "#RRGGBB", "#AARRGGBB", "RRGGBB", "AARRGGBB"
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
  final skinUrl = _buildSkinUrl();

  if (skinUrl.isEmpty) {
    return defaultSkin;
  }

  try {
    final uri = Uri.parse(skinUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return AstorSkin.fromJson(decoded);
      }
    }
  } catch (e) {
     print("Error cargando skin: $e");
  }

  return defaultSkin;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load(fileName: "assets/config.env");
  await AppVersionInfo().init(); // carga versión de la app

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


class AppVersionInfo {
  static final AppVersionInfo _instance = AppVersionInfo._();
  factory AppVersionInfo() => _instance;
  AppVersionInfo._();

  String version = '';
  String buildNumber = '';

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;       // ej: "1.0.3"
    buildNumber = info.buildNumber; // ej: "45"
  }
}

class AboutPanel extends StatelessWidget {
  const AboutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersion = AppVersionInfo().version;
    final buildNumber = AppVersionInfo().buildNumber;

    // Si ya tenés el AstorApp, podés sacar la version del backend también
    // por ejemplo: astorApp.applicationVersionInfo
    // (lo que viene de "application_version_info" del JSON) :contentReference[oaicite:1]{index=1}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Versión app móvil: $appVersion+$buildNumber'),
        // Text('Versión backend: ${astorApp.applicationVersionInfo}'),
      ],
    );
  }
}
