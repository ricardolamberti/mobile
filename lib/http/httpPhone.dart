import 'dart:convert';
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'astorHttp.dart';

class AstorWebHttpPhone extends AstorWebHttp {
  OnResponse? doReponse;
  OnAjax? doAjax;
  OnNotif? doNotif;
  OnSubscribe? doSubscribe;
  OnDownload? doDownload;

  late String aBaseUrl;
  String aToken = '';

  late http.Client client;
  late Map<String, String> headers;

  AstorWebHttpPhone();

  final Map<String, String> _cookies = {}; // ← todas las cookies vivas
  String? _jwtTokenValue; // token Authorization puro

  @override
  Future<AstorApp> get(String url) {
    return getPhone(url);
  }

  @override
  Future<AstorApp> post(String url, Map<String, String> params) {
    return postPhone(url, params);
  }

  @override
  Future<List<AstorItem>> ajax(String url, Map<String, String> params) {
    return ajaxPhone(url, params);
  }

  @override
  Future<List<AstorNotif>> notification(String url,
      Map<String, String> params,) {
    return notifPhone(url, params);
  }

  @override
  Future<String> subscribe(String url, Map<String, String> params) {
    return subscribePhone(url, params);
  }

  void openPhone(String baseUrl) {
    aBaseUrl = baseUrl;
    client = http.Client();
    headers = initHeader();
  }

  Map<String, String> initHeader() {
    return {
      "Accept": "application/json",
      // estos headers de CORS realmente son del SERVIDOR, pero los dejo
      'Access-Control-Allow-Origin': aBaseUrl,
      'Access-Control-Allow-Methods': '*',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Allow-Headers':
      'Access-Control-Allow-Credentials,Access-Control-Allow-Methods, Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers',
    };
  }

  @override
  void close() {
    headers.remove('cookie');
    headers.remove('Authorization');
    _cookies.clear();
    _jwtTokenValue = null;
    aToken = '';
    client.close();
  }

  // ---------------------------------------------------------------------------
  // HELPERS DE COOKIES
  // ---------------------------------------------------------------------------

  /// Parsea un header Set-Cookie (que puede traer 1 o varias cookies) y las guarda en `_cookies`.
  void _parseAndStoreCookies(String setCookieHeader) {
    // OJO: esto es simplificado; si tu backend usa `Expires=Wed, 01 Jan 2025 ...`
    // con coma, puede requerir un parser más fino. Para muchos casos igual funciona.
    final cookieStrings = setCookieHeader.split(',');
    for (final raw in cookieStrings) {
      final cookie = raw.trim();
      if (cookie.isEmpty) continue;

      final parts = cookie.split(';');
      final nameValue = parts.first.trim(); // "Nombre=Valor"
      final nvSplit = nameValue.split('=');
      if (nvSplit.length != 2) continue;

      final name = nvSplit[0].trim();
      final value = nvSplit[1].trim();

      if (name.isEmpty) continue;

      _cookies[name] = value; // guarda/actualiza la cookie

      if (name == 'Authorization') {
        _jwtTokenValue = value;
      }
    }
  }

  /// Reconstruye el header `Cookie` y el header `Authorization` a partir de `_cookies`.
  void _rebuildCookieHeaders() {
    if (_cookies.isEmpty) {
      headers.remove('cookie');
      headers.remove('Authorization');
      return;
    }

    // Cookie: name1=val1; name2=val2; ...
    final cookieHeader =
    _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    headers['cookie'] = cookieHeader;

    // Si hay cookie Authorization, usála también como Bearer
    final authCookie = _cookies['Authorization'];
    if (authCookie != null && authCookie.isNotEmpty) {
      _jwtTokenValue = authCookie;
      headers['Authorization'] = 'Bearer $authCookie';
    } else if (_jwtTokenValue != null && _jwtTokenValue!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtTokenValue';
    } else {
      headers.remove('Authorization');
    }

    debugPrint('🍪 Enviando Cookie: $cookieHeader');
    if (headers.containsKey('Authorization')) {
      debugPrint('🔑 Enviando Authorization: ${headers['Authorization']}');
    }
  }

  /// Asegura que headers tengan las cookies (y Authorization) correctas.
  void _ensureCookieHeader() {
    // Si no tenemos cookies en memoria, intentá recuperar del storage
    if (_cookies.isEmpty) {
      final recovered = recoveryLogin();
      if (recovered.isNotEmpty) {
        // recovered puede ser un header completo con varias cookies
        _parseAndStoreCookies(recovered);
        aToken = recovered; // por compatibilidad con tu código previo
      }
    }

    _rebuildCookieHeaders();
  }

  /// Lee todos los Set-Cookie + headers legacy y actualiza `_cookies`.
  void updateCookie(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    debugPrint('SET-COOKIE crudo: $setCookie');

    if (setCookie != null && setCookie.isNotEmpty) {
      // guardamos el header completo para persistencia (puede traer varias cookies)
      saveLogin(setCookie);

      // parseo y guardado en el map
      _parseAndStoreCookies(setCookie);
    }

    // soporte legacy: set-mobile-cookie (normalmente un cookie suelto)
    final String? rawCookie = response.headers['set-mobile-cookie'];
    if (rawCookie != null && rawCookie.isNotEmpty) {
      debugPrint('set-mobile-cookie: $rawCookie');
      _parseAndStoreCookies(rawCookie);
      saveLogin(rawCookie); // si querés persistir también este
    }

    final String? rawPersistentCookie =
    response.headers['set-mobile-persistent-cookie'];
    if (rawPersistentCookie != null && rawPersistentCookie.isNotEmpty) {
      debugPrint('set-mobile-persistent-cookie: $rawPersistentCookie');
      _parseAndStoreCookies(rawPersistentCookie);
      saveLogin(rawPersistentCookie);
    }

    // Finalmente reconstruimos los headers de salida
    _rebuildCookieHeaders();
  }
  @override
  void setResponses({
    OnResponse? doReponse,
    OnAjax? doAjax,
    OnNotif? doNotif,
    OnSubscribe? doSubscribe,
    OnDownload? doDownload,
  }) {
    this.doReponse = doReponse;
    this.doAjax = doAjax;
    this.doNotif = doNotif;
    this.doSubscribe = doSubscribe;
    this.doDownload = doDownload;
  }
  dynamic _decodeJsonBody(http.Response response) {
    // <<<
    final bodyStr = const Utf8Decoder().convert(response.bodyBytes);
    debugPrint(bodyStr, wrapWidth: 200000);

    final trimmed = bodyStr.trimLeft();

    // Si viene HTML (por ejemplo página de error / login), no intentes parsear JSON
    if (trimmed.startsWith('<!DOCTYPE html') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<!doctype html')) {
      throw Exception(
          'El servidor devolvió HTML en lugar de JSON. Probable 401, login o URL incorrecta.');
    }

    try {
      return jsonDecode(trimmed);
    } catch (e) {
      throw Exception('Error al parsear JSON: $e\nBody: $trimmed');
    }
  }

  // --- requests --------------------------------------------------------- //


  Future<AstorApp> getPhone(String url) async {
    final uri = Uri.parse(aBaseUrl + url);

    final response = await _sendWithRedirect(
      method: 'GET',
      uri: uri,
    );

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor (status ${response.statusCode})');
    }
  }

  Future<AstorApp> postPhone(String url, Map<String, String> params) async {
    final uri = Uri.parse(aBaseUrl + url);

    final response = await _sendWithRedirect(
      method: 'POST',
      uri: uri,
      bodyFields: params,
    );

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor (status ${response.statusCode})');
    }
  }

  Future<List<AstorItem>> ajaxPhone(String url,
      Map<String, String> params,) async {
    _ensureCookieHeader(); // asegura que se envíen todas las cookies

    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processAjaxResponse(response);
    } else {
      throw Exception('Failed to load astor (status ${response.statusCode})');
    }
  }

  Future<http.Response> _sendWithRedirect({
    required String method,
    required Uri uri,
    Map<String, String>? bodyFields,
  }) async {
    late Uri finalUri;
    Map<String, String>? finalBody;

    if (method.toUpperCase() == 'GET') {
      final qp = Map<String, String>.from(uri.queryParameters);
      qp['is_mobile'] = 'Y';
      finalUri = uri.replace(queryParameters: qp);
      finalBody = null;
    } else {
      finalBody = Map<String, String>.from(bodyFields ?? {});
      finalBody['is_mobile'] = 'Y';
      finalUri = uri;
    }

    _ensureCookieHeader(); // <- usa todas las cookies actuales

    final request = http.Request(method, finalUri)
      ..headers.addAll(headers)
      ..followRedirects = false;

    if (finalBody != null) {
      request.bodyFields = finalBody;
    }

    print('➡️ $method $finalUri');
    print('➡️ HEADERS: $headers');
    if (finalBody != null) print('➡️ BODY: $finalBody');

    final streamed = await client.send(request);
    var response = await http.Response.fromStream(streamed);

    print('⬅️ STATUS: ${response.statusCode}');
    print('⬅️ HEADERS: ${response.headers}');
    print('⬅️ SET-COOKIE: ${response.headers['set-cookie']}');

    updateCookie(response);

    if (response.isRedirect ||
        (response.statusCode >= 300 && response.statusCode < 400)) {
      final loc = response.headers['location'];
      if (loc != null) {
        final redirectUri = finalUri.resolve(loc);
        print('↪️ FOLLOW REDIRECT TO: $redirectUri');

        _ensureCookieHeader(); // también enviar cookies en el redirect
        final redirected = await client.get(redirectUri, headers: headers);
        updateCookie(redirected);

        print('⬅️ REDIRECTED STATUS: ${redirected.statusCode}');
        print('⬅️ REDIRECTED SET-COOKIE: ${redirected.headers['set-cookie']}');

        response = redirected;
      }
    }

    return response;
  }

  Future<List<AstorNotif>> notifPhone(String url,
      Map<String, String> params,) async {
    _ensureCookieHeader(); // <<<

    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processNotifResponse(response);
    } else {
      throw Exception('Failed to load astor (status ${response.statusCode})');
    }
  }

  Future<String> subscribePhone(String url,
      Map<String, String> params,) async {
    _ensureCookieHeader(); // <<<

    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processSubscribeResponse(response);
    } else {
      throw Exception('Failed parser ${response.body}');
    }
  }

  @override
  void open(String aBaseUrl) {
    openPhone(aBaseUrl);
  }

  // --- procesamiento de respuestas -------------------------------------- //

  Future<AstorApp> processResponse(http.Response response) async {
    if (isDownloadFile(response)) {
      return processDownloadResponse(response);
    }
    final dynamic json = _decodeJsonBody(response); // <<<
    return doReponse!(json);
  }

  Future<List<AstorItem>> processAjaxResponse(http.Response response,) async {
    final dynamic json = _decodeJsonBody(response); // <<<
    return doAjax!(json);
  }

  Future<List<AstorNotif>> processNotifResponse(http.Response response,) async {
    final dynamic json = _decodeJsonBody(response); // <<<
    return doNotif!(json);
  }

  Future<String> processSubscribeResponse(http.Response response,) async {
    final dynamic json = _decodeJsonBody(response); // <<<
    return doSubscribe!(json);
  }

  bool isDownloadFile(http.Response response) {
    final String? contentDisposition = response.headers['content-disposition'];
    if (contentDisposition == null) return false;
    return contentDisposition.contains('attachment');
  }

  Future<AstorApp> processDownloadResponse(http.Response response,) async {
    String filename = response.headers['content-disposition']!;
    filename = filename.substring(filename.lastIndexOf('=') + 1);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.bodyBytes);

    return doDownload!(file);
  }

  // --- persistencia de login -------------------------------------------- //

  final storage = GetStorage();

  void saveLogin(String token) {
    int seconds = 0;
    final parts = token.split(';');
    for (final s in parts) {
      if (s.contains('Max-Age=')) {
        seconds = int.tryParse(
          s.substring(s.indexOf('Max-Age=') + 8).trim(),
        ) ??
            0;
      }
    }
    if (seconds == 0) {
      // si el cookie no trae Max-Age, será solo de sesión (no persistente)
      return;
    }

    var fecha = DateTime.now().add(Duration(seconds: seconds));
    storage.write("userInfoDate", fecha.toIso8601String());
    storage.write("userInfo", token); // puede ser un header con varias cookies
    storage.save();
  }

  String recoveryLogin() {
    final fechaStr = storage.read<String>("userInfoDate");
    if (fechaStr == null) return '';

    final fecha = DateTime.tryParse(fechaStr);
    if (fecha == null) return '';

    final hoy = DateTime.now();
    if (!fecha.isAfter(hoy)) return '';

    return storage.read<String>("userInfo") ?? '';
  }
}

AstorWebHttp getManager() => AstorWebHttpPhone();
