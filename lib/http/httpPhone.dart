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

  Future<AstorApp> get(String url) {
    return getPhone(url);
  }

  Future<AstorApp> post(String url, Map<String, String> params) {
    return postPhone(url, params);
  }

  Future<List<AstorItem>> ajax(String url, Map<String, String> params) {
    return ajaxPhone(url, params);
  }

  Future<List<AstorNotif>> notification(
    String url,
    Map<String, String> params,
  ) {
    return notifPhone(url, params);
  }

  Future<String> subscribe(String url, Map<String, String> params) {
    return subscribePhone(url, params);
  }

  void openPhone(String baseUrl) {
    aBaseUrl = baseUrl;
    client = http.Client();
    headers = initHeader();
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

  Map<String, String> initHeader() {
    return {
      "Accept": "application/json",
      'Access-Control-Allow-Origin': aBaseUrl,
      'Access-Control-Allow-Methods': '*',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Allow-Headers':
          'Access-Control-Allow-Credentials,Access-Control-Allow-Methods, Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers',
    };
  }

  void close() {
    headers['cookie'] = '';
    client.close();
  }

  Future<AstorApp> getPhone(String url) async {
    // siempre inicializamos headers en openPhone
    if (aToken.isNotEmpty &&
        (headers['cookie'] == null || headers['cookie']!.isEmpty)) {
      headers["cookie"] = aToken;
    } else {
      aToken = recoveryLogin();
      if (aToken.isNotEmpty) {
        headers['cookie'] = aToken;
      }
    }

    final response =
        await client.get(Uri.parse(aBaseUrl + url), headers: headers);
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  void updateCookie(http.Response response) {
    final String? rawCookie = response.headers['set-mobile-cookie'];
    final String? rawPersistentCookie =
        response.headers['set-mobile-persistent-cookie'];

    if (rawCookie != null) {
      final index = rawCookie.indexOf(';');
      aToken = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      headers['cookie'] = aToken;
    }

    if (rawPersistentCookie != null) {
      saveLogin(rawPersistentCookie);
    }
  }

  Future<AstorApp> postPhone(
    String url,
    Map<String, String> params,
  ) async {
    if (aToken.isNotEmpty &&
        (headers['cookie'] == null || headers['cookie']!.isEmpty)) {
      headers["cookie"] = aToken;
    }

    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<List<AstorItem>> ajaxPhone(
    String url,
    Map<String, String> params,
  ) async {
    if (aToken.isNotEmpty &&
        (headers['cookie'] == null || headers['cookie']!.isEmpty)) {
      headers["cookie"] = aToken;
    }

    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processAjaxResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<List<AstorNotif>> notifPhone(
    String url,
    Map<String, String> params,
  ) async {
    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processNotifResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<String> subscribePhone(
    String url,
    Map<String, String> params,
  ) async {
    if (aToken.isNotEmpty &&
        (headers['cookie'] == null || headers['cookie']!.isEmpty)) {
      headers["cookie"] = aToken;
    }

    final response = await client.post(
      Uri.parse(aBaseUrl + url),
      headers: headers,
      body: params,
    );

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

  Future<AstorApp> processResponse(http.Response response) async {
    if (isDownloadFile(response)) {
      return processDownloadResponse(response);
    }
    debugPrint(response.body, wrapWidth: 200000);
    final dynamic json =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    return doReponse!(json);
  }

  Future<List<AstorItem>> processAjaxResponse(
    http.Response response,
  ) async {
    debugPrint(response.body, wrapWidth: 200000);
    final dynamic json =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    return doAjax!(json);
  }

  Future<List<AstorNotif>> processNotifResponse(
    http.Response response,
  ) async {
    debugPrint(response.body, wrapWidth: 200000);
    final dynamic json =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    return doNotif!(json);
  }

  Future<String> processSubscribeResponse(
    http.Response response,
  ) async {
    debugPrint(response.body, wrapWidth: 200000);
    final dynamic json =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    return doSubscribe!(json);
  }

  bool isDownloadFile(http.Response response) {
    final String? contentDisposition = response.headers['content-disposition'];
    if (contentDisposition == null) return false;
    return contentDisposition.contains('attachment');
  }

  Future<AstorApp> processDownloadResponse(
    http.Response response,
  ) async {
    String filename = response.headers['content-disposition']!;
    filename = filename.substring(filename.lastIndexOf('=') + 1);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.bodyBytes);

    return doDownload!(file);
  }

  final storage = GetStorage();

  void saveLogin(String token) {
    int seconds = 0;
    final parts = token.split(';');
    for (final s in parts) {
      if (s.contains('Max-Age=')) {
        seconds =
            int.parse(s.substring(s.indexOf('Max-Age=') + 8).trim());
      }
    }
    if (seconds == 0) {
      return;
    }

    var fecha = DateTime.now();
    fecha = fecha.add(Duration(seconds: seconds));
    storage.write("userInfoDate", fecha.toIso8601String());
    storage.write("userInfo", token);
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
