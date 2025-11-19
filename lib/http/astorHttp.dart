
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:astor_mobile/http/httpStub.dart'
if (dart.library.io)  'package:astor_mobile/http/httpPhone.dart'
if (dart.library.js) 'package:astor_mobile/http/httpJs.dart';



typedef OnResponse = Future<AstorApp> Function(dynamic value);
typedef OnAjax = Future<List<AstorItem>> Function(dynamic value);
typedef OnDownload = Future<AstorApp> Function(File value);
typedef OnNotif = Future<List<AstorNotif>> Function(dynamic value);
typedef OnSubscribe = Future<String> Function(dynamic value);

abstract class AstorWebHttp {

  static late AstorWebHttp _instance;

  static AstorWebHttp get instance {
    _instance = getManager();
    return _instance;
  }

  void close();
  void open(String aBaseUrl);
  void setResponses({OnResponse? doReponse, OnAjax? doAjax, OnNotif? doNotif, OnSubscribe? doSubscribe, OnDownload? doDownload});

  Future<AstorApp> get(String url);
  Future<AstorApp> post(String url, Map<String, String>params);
  Future<List<AstorItem>> ajax(String url, Map<String, String>params);
  Future<List<AstorNotif>> notification(String url, Map<String, String>params);
  Future<String> subscribe(String url, Map<String, String>params);

}