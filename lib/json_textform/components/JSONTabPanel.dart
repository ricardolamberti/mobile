import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import '../JSONForm.dart';
import 'JSONDiv.dart';

typedef OnChange = void Function(String value);

class JSONTabPanel extends StatelessWidget {
  final AstorTabPanel schema;
  final OnChange onSaved;
  final bool showIcon;
  final bool isOutlined;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;

  const JSONTabPanel({
    super.key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    required this.onSaved,
    this.showIcon = true,
    this.isOutlined = false,
  });

  int getIndex(String? key) {
    int id = 0;
    for (AstorComponente tabHeader in schema.tabs.values) {
      if (tabHeader.tabHeaderId == key) return id;
      id++;
    }
    return 0;
  }

  String getKey(int index) {
    int id = 0;
    for (AstorComponente tabHeader in schema.tabs.values) {
      if (id == index) return tabHeader.tabHeaderId ?? '';
      id++;
    }
    return "";
  }

  void localOnPressed(AstorComponente tabheader, [BuildContext? context]) {
    final selectTab = tabheader.tabHeaderId ?? '';
    onSaved(selectTab);
    if (context != null) {
      onPressed(tabheader, context);
    } else {
      onPressed(tabheader);
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: schema.tabs.length, // length of tabs
        initialIndex: getIndex(schema.tabselect),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            tabs: [
              for (final tabheader in schema.tabs.values)
                Tab(text: tabheader.title)
            ],
            onTap: (index) {
              final name = getKey(index);
              if (name == "") return;
              final comp = schema.tabs[name];
              if (comp != null && comp.tabselectOnDemand) {
                localOnPressed(comp, context);
              }
            },
          ),
          Container(
              height: 1800, //height of TabBarView
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 0.5))
              ),
              child: TabBarView(children: <Widget>[
                for (final tabcontent in schema.tabsContent.values)
                  JSONDiv(
                      schema: tabcontent,
                      useBootstrap: false,
                      actionBar: false,
                      onBuildBody: onBuildBody)
              ])
          )
        ]));
  }
}

