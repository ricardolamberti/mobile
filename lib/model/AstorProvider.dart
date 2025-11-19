


import 'dart:io';

import 'package:astor_mobile/http/astorHttp.dart';
import 'package:astor_mobile/json_schema_form.dart';
import 'package:astor_mobile/json_textform/utils-components/pushNotification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

import '../main.dart';
import 'astorSchema.dart';
import 'dart:async';




class AstorProvider with ChangeNotifier {

  static final String url = kIsWeb?dotenv.env["LOCAL_URL"]!: dotenv.env["URL"]!;



  Map<String, String> mainForm = <String, String>{};

  Map<String, String> buildMainForm(Map<String, dynamic> json) {
    Map<String, String> main = <String, String>{};
    main['dg_dictionary'] = json['dictionary'];
    main['dg_request'] = json['request'];
    main['subsession'] = json['subsession'];
    main['src_uri'] = json['src_uri'];
    main['src_sbmt'] = json['src_sbmt'];
    main['dg_action'] = ""; // comunica la accion a realizar
    main['dg_tree_selection'] = ""; // comunica la seleccion en el arbol
    main['dg_source_control_id'] = ""; // contiene el parent en el formlov
    main['dg_client_conf'] = ""; // configuracion del cliente ancho y alto de la pantalla
    main['dg_act_owner'] = ""; //  comunica el owner action de la accion
    main['dg_is_modal'] = ""; //  comunica si la accion es modal
    main['dg_object_owner'] = ""; //  comunica el object owner de la accion
    main['dg_object_owner_dest'] = ""; //   comunica el object owner dest de la accion swap
    main['dg_object_owner_context'] = ""; //  comunica el object owner context para lista extendidas
    main['dg_object_select'] = ""; //   comunica el object select  de la accion
    main['dg_table_provider'] =""; //   comunica el action owner de la accion en las solapas
    main['dg_clear_select'] = ""; //   comunica que se elimina la seleccion anterior
    main['dg_multiple_owner_list'] =""; //   comunica multiples owners de la accion
    main['dg_is_multiple_owner'] =""; //  comunica si hay multiples owners de la accion
    main['dg_row_select'] = ""; //   comunica multiples owners de la accion
    main['dg_cell_select'] = ""; //  comunica multiples owners de la accion
    main['dg_scroller'] = ""; //  comunica la posicion y del scroll actual
    main['dg_back_modal'] =""; //  comunica si los retornos deben hacerse a modal
    main['dg_extra_form_data'] = ""; //  si el form es embedded
    main['dg_stadistics'] = ""; //  informacion estadistica
    main['dg_url'] = url; //   url address
    main['is_mobile'] = 'Y';
    return mainForm = main;
  }

  late Future<AstorApp?>? _futureAstorApp = firstAction();
  AstorApp? _astorApp;
  bool _redraw = false;

  Future<AstorApp?>? get futureAstorApp => _futureAstorApp;

  set redraw(bool value) {
    _redraw = value;
    if (_redraw) {
      notifyListeners();
    }
  }

  set futureAstorApp(Future<AstorApp?>? value) {
    _futureAstorApp = value;
  }

  set astorApp(AstorApp? value) {
    _astorApp = value;
  }

  AstorApp? get astorApp => _astorApp;

  bool get redraw => _redraw;

  void reload() {
    _futureAstorApp = firstAction();
    notifyListeners();
  }


  // bool isHistoriable(String url,String ajaxContainer) {
  //   return (url.indexOf('do-Back')==-1 &&  ajaxContainer=='view_area_and_title');
  // }
  // bool isBackHistoriable(String url) {
  //   return url.indexOf('do-Back')!=-1;
  // }
  Future<AstorApp?>? doAction(AstorComponente comp, BuildContext? context,
      String? zActionTarget, bool? zuploaddata, bool zredraw) {
    Map<String, dynamic> parameters = <String, dynamic>{};
    Map<String, String> params = <String, String>{};
    Map<String, dynamic> parametersFormLov = <String, dynamic>{};
    String actionTarget = zActionTarget ?? comp.actionTarget;
    String ajaxContainer = comp.ajaxContainer;
    bool uploaddata = zuploaddata ?? comp.uploadData;
    bool modoGet = true;
    addActionOwnerParameters(actionTarget, comp, context);
    if ((ajaxContainer != "") && astorApp != null) {
      // addFormLovParameters(params, actionTarget);
      addSubmitParameters(params, actionTarget, comp);
      modoGet = false;
    }
    if (astorApp != null) {
      parameters = getMap(astorApp!.application_views, uploaddata);
    }


    if (context != null) {
      addLoginParameters(params, actionTarget, context);
    }

    String nextUrl = "";
    nextUrl += "/$actionTarget";
    params.addAll(mainForm);
    toParams(params, parameters);
    // addTreeParameters(zFormToSubmit); no implementado
    if (modoGet) {
      nextUrl += "?${toUrl(params)}";
      futureAstorApp = astorHttp.get(nextUrl);
    } else {
      futureAstorApp = astorHttp.post(nextUrl, params);
    }

    if (zredraw) {
      redraw = true;
    }
    return futureAstorApp;
  }

  Future<String> subscribe() {
    String nextUrl = "/do-getchannel";
    Map<String, String> params = <String, String>{};
    params.addAll(mainForm);
    params['mobile_uuid']=uuid;
    params['mobile_type']=getDeviceType();
    return astorHttp.subscribe(nextUrl, params);

  }

  Future<AstorApp?>? doDiferido(AstorComponente comp, BuildContext? context,
      String? zActionTarget) {

    Map<String, dynamic> parameters = <String, dynamic>{};
    Map<String, String> params = <String, String>{};
    Map<String, dynamic> parametersFormLov = <String, dynamic>{};
    String actionTarget = zActionTarget ?? comp.actionTarget;
    String ajaxContainer = comp.ajaxContainer;
    addActionOwnerParameters(actionTarget, comp, context);
    addSubmitParameters(params, actionTarget, comp);

    String nextUrl = "";
    nextUrl += "/$actionTarget";
    params.addAll(mainForm);
    toParams(params, parameters);
    // addTreeParameters(zFormToSubmit); no implementado

    return astorHttp.post(nextUrl, params);
  }

  Future<List<AstorNotif>>? doNotification() {

    String nextUrl = "do-pushnotification";
    Map<String, String> params = <String, String>{};
    params.addAll(mainForm);
    params['mobile_id']=uuid;
    params['mobile_type']=deviceType;

    return astorHttp.notification(nextUrl, params);
  }

  late AstorWebHttp astorHttp = getHttp();

  AstorWebHttp getHttp() {
    AstorWebHttp obj = AstorWebHttp.instance;
    obj.open(url);
    obj.setResponses(
      doReponse: processResponse,
      doAjax: processAjax,
      doSubscribe: processSubscribe,
      doNotif: processNotif,
      doDownload: processDownload
    );
    return obj;
  }

  Future<AstorApp> firstAction() {
    astorApp = null;
    userLogin=null;
    return astorHttp.get('/mobile-do');
  }
  static String? userLogin;

  void checkUserLogin() {
    if (_astorApp==null) return;
    if (_astorApp!.user=="") return;
    if (userLogin!=null) {
      if (userLogin!=_astorApp!.user) {
        userLogin = _astorApp!.user;
        detectNewLogin();
      }
      return;
    }
    userLogin=_astorApp!.user;
    detectNewLogin();
  }
  void detectNewLogin() async {
    if (kIsWeb) return;
    PushNotification notification = PushNotification();
    notification.subscribe(this);
    await subscribeBackroundTask();
  }

  Future<AstorApp> processResponse(dynamic json) async {
    String ajaxContainer = json['ajax_container'];
    if (ajaxContainer.startsWith("modal_")) {
      ajaxContainer = "view_area_and_title"; // modal no implementado
    }

    buildMainForm(json);
    if (ajaxContainer == "" || astorApp == null) {
      redraw=true;
      return AstorApp.fromJson(json);
    } else {
      return _astorApp!.update(ajaxContainer, json); //simil ajax
    }
  }

  void toParams(Map<String, String> dest, Map<String, dynamic> orig) {
    orig.forEach((key, value) =>
    dest[key] = value == null ? "" : value.toString());
  }

  String toUrl(Map<String, String> form) {
    String output = "";
    form.forEach((key, value) {
      output += ((output == "") ? "" : "&") + key + "=" +
          Uri.encodeComponent(value);
    });

    return output;
  }

  void addLoginParameters(Map<String, String> param, zUrl,
      BuildContext context) {
    String newConf = 'pw=${MediaQuery
        .of(context)
        .size
        .width
        .toInt()},ph=${MediaQuery
        .of(context)
        .size
        .height
        .toInt()}';
    if (zUrl == 'do-login') {
      newConf += ',sw=${MediaQuery
          .of(context)
          .size
          .width
          .toInt()},sh=${MediaQuery
          .of(context)
          .size
          .height
          .toInt()}';
    }
    mainForm['dg_client_conf'] = newConf;
    if (astorApp != null) {
      mainForm['subsession'] = astorApp!.subsession;
    }
  }

  // void addFormLovParameters(Map<String,String> param,String zUrl) {
  //   if (zUrl.indexOf('do-FormLovRefreshAction')>=0 || zUrl.indexOf('do-PartialRefreshForm')>=0) {
  //     param['dg_formLov_id']=astorApp!.formLovControlId;
  //   }
  //
  // }


  void addSubmitParameters(Map<String, String> param, String? zUrl,
      AstorComponente comp) {
    param['issubmit'] = comp.issubmit ? "true" : "false";
    param['isbackaftersubmit'] = comp.isSubmitAfterBack ? "true" : "false";
    param['data_asoc'] = comp.dataAsoc;
    param['ajaxContainer'] = comp.ajaxContainer;
    if (isAjaxSubmit(zUrl)) {
      // param['dg_container_height']=astorApp.findAjaxContainer(comp.attributes['action_ajax_container']).height;
      // param['dg_container_width']=astorApp.findAjaxContainer(comp.attributes['action_ajax_container']).width;
      param['back_on_print'] = comp.backOnPrinter;
      param['refresh_on_print'] = comp.refreshOnPrinter;
    }
  }

  void addActionOwnerParameters(String? zUrl, AstorComponente comp,
      BuildContext? context) {
    String zActionOwnerProvider = comp.actionObjProvider;
    String zTheObjectResolveString = comp.resolveString;
    String? zObjectOwnerId = comp.objectOwner;
    String zIdAction = comp.idAction;
    String zAjaxContainer = comp.ajaxContainer;
    String specialselector = comp.specialSelector;
    String contextobj = comp.contextId;
    String? sTheObjectResolveString;
    String? zObjectOwnerDest;
    String? sMultipleOwnerList = "";
    bool bHasMultipleOwner = false;
    String? zCellSelect = "";
    String? zRowSelect = "";
    String? zObjectSelectId = "";
    String zClearSelection = "0";
    String sScroller = "";
    bool embedded = false;
    String objectDrop = ""; //!event || !event.dataTransfer ? null : event.dataTransfer.getData("object");
    // if (objectDrop) {
    //   // var oProvider = getObjectProvider(zActionOwnerProvider);
    //   zObjectSelectId = zObjectOwnerId; // listener
    //   zObjectOwnerId = objectDrop; // drop
    // } else
    if (zTheObjectResolveString != "" && zTheObjectResolveString.isNotEmpty) {
      sTheObjectResolveString = zTheObjectResolveString;
    } else {
      sTheObjectResolveString = '';
      if (zActionOwnerProvider != "" && zActionOwnerProvider.isNotEmpty) {
        Widget? oProvider = astorApp!.getObjectProvider(zActionOwnerProvider);
        // alert("getObjectProvider="+oProvider);
        if (oProvider != null && (oProvider is InterfaceProvider)) {
          InterfaceProvider oProviderList = oProvider as InterfaceProvider;
          if (specialselector != '') {
            zObjectOwnerId = oProviderList.getCurrentActionOwnerFromSelect();
            sMultipleOwnerList =
                oProviderList.getSelectionSpecial(specialselector);
            bHasMultipleOwner =
                oProviderList.hasMultipleSelectSpecial(specialselector);
            zClearSelection = "0";
          } else if (!oProviderList.getClearSelection() &&
              oProviderList.hasMoreSelections()) {
            zObjectOwnerId = oProviderList.getCurrentActionOwnerFromSelect();
            sMultipleOwnerList = oProviderList.getSelection();
            bHasMultipleOwner = oProviderList.hasMultipleSelect();
            zClearSelection = oProviderList.getClearSelection() ? "1" : "0";
          } else {
            zObjectOwnerId = (zObjectOwnerId != '') ? zObjectOwnerId : oProviderList.getCurrentActionOwner();
            zObjectOwnerDest = oProviderList.getMultipleCurrentActionOwnerDest();
            sMultipleOwnerList = oProviderList.getMultipleActionOwnerList();
            bHasMultipleOwner = oProviderList.hasMultipleSelect();
            zClearSelection = oProviderList.getClearSelection() ? "1" : "0";
          }
          embedded = false;
          zRowSelect = oProviderList.getSelectedRow();
          zCellSelect = oProviderList.getSelectedCell();
          if (isWinDependant(zUrl) && zObjectOwnerId == null) {
            throw Exception("seleccionar una fila");
          }
        }
      } else {
        if (zUrl!.contains('do-SwapListRefreshAction') ||
            zUrl.contains('do-WinListRefreshAction') ||
            zUrl.contains('do-WinListExpandAction')) {
          Widget? oProvider = astorApp!.getObjectProvider(zActionOwnerProvider);
          if (oProvider != null && (oProvider is InterfaceProvider)) {
            InterfaceProvider oProviderList = oProvider as InterfaceProvider;
            zClearSelection = oProviderList.getClearSelection() ? "1" : "0";
            zObjectSelectId = oProviderList.getCurrentActionOwnerFromSelect();
            zRowSelect = oProviderList.getSelectedRow();
            zCellSelect = oProviderList.getSelectedCell();
            sMultipleOwnerList = oProviderList.getSelection();
          }
        }
      }
    }
    if (zUrl!.contains('do-PartialRefreshForm')) {
      mainForm['dg_source_control_id'] = comp.name;
    }
    mainForm['is_modal'] = "N";
    mainForm['dg_act_owner'] = sTheObjectResolveString;
    mainForm['dg_action'] = zIdAction ?? "";
    mainForm['dg_object_owner'] = zObjectOwnerId ?? "";
    mainForm['dg_object_owner_dest'] =
    zObjectOwnerDest ?? "";
    mainForm['dg_object_owner_context'] = contextobj ?? "";
    mainForm['dg_object_select'] =
    zObjectSelectId ?? "";
    mainForm['dg_clear_select'] =
    zClearSelection ?? "false";
    mainForm['dg_table_provider'] =
    zActionOwnerProvider ?? "";
    mainForm['dg_cell_select'] = zCellSelect ?? "";
    mainForm['dg_row_select'] = zRowSelect ?? "";
    mainForm['dg_multiple_owner_list'] =
    sMultipleOwnerList ?? "";
    mainForm['dg_is_multiple_owner'] = (bHasMultipleOwner ? "true" : "false");
    mainForm['dg_scroller'] = sScroller ?? "";
    mainForm['dg_back_modal'] = "N";
    mainForm['dg_extra_form_data'] =
        "embedded=${embedded ? "true" : "false"}";
    mainForm['dg_stadistics'] = "";
    mainForm['dg_ajaxcontainer'] = zAjaxContainer ?? "";
    mainForm['dg_url'] = url;
  }

  void closeSession(bool deleteCookie) {
    astorHttp.close();
    firstAction();
  }

  bool isWinDependant(zUrl) {
    if (zUrl.indexOf("do-WinListDeleteAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    if (zUrl.indexOf("do-ViewAreaAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    if (zUrl.indexOf("do-ViewAreaAndTitleAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    if (zUrl.indexOf("do-allPanelsAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }

    if (zUrl.indexOf("do-WinListReloadAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    //alert("not is ajax submit");
    return false;
  }


  bool isAjaxSubmit(zUrl) {
    //alert("testing is ajax submit");
    if (zUrl.indexOf("do-WinListRefreshAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    if (zUrl.indexOf("do-SwapListRefreshAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    if (zUrl.indexOf("do-WinListDeleteAction") == 0) {
      //alert("is Submit WinListDelete");
      return true;
    }
    if (zUrl.indexOf("do-WinListReloadAction") == 0) {
      //alert("is Submit WinListReload");
      return true;
    }
    if (zUrl.indexOf("do-comboAction") == 0) {
      //alert("is Submit ComboAction");
      return true;
    }
    if (zUrl.indexOf("do-comboFormLovAction") == 0) {
      //alert("is Submit ComboFormLovAction");
      return true;
    }
    if (zUrl.indexOf("do-FormLovRefreshAction") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }
    if (zUrl.indexOf("do-security") == 0) {
      //alert("is Submit WinListRefresh");
      return true;
    }

    //alert("not is ajax submit");
    return false;
  }


  Future<List<AstorItem>?>? winLovOpen(AstorCombo combo, String search) {
    Map<String, dynamic> parameters = <String, dynamic>{};
    Map<String, String> params = <String, String>{};

    String listFilter = "";
    String url = combo.searchUrl;

    var cfg = {
      "ajaxContainer": combo.name,
      "dg_dictionary": mainForm['dg_dictionary'],
      "subsession": mainForm['subsession'],
      "src_uri": mainForm['src_uri'],
      "src_sbmt": mainForm['src_sbmt'],
      "dg_comboFormLov_id": combo.name,
      "dg_object_owner": combo.getObjectOwner(),
      "dg_object_action": combo.getobjectAction(),
      "dg_table_provider": combo.getObjProvider(),
      "dg_source_control_id": combo.name,
      "dg_partial_info": 'S',
      "search": search,
      "${combo.name}_text": search,
      "type": 'public'
    };

    parameters = getMap(astorApp!.application_views, true);

    String nextUrl = "";
    nextUrl += "/$url";
    params.addAll(mainForm);
    toParams(params, parameters);
    toParams(params, cfg);

    Future<List<AstorItem>?> result = astorHttp.ajax(nextUrl, params);

    return result;
  }



  Future<List<AstorItem>> processAjax(dynamic json) async {
    List<AstorItem> itemsList = [];
    if (json['results'] != null) {
      var listItems = json['results'] as List;
      for (var i in listItems) {
        AstorItem item = AstorItem.fromJson(i);
        itemsList.add(item);
      }
    }
    return itemsList;
  }

  Future<List<AstorNotif>> processNotif(dynamic json) async {
    List<AstorNotif> itemsList = [];
    if (json['results'] != null) {
      var listItems = json['results'] as List;
      for (var i in listItems) {
        AstorNotif item = AstorNotif.fromJson(i);
        itemsList.add(item);
      }
    }
    return itemsList;
  }

  Future<String> processSubscribe(dynamic json) async {
      return json['channel'];

  }

  Future<AstorApp> processDownload(File file) async {
    return astorApp!.download(file);
  }

}

abstract class InterfaceProvider {
  String? getCurrentActionOwnerFromSelect();
  String? getSelectionSpecial(String specialselector);
  bool hasMultipleSelectSpecial(String specialselector);
  String? getSelection();
  bool hasMultipleSelect();
  bool hasMoreSelections();
  String? getCurrentActionOwner();
  String? getMultipleCurrentActionOwnerDest();
  String? getMultipleActionOwnerList();
  bool getClearSelection();
  String? getSelectedRow();
  String? getSelectedCell();
}
