import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:astor_mobile/json_textform/components/JSONDiv.dart';
import 'package:astor_mobile/json_textform/components/JSONMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../json_textform/models/components/Action.dart';
import '../json_textform/models/components/AvaliableWidgetTypes.dart';
import '../json_textform/models/components/Icon.dart';
import 'AstorProvider.dart';

class AstorNotif  {
  final String title;
  final String info;
  final String image;
  final String link;
  final String type;

  AstorNotif({
    required this.title,
    required this.info,
    required this.image,
    required this.link,
    required this.type
  });
  factory AstorNotif.fromJson(Map<String, dynamic> json) {

    String title = json["title"] ?? "";
    String info = json["info"] ?? "";
    String image = json["image"] ?? "";
    String link = json["link"] ?? "";
    String type = json["type"] ?? "";
    return AstorNotif(
      title: title,
      info: info,
      image: image,
      link: link,
      type: type,
    );

  }
}
class AstorColumn extends AstorComponente {
  AstorColumn({type,name,components,attributes,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    value:null,
    widget: widget,
  );
  factory AstorColumn.fromJson(Map<String, dynamic> json) {
    LinkedHashMap<String,AstorColumn> columnMap=LinkedHashMap<String,AstorColumn>();
    LinkedHashMap<String,AstorRow> rowMap=LinkedHashMap<String,AstorRow>();
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";

    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }
    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }


    return AstorColumn(
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes:  attributeList,
      widget: WidgetType.column,
    );

  }
}
class AstorRow extends AstorComponente {
  Map<String,AstorCell>? cells;
  bool selected;
  bool selectedSpecial=false; //parcialmente implementado, faltaria el modo de setearlo en true
  @override
  String id;
  bool open =false;
  bool hasChilds=false;

  AstorRow({
    required this.cells,
    required this.selected,
    required this.id,
    type,name,components,attributes,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    value:null,
    widget: widget,
  );


  factory AstorRow.fromJson(Map<String, dynamic> json) {
    LinkedHashMap<String,AstorCell> cellsMap=LinkedHashMap<String,AstorCell>();
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";
    String zId = json['zobject'];


    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['cells'] !=null) {
      var listCells= json['cells'] as List;
      for (var i in listCells) {
        cellsMap[i['axis']]= AstorCell.fromJson(i);
      }
     }
    if (json['name'] !=null) {
      auxName=json['name'];
    }
    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }



    return AstorRow(
      cells: cellsMap,
      selected: json['selected']=="true",
      type: 'row',
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget: WidgetType.row,
      id: zId,
    );


  }
  String get idTree => attributes['id_tree']==null?'':attributes['id_tree']!.substring(10);
  String get idTreeParent => attributes['id_tree_parent']==null?'':attributes['id_tree_parent']!.substring(17);

}
class AstorCell extends AstorComponente {

  AstorCell({type,name,components,attributes,super.value,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    widget: widget,
  );
  factory AstorCell.fromJson(Map<String, dynamic> json) {
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";
    String auxValue = "";

    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }
    if (json['value'] !=null) {
      auxValue=json['value'];
    }
    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }


    return AstorCell(
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes:  attributeList,
      value: auxValue,
      widget: WidgetType.cell,
    );

  }
}
class AstorActions {
  final String id;
  final String win;
  final bool multiple;
  final List<String> allowed;
  final List<String> notAllowed;
  AstorActions({
    required this.id,
    required this.win,
    required this.multiple,
    required this.allowed,
    required this.notAllowed,
  });

  factory AstorActions.fromJson(Map<String, dynamic> json) {
    List<String> allowed=[];
    List<String> notAllowed=[];

    if (json['allowed'] !=null) {
      var list = json['allowed'] as List;
      for(var element in list) {
        allowed.add(element['id']);
      }
    }
    if (json['not_allowed'] !=null) {
      var list = json['not_allowed'] as List;
      for(var element in list) {
        notAllowed.add(element['id']);
      }
    }


    return AstorActions(
      id: json['id'],
      win: json['win'],
      multiple: json['multiple']=='true',
      allowed: allowed,
      notAllowed: notAllowed,
    );

  }
}
class AstorList extends AstorComponente {
  final LinkedHashMap<String,AstorColumn> columns;
  final LinkedHashMap<String,AstorRow> rows;
  final LinkedHashMap<String,AstorActions> actions;
  AstorList({
    required this.columns,
    required this.rows,
    required this.actions,
    type,name,components,attributes,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    value:null,
    widget: widget,
  );
  factory AstorList.fromJson(Map<String, dynamic> json) {
    LinkedHashMap<String,AstorColumn> columnMap=LinkedHashMap<String,AstorColumn>();
    LinkedHashMap<String,AstorRow> rowMap=LinkedHashMap<String,AstorRow>();
    LinkedHashMap<String,AstorActions> actionMap=LinkedHashMap<String,AstorActions>();
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";
    if (json['actions'] !=null) {
      var listCols = json['actions'] as List;
      for (var i in listCols) {
        actionMap[i['id']] = AstorActions.fromJson(i);
      }
    }
    if (json['header_columns'] !=null) {
      var listCols = json['header_columns'] as List;
      for (var i in listCols) {
        columnMap[i['pos']] = AstorColumn.fromJson(i);
      }
    }
    if (json['rows'] !=null) {
      var listRows = json['rows'] as List;
      for (var i in listRows) {
        String id =i['rowpos'];
        rowMap[id] = AstorRow.fromJson(i);
      }
    }
    if (json['components'] !=null) {
      var list = json['components'] as List;
       componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }

    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }

    WidgetType cWidgetType =  WidgetType.winlist;
    if (json['with_flat']=='true') cWidgetType=WidgetType.winlistflat;
    if (json['type']=='tree_responsive') cWidgetType=WidgetType.tree;


    return AstorList(
      columns: columnMap,
      rows: rowMap,
      actions: actionMap,
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget: cWidgetType,
    );

  }

  void updateActions(bool refresh,AstorApp astorapp) {

    for(String keyaction in actions.keys){
      AstorActions action = actions[keyaction]!;
      // if (action.win!="true") continue;

      if (action.allowed.isNotEmpty) {
        for (String act in action.allowed) {
          showHideAction(action,false,action.allowed,astorapp,action.win=="true");
        }

      }
      if (action.notAllowed.isNotEmpty) {
        for (String act in action.notAllowed) {
          showHideAction(action,true,action.notAllowed,astorapp,action.win=="true");

        }
      }
    }
 }
  void showHideAction(AstorActions action,bool negado,List<String> permisos,AstorApp astorapp, bool isWin) {
    bool bFind= true;
    int numSelected=0;
    bool bShowAction = false;
    if (isWin) {
      for (AstorRow schemaRows in rows.values) {
        if (!schemaRows.selected) continue;
        numSelected++;
        bFind &= showHideActionSingle(schemaRows.name,action, schemaRows, negado, permisos, astorapp, isWin);
        if (!bFind) {
          break;
        }
      }
    }
    if (numSelected==0 && action.win=="true") {
      bFind= false;
    }
    if (numSelected>1 && !action.multiple) {
      bFind = false;
    }

    bShowAction = bFind;

    astorapp.setObjAction(action.id,bShowAction);


  }
  bool showHideActionSingle(String selected,AstorActions action,AstorRow? schemaRows,bool negado,List<String> permisos,AstorApp astorapp,bool isWin) {
    var bShowAction = negado;

    for (String permiso in permisos) {

      if (schemaRows!=null && permiso==schemaRows.name) {
        bShowAction = negado?false:true;
        break;
      }
      if (selected!="" && permiso==selected) {
        bShowAction = negado?false:true;
        break;
      }
    }
    return bShowAction;
  }

  void select(AstorRow schemaRows) {
    bool ant = schemaRows.selected;
    if (true) {
      // if (!isMultiple) // habria que ver como poner un ctrl algo para la seleccion multiple
      for (var item in rows.values) {
        item.selected = false;
      }
    }
    schemaRows.selected = !ant;
   }
  void forceSelect(AstorRow schemaRows) {
    bool ant = schemaRows.selected;
    if (true) {
      // if (!isMultiple) // habria que ver como poner un ctrl algo para la seleccion multiple
      for (var item in rows.values) {
        item.selected = false;
      }
    }
    schemaRows.selected = true;
  }
  void selectAll(bool value) {
    if (!multiselect) return;
    for (var item in rows.values) {
        item.selected = value;
    }
   }

}
class AstorTree extends AstorList {
  final int treeColumn;
  LinkedHashMap<AstorRow,AstorRow> parents = LinkedHashMap();

  AstorTree({
    required this.parents,
    required this.treeColumn,
    columns,rows,actions,super.type,super.name,super.components,super.attributes,super.widget}): super(
    columns: columns,
    rows: rows,
    actions: actions,
  );

  factory AstorTree.fromJson(Map<String, dynamic> json) {
    LinkedHashMap<String,AstorColumn> columnMap=LinkedHashMap<String,AstorColumn>();
    LinkedHashMap<String,AstorRow> rowMap=LinkedHashMap<String,AstorRow>();
    LinkedHashMap<String,AstorActions> actionMap=LinkedHashMap<String,AstorActions>();
    LinkedHashMap<AstorRow,AstorRow> parents=LinkedHashMap<AstorRow,AstorRow>();
    LinkedHashMap<String,AstorRow> rowsByKeys=LinkedHashMap<String,AstorRow>();
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";
    if (json['actions'] !=null) {
      var listCols = json['actions'] as List;
      for (var i in listCols) {
        actionMap[i['id']] = AstorActions.fromJson(i);
      }
    }
    if (json['header_columns'] !=null) {
      var listCols = json['header_columns'] as List;
      for (var i in listCols) {
        columnMap[i['pos']] = AstorColumn.fromJson(i);
      }
    }
    if (json['rows'] !=null) {
      var listRows = json['rows'] as List;
      for (var i in listRows) {
        String id =i['rowpos'];
        AstorRow row = AstorRow.fromJson(i);
        rowMap[id]=row;
        rowsByKeys[row.idTree] = row;
      }
    }
    for (AstorRow r in rowMap.values) {
      if (r.idTreeParent!='') {
        AstorRow? parent = rowsByKeys[r.idTreeParent];
        if (parent!=null) {
          parents[r] = parent;
          parent.hasChilds=true;
        }
      }
    }

    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }
    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }

    WidgetType cWidgetType =  WidgetType.winlist;
    if (json['with_flat']=='true') cWidgetType=WidgetType.winlistflat;
    if (json['type']=='tree_responsive') cWidgetType=WidgetType.tree;


    return AstorTree(
      parents: parents,
      treeColumn: int.parse(json['treeColumn']),
      columns: columnMap,
      rows: rowMap,
      actions: actionMap,
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget: cWidgetType,
    );

  }

  bool isOpen(AstorRow row) {
    if (!row.open) {
      return false;
    }
    AstorRow? parent = parents[row];
    if (parent==null) return true;
    return isOpen(parent);
  }

  bool isVisible(AstorRow row) {
    AstorRow? parent = parents[row];
    if (parent==null) return true;
    return isOpen(parent);
  }

}
class AstorSwap extends AstorComponente {
  final List<AstorItem> origen;
  final List<AstorItem> destino;
  final LinkedHashMap<String,AstorActions> actions;

  AstorSwap({
    required this.origen,
    required this.destino,
    required this.actions,
    type,name,components,attributes,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    value:null,
    widget: widget,
  );
  factory AstorSwap.fromJson(Map<String, dynamic> json) {
    List<AstorItem> origenMap=[];
    List<AstorItem> destinoMap=[];
    LinkedHashMap<String,AstorActions> actionMap=LinkedHashMap<String,AstorActions>();
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";
    if (json['actions'] !=null) {
      var listCols = json['actions'] as List;
      for (var i in listCols) {
        actionMap[i['id']] = AstorActions.fromJson(i);
      }
    }
    if (json['origen'] !=null) {
      var listCols = json['origen'] as List;
      for (var i in listCols) {
        origenMap.add(AstorItem.fromJson(i));
      }
    }
    if (json['destino'] !=null) {
      var listCols = json['destino'] as List;
      for (var i in listCols) {
        destinoMap.add(AstorItem.fromJson(i));
      }
    }

    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }
    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }

    return AstorSwap(
      origen: origenMap,
      destino: destinoMap,
      actions: actionMap,
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget:  WidgetType.swap,
    );

  }

  void filterLeft(String value) {
    for(AstorItem i in origen) {
      if (value!="" && !i.descripcion.toLowerCase().contains(value.toLowerCase())) {
        i.forceVisible=false;
      } else {
        i.forceVisible=true;
      }
    }
  }
  void filterRight(String value) {
    for(AstorItem i in destino) {
      if (value!="" && !i.descripcion.toLowerCase().contains(value.toLowerCase())) {
        i.forceVisible=false;
      } else {
        i.forceVisible=true;
      }
    }
  }


  void toLeft(List<AstorItem> items) {
    for(AstorItem i in items) {
      destino.remove(i);
      origen.add(i);
      i.selected=false;
    }
  }
  void toRight(List<AstorItem> items) {
    for(AstorItem i in items) {
      origen.remove(i);
      destino.add(i);
      i.selected=false;
    }
  }

}
class AstorItem extends AstorComponente {
  @override
  final String id;
  final String idReal;
  final String descripcion;
  bool selected=false;
  final bool separator;
  AstorItem({
    required this.id,
    required this.idReal,
    required this.descripcion,
    required this.selected,
    required this.separator,
    type,name,components,attributes,widget, super.value}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    widget: widget,
  );
  factory AstorItem.fromJson(Map<String, dynamic> json) {
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();

    for (var key in json.keys) {
      if (key!='components'  && key!='selected' && key!='separator' && key!='real_id' && key!='value' && key!='text' && key!='description'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }
    String id = json["value"]==null&&json["real_id"]!=null?json["real_id"]:json["value"];
    String description = json["description"] ?? (json["text"]==null?null:json["text"]);
    return AstorItem(
      id: id,
      idReal: json["real_id"],
      descripcion: description,
      selected: json["selected"]=="true",
      separator: json["separator"]=="true",
      type: 'astoritem',
      name:  id,
      components: <AstorComponente>[],
      attributes: attributeList,
      widget: WidgetType.unknown,
      value: null,
      );

  }
}
class AstorCombo extends AstorComponente {
  final List<AstorItem> items;
  String searchUrl = "do-comboResponsiveFormLovAction";
  List<AstorItem?> choices=[];
  final bool multiple;



  String getObjectOwner() {
    if (widget==WidgetType.ddwinlov) {
      if (attributes['form_objectOwner']==null) return "";
      return attributes['form_objectOwner']!;
    }
    if (attributes['objectOwner']==null) return "";
    return attributes['objectOwner']!;
  }
  String getobjectAction() {
    if (widget==WidgetType.ddwinlov) {
      if (attributes['form_objectAction']==null) return "";
      return attributes['form_objectAction']!;
    }
    if (attributes['objectAction']==null) return "";
    return attributes['objectAction']!;
  }
  String getObjProvider() {
    if (widget==WidgetType.ddwinlov) {
      if (attributes['form_obj_provider']==null) return "";
      return attributes['form_obj_provider']!;
    }
    if (attributes['obj_provider']==null) return "";
    return attributes['obj_provider']!;
  }

  AstorCombo({
    required this.items,
    required this.multiple,
    required this.choices,
    type,name,components,attributes,widget, super.value}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    widget: widget,
  );
  factory AstorCombo.fromJson(Map<String, dynamic> json) {
    List<AstorItem> itemsList=<AstorItem>[];
    List<AstorComponente> componentsList=<AstorComponente>[];
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    List<AstorItem?> choices=<AstorItem?>[];
    String auxName = "";
    String? auxValue;
    String type= json['type'];
    bool multiple=false;
    if (json['multiple']=='true' || type.contains("multiple_check")) {
      multiple=true;
    }

    if (json['items'] !=null) { // en los que viene la lista, viene la marca de selected
      var listItems = json['items'] as List;
      String s="";
      for (var i in listItems) {
        AstorItem item =AstorItem.fromJson(i);
        itemsList.add(item);
        if (item.selected) {
          if (multiple) {
            s += (s==""?"":",")+item.id;
          } else {
            s = item.id;
          }
          choices.add(item);
        }
      }
      auxValue=s;
    }

    if (json['selected'] !=null) {// en los de busqueda remota, viene la lista de elegidos
      var list = json['selected'] as List;
      choices = list.map((i) =>  AstorItem.fromJson(i)).toList();
      String s="";
      if (choices.isNotEmpty) {
        if (multiple) {
          for(AstorItem? item in choices) {
            s+= (s==""?"":",")+item!.id;
          }
        } else {
          s=choices.first!.id;
        }
      }
      auxValue=s;
    }
    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }

    if (json['name'] !=null) {
      auxName=json['name'];
    }
    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }

    WidgetType ctype = WidgetType.select;
    if (type.contains("radio")) {
      ctype=WidgetType.radio;
    } else if (type.contains("win_lov")) ctype=WidgetType.winlov;
    else if (type.contains("dropdowncombo")) ctype=WidgetType.ddcombo;
    else if (type.contains("dropdownwinlov")) ctype=WidgetType.ddwinlov;
    else if (type.contains("multiple_list")) ctype=WidgetType.multiple;
    else if (type.contains("multiple_check")) ctype=WidgetType.multiplecheck;


    return AstorCombo(
      items: itemsList,
      type: type,
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget: ctype,
      value: auxValue,
      multiple: multiple,
      choices: choices,
    );

  }
}
class AstorTabPanel extends AstorComponente {
  final Map<String,AstorComponente> tabs;
  final Map<String,AstorComponente> tabsContent;

  @override
  void setSubmit(Map<String, dynamic> internalMap , String name , dynamic value) => internalMap["meta_$name"]=value;


  AstorTabPanel({
    required this.tabs,
    required this.tabsContent,
    type,name,components,attributes,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    value:null,
    widget: widget,
  );
  factory AstorTabPanel.fromJson(Map<String, dynamic> json) {
    LinkedHashMap<String,AstorComponente> tabsMap=LinkedHashMap<String,AstorComponente>();
    LinkedHashMap<String,AstorComponente> tabsContentMap=LinkedHashMap<String,AstorComponente>();
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";
    if (json['tabs'] !=null) {
      var listCols = json['tabs'] as List;
      for (var i in listCols) {
        tabsMap[i['id']] = AstorComponente.fromJson(i);
      }
    }
    if (json['tabs_content'] !=null) {
      var listCols = json['tabs_content'] as List;
      for (var i in listCols) {
        tabsContentMap[i['id']] = AstorComponente.fromJson(i);
      }
    }

    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }

    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }


    return AstorTabPanel(
      tabs: tabsMap,
      tabsContent: tabsContentMap,
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget: WidgetType.tabpanel,
    );

  }

  @override
  bool update(String ajaxContainer,Map<String, dynamic> json) {
    bool find =  super.update(ajaxContainer, json);
    if (find) return true;
    for (AstorComponente view in tabsContent.values) {
      find=view.update(ajaxContainer,json);
      if (find) break;
    }
    return find;
  }

  @override
  Map<String, dynamic> onSubmit(bool uploadData) {
    Map<String, dynamic> internalMap = <String, dynamic>{};

    if (components.isNotEmpty){
      for (var element in components) {
        internalMap.addAll(element.onSubmit(uploadData));
      }
    }
    for (AstorComponente view in tabsContent.values) {
      internalMap.addAll(view.onSubmit(uploadData));
    }
    if (!uploadData && !name.contains('_filter_pane_')) {
      return internalMap;
    }
    if (attributes.isNotEmpty && value!=null) {
      if (twoProp) {
        setSubmit(internalMap,nameFrom!,value);
        setSubmit(internalMap,nameTo!,value2);
      } else {
        setSubmit(internalMap,name,value);
      }
    }
    return internalMap;
  }
}

class AstorTable extends AstorComponente {

  @override
  void setSubmit(Map<String, dynamic> internalMap , String name , dynamic value) => internalMap["meta_$id"]=active;


  AstorTable({
    type,name,components,attributes,widget}): super(
    type:type,
    name:name,
    components:components,
    attributes:attributes,
    value:null,
    widget: widget,
  );
  factory AstorTable.fromJson(Map<String, dynamic> json) {
    List<AstorComponente> componentsList=List.empty();
    LinkedHashMap<String,String> attributeList=LinkedHashMap<String, String>();
    String auxName = "";

    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
    }
    if (json['name'] !=null) {
      auxName=json['name'];
    }

    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }


    return AstorTable(
      type: json['type']??'',
      name:  auxName,
      components: componentsList,
      attributes: attributeList,
      widget: WidgetType.table,
    );

  }

}



class AstorComponente {
  final String type;
  final String name;
  List<AstorComponente> components;
  final Map<String,String> attributes;
  /// Text which will be displayed at screen

  bool twoProp=false;
  bool initiallyExpanded = true;
  dynamic value;
  dynamic value2;
  String? nameFrom;
  String? nameTo;
  bool? forceVisible;
  /// Could be null
  //Extra? extra;

  /// If widget type is not defined in the enum, then
  /// return widgetType.unknown
  WidgetType? widget;

  /// could be null
  Validation? validation;

  /// Set this value only if the field includes selection
  // Choice? choice;
  //
  // /// List of choices. Set this value only if you are using many to many field;
  // List<Choice>? choices;

  /// icon for the field
  /// this will be set through the params of JSONForm widget
  FieldIcon? icon;

  /// action for the field
  /// this will be set through the params of JSONForm widget
  FieldAction? action;





  AstorComponente({
    required this.type,
    required this.name,
    required this.components,
    required this.attributes,
    required this.value,
    this.widget,
    this.twoProp=false,
    this.nameFrom,
    this.nameTo,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'value':value,

  };


  bool isVisibleInContext(context) {
    if (forceVisible!=null) {
      return forceVisible!;
    }
    String command = classResponsive;

    if (command.contains("collapse"))  {
      return false;
    }

    if ((command.contains("hidden"))) {
      if (MediaQuery.of(context).size.width<576) {
        return !command.contains("hidden-xs") ;
      } else if ((MediaQuery.of(context).size.width<768))
        return !command.contains("hidden-sm") ;
      else if (  (MediaQuery.of(context).size.width<992))
        return !command.contains("hidden-md") ;
      else if ((MediaQuery.of(context).size.width<1200))
        return !command.contains("hidden-lg") ;
      else if (  (MediaQuery.of(context).size.width>1200))
        return !command.contains("hidden-xl") ;

    }
    if ((classResponsive.contains("visible"))) {
      if (MediaQuery.of(context).size.width<576) {
        return command.contains("visible-xs") ;
      } else if ((MediaQuery.of(context).size.width<768))
        return command.contains("visible-sm") ;
      else if (  (MediaQuery.of(context).size.width<992))
        return command.contains("visible-md") ;
      else if ((MediaQuery.of(context).size.width<1200))
        return command.contains("visible-lg") ;
      else if (  (MediaQuery.of(context).size.width>1200))
        return command.contains("visible-xl") ;

    }

    return visible;
  }

  bool get visible => (forceVisible!=null)? forceVisible!:classResponsive.contains("collapse")?false:attributes['visibility']==null?true:attributes['visibility']=="visible";
  bool get edited =>  type=="text_label_responsive"?false:attributes['editable']==null?true:attributes['editable']=="true";
  bool get multiselect =>  attributes['is_multiple_select']==null?false:attributes['is_multiple_select']=="true";
  bool get valueChecked =>  value==null?false:value.toString()!="N";
  String get mode => attributes['mode']==null?"":attributes['mode']!;
  String get constraintType =>  attributes['constraints_datatype']==null?"VOID":attributes['constraints_datatype']!;
  String get constraintTypeForDate =>  attributes['constraints_datatype']==null?"JDATE":attributes['constraints_datatype']!;
  String? get tabselect =>  attributes['tab_select'];
  bool get tabselectOnDemand =>  attributes['ondemand']==null?false:attributes['ondemand']=='true';
  String? get tabHeaderId => attributes["id"];
  String get id =>  attributes['id']==null?"":attributes['id']!;
  String get active =>  attributes['active']==null?"":attributes['active']!;
  String get title =>  attributes['title']==null?"":attributes['title']!;
  String get sizeResponsive =>  attributes['size_responsive']==null?'':attributes['size_responsive']!;
  String get help =>   attributes['tooltip'] == null ? "" : attributes['tooltip']!;
  bool get readOnly =>   attributes['read_only']=='true';
  bool get required =>   attributes['required']=='true';
  bool get noForm =>   attributes['noform']==null?false:attributes['noform']=='true';
  bool get composite =>   attributes['composite']==null?false:attributes['composite']=='true';
  bool get diferido =>   attributes['diferido']==null?false:attributes['diferido']=='true';
  String get text =>    attributes['text']==null?"":attributes['text']!;
  String get dataTitle =>    attributes['data']==null?"":attributes['data']!;
  String get dataSubtitle =>    attributes['title']==null?"":attributes['title']!;
  String get dataLink =>    attributes['label_link']==null?"":attributes['label_link']!;
  String get orientation =>    attributes['orientation']==null?"":attributes['orientation']!;
  double get sizeHResponsive => type=='h1_responsive'?120:type=='h2_responsive'?80:type=='h3_responsive'?40:type=='h4_responsive'?20:10;
  String get iconPath =>    attributes['icon_path']==null?AstorProvider.url:attributes['icon_path']!;
  String get iconSource =>    attributes['icon_source']==null?"":attributes['icon_source']!;
  String get iconFile =>    attributes['icon_file']==null?"":attributes['icon_file']!;
  bool get hasIcon =>    iconFile!=""||iconSource!="";
  String get iconClassImage =>    attributes['icon_class_image']==null?"":attributes['icon_class_image']!;
  String get labelRight =>    attributes['label_right']==null?"":attributes['label_right']!;
  String get dateOptions =>    attributes['options']==null?"":attributes['options']!;
  String get modeButton =>    attributes['mode']==null?"":attributes['mode']!;
  bool get isGroupButtonWithIcon =>   modeButton=='buttongroup' && attributes['icon_file']!=null;
  bool get isGroupButtonWithinIcon =>   modeButton=='buttongroup' && attributes['icon_file']==null;
  bool get isButtonWithIcon =>   (modeButton=='button' || classResponsive.contains("btn")) && attributes['icon_file']!=null;
  bool get isButtonWithinIcon =>  (modeButton=='button' || classResponsive.contains("btn")) && attributes['icon_file']==null;
  bool get isCollapsableButtonWithIcon =>   type=='collapsable_responsive' && attributes['icon_class_image']!=null;
  bool get isCollapsableButtonWithinIcon =>   type=='collapsable_responsive' && attributes['icon_class_image']==null;
  String get dataTarget =>  attributes['data-target']==null?'':attributes['data-target']!;
  String get dataToggle=>  attributes['data-toggle']==null?'':attributes['data-toggle']!;
  bool get unsigned =>  attributes['constraints_unsigned']==null?false:attributes['constraints_unsigned']=="true";
  String? get actionOwner =>  attributes['zobject'];
  String get actionOwnerDest =>  attributes['zobjectdest']==null?'':attributes['zobjectdest']!;
  String? get rowpos =>  attributes['rowpos'];
  String get objProvider =>  attributes['obj_provider']==null?'':attributes['obj_provider']!;
  String get actionObjProvider =>  attributes['action_obj_provider']==null?'':attributes['action_obj_provider']!;
  String? get axis =>  attributes['axis'];
  String get actionTarget =>  attributes['action_target']==null?'':attributes['action_target']!;
  String get idAction =>  attributes['action_id_action']==null?'':attributes['action_id_action']!;
  bool get uploadData =>  attributes['action_upload_data']==null?false:attributes['action_upload_data']=="true";
  bool get issubmit =>  attributes['action_is_submit']==null?false:attributes['action_is_submit']=="true";
  bool get isSubmitAfterBack =>  attributes['action_is_submitafterback']==null?false:attributes['action_is_submitafterback']=="true";
  String get dataAsoc =>  attributes['action_dataasoc']==null?'':attributes['action_dataasoc']!;
  String get backOnPrinter =>  attributes['action_back_on_printer']==null?'':attributes['action_back_on_printer']!;
  String get refreshOnPrinter =>  attributes['action_refresh_on_printer']==null?'':attributes['action_refresh_on_printer']!;
  String get resolveString =>  attributes['action_resolve_string']==null?'':attributes['action_resolve_string']!;
  String get specialSelector =>  attributes['action_special_selector']==null?'':attributes['action_special_selector']!;
  String get contextId =>  attributes['action_object_context_id']==null?'':attributes['action_object_context_id']!;
  String get objectOwner =>  attributes['action_object_owner_id']==null?'':attributes['action_object_owner_id']!;
  String get classResponsive =>  attributes['class_responsive']==null?'':attributes['class_responsive']!;
  String get classTableResponsive =>  attributes['class_table_responsive']==null?'':attributes['class_table_responsive']!;
  String get fullClassResponsive =>  attributes['size_responsive']==null?classResponsive:sizeResponsive;
  bool get hasMoreSelection =>  attributes['has_more_selection']==null?false:attributes['has_more_selection']=="true";
  String get ajaxContainer =>  attributes['action_ajax_container']==null?'':attributes['action_ajax_container']!;
  bool get refreshForm =>  attributes['refreshForm']==null?false:attributes['refreshForm']=="true";
  String get rowsZObject =>  attributes['rows_zobject']==null?'':attributes['rows_zobject']!;
  bool get inline =>  sizeResponsive.contains("inline_component");


  String get label {
    if (attributes['label_lateral']!=null) {
      return attributes['label_lateral']!;
    }
    if (attributes['title']!=null) {
      return attributes['title']!;
    }
    if (attributes['label_button']!=null) {
      return attributes['label_button']!;
    }
    return "";
  }

  String get formatDate {
    String format = "";
    if (constraintTypeForDate=="JINTERVALDATE" ) {
      format=attributes['out_format']==null?"DD/MM/YYYY":attributes['out_format']!;
    } else {
      String options = dateOptions;
      int pos = options.indexOf("format:'") + 8;
      int pos2 = options.indexOf("'", pos + 1);
      format = options.substring(pos, pos2);
    }
    format = format.replaceAll("YYYY", "yyyy");
    format = format.replaceAll("DD", "dd");
    return format;
  }

  List<AstorComponente> get options => components.where((element) =>
  element.widget==WidgetType.navigator_group ||
      element.widget==WidgetType.navigator_item ||
      element.widget==WidgetType.ul || element.widget==WidgetType.li ||
      element.widget==WidgetType.button
  ).toList();

  factory AstorComponente.fromJson(Map<String, dynamic> json) {
    if (json['type']=="swaplist_responsive") {
      return AstorSwap.fromJson(json);
    }
    if (json['type']=="tree_responsive") {
      return AstorTree.fromJson(json);
    }
    if (json['type']=="win_list") {
      return AstorList.fromJson(json);
    }
    if (json['type']=="tabpanel_responsive") {
      return AstorTabPanel.fromJson(json);
    }
     if (json['type']=="multiple_list") {
       return AstorCombo.fromJson(json);
     }
    if (json['type']=="multiple_check_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="multiple_list_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="combobox_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="combobox_responsive_noform") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="dropdowncombo_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="dropdownwinlov_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="radio_button_set") {
      return AstorCombo.fromJson(json);
    }
    if (json['type']=="radio_button_set_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type'] == "win_lov_responsive") {
      return AstorCombo.fromJson(json);
    }
    if (json['type'] == "win_lov") {
      return AstorCombo.fromJson(json);
    }
    if (json['type'] == "table_responsive") {
      return AstorTable.fromJson(json);
    }


    List<AstorComponente> componentsList=List.empty();
    Map<String,String> attributeList=<String, String>{};
    String auxName = "";
    dynamic value;
    WidgetType widgetType;
    if (json['composite'] == "true") {
      if (json['type'] == "navigation_bar_complex") {
        widgetType = WidgetType.navigationbar;
      } else if (json['type'] == "navigation_group") {
        widgetType = WidgetType.navigator_group;
      } else if (json['type'] == "navigation_item") {
        widgetType = WidgetType.navigator_item;
      } else if (json['type'] == "li") {
        widgetType = WidgetType.li;
      } else if (json['type'] == "ul") {
        widgetType = WidgetType.ul;
      } else if (json['type'] == "win_form") {
        widgetType = WidgetType.winForm;
      } else if (json['type'] == "win_form_embedded") {
        widgetType = WidgetType.winForm;
      } else if (json['type'] == "card_responsive") {
        widgetType = WidgetType.card;
      } else if (json['type'] == "win_row_expand_responsive") {
        if (json['expanded']=='false') {
          widgetType = WidgetType.fieldset;
        } else {
          widgetType = WidgetType.div;
        }
      } else if (json['type'] == "fieldset_responsive") {
        widgetType = WidgetType.fieldset;
      } else if (json['type'] == "win_action_bar_internal") {
        widgetType = WidgetType.actionbar;
      } else if (json['type'] == "win_action_bar") {
        widgetType = WidgetType.actionbar;
      } else if (json['type'] == "navigation_group_sidebar") {
        widgetType = WidgetType.navigation_group_sidebar;
      } else if (json['type'] == "h1_responsive") {
        widgetType = WidgetType.h1;
      } else if (json['type'] == "h2_responsive") {
        widgetType = WidgetType.h2;
      } else if (json['type'] == "h3_responsive") {
        widgetType = WidgetType.h3;
      } else if (json['type'] == "tab_content") {
        widgetType = WidgetType.div;
      } else if (json['type'] == "h4_responsive") {
        widgetType = WidgetType.h4;
      }else if (json['type'] == "dropdown") {
        widgetType = WidgetType.dropdown;
      }else
        widgetType = WidgetType.div;
      if (json['components'] !=null) {
        var list = json['components'] as List;
        componentsList = list.map((i) =>  AstorComponente.fromJson(i)).toList();
      }
    } else if (json['type'] == "imagecard_responsive") {
      widgetType = WidgetType.infocard;
    } else if (json['type'] == "infocard_responsive") {
      widgetType = WidgetType.infocard;
    } else if (json['type'] == "image_responsive") {
      widgetType = WidgetType.image;
    } else if (json['type'] == "end") {
      widgetType = WidgetType.unknown;
    } else if (json['type'] == "text_area_responsive") {
      widgetType = WidgetType.text;
    } else if (json['type'] == "text_field_responsive") {
      widgetType = WidgetType.text;
    } else if (json['type'] == "color_field") {
      widgetType = WidgetType.color;
    } else if (json['type'] == "color_field_responsive") {
      widgetType = WidgetType.color;
    } else if (json['type'] == "date_chooser_responsive") {
      widgetType = WidgetType.datetime;
    } else if (json['type'] == "interval_date_chooser_responsive") {
      widgetType = WidgetType.intervaldate;
    } else if (json['type'] == "check_box_responsive_noform") {
      widgetType = WidgetType.checkbox;
    } else if (json['type'] == "check_box_responsive") {
      widgetType = WidgetType.checkbox;
    } else if (json['type'] == "link") {
      widgetType = WidgetType.button;
    } else if (json['type'] == "card_responsive") {
      widgetType = WidgetType.card;
    } else if (json['type'] == "break") {
      widgetType = WidgetType.line;
    } else if (json['type'] == "web_button_responsive") {
      widgetType = WidgetType.button;
    } else if (json['type'] == "collapsable_responsive") {
      widgetType = WidgetType.collapsable;
    } else if (json['type'] == "web_button") {
      widgetType = WidgetType.button;
    } else if (json['type'] == "label_responsive") {
      widgetType = WidgetType.label;
    } else if (json['type'] == "text_label_responsive") {
      if (json['label_lateral']==null || json['label_lateral']==json['value']) {
        widgetType = WidgetType.label;
      } else {
        widgetType = WidgetType.text;
      }
    } else if (json['type'] == "file_responsive") {
      widgetType = WidgetType.file;
    } else if (json['type'] == "message") {
      widgetType = WidgetType.message;
    }  else {
      widgetType = WidgetType.text;
    }


    if (json['name'] !=null) {
      auxName=json['name'];
      if (json['diferido']!=null && json['diferido']=="true" && json['action_ajax_container']!=null ) {
        auxName=json['action_ajax_container'];
      }
    }
    if (json['value'] !=null) {
      //debugPrint("Componente "+json['name']+" valor ("+json['value']+")");
      value=json['value'];
    } else {
      if (json['name']!=null) debugPrint("Componente "+json['name']);

    }
    bool twoProp=false;
    String? nameFrom;
    String? nameTo;
    if (json['two_prop']!=null && json['two_prop']=="true") {
      twoProp = true;
      nameFrom = json['name_from'];
      nameTo = json['name_to'];
    }

    for (var key in json.keys) {
      if (key!='components' && key!='type' && key!='name' && key!='value'  && json[key].runtimeType==String) {
        attributeList[key]=json[key];
      }
    }

    // if (_widgetType==WidgetType.winlist)
    //   return AstorList.fromJson(json);
    return AstorComponente(
        type: json['type']??'',
        name: auxName,
        components: componentsList,
        attributes: attributeList,
        value: value,
        widget: widgetType,
        twoProp: twoProp,
        nameFrom: nameFrom,
        nameTo: nameTo,
    );



  }
  Map<String, dynamic> onSubmit(bool uploadData) {
    Map<String, dynamic> internalMap = <String, dynamic>{};
    if (components.isNotEmpty){
      for (var element in components) {
        internalMap.addAll(element.onSubmit(uploadData));
      }
    }
    if (!uploadData && !name.contains('_filter_pane_')) {
      return internalMap;
    }
    if (attributes.isNotEmpty && value!=null) {
      if (twoProp) {
        setSubmit(internalMap,nameFrom!,value);
        setSubmit(internalMap,nameTo!,value2);
      } else {
        setSubmit(internalMap,name,value);
      }
    }
    return internalMap;
  }

  void setSubmit(Map<String, dynamic> internalMap , String name , dynamic value) => internalMap[name]=value;

  List<AstorComponente> findMenuPrincipal() {
    List<AstorComponente> list= [];
    if (attributes['role_mobile']=="PRINCIPAL") {
      list.add(this);
    } else {
      components.forEach((element) {element.findMenuPrincipal().forEach((elementN) {list.add(elementN);});});
    }
    return list;
  }
  List<AstorComponente> findNavBar() {
    List<AstorComponente> list= [];
    if (attributes['role_mobile']=="NAVBAR") {
      list.add(this);
    } else {
      components.forEach((element) {element.findNavBar().forEach((elementN) {list.add(elementN);});});
    }
    return list;
  }
  List<AstorComponente> findDrawer() {
    List<AstorComponente> list= [];
    if (attributes['role_mobile']=="SIDEBAR") {
      list.add(this);
    } else {
      components.forEach((element) {element.findDrawer().forEach((elementN) {list.add(elementN);});});
    }
    return list;
  }
  void hideAllRowsChilds(String type,String except) {
    if (this.type==type) {
      initiallyExpanded=name==except;
    }
    else {
      components.forEach((element) {element.hideAllRowsChilds(type,except);});
    }

  }


  List<AstorComponente> mergeValues(Map<String, dynamic> values) {

    return components.map((s) {

      if (s.attributes['composite']=='true') {
        s.components.map((e) => e.mergeValues(values));
      }


      // if values match
      if (values.containsKey(s.name)) {
        var value = values[s.name];
        if (s.value != null) {
          return s;
        }


        switch (s.widget) {

        
          case WidgetType.text:
          case WidgetType.number:
          case WidgetType.datetime:
          case WidgetType.unknown:
          case WidgetType.checkbox:
          case WidgetType.file:
          case WidgetType.url:
            s.value = value;
            break;
          default:
          break;
         
        }
      }
      return s;
    }).toList();
  }
  AstorComponente? findAjaxContainer(String ajaxContainer) {
    if (name==ajaxContainer) {
      return this;
    }
    for (AstorComponente view in components) {
      AstorComponente? ac=view.findAjaxContainer(ajaxContainer);
      if (ac!=null) return ac;
    }
    return null;
  }
  AstorComponente? findName(String zName) {
    if (name==zName) {
      return this;
    }
    for (AstorComponente view in components) {
      AstorComponente? ac=view.findName(zName);
      if (ac!=null) return ac;
    }
    return null;
  }
  bool update(String ajaxContainer,Map<String, dynamic> json) {
    if (name==ajaxContainer) {
      components=[];
      AstorApp auxAstor=AstorApp.fromJson(json);

      components=auxAstor.application_views.first.components;
      return true;
    }
    bool find = false;
    for (AstorComponente view in components) {
      find=view.update(ajaxContainer,json);
      if (find) break;
    }
    return find;
  }
  bool showLoading() {
    if (attributes['accion_ajax_container']==null) return true;
    if (attributes['accion_ajax_container']=='') return true;
    return false;
  }

}

class AstorView extends AstorComponente {
  List<AstorComponente> msg = [];
  AstorView({name,components,msg}): super(
    type:"views",
    name:name,
    components:components,
    attributes:Map.identity(),
    value:null,
    widget: WidgetType.unknown,
  );
  factory AstorView.fromJson(Map<String, dynamic> json) {
    List<AstorComponente> componentsList=List.empty();
    List<AstorComponente> messageList=List.empty();
    if (json['components'] !=null) {
      var list = json['components'] as List;
      componentsList = list.map((i) => AstorComponente.fromJson(i)).toList();
    }
    if (json['message']!=null) {
      var list = json['message'] as List;
      messageList = list.map((i) => AstorComponente.fromJson(i)).toList();
    }

    return AstorView(
      name: json['name'],
      components: componentsList,
      msg: messageList,
    );
  }
  @override
  AstorComponente? findAjaxContainer(String ajaxContainer) {
    for (AstorComponente view in components) {
      AstorComponente? ac=view.findAjaxContainer(ajaxContainer);
      if (ac!=null) return ac;
    }
    return null;
  }


}

class AstorApp {
  final String user;
  final String company;
  final String application_name;
  final String application_version_info;
  final String application_release_info;
  final List<AstorView> application_views;
  LinkedHashMap<String,Widget> providers = LinkedHashMap<String,Widget> ();
  LinkedHashMap<String,bool> actions = LinkedHashMap<String,bool>();
  // List<String> actionsActive = [];
  String formLovControlId;
  String subsession;
  File? downloadFile;

  AstorApp({
    required this.user,
    required this.company,
    required this.application_name,
    required this.application_version_info,
    required this.application_release_info,
    required this.application_views,
    required this.formLovControlId,
    required this.subsession,
  });
  AstorComponente? _menuPrincipal;
  AstorComponente? _navBar;
  AstorComponente? _drawer;

  AstorComponente get menuPrincipal => findMenuPrincipal();
  AstorComponente get navBar => findNavBar();
  AstorComponente get drawer => findDrawer();

   void clearProviders() {
    providers=LinkedHashMap<String,Widget>();
  }
  void addObjProvider(String key,Widget provider) {
    providers[key]=provider;
  }
  Widget? getObjectProvider(String key) {
    return providers[key];
  }
  void clearActions() {
   actions=LinkedHashMap();
    // actionsActive=[];
  }


  void addObjAction(String key,bool visible) {
   actions[key]=visible;
    // if (visible) {
    //   if (!actionsActive.contains(key)) actionsActive.add(key);
    // } else {
    //   if (actionsActive.contains(key)) actionsActive.remove(key);
    // }
  }
  void setObjAction(String key,bool visible) {
   actions[key]=visible;
 //    if (visible) {
 //      if (!actionsActive.contains(key)) actionsActive.add(key);
 //    } else {
 //      if (actionsActive.contains(key)) actionsActive.remove(key);
 //    }
  }
  bool? getObjAction(String key) {
     // return actionsActive.contains(key);
   return actions[key];
  }
  void cleanMenuPrincipal() {
    _menuPrincipal=null;
  }
  void cleanNavBar() {
    _navBar=null;
  }

  bool hasMenuPrincipal() {
    return findMenuPrincipal().components.isNotEmpty;
  }
  bool hasNavBar() {
    return findNavBar().components.isNotEmpty;
  }
  bool hasDrawer() {
    return findDrawer().components.isNotEmpty;
  }
  AstorComponente? findAjaxContainer(String ajaxContainer) {
     for (AstorView view in application_views) {
       AstorComponente? ac=view.findAjaxContainer(ajaxContainer);
        if (ac!=null) return ac;
     }
     return null;
  }
  AstorComponente? findName(String ajaxContainer) {
    for (AstorView view in application_views) {
      AstorComponente? ac=view.findName(ajaxContainer);
      if (ac!=null) return ac;
    }
    return null;
  }

  AstorComponente findMenuPrincipal() {
    if (_menuPrincipal!=null) return _menuPrincipal!;
    AstorComponente comp =AstorComponente(
      type: "drawer",
      name: "drawer",
      components: application_views.first.findMenuPrincipal(),
      attributes: LinkedHashMap.identity(),
      value: "Menu",
      widget: WidgetType.drawer,
    );
    return _menuPrincipal=comp;
  }

  AstorComponente findNavBar() {
    if (_navBar!=null) return _navBar!;
    AstorComponente comp =AstorComponente(
      type: "drawer",
      name: "drawer",
      components: application_views.first.findNavBar(),
      attributes: LinkedHashMap.identity(),
      value: "Opciones",
      widget: WidgetType.drawer,
    );
    return _navBar=comp;
  }

  AstorComponente findDrawer() {
    if (_drawer!=null) return _drawer!;
    AstorComponente comp =AstorComponente(
      type: "drawer",
      name: "drawer",
      components: application_views.first.findDrawer(),
      attributes: LinkedHashMap.identity(),
      value: "Drawer",
      widget: WidgetType.drawer,
    );
    return _drawer=comp;
  }
  factory AstorApp.fromJson(Map<String, dynamic> json) {
    List<AstorView> componentsList = List.empty();
    if (json['views'] != null) {
      var list = json['views'] as List;
      componentsList = list.map((i) => AstorView.fromJson(i)).toList();
    }
    return AstorApp(
      user: json['user'],
      company: json['company_id'],
      application_name: json['application_name'],
      application_version_info: json['application_version_info'],
      application_release_info: json['application_release_info'],
      application_views: componentsList,
      formLovControlId: json['form_lov_control_id'],
      subsession: json['subsession'],
    );
  }
  Future<AstorApp> update(String ajaxContainer,Map<String, dynamic> json) async{
    return _update(ajaxContainer,json) ;
   }

  Future<AstorApp> download(File file) async{
     downloadFile = file;
    return this;
  }

  AstorApp _update(String ajaxContainer,Map<String, dynamic> json) {
    bool find = false;
    if (ajaxContainer=='view_area_and_title') {
      clearProviders();
      clearActions();
    }
    for (AstorView view in application_views) {
      find=view.update(ajaxContainer,json);
      if (find) break;
    }
    return this;

  }

  List<Widget> build() {
    List<Widget> listOfFields = List.empty();
    var view;
    for (view in application_views) {
      view.build().forEach((element) {
        listOfFields.add(element);
      });
    }
    return listOfFields;
  }






}


// class Extra {
//   dynamic defaultValue;
//   String helpText;
//   List<Choice> choices;
//   String relatedModel;
//   Extra({this.defaultValue, required this.helpText,required this.choices, required this.relatedModel});
//
//   // factory Extra.fromJSON(Map<dynamic, dynamic> json) {
//   //   if (json == null) return null;
//   //   List<Choice> choices =
//   //   json['choices']?.map<Choice>((s) => Choice.fromJSON(s))?.toList();
//   //   return Extra(
//   //     defaultValue: json['default'],
//   //     helpText: json['help'],
//   //     relatedModel: json['related_model'],
//   //     choices: choices,
//   //   );
//   // }
// }

class Validation {
  Length length;

  Validation({required this.length});

  // factory Validation.fromJSON(Map<dynamic, dynamic> json) {
  //   return Validation(
  //       length: json != null ? Length.fromJSON(json['length']) : null);
  // }
}

class Length {
  int maximum;
  int minimum;

  Length({required this.maximum, required this.minimum});

  // factory Length.fromJSON(Map<String, dynamic> json) {
  //   if (json == null) {
  //     return null;
  //   }
  //   return Length(maximum: json['maximum'], minimum: json['minimum']);
  // }
}

class Choice {
  String label;
  dynamic value;

  Choice({required this.label,required this.value});

  @override
  bool operator ==(o) {
    if (o is Choice) {
      return o.label == label && o.value == value;
        }
    return false;
  }

  // factory Choice.fromJSON(Map<dynamic, dynamic> json) {
  //   return Choice(label: json['label'], value: json['value']);
  // }
  //
  // toJson() {
  //   return {
  //     "label": label,
  //     "value": value,
  //   };
  // }

}


