// @dart=2.9

import 'package:astor_mobile/json_textform/components/pages/NewPage.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../JSONForm.dart';
import '../components/pages/SelectionPage.dart';
import '../utils-components/OutlineButtonContainer.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

typedef void OnChange(List<AstorItem> choice);

class JSONSelectField extends StatelessWidget implements InterfaceProvider {
  final AstorCombo schema;
  final OnChange onSaved;

  /// implementation. Default is false
  final bool useDropdownButton;
  final bool useRadioButton;
  final bool useCheckButton;
  final bool useGridButton;
  final OnBuildBody onBuildBody;
  final OnRefereshForm onRefreshForm;

  JSONSelectField({
    @required this.schema,
    @required this.useRadioButton,
    @required this.useDropdownButton,
    @required this.useCheckButton,
    @required this.useGridButton,
    this.onRefreshForm=null,
    this.onBuildBody=null,
    this.onSaved,
  });


  @override
  Widget build(BuildContext context) {
    bool visible = schema.visible;
    bool edited = schema.edited;
    if (!edited)
      return buildReadOnly(visible, context);

    if (useCheckButton != null && useCheckButton)
      return buildMultiCheck(visible,context);
    if (useRadioButton != null && useRadioButton) {
      if (schema.orientation=='toogle')
        return buildRabioButtonToggle(visible, context);
      if (schema.orientation=='horizontal')
        return buildRabioButtonHorizontal(visible, context);
      return buildRabioButtonVertical(visible, context);
    }
    if (useGridButton != null && useGridButton)
      return buildGridButton(visible,context);
    if (useDropdownButton != null && useDropdownButton)
      return buildCombo(visible,context);
    return buildWinLov(visible,context);
  }

  Widget buildReadOnly(bool visible, BuildContext context) {
    return Visibility(
        visible: visible,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              key: Key("textfield-${schema.name}"),
              maxLines: 1,
              enabled: false,
              initialValue: getDescripcion(),
              decoration: InputDecoration(
                filled: false,
                labelText: schema.label,
              ),
            ),
          ),
        )
    );
  }
  Widget buildRabioButtonVertical(bool visible, BuildContext context) {
    AstorItem selectedValue;
    selectedValue = schema.choices!=null&&schema.choices.isNotEmpty? schema.choices.first: null;

    return Visibility(
        visible: visible,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: OutlineButtonContainer(
                isFilled: false,
                isOutlined: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schema.label,
                      style:
                      Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18),
                    ),
                    for (AstorItem choice in schema.items)
                      RadioListTile<AstorItem>(
                        onChanged: (v) {
                          this.onSaved([v]);
                          if (schema.refreshForm) {
                            onRefreshForm(schema, context);
                          }
                        },
                        groupValue: selectedValue,
                        value: choice,
                        title: Text(choice.descripcion),
                      ),
                    Divider(),
                  ],
                )
            )
        )
    );
  }
  Widget buildRabioButtonHorizontal(bool visible, BuildContext context) {
    AstorItem selectedValue;
    selectedValue = schema.choices!=null&&schema.choices.isNotEmpty? schema.choices.first: null;

    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(schema.label,
                style:
                Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                children: [
                  for (AstorItem choice in schema.items)
                    Container(
                      width: 50,
                      child: RadioListTile<AstorItem>(
                        onChanged: (v) {
                          this.onSaved([v]);
                          if (schema.refreshForm) {
                            onRefreshForm(schema, context);
                          }
                        },
                        groupValue: selectedValue,
                        value: choice,
                        title: Text(choice.descripcion),
                      ),
                    )
                ],
              )
            ],
          )
        )
      )
    );
  }
  Widget buildRabioButtonToggle(bool visible, BuildContext context) {
    AstorItem selectedValue;
    selectedValue = schema.choices!=null&&schema.choices.isNotEmpty? schema.choices.first: null;

    return Visibility(
        visible: visible,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: OutlineButtonContainer(
                isFilled: false,
                isOutlined: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (schema.label!='')
                      Text(schema.label,
                        style:
                        Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18),
                      ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      direction: Axis.horizontal,
                      children: [
                        for (AstorItem choice in schema.items)
                          TextButton(

                              child: Text(
                                  choice.descripcion,
                                   style: TextStyle(fontSize: 10),
                                    overflow: TextOverflow.fade,),
                              onPressed:() {
                                this.onSaved([choice]);
                                if (schema.refreshForm) {
                                  onRefreshForm(schema, context);
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                    side: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all( selectedValue==choice?Colors.blue:Colors.white),
                                foregroundColor: MaterialStateProperty.all( selectedValue==choice?Colors.white:Colors.blue),
                              ),
                            ),

                      ],
                    )
                  ],
                )
            )
        )
    );
  }
  Widget buildGridButton(bool visible, BuildContext context) {
    AstorItem selectedValue;
    selectedValue = schema.choices!=null&&schema.choices.isNotEmpty? schema.choices.first: null;
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined:  schema.items.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(schema.label,
                style:
                Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18),
              ),
              Container (
                width: double.maxFinite,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                  for (AstorItem choice in schema.items)
                    InkWell(
                      onTap: () {
                        this.onSaved([choice]);
                        if (schema.refreshForm) {
                          onRefreshForm(schema, context);
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child:  OutlineButtonContainer(
                          isFilled: selectedValue==choice,
                          isOutlined: true,
                          child: Column (
                            children: [
                              Text(choice.descripcion),
                              JSONIcon(schema: choice,),
                            ],
                          )
                        )
                      )
                    ),
                  ],
                )
              )
            ],
          )
        )
      )
    );
  }
  Widget buildFormAlta(BuildContext context) {

    return NewPage(
      schema: schema,
      onBuildBody: onBuildBody,
      title: schema.label,
    );
  }
  Widget buildCombo(bool visible, BuildContext context) {
    AstorItem selectedValue;
    selectedValue = schema.choices!=null&&schema.choices.isNotEmpty? schema.choices.first:null;
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        child: GestureDetector(

            onLongPress: () => (schema.components.isEmpty)?null:showDialog(
              context: context,
              builder: (context) => buildFormAlta(context),
            ),
          child: OutlineButtonContainer(
            isFilled: false,
            isOutlined: true,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: DropdownButton(
                    key: Key("Dropdown"),
                    hint: Text(schema.label),
                    isExpanded: true,
                    onChanged: (v) {
                      this.onSaved([v]);
                      if (schema.refreshForm) {
                        onRefreshForm(schema, context);
                      }
                    },
                    value: selectedValue,
                    items: schema.items.map(
                          (e) => DropdownMenuItem(
                        key: Key("Dropdown-${e.id}"),
                        value: e,
                        child: Text(e.descripcion),
                      ),
                    )?.toList(),
                    //    if (schema.components.isNotEmpty)
                    //     JSONDiv(schema:schema,
                    //     onBuildBody: onBuildBody,
                    //    ),

                  ),
                ),
              ],
            ),
          ),
        )

      ),
    );
  }

  Widget buildMultiCheck(bool visible, BuildContext context) {
    List<AstorItem> selectValues;
    selectValues = schema.choices!=null&&schema.choices.isNotEmpty? schema.choices:[];
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: OutlineButtonContainer(
            isFilled: false,
            isOutlined: schema.items.isEmpty,
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(schema.label,
                  style:
                  Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18),
                ),
                Container (
                  width: double.maxFinite,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      for (AstorItem choice in schema.items)
                        Container (
                          width: 200,
                          child: OutlineButtonContainer(
                            isFilled: false,
                            isOutlined: true,
                            child:  SwitchListTile(
                            title: Text(choice.descripcion),
                              value: selectValues.contains(choice),
                              onChanged: (v) {
                                if (v)
                                  selectValues.add(choice);
                                else
                                  selectValues.remove(choice);

                                this.onSaved(selectValues);
                                if (schema.refreshForm) {
                                  onRefreshForm(schema, context);
                                }
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                              inactiveTrackColor: Colors.grey,
                              inactiveThumbColor: Colors.black45,
                            ),
                          )

                      )

                    ],
                  )
                )
              ]
            )
          )
      )
    );

  }
  Widget buildWinLov(bool visible, BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        child: GestureDetector(
          onLongPress: () => (schema.components.isEmpty)?null:showDialog(
             context: context,
             builder: (context) => buildFormAlta(context),
          ),
          child:OutlineButtonContainer(
            isFilled: false,
            isOutlined: true,
            child: ListTile(
              key: Key("selection-field"),
              leading: schema.icon != null
                  ? Icon(
                schema.icon.iconData,
                color: Theme.of(context).iconTheme.color,
              )
                  : null,
              trailing:
              Icon(Icons.expand_more, color: Theme.of(context).iconTheme.color),
              onTap: schema.items == null
                  ? null
                  : () {
                FocusScope.of(context).requestFocus(FocusNode());
                showDialog(
                  context: context,
                  builder: (context) => buildSelectionPage(context),
                );
              },
              title: Text("${schema.label}"),
              subtitle: Text(getDescripcion()),
            ),
          ),
        ),
      ),
    );
  }


  String getDescripcion() {
    List<AstorItem> selectValues=
    schema.choices != null ? schema.choices : [];
    String out = "";
    selectValues.forEach((element) {out+=(out==""?"":",")+element.descripcion;});
    return out;
  }

  SelectionPage buildSelectionPage(BuildContext context) {
    AstorProvider provider = Provider.of<AstorProvider>(context,listen: false);
    return SelectionPage(
      schema: schema,
      onSearch: provider.winLovOpen,
      multiple: schema.multiple,
      useDialog: true,
      onSelected: (value) {
        if (this.onSaved != null) {
          this.onSaved(value);
          if (schema.refreshForm) {
            onRefreshForm(schema, context);
          }
        }
      },
      title: "${schema.label}",
      selections: schema.items,
      value: schema.choices,
    );

  }

  @override
  bool getClearSelection() {
    return false;
  }

  @override
  String getCurrentActionOwner() {
    return schema.actionOwner;
  }

  @override
  String getCurrentActionOwnerFromSelect() {
    return schema.actionOwner;
  }

  @override
  String getMultipleActionOwnerList() {
    return "";
  }

  @override
  String getMultipleCurrentActionOwnerDest() {
    return null;
  }

  @override
  String getSelectedCell() {
    return "";

  }

  @override
  String getSelectedRow() {
    return "";

  }

  @override
  String getSelection() {
    return "";
  }

  @override
  String getSelectionSpecial(String specialselector) {
    return "";

  }

  @override
  bool hasMoreSelections() {
    return false;
  }

  @override
  bool hasMultipleSelect() {
    return false;
  }

  @override
  bool hasMultipleSelectSpecial(String specialselector) {
    return false;
  }
}

