// @dart=2.9
import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/astorSchema.dart';
import '../JSONForm.dart';
import '/json_textform/models/components/Action.dart';

class JSONTextFormField extends StatefulWidget {
  final AstorComponente schema;
  final Function onSaved;
  final OnRefereshForm onRefreshForm;

  JSONTextFormField({
      @required this.schema,
      this.onSaved,
      this.onRefreshForm=null,
      Key key,
  })
      : super(key: key);

  @override
  _JSONTextFormFieldState createState() => _JSONTextFormFieldState();
}

class _JSONTextFormFieldState extends State<JSONTextFormField> {
  TextEditingController _controller;
  bool multiLine = false;
  bool isNumber = false;
  dynamic customActionValue;

  @override
  void initState() {
    super.initState();
    init();
  }

  FocusNode focusNode = FocusNode();
  bool modified=false;


  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(JSONTextFormField oldWidget) {
    if (oldWidget.schema.value != widget.schema.value) {
      Future.delayed(Duration(milliseconds: 50)).then((value) => init());
    }
    super.didUpdateWidget(oldWidget);
  }

  void init() {
    String value = widget.schema.value;
    multiLine = widget.schema.type=="text_area_responsive";
    isNumber=(widget.schema.constraintType == "JLONG")||
        (widget.schema.constraintType == "JFLOAT")||
        (widget.schema.constraintType == "JINTEGER")||
        (widget.schema.constraintType == "JCURRENCY");
    if (_controller == null) {
      _controller = TextEditingController(text: value);
    } else {
      _controller.text = value;
    }

    if (widget.schema.refreshForm) {
      focusNode.addListener(() {
        if (modified) {
          if (widget.schema.refreshForm) {
            widget.onRefreshForm(widget.schema, context);
          }
          modified = false;
        }
      });
    }
  }

  // ignore: missing_return
  String validation(String value) {
    if(isNumber) {
      final n = num.tryParse(value);
      if (n == null) {
        return '';//return '$value is not a valid number';
      }
    };

    if ((value == null || value == "") && widget.schema.required) {
      return '';//return "This field is required";
    }
  }

  _suffixIconAction({File image, String inputValue}) async {
    switch (widget.schema.action.actionDone) {
      case ActionDone.getInput:
        if (inputValue != null) {
          setState(() {
            _controller.text = inputValue.toString();
          });
        } else if (image != null) {
          var value =
              await (widget.schema.action as FieldAction<File>).onDone(image);
          if (value is String) {
            setState(() {
              _controller.text = value;
            });
          }
        }
        break;

      case ActionDone.getImage:
        if (image != null) {
          await (widget.schema.action as FieldAction<File>).onDone(image);
        }
        break;
    }
  }

  Widget _renderSuffixIcon() {
    if (widget.schema.action != null) {
      switch (widget.schema.action.actionTypes) {
        case ActionTypes.image:
          return IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Container(
                  child: Wrap(
                    children: <Widget>[
                      Platform.isAndroid || Platform.isIOS
                          ? ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text("From Camera"),
                              onTap: () async {
                                ImagePicker imagePicker = ImagePicker();
                                var pickedFile = await imagePicker.getImage(
                                  source: ImageSource.camera,
                                );
                                File file = File(pickedFile.path);
                                await _suffixIconAction(image: file);
                              },
                            )
                          : Container(),
                      ListTile(
                        leading: Icon(Icons.filter),
                        title: Text("From Gallery"),
                        onTap: () async {
                          if (Platform.isIOS || Platform.isAndroid) {
                            ImagePicker imagePicker = ImagePicker();
                            var pickedFile = await imagePicker.getImage(
                              source: ImageSource.gallery,
                            );
                            File file = File(pickedFile.path);
                            await _suffixIconAction(image: file);
                          } else if (Platform.isMacOS) {
                            FilePickerCross filePickerCross = await FilePickerCross.pick();
                            File file = File(filePickerCross.path);
                            await _suffixIconAction(image: file);
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            },
            icon: Icon(Icons.camera_alt),
          );

        case ActionTypes.qrScan:
          return IconButton(
            onPressed: () async {
              // if (Platform.isAndroid || Platform.isIOS) {
              //   try {
              //     var result = await BarcodeScanner.scan();
              //     await _suffixIconAction(inputValue: result.rawContent);
              //   } on PlatformException catch (e) {
              //     print(e);
              //   } on FormatException {} catch (e) {
              //     print("format error: $e");
              //   }
              // } else if (Platform.isMacOS) {
              //   //TODO: Add macOS support
              // }
            },
            icon: Icon(Icons.camera_alt),
          );
          break;
        case ActionTypes.custom:
          return IconButton(
            icon: Icon(widget.schema.action.icon),
            onPressed: () async {
              if (widget.schema.action.onActionTap != null) {
                var value =
                    await widget.schema.action.onActionTap(widget.schema);
                await _suffixIconAction(inputValue: value);
              }
            },
          );
          break;
      }
    }
    return null;
  }

  TextInputType _getTextInputType() {
    bool unsigned = widget.schema.unsigned;
    if (widget.schema.constraintType == "JLONG") {
      return TextInputType.numberWithOptions(signed: unsigned, decimal: false);
    } else if (widget.schema.constraintType == "JINTEGER") {
      return TextInputType.numberWithOptions(signed: unsigned, decimal: false);
    }else if (widget.schema.constraintType == "JFLOAT") {
      return TextInputType.numberWithOptions(signed: unsigned, decimal: true);
    }else if (widget.schema.constraintType == "JCURRENCY") {
      return TextInputType.numberWithOptions(signed: unsigned, decimal: true);
    }

    // if (widget.schema.name == "email") {
    //   return TextInputType.emailAddress;
    // }

    if (multiLine) {
      return TextInputType.multiline;
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    bool visible = widget.schema.visible;
    bool edited = widget.schema.edited;

    return Visibility(
      visible: visible,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: TextFormField(
            onChanged: (value) {
              widget.onSaved(value);
              modified=true;
            },
            focusNode: focusNode,
            key: Key("textfield-${widget.schema.name}"),
            maxLines: multiLine ? 10 : 1,
            controller: _controller,
            enabled: edited,
            keyboardType: _getTextInputType(),
            validator: this.validation,
            maxLength: widget.schema.validation?.length?.maximum,
            obscureText: widget.schema.type == "password_field_responsive",
            decoration: InputDecoration(
              filled: false,
              // isDense: widget.schema.inline,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
             errorStyle: TextStyle(height: 0),
              //contentPadding: EdgeInsets.all(0.0),
              // helperText: widget.schema.help,
              labelText: widget.schema.label,
              prefixIcon: widget.schema.icon != null
                  ? Icon(widget.schema.icon.iconData)
                  : null,
              suffixIcon: _renderSuffixIcon(),
              border: edited == true
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    )
                  : null,
            ),
            onSaved: this.widget.onSaved,
          ),
      ),

    );
  }
}
