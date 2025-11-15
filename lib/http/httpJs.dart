import 'dart:convert';
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
// si no usás nada de foundation, podés borrar este import
// import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes, debugPrintThrottled, kIsWeb;

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

  // Usamos late para no tener que hacer _dio!
  late final DioForBrowser _dio;

  Future<AstorApp> get(String url) {
    return getWeb(url);
  }

  void close() {
    // Si necesitás cerrar algo de Dio, lo podés hacer acá
  }

  Future<AstorApp> post(String url, Map<String, String> params) {
    return postWeb(url, params);
  }

  Future<List<AstorItem>> ajax(String url, Map<String, String> params) {
    return ajaxWeb(url, params);
  }

  Future<List<AstorNotif>> notification(String url, Map<String, String> params) {
    return notifWeb(url, params);
  }

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

  Future<AstorApp> getWeb(String url) async {
    final response = await _dio.get<dynamic>(url);
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<AstorApp> postWeb(String url, Map<String, String> params) async {
    final formData = FormData.fromMap(params);
    final response = await _dio.post<dynamic>(url, data: formData);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<List<AstorItem>> ajaxWeb(String url, Map<String, String> params) async {
    final formData = FormData.fromMap(params);
    final response = await _dio.post<dynamic>(url, data: formData);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! <= 399) {
      return processAjaxResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<List<AstorNotif>> notifWeb(
    String url,
    Map<String, String> params,
  ) async {
    final formData = FormData.fromMap(params);
    final response = await _dio.post<dynamic>(url, data: formData);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! <= 399) {
      return processNotifResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<String> subscribeWeb(
    String url,
    Map<String, String> params,
  ) async {
    final formData = FormData.fromMap(params);
    final response = await _dio.post<dynamic>(url, data: formData);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! <= 399) {
      return processSubscribeResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  @override
  void open(String aBaseUrl) {
    openWeb(aBaseUrl);
  }

  bool isDownloadFile(Response response) {
    final contentTypes = response.headers['content-type'];
    if (contentTypes == null || contentTypes.isEmpty) return false;

    final mime = contentTypes.first;
    if (mime.contains("text/csv")) return true;
    if (mime.contains("application/vnd.ms-excel")) return true;

    // if (mime.contains("file/")) return true;
    // if (mime.contains("business_resource/")) return true;
    return false;
  }

  Future<AstorApp> processResponse(Response response) async {
    if (isDownloadFile(response)) {
      return processDownloadResponse(response);
    }

    final dynamic json = response.data;
    // asumimos que doReponse no es null cuando se usa
    return doReponse!(json);
  }

  Future<List<AstorItem>> processAjaxResponse(Response response) async {
    final dynamic json = response.data;
    return doAjax!(json);
  }

  Future<List<AstorNotif>> processNotifResponse(Response response) async {
    final dynamic json = response.data;
    return doNotif!(json);
  }

  Future<String> processSubscribeResponse(Response response) async {
    final dynamic json = response.data;
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
