
import 'package:astor_mobile/astorScreen.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../JSONForm.dart';
import 'JSONDiv.dart';
import 'JSONIcon.dart';

typedef void OnChange(bool value);

class JSONColorField extends StatefulWidget {
final AstorComponente schema;
final Function onSaved;
bool inList = false;

JSONColorField({
  @required this.schema,
  this.onSaved,
  this.inList=false,
  Key key,
}) : super(key: key);

@override
State<StatefulWidget> createState() {
  return _JSONColorFieldState();
}
}

class _JSONColorFieldState extends State<JSONColorField> {
  TextEditingController _controller;
  DateTime dateTime;
  TimeOfDay time;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(JSONColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }
  Color color;

  void init() {
   color = widget.schema.value==""?Colors.white:Color(int.parse("FF"+widget.schema.value,radix: 16));
  }
  Widget addInList() {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
  Widget addReadonly(bool visible) {
    return Visibility(
        visible: visible,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              key: Key("textfield-${widget.schema.name}"),
              maxLines: 1,
              enabled: false,
              initialValue: "",
              decoration: InputDecoration(
                filled: true,
                labelText: widget.schema.label,
                fillColor: color,
              ),

            ),
          ),
        )
    );
  }
  void changeColor(Color newcolor) {
    setState(() => color = newcolor);
    Navigator.of(context).pop();
  }
  bool bugSuffixOpen=false;
  Widget addColorPicker(bool visible) {
    return Visibility(
        visible: visible,
        child:  Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              onTap: ()  {
                if (bugSuffixOpen==true) return;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0.0),
                      contentPadding: const EdgeInsets.all(0.0),
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: color,
                          onColorChanged: changeColor,

                        ),
                      ),
                    );
                  },
                );
              },
              enabled: true,
              key: Key("colorfield"),
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                helperText: widget.schema.help,
                labelText: widget.schema.label,
                prefixIcon: widget.schema.icon != null
                    ? Icon(widget.schema.icon.iconData)
                    : null,
                fillColor: color,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorStyle: TextStyle(height: 0),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    bugSuffixOpen=true;
                    clear();
                    Future.delayed(Duration(milliseconds: 100), () { bugSuffixOpen = false; });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onSaved: (v) {
                this.widget.onSaved(color.red.toRadixString(16).padLeft(2, '0')+color.green.toRadixString(16).padLeft(2, '0')+color.blue.toRadixString(16).padLeft(2, '0'));
              },
            ),
          ),
        )
    );
  }
  void clear() {
    color =null;
  }bool isEdited() {
    return widget.schema.edited;
  }
  bool isVisible() {
    return  widget.schema.visible;
  }

  @override
  Widget build(BuildContext context) {
    bool visible = isVisible();
    bool edited = isEdited();

    if (widget.inList) {
      return addInList();
    } else if (!edited) {
      return addReadonly(visible);
    }
    return addColorPicker(visible);
  }
}
