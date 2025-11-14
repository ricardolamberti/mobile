
import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:astor_mobile/http/httpStub.dart'
if (dart.library.io)  'package:astor_mobile/http/httpPhone.dart'
if (dart.library.js) 'package:astor_mobile/http/httpJs.dart';



typedef Future<AstorApp> OnResponse(dynamic value);
typedef Future<List<AstorItem>> OnAjax(dynamic value);
typedef Future<AstorApp> OnDownload(File value);
typedef Future<List<AstorNotif>> OnNotif(dynamic value);
typedef Future<String> OnSubscribe(dynamic value);

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