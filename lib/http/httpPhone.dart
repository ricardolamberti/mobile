
import 'dart:convert';
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;

import 'astorHttp.dart';



class AstorWebHttpPhone extends AstorWebHttp  {

  OnResponse? doReponse;
  OnAjax? doAjax;
  OnNotif? doNotif;
  OnSubscribe? doSubscribe;
  OnDownload? doDownload;
  String? aBaseUrl;

  String aToken = '';
  http.Client? client;

  AstorWebHttpPhone();

  Future<AstorApp> get(String url) {
      return getPhone(url);
  }

  Future<AstorApp> post(String url, Map<String, String>params) {
      return postPhone(url, params);
  }

  Future<List<AstorItem>> ajax(String url, Map<String, String>params) {
    return ajaxPhone(url, params);
  }

  Future<List<AstorNotif>> notification(String url, Map<String, String>params) {
    return notifPhone(url, params);
  }
  Future<String> subscribe(String url, Map<String, String>params) {
    return subscribePhone(url, params);
  }


  void openPhone(String _aBaseUrl) {
    aBaseUrl = _aBaseUrl;
    client = http.Client();
  }

  void setResponses({OnResponse? doReponse, OnAjax? doAjax, OnNotif? doNotif, OnSubscribe? doSubscribe, OnDownload? doDownload}) {
    this.doReponse =doReponse;
    this.doAjax = doAjax;
    this.doNotif = doNotif;
    this.doSubscribe = doSubscribe;
    this.doDownload = doDownload;
  }


  Future<AstorApp> getPhone(url) async {
    initHeader();
    if (aToken != null && aToken!="" && (headers['cookie'] == null || headers['cookie'] == ''))
      headers["cookie"] = aToken;
    else {
      aToken = recoveryLogin();
      if (aToken!=null&& aToken!='')
        headers['cookie'] = (aToken);
    }
    http.Response response = await client!.get(Uri.parse(aBaseUrl!+url), headers: headers);
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }
  late Map<String, String> headers = initHeader();


  Map<String, String> initHeader() {
    return {
    "Accept": "application/json",
    'Access-Control-Allow-Origin': aBaseUrl!,
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Credentials': 'true',
    'Access-Control-Allow-Headers': 'Access-Control-Allow-Credentials,Access-Control-Allow-Methods, Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers',
    };
  }
  void close() {
    headers['cookie'] == '';
  }


  void updateCookie(response) {
    // String? rawCookie = response.headers['set-cookie'];
    // if (rawCookie == null)
    String rawCookie = response.headers['set-mobile-cookie'];
    String rawPersistentCookie = response.headers['set-mobile-persistent-cookie'];

    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      aToken = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      headers['cookie'] = (aToken);
    }
    if (rawPersistentCookie != null) {
      saveLogin(rawPersistentCookie);
    }

  }

  Future<AstorApp> postPhone(url, Map<String, String>params) async {
    if (aToken != null && (headers['cookie'] == null ||
        headers['cookie'] == ''))
      headers["cookie"] = aToken;

    final response =await client!.post(Uri.parse(aBaseUrl!+url),headers: headers,body:params);
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }
  Future<List<AstorItem>> ajaxPhone(url, Map<String, String>params) async {
    if (aToken != null && (headers['cookie'] == null ||
        headers['cookie'] == ''))
      headers["cookie"] = aToken;

    final response =await client!.post(Uri.parse(aBaseUrl!+url),headers: headers,body:params);
    updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processAjaxResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }
  Future<List<AstorNotif>> notifPhone(url, Map<String, String>params) async {
    final response =await client!.post(Uri.parse(aBaseUrl!+url),headers: headers,body:params);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processNotifResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }


  Future<String> subscribePhone(url, Map<String, String>params) async {
    if (aToken != null && (headers['cookie'] == null ||
        headers['cookie'] == ''))
      headers["cookie"] = aToken;

    final response =await client!.post(Uri.parse(aBaseUrl!+url),headers: headers,body:params);
    // updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode <= 399) {
      return processSubscribeResponse(response);
    } else {
      throw Exception('Failed parser '+response.body);
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
    debugPrint(response.body,wrapWidth: 200000);
    dynamic json = jsonDecode( Utf8Decoder().convert(response.bodyBytes));

    return doReponse!(json);
  }
  Future<List<AstorItem>> processAjaxResponse(http.Response response) async {
    debugPrint(response.body,wrapWidth: 200000);
    dynamic json = jsonDecode( Utf8Decoder().convert(response.bodyBytes));

    return doAjax!(json);
  }
  Future<List<AstorNotif>> processNotifResponse(http.Response response) async {
    debugPrint(response.body,wrapWidth: 200000);
    dynamic json = jsonDecode( Utf8Decoder().convert(response.bodyBytes));

    return doNotif!(json);
  }
  Future<String> processSubscribeResponse(http.Response response) async {
    debugPrint(response.body,wrapWidth: 200000);
    dynamic json = jsonDecode( Utf8Decoder().convert(response.bodyBytes));

    return doSubscribe!(json);
  }
  bool isDownloadFile(http.Response response) {
    String? url= response.headers['content-disposition'];
    if (url==null) return false;
    if (url.indexOf("attachment")!=-1) return true;
    return false;
  }

  Future<AstorApp> processDownloadResponse(http.Response response) async {
    String filename = response.headers['content-disposition']!;
    filename = filename.substring(filename.lastIndexOf("=")+1);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    file.writeAsBytes(response.bodyBytes);
    return doDownload!(file);
  }

  final storage = GetStorage();
  void saveLogin(String token) {
    int seconds = 0 ;
    List<String> a = token.split(';');
    for (String s in a) {
      if (s.indexOf('Max-Age=')!=-1) {
        seconds = int.parse(s.substring(s.indexOf('Max-Age=')+8).trim());
      }
    }
    if (seconds==0) {
      return;
    }
    DateTime fecha = DateTime.now();
    fecha= fecha.add(Duration(seconds: seconds));
    storage.write("userInfoDate", fecha.toIso8601String());
    storage.write("userInfo", token);  // Save here
    storage.save();
  }
  String recoveryLogin() {
    String fecha = storage.read("userInfoDate");
    if (fecha==null) return '';
    String hoy = DateTime.now().toIso8601String();
    if (fecha.compareTo(hoy)<=0) return '';
    return storage.read("userInfo");  // Save here
  }
}


AstorWebHttp getManager() => AstorWebHttpPhone();
