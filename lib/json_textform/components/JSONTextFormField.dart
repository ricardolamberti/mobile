import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/astorSchema.dart';
import '../JSONForm.dart';
import '/json_textform/models/components/Action.dart';

class JSONTextFormField extends StatefulWidget {
  final AstorComponente schema;
  final FormFieldSetter<String>? onSaved;
  final OnRefereshForm? onRefreshForm;

  const JSONTextFormField({
    super.key,
    required this.schema,
    this.onSaved,
    this.onRefreshForm,
  });

  @override
  _JSONTextFormFieldState createState() => _JSONTextFormFieldState();
}

class _JSONTextFormFieldState extends State<JSONTextFormField> {
  TextEditingController? _controller;
  bool multiLine = false;
  bool isNumber = false;

  final FocusNode focusNode = FocusNode();
  bool modified = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(JSONTextFormField oldWidget) {
    if (oldWidget.schema.value != widget.schema.value) {
      Future.delayed(const Duration(milliseconds: 50)).then((value) => init());
    }
    super.didUpdateWidget(oldWidget);
  }

  void init() {
    final String value = widget.schema.value?.toString() ?? '';
    multiLine = widget.schema.type == 'text_area_responsive';
    isNumber = widget.schema.constraintType == 'JLONG' ||
        widget.schema.constraintType == 'JFLOAT' ||
        widget.schema.constraintType == 'JINTEGER' ||
        widget.schema.constraintType == 'JCURRENCY';

    if (_controller == null) {
      _controller = TextEditingController(text: value);
    } else {
      _controller!.text = value;
    }

    if (widget.schema.refreshForm) {
      focusNode.addListener(() {
        if (modified) {
          if (widget.schema.refreshForm) {
            widget.onRefreshForm?.call(widget.schema, context);
          }
          modified = false;
        }
      });
    }
  }

  String? validation(String? value) {
    final fieldValue = value ?? '';

    if (isNumber) {
      final n = num.tryParse(fieldValue);
      if (n == null) {
        return ''; // '$value is not a valid number'
      }
    }

    if (fieldValue.isEmpty && widget.schema.required) {
      return ''; // 'This field is required'
    }
    return null;
  }

  Future<void> _suffixIconAction({File? image, String? inputValue}) async {
    final action = widget.schema.action;
    if (action == null) {
      return;
    }

    switch (action.actionDone) {
      case ActionDone.getInput:
        if (inputValue != null) {
          setState(() {
            _controller?.text = inputValue;
          });
        } else if (image != null && action is FieldAction<File> && action.onDone != null) {
          final value = await action.onDone!(image);
          if (value is String) {
            setState(() {
              _controller?.text = value;
            });
          }
        }
        break;

      case ActionDone.getImage:
        if (image != null && action is FieldAction<File> && action.onDone != null) {
          await action.onDone!(image);
        }
        break;

      case null:
        // Nada que hacer si no hay acción definida
        return;
    }
  }

  Widget? _renderSuffixIcon() {
    final action = widget.schema.action;
    if (action == null) return null;

    switch (action.actionTypes) {
      case ActionTypes.image:
        return IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => Wrap(
                children: <Widget>[
                  if (Platform.isAndroid || Platform.isIOS)
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('From Camera'),
                      onTap: () async {
                        final imagePicker = ImagePicker();
                        final pickedFile = await imagePicker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (pickedFile == null) return;
                        final file = File(pickedFile.path);
                        await _suffixIconAction(image: file);
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.filter),
                    title: const Text('From Gallery'),
                    onTap: () async {
                      if (Platform.isAndroid || Platform.isIOS) {
                        final imagePicker = ImagePicker();
                        final pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile == null) return;
                        final file = File(pickedFile.path);
                        await _suffixIconAction(image: file);
                      } else {
                        // Desktop / macOS / web: usar file_picker
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        if (result == null || result.files.isEmpty) return;

                        final path = result.files.single.path;
                        if (path == null) return;

                        final file = File(path);
                        await _suffixIconAction(image: file);
                      }
                    },
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.camera_alt),
        );

      case ActionTypes.qrScan:
        return IconButton(
          onPressed: () async {
            // Implementación comentada (dependía de BarcodeScanner / PlatformException)
            // Mantengo el botón por compatibilidad visual.
          },
          icon: const Icon(Icons.camera_alt),
        );

      case ActionTypes.custom:
        return IconButton(
          icon: Icon(action.icon),
          onPressed: () async {
            if (action.onActionTap != null) {
              final value = await action.onActionTap!(widget.schema);
              await _suffixIconAction(inputValue: value);
            }
          },
        );
    }
  }

  TextInputType? _getTextInputType() {
    final bool unsigned = widget.schema.unsigned;

    if (widget.schema.constraintType == 'JLONG' ||
        widget.schema.constraintType == 'JINTEGER') {
      return TextInputType.numberWithOptions(
        signed: unsigned,
        decimal: false,
      );
    } else if (widget.schema.constraintType == 'JFLOAT' ||
        widget.schema.constraintType == 'JCURRENCY') {
      return TextInputType.numberWithOptions(
        signed: unsigned,
        decimal: true,
      );
    }

    if (multiLine) {
      return TextInputType.multiline;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool visible = widget.schema.visible;
    final bool edited = widget.schema.edited;
    final lengthValidation = widget.schema.validation?.length;

    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: TextFormField(
          onChanged: (value) {
            widget.onSaved?.call(value);
            modified = true;
          },
          focusNode: focusNode,
          key: Key('textfield-${widget.schema.name}'),
          maxLines: multiLine ? 10 : 1,
          controller: _controller,
          enabled: edited,
          keyboardType: _getTextInputType(),
          validator: validation,
          maxLength: lengthValidation?.maximum,
          obscureText: widget.schema.type == 'password_field_responsive',
          decoration: InputDecoration(
            filled: false,
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            errorStyle: const TextStyle(height: 0),
            labelText: widget.schema.label,
            prefixIcon: widget.schema.icon != null
                ? Icon(widget.schema.icon!.iconData)
                : null,
            suffixIcon: _renderSuffixIcon(),
            border: edited
                ? const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  )
                : null,
          ),
          onSaved: widget.onSaved,
        ),
      ),
    );
  }
}
