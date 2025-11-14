// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:astor_mobile/json_textform/components/JSONDiv.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '/json_textform/components/JSONCheckboxField.dart';
import '/json_textform/components/JSONDateTimeField.dart';
import '/json_textform/components/JSONFileField.dart';
import '/json_textform/components/JSONSelectField.dart';
import '/json_textform/components/JSONTextFormField.dart';
import '/json_textform/components/LoadingDialog.dart';
import '/json_textform/models/components/Action.dart';
import '/json_textform/models/Controller.dart';
import '/json_textform/utils.dart';

import 'components/JSONActionBar.dart';
import 'components/JSONButton.dart';
import 'components/JSONCard.dart';
import 'components/JSONColor.dart';
import 'components/JSONDropDownButton.dart';
import 'components/JSONFieldset.dart';
import 'components/JSONIcon.dart';
import 'components/JSONInfoCard.dart';
import 'components/JSONLabel.dart';
import 'components/JSONLine.dart';
import 'components/JSONMessage.dart';
import 'components/JSONSwap.dart';
import 'components/JSONTabPanel.dart';
import 'components/JSONTable.dart';
import 'components/JSONTree.dart';
import 'components/JSONWinList.dart';
import 'components/JSONSubForm.dart';
import 'components/JSONWinListFlat.dart';
import 'models/components/AvaliableWidgetTypes.dart';
import 'models/components/Icon.dart';
import 'package:astor_mobile/model/astorSchema.dart';

/// A schema values which represents both schema and its values.
class SchemaValues {
  /// schema data.
  AstorComponente schema;

  /// schema's value
  Map<String, dynamic> values;

  SchemaValues({@required this.schema, @required this.values});
}
typedef Widget OnBuildBody(AstorComponente comp);


typedef Future<List<AstorItem>> OnSearch(AstorCombo combo, String keyword);

/// Will be called when user clicks submit button or uses controller to submit
typedef Future OnSubmit(Map<String, dynamic> json);
typedef void OnPressed(AstorComponente schema,[BuildContext context]);
typedef void OnRefereshForm(AstorComponente schema,[BuildContext context]);

/// Fetch schema based on the [path] and [id].
/// If this function has been called when user want to edit a foreignkey's value,
/// then [isEdit] will be true and id will be provided. Otherwise, id will be null.
///
/// This function should return a [schemaValues] which includes both schema and its value.
typedef Future<SchemaValues> OnFetchingSchema(
    String path, bool isEdit, dynamic id);

/// Fetch list of foreignkey's selections based on the [path].
/// This will be called when user want to select a foreignkey(s).
typedef Future<List<Choice>> OnFetchforeignKeyChoices(String path);

/// This function will be called when user wants
/// to update a foreign key's value based on the [path].
///
/// [values] and [id] will be provided for you so that you can use them
/// to do something like making an api request.
typedef Future<Choice> OnUpdateforeignKeyField(
    String path, Map<String, dynamic> values, dynamic id);

/// This function will be called when user wants to add a foreignkey.
/// The [values] and [path] will be provided so that you can use them
/// to make a api request.
typedef Future<Choice> OnAddforeignKeyField(
    String path, Map<String, dynamic> values);

/// Delete a foreignkey based on the [path] and [id]
typedef Future<Choice> OnDeleteforeignKeyField(String path, dynamic id);

/// Open a file based on the platform.
///
/// For example, use [FilePicker] to pick a file on mobile platform
typedef Future<File> OnFileUpload(String path);

/// A JSON Schema Form Widget
/// Which will take a schema input
/// and generate a form
class JSONForm extends StatefulWidget {

  final Widget loadingDialog;

  final OnSearch onSearch;

  final OnFileUpload onFileUpload;

  /// [optional] Schema controller.
  /// Call this to get value back from fields if you want to have
  /// your custom submit button.
  final JSONSchemaController controller;

  /// Schema's name
  /// Use this to identify the actions and icons
  /// if foreignkey text field has the same name as the home screen's field.
  /// Default is null
  final String schemaName;

  /// Schema you want to have. This is a JSON object
  /// Using dart's map data structure
  final AstorComponente schema;

  /// List of actions. Each field will only have one action.
  /// If not, the last one will replace the first one.
  final List<FieldAction> actions;

  /// List of icons. Each field will only have one icon.
  /// If not, the last one will replace the first one.
  final List<FieldIcon> icons;

  /// Default values for each field
  final Map<String, dynamic> values;

  /// Will call this function after user
  /// clicked the submit button
  final OnSubmit onSubmit;

  JSONForm({
    @required this.schema,
    @required this.onSearch,
    this.onSubmit,
    this.icons,
    this.actions,
    this.values,
    this.schemaName,
    this.controller,
    this.loadingDialog,
    @required this.onFileUpload,
  });

   @override
   _JSONSchemaFormState createState() => _JSONSchemaFormState();
}

class _JSONSchemaFormState extends State<JSONForm> {
  bool isLoading = false;
  bool hasMessage = false;
  final _formKey = GlobalKey<FormState>();
  BootstrapCol internalDiv;

  _JSONSchemaFormState();

  List<AstorComponente> schemaList = [];

  @override
  void initState() {
    super.initState();

    // /// Merge actions
    // if (widget.actions != null) {
    //   // if (Platform.isIOS || Platform.isAndroid) {
    //   //   PermissionHandler()
    //   //       .requestPermissions([PermissionGroup.camera]).then((m) => null);
    //   // }
    //
    //   schemaList = FieldAction().merge(schemaList, widget.actions, widget.schemaName);
    // }
    //
    // /// Merge icons
    // if (widget.icons != null) {
    //   schemaList =
    //       FieldIcon().merge(schemaList, widget.icons, widget.schemaName);
    // }

    /// Merge values
    // if (widget.values != null) {
    //   schemaList = Schema.mergeValues(schemaList, widget.values);
    // }
    // if (widget.controller != null) {
    //   widget.controller.onSubmit = this.onPressSubmitButton;
    // }
  }

  @override
  void didUpdateWidget(JSONForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool schemaEquals =
        jsonEncode(widget.schema) == jsonEncode(oldWidget.schema);
    bool valueEquals =
        jsonEncode(widget.values) == jsonEncode(oldWidget.values);
  }

  /// Render body widget based on widget type
  Widget _buildBodyInternal(AstorComponente schema) {
    internalDiv = BootstrapCol(
        sizes: 'col-12',
        child: JSONDiv(
          schema: schema,
          onBuildBody: _buildBodyChild,
          onFileUpload: widget.onFileUpload,
        )
    );
    return internalDiv;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: BootstrapContainer(
                  fluid: true,
                  children: [ BootstrapRow(
                      height: 60,
                      children: [
                        _buildBodyInternal(widget.schema),
                      ]),
                  ]),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: widget.loadingDialog ?? LoadingDialog(),
              ),
            ),
        ],
      ),
    );
  }

  /// Render body widget based on widget type
  Widget _buildBodyChild(AstorComponente schema) {
    switch (schema.widget) {
      case WidgetType.winlistflat:
        JSONWinListFlat list = JSONWinListFlat(
          schema: schema as AstorList,
          onBuildBody: _buildBodyChild,
          onPressed: onPressSubmitButton,
        );
        Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,list);
        return list;
      case WidgetType.swap:
        JSONSwap list = JSONSwap(
          schema: schema as AstorSwap,
          onBuildBody: _buildBodyChild,
          onPressed: onPressSubmitButton,
        );
        Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,list);
        return list;
      case WidgetType.winlist:
        JSONWinList list = JSONWinList(
          schema: schema as AstorList,
          onBuildBody: _buildBodyChild,
          onPressed: onPressSubmitButton,
        );
         Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,list);
        return list;
      case WidgetType.tree:
        JSONTree list = JSONTree(
          schema: schema as AstorTree,
          onBuildBody: _buildBodyChild,
          onPressed: onPressSubmitButton,
        );
        Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,list);
        return list;
      case WidgetType.winForm:
        JSONSubForm form = JSONSubForm(
          schema: schema,
          onBuildBody: _buildBodyChild,
        );
        Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,form);
      return form;

      case WidgetType.actionbar:
        return JSONActionBar(
          schema: schema,
          onBuildBody: _buildBodyChild,
        );
      case WidgetType.ul:
        return JSONDiv(
          onBuildBody: _buildBodyChild,
          onFileUpload: widget.onFileUpload,
          schema: schema,
          actionBar: true,
          useBootstrap: false,
        );
      case WidgetType.table:
        return JSONTable(
          onBuildBody: _buildBodyChild,
          schema: schema,

        );
      case WidgetType.div:
        return JSONDiv(
          onBuildBody: _buildBodyChild,
          onFileUpload: widget.onFileUpload,
          schema: schema,

        );
      case WidgetType.fieldset:
        return JSONFieldset(
          schema: schema,
          onBuildBody: _buildBodyChild,
          onFileUpload: widget.onFileUpload,
        );
      case WidgetType.infocard:
        return JSONInfoCard(
          schema: schema,
          onPressed: schema.refreshForm?onRefreshForm:onPressSubmitButton,
          onBuildBody: _buildBodyChild,
        );
      case WidgetType.card:
        return JSONCard(
          schema: schema,
          onBuildBody: _buildBodyChild,
        );
      case WidgetType.color:
        return JSONColorField(
          key: Key(schema.name),
          schema: schema,
          onSaved: (String value) {
             setState(() {
               schema.value = value;
             });
          },
          inList: false,
        );

      case WidgetType.datetime:
        return JSONDateTimeField(
          key: Key(schema.name),
          schema: schema,
          onSaved: (String value) {
             setState(() {
              schema.value = value;
           });
          },
        );
      case WidgetType.intervaldate:
        return JSONDateTimeField(
          key: Key(schema.name),
          schema: schema,
          onSaved: (String value) {
               setState(() {
            if (schema.twoProp) {
              List<String> values=value.split(" - ");
              schema.value = values[0];
              schema.value2 = values[1];
            } else
              schema.value = value;
               });
          },
        );

      case WidgetType.collapsable:
        return JSONButton(
          onPressed: onToggleVisibilityTarget,
          schema: schema,
          onSaved: (v) {
            //   setState(() {
            schema.value = v;
            //   });
          },
        );
      case WidgetType.li:
        return JSONButton(
          onPressed: onPressSubmitButton,
          schema: schema.components.first,
          onSaved: (v) {
            //   setState(() {
            schema.value = v;
            //   });
          },
        );
      case WidgetType.button:
        return JSONButton(
          onPressed: onPressSubmitButton,
          schema: schema,
          onSaved: (v) {
          //   setState(() {
              schema.value = v;
          //   });
          },
        );
      case WidgetType.tabpanel:
        return JSONTabPanel(
          onPressed: onPressSubmitButton,
          onBuildBody: _buildBodyChild,
          schema: schema,
          onSaved: (v) {
               setState(() {
            schema.value = v;
               });
          },
        );
      case WidgetType.dropdown:
        return JSONDropDownButton(
          onPressed: onPressSubmitButton,
          onBuildBody: _buildBodyChild,
          schema: schema,
        );
      case WidgetType.line:
        return JSONLine(
          schema: schema,
        );
      case WidgetType.checkbox:
        return JSONCheckboxField(
          schema: schema,
          onRefreshForm: onRefreshForm,
          onSaved: (v) {
             setState(() {
              schema.value = v;
             });
          },
        );
      case WidgetType.radio:
        return JSONSelectField(
          schema: schema as AstorCombo,
           useRadioButton: true,
          onRefreshForm: onRefreshForm,
          onSaved: (List<AstorItem> value) {
            setState(() {
              schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
        case WidgetType.select:
        return JSONSelectField(
          schema: schema as AstorCombo,
          useDropdownButton: true,
          onRefreshForm: onRefreshForm,
          onSaved: (List<AstorItem> value) {
             setState(() {
              schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
      case WidgetType.ddcombo:
        JSONSelectField dd = JSONSelectField(
          schema: schema as AstorCombo,
          onRefreshForm: onRefreshForm,
          onBuildBody: _buildBodyChild,
          useDropdownButton: true,
          onSaved: (List<AstorItem> value) {
            setState(() {
              schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
        Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,dd);
        return dd;
      case WidgetType.multiple:
        return JSONSelectField(
          schema: schema as AstorCombo,
          onRefreshForm: onRefreshForm,
          useGridButton: true,
          onSaved: (List<AstorItem> value) {
            setState(() {
              schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
      case WidgetType.multiplecheck:
        return JSONSelectField(
          schema: schema as AstorCombo,
          onRefreshForm: onRefreshForm,
          useCheckButton: true,
          onSaved: (List<AstorItem> value) {
            setState(() {
              if ((schema as AstorCombo).multiple) {
                schema.value="";
                for(AstorItem item in value) {
                  schema.value += (schema.value==""?"":",")+item.id;
                }
              } else
                schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
      case WidgetType.ddwinlov:
        JSONSelectField dd= JSONSelectField(
          schema: schema as AstorCombo,
          onRefreshForm: onRefreshForm,
          onBuildBody: _buildBodyChild,
          onSaved: (List<AstorItem> value) {
            setState(() {
              if ((schema as AstorCombo).multiple) {
                schema.value="";
                for(AstorItem item in value) {
                  schema.value += (schema.value==""?"":",")+item.id;
                }
              } else
                schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
        Provider.of<AstorProvider>(context,listen: false).astorApp.addObjProvider(schema.objProvider,dd);
        return dd;
      case WidgetType.winlov:
        return JSONSelectField(
          schema: schema as AstorCombo,
          onRefreshForm: onRefreshForm,
          onSaved: (List<AstorItem> value) {
            setState(() {
              if ((schema as AstorCombo).multiple) {
                schema.value="";
                for(AstorItem item in value) {
                  schema.value += (schema.value==""?"":",")+item.id;
                }
              } else
                schema.value = value.first.id;
              (schema as AstorCombo).choices = value;
            });
          },
        );
      case WidgetType.file:
        return JSONFileField(
          schema: schema,
          onFileUpload: widget.onFileUpload,
          onSaved: (value) {
             setState(() {
              schema.value = value;
             });
          },
        );
      case WidgetType.message:
        return JSONMessage(
          schema: schema,
        );
      case WidgetType.h1:
      case WidgetType.h2:
      case WidgetType.h3:
      case WidgetType.h4:
      case WidgetType.label:
        return JSONLabel(
          schema: schema,
          onBuildBody: _buildBodyChild,
        );
      case WidgetType.image:
        return JSONIcon(
          schema: schema,
        );
      case WidgetType.text:
        return JSONTextFormField(
          key: Key(schema.name),
          schema: schema,
          onRefreshForm: onRefreshForm,
          onSaved: (String value) {
             setState(() {
              schema.value = value;

            });
          },
        );
    }
    return Container();
  }
  void onToggleVisibilityTarget(AstorComponente schema, [BuildContext context]) async {

    try {
      AstorProvider provider = Provider.of(context,listen: false);
      AstorComponente comp=provider.astorApp.findName(schema.dataTarget.substring(1));
      if (comp!=null) {
        setState(() {
          comp.forceVisible= !(comp.visible);
        });
      }
      return ;
    } catch (err) {
      rethrow;
    }
  }

  void onPressSubmitButton(AstorComponente schema, [BuildContext context]) async {
    if (isLoading) {
      return null;
    }
    setState(() {
      isLoading = true;
    });
    try {
      String actionTarget = schema.actionTarget;
      bool uploadData = schema.uploadData;
      bool issubmit = schema.issubmit;
      String id_action = schema.idAction;
      bool isRefreshForm = actionTarget.indexOf('do-PartialRefreshForm') != -1;
      if (uploadData && issubmit) {
        if (id_action != "" && !isRefreshForm) // verificar
          if (!_formKey.currentState.validate()) {
            print("Form is not vaild");
            return;
          }
      }

      _formKey.currentState.save();
      // hide keyboard
      if (context != null) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      AstorProvider astorProvider = Provider.of(context,listen: false);
      await astorProvider.doAction(schema,context, null,isRefreshForm?true:null,true);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        // clear the content
        _formKey.currentState.reset();
      }
      return ;
    } catch (err) {
      if (mounted)
        setState(() {
          isLoading = false;
        });
      rethrow;
    }
  }

  void onRefreshForm(AstorComponente schema, [BuildContext context]) async {
     if (isLoading) {
       return null;
     }
     setState(() {
       isLoading = true;
     });
     try {


       _formKey.currentState.save();
       // hide keyboard
       if (context != null) {
         FocusScope.of(context).requestFocus(FocusNode());
       }
    // <xsl:when test="starts-with(@form_name,'filter_pane') or (@noform='true')">
    // goToRefreshForm('do-WinListRefreshAction
    //
       AstorProvider astorProvider = Provider.of(context,listen: false);
       if (schema.name.indexOf('_filter_pane_')!=-1 || schema.noForm)
         await astorProvider.doAction(schema,context, schema.actionTarget,true,false);
       else
         await astorProvider.doAction(schema,context, 'do-PartialRefreshForm',true, false);

       if (mounted) {
         setState(() {
           isLoading = false;
         });
         _formKey.currentState.reset();
       }
       return ;
     } catch (err) {
       if (mounted)
         setState(() {
           isLoading = false;
         });
       rethrow;
     }
  }


}