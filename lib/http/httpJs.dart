import 'dart:convert';
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';

import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'package:get_storage/get_storage.dart';

import 'astorHttp.dart';

class AstorWebHttpJs extends AstorWebHttp {
  OnResponse? doReponse;
  OnAjax? doAjax;
  OnNotif? doNotif;
  OnSubscribe? doSubscribe;
  OnDownload? doDownload;
  String? aBaseUrl;

  String aToken = '';

  late final DioForBrowser _dio;

  // --- helpers internos ------------------------------------------------- //

  /// Asegura que la URL tenga is_mobile=Y en el querystring.       // <<<
  String _addIsMobileToUrl(String url) {
    if (url.contains('is_mobile=')) return url;
    if (url.contains('?')) {
      return '$url&is_mobile=Y';
    } else {
      return '$url?is_mobile=Y';
    }
  }

  /// Asegura que el body tenga is_mobile=Y.                        // <<<
  Map<String, String> _addIsMobileToParams(Map<String, String> params) {
    final copy = Map<String, String>.from(params);
    copy['is_mobile'] = 'Y';
    return copy;
  }

  /// Normaliza el body a JSON y detecta HTML “indeseado”.          // <<<
  dynamic _decodeJsonBody(Response response) {
    final data = response.data;

    // Si Dio ya decodificó JSON a Map/List, lo devolvemos directo
    if (data is Map || data is List) {
      return data;
    }

    if (data is String) {
      final trimmed = data.trimLeft();

      // Si viene HTML, tiramos una excepción clara
      if (trimmed.startsWith('<!DOCTYPE html') ||
          trimmed.startsWith('<html') ||
          trimmed.startsWith('<!doctype html')) {
        throw Exception(
            'El servidor devolvió HTML en lugar de JSON. '
                'Probable 401, login o URL sin is_mobile=Y.');
      }

      try {
        return jsonDecode(trimmed);
      } catch (e) {
        throw Exception('Error al parsear JSON: $e\nBody: $trimmed');
      }
    }

    // Fallback: devolvemos lo que vino
    return data;
  }

  // --- interface AstorWebHttp ------------------------------------------- //

  @override
  Future<AstorApp> get(String url) {
    return getWeb(url);
  }

  @override
  void close() {
    // En browser no hay mucho que cerrar, pero lo dejamos por compatibilidad
  }

  @override
  Future<AstorApp> post(String url, Map<String, String> params) {
    return postWeb(url, params);
  }

  @override
  Future<List<AstorItem>> ajax(String url, Map<String, String> params) {
    return ajaxWeb(url, params);
  }

  @override
  Future<List<AstorNotif>> notification(String url, Map<String, String> params) {
    return notifWeb(url, params);
  }

  @override
  Future<String> subscribe(String url, Map<String, String> params) {
    return subscribeWeb(url, params);
  }

  void openWeb(String baseUrl) {
    aBaseUrl = baseUrl;

    _dio = DioForBrowser(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 13000),
        headers: {
          "Accept": "application/json",
          'Access-Control-Allow-Origin': baseUrl,
          'Access-Control-Allow-Methods': '*',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Allow-Headers':
          'Access-Control-Allow-Credentials,Access-Control-Allow-Methods, Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers',
        },
      ),
    );

    final adapter = BrowserHttpClientAdapter()..withCredentials = true;
    _dio.httpClientAdapter = adapter;
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

  // --- requests --------------------------------------------------------- //

  Future<AstorApp> getWeb(String url) async {
    final finalUrl = _addIsMobileToUrl(url);                     // <<<

    try {
      print('➡️ GET (web): $finalUrl');

      final response = await _dio.get<dynamic>(finalUrl);

      print('⬅️ status: ${response.statusCode}');
      // Ojo: response.data puede ser Map, List o String
      // print('⬅️ data: ${response.data}'); // cuidado con dumps enormes

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 399) {
        return processResponse(response);
      } else {
        throw Exception(
            'Failed to load astor (web). Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR (GET web): ${e.message}');
      print('   TYPE: ${e.type}');
      print('   RESPONSE STATUS: ${e.response?.statusCode}');
      print('   RESPONSE DATA: ${e.response?.data}');
      rethrow;
    } catch (e, st) {
      print('❌ ERROR GENÉRICO (GET web): $e');
      print(st);
      rethrow;
    }
  }

  Future<AstorApp> postWeb(String url, Map<String, String> params) async {
    final finalParams = _addIsMobileToParams(params);            // <<<
    final formData = FormData.fromMap(finalParams);

    try {
      print('➡️ POST (web): $url');
      print('➡️ BODY: $finalParams');

      final response = await _dio.post<dynamic>(url, data: formData);

      print('⬅️ status: ${response.statusCode}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 399) {
        return processResponse(response);
      } else {
        throw Exception(
            'Failed to load astor (web). Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR (POST web): ${e.message}');
      print('   TYPE: ${e.type}');
      print('   RESPONSE STATUS: ${e.response?.statusCode}');
      print('   RESPONSE DATA: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<AstorItem>> ajaxWeb(
      String url, Map<String, String> params) async {
    final finalParams = _addIsMobileToParams(params);           // <<<
    final formData = FormData.fromMap(finalParams);

    try {
      print('➡️ AJAX (web): $url');
      print('➡️ BODY: $finalParams');

      final response = await _dio.post<dynamic>(url, data: formData);

      print('⬅️ status: ${response.statusCode}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 399) {
        return processAjaxResponse(response);
      } else {
        throw Exception(
            'Failed to load astor (ajax web). Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR (AJAX web): ${e.message}');
      print('   TYPE: ${e.type}');
      print('   RESPONSE STATUS: ${e.response?.statusCode}');
      print('   RESPONSE DATA: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<AstorNotif>> notifWeb(
      String url,
      Map<String, String> params,
      ) async {
    final finalParams = _addIsMobileToParams(params);           // <<<
    final formData = FormData.fromMap(finalParams);

    try {
      print('➡️ NOTIF (web): $url');
      print('➡️ BODY: $finalParams');

      final response = await _dio.post<dynamic>(url, data: formData);

      print('⬅️ status: ${response.statusCode}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 399) {
        return processNotifResponse(response);
      } else {
        throw Exception('Failed to load astor (notif web). '
            'Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR (NOTIF web): ${e.message}');
      print('   TYPE: ${e.type}');
      print('   RESPONSE STATUS: ${e.response?.statusCode}');
      print('   RESPONSE DATA: ${e.response?.data}');
      rethrow;
    }
  }

  Future<String> subscribeWeb(
      String url,
      Map<String, String> params,
      ) async {
    final finalParams = _addIsMobileToParams(params);           // <<<
    final formData = FormData.fromMap(finalParams);

    try {
      print('➡️ SUBSCRIBE (web): $url');
      print('➡️ BODY: $finalParams');

      final response = await _dio.post<dynamic>(url, data: formData);

      print('⬅️ status: ${response.statusCode}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! <= 399) {
        return processSubscribeResponse(response);
      } else {
        throw Exception('Failed to load astor (subscribe web). '
            'Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR (SUBSCRIBE web): ${e.message}');
      print('   TYPE: ${e.type}');
      print('   RESPONSE STATUS: ${e.response?.statusCode}');
      print('   RESPONSE DATA: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  void open(String aBaseUrl) {
    openWeb(aBaseUrl);
  }

  // --- procesamiento de respuestas -------------------------------------- //

  bool isDownloadFile(Response response) {
    final contentTypes = response.headers['content-type'];
    if (contentTypes == null || contentTypes.isEmpty) return false;

    final mime = contentTypes.first;
    if (mime.contains("text/csv")) return true;
    if (mime.contains("application/vnd.ms-excel")) return true;

    return false;
  }

  Future<AstorApp> processResponse(Response response) async {
    if (isDownloadFile(response)) {
      return processDownloadResponse(response);
    }

    final dynamic json = _decodeJsonBody(response);            // <<<
    return doReponse!(json);
  }

  Future<List<AstorItem>> processAjaxResponse(Response response) async {
    final dynamic json = _decodeJsonBody(response);            // <<<
    return doAjax!(json);
  }

  Future<List<AstorNotif>> processNotifResponse(Response response) async {
    final dynamic json = _decodeJsonBody(response);            // <<<
    return doNotif!(json);
  }

  Future<String> processSubscribeResponse(Response response) async {
    final dynamic json = _decodeJsonBody(response);            // <<<
    return doSubscribe!(json);
  }

  Future<AstorApp> processDownloadResponse(Response response) async {
    const filename = 'a.csv';
    final dir = "."; // ajustar si querés otra ruta
    final file = File('$dir/$filename');

    // asumimos que response.data es String
    await file.writeAsString(response.data as String);

    return doDownload!(file);
  }
}

AstorWebHttp getManager() => AstorWebHttpJs();
