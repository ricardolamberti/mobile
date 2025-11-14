import 'dart:convert';
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes, debugPrintThrottled, kIsWeb;

import 'package:dio/adapter_browser.dart';
import 'package:dio/browser_imp.dart';
import 'package:dio/dio.dart';
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
  DioForBrowser? _dio;

  Future<AstorApp> get(String url) {
    return getWeb(url);
  }

  void close() {

  }

  Future<AstorApp> post(String url, Map<String, String>params) {
    return postWeb(url, params);
  }

  Future<List<AstorItem>> ajax(String url, Map<String, String>params) {
    return ajaxWeb(url, params);
  }

  Future<List<AstorNotif>> notification(String url, Map<String, String>params) {
    return notifWeb(url, params);
  }

  Future<String> subscribe(String url, Map<String, String>params) {
    return subscribeWeb(url, params);
  }

  void openWeb( String _aBaseUrl) {

    _dio = DioForBrowser(new BaseOptions(
      baseUrl: _aBaseUrl,
      connectTimeout: 15000,
      receiveTimeout: 13000,
      headers: {
        "Accept": "application/json",
        'Access-Control-Allow-Origin': _aBaseUrl,
        'Access-Control-Allow-Methods': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Access-Control-Allow-Credentials,Access-Control-Allow-Methods, Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers',
      },
    ));
    var adapter = BrowserHttpClientAdapter();
    adapter.withCredentials = true;
    _dio!.httpClientAdapter = adapter;
  }

  void setResponses({OnResponse? doReponse, OnAjax? doAjax, OnNotif? doNotif, OnSubscribe? doSubscribe, OnDownload? doDownload}) {
    this.doReponse = doReponse;
    this.doAjax = doAjax;
    this.doNotif = doNotif;
    this.doSubscribe = doSubscribe;
    this.doDownload = doDownload;
  }


  Future<AstorApp> getWeb(url) async {
    final response = await _dio!.get(url);
    if (response.statusCode! >= 200 && response.statusCode! <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }


  Future<AstorApp> postWeb(url, Map<String, String>params) async {
    FormData formData = FormData.fromMap(params);
    final response = await _dio!.post(url, data: formData);

    if (response.statusCode! >= 200 && response.statusCode! <= 399) {
      return processResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<List<AstorItem>> ajaxWeb(url, Map<String, String>params) async {
    FormData formData = FormData.fromMap(params);
    final response = await _dio!.post(url, data: formData);

    if (response.statusCode! >= 200 && response.statusCode! <= 399) {
      return processAjaxResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }

  Future<List<AstorNotif>> notifWeb(url, Map<String, String>params) async {
    FormData formData = FormData.fromMap(params);
    final response = await _dio!.post(url, data: formData);

    if (response.statusCode! >= 200 && response.statusCode! <= 399) {
      return processNotifResponse(response);
    } else {
      throw Exception('Failed to load astor');
    }
  }
  Future<String> subscribeWeb(url, Map<String, String>params) async {
    FormData formData = FormData.fromMap(params);
    final response = await _dio!.post(url, data: formData);

    if (response.statusCode! >= 200 && response.statusCode! <= 399) {
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
    if (response.headers['content-type']==null) return false;
    String? url= response.headers['content-type']!.first;
    if (url==null) return false;
    if (url.indexOf("text/csv")!=-1) return true;
    if (url.indexOf("application/vnd.ms-excel")!=-1) return true;

    // if (url.indexOf("file/")!=-1) return true;
    // if (url.indexOf("business_resource/")!=-1) return true;
    return false;
  }
  Future<AstorApp> processResponse( Response response) async {
      if (isDownloadFile(response)) {
        return processDownloadResponse(response);
      }

      dynamic json =  response.data;
      return doReponse!(json);
  }
  Future<List<AstorItem>> processAjaxResponse( response) async {
    dynamic json =  response.data;
    return doAjax!(json);
  }

  Future<List<AstorNotif>> processNotifResponse( response) async {
    dynamic json =  response.data;
    return doNotif!(json);
  }


  Future<String> processSubscribeResponse( response) async {
    dynamic json =  response.data;
    return doSubscribe!(json);
  }


  Future<AstorApp> processDownloadResponse(Response response) async {
    String filename = 'a.csv';
    String data = response.data;
    // filename = filename.substring(filename.lastIndexOf("/"));
    String dir = ".";
    File file = new File('$dir/$filename');
    file.writeAsString(response.data);

    return doDownload!(file);
  }

}

AstorWebHttp getManager() => AstorWebHttpJs();
