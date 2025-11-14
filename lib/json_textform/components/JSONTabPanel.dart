
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONButton.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

typedef void OnChange(String value);

class JSONTabPanel extends StatelessWidget {
  final AstorTabPanel schema;
  final OnChange onSaved;
  final bool showIcon;
  final bool isOutlined;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;
  String selectTab="";
  JSONTabPanel({
    @required this.schema,
    @required this.onBuildBody,
    @required this.onPressed,
    this.onSaved,
    this.showIcon = true,
    this.isOutlined = false,
  });

  int getIndex(String key){
    int id=0;
    for(AstorComponente tabHeader in schema.tabs.values) {
      if (tabHeader.tabHeaderId== key) return id;
      id++;
    }
    return 0;
  }
  String getKey(int index){
    int id=0;
    for(AstorComponente tabHeader in schema.tabs.values) {
      if (id == index) return tabHeader.tabHeaderId;
      id++;
    }
    return "";
  }
  void localOnPressed(AstorComponente tabheader,[BuildContext context]) {
    selectTab=tabheader.tabHeaderId;
    onSaved(selectTab);
    onPressed(tabheader,context);
  }
  @override
  Widget build(BuildContext context) {
    selectTab = schema.tabselect;
    return DefaultTabController(
        length: schema.tabs.length, // length of tabs
        initialIndex: getIndex(schema.tabselect),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
              tabs: [
                for(AstorComponente tabheader in schema.tabs.values)
                       Tab( text: tabheader.title)
              ],
              onTap: (index) {
                String name = getKey(index);
                if (name=="") return;
                AstorComponente comp = schema.tabs[name];
                if (comp.tabselectOnDemand )
                 localOnPressed(comp,context);
              }
            ),
          ),
          Container(
              height: 1800, //height of TabBarView
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 0.5))
              ),
              child: TabBarView(children: <Widget>[
                for(AstorComponente tabcontent in schema.tabsContent.values)
                Container(
                  child:
                  JSONDiv(schema: tabcontent,
                      useBootstrap: false,
                      actionBar: false,
                      onBuildBody: onBuildBody)
                ),
              ])
          )
        ])
    );






  }



}

