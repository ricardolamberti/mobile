
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONIcon.dart';

typedef OnChange = void Function(bool value);

class JSONInfoCard extends StatelessWidget {
  final AstorComponente schema;
  final OnChange? onSaved;
  final bool showIcon;
  final bool isOutlined;
  final OnPressed onPressed;
  final OnBuildBody onBuildBody;

  const JSONInfoCard({
    super.key,
    required this.schema,
    required this.onBuildBody,
    required this.onPressed,
    this.onSaved,
    this.showIcon = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final String title = schema.dataTitle;
    final String subtitle = schema.dataSubtitle;
    final String labelLink = schema.dataLink;
    return Card(
      shape: const Border(left: BorderSide(color: Colors.blue, width: 5)),
      borderOnForeground: true,
      elevation: 10.0,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () {
            onPressed(schema, context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: JSONIcon(
                  schema: schema,
                  size: 50.0,
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontSize: 25),
                  textAlign: TextAlign.right,
                ),
                subtitle: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.right,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xfff5f5f5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          color: Colors.black12,
                        ),
                      ),
                      child: Text(
                        labelLink,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  )
                  // TextButton(
                  //   child:  new Text(labelLink,style: TextStyle(fontSize: 20),),
                  //
                  //      onPressed: (){ onPressed(schema,context);}
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}

