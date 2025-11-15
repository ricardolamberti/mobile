import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class JSONColorField extends StatefulWidget {
  final AstorComponente schema;
  final ValueChanged<String>? onSaved;
  final bool inList;

  const JSONColorField({
    Key? key,
    required this.schema,
    this.onSaved,
    this.inList = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JSONColorFieldState();
  }
}

class _JSONColorFieldState extends State<JSONColorField> {
  Color? color;
  bool bugSuffixOpen = false;

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

  void init() {
    final String value = widget.schema.value?.toString() ?? '';
    color = value.isEmpty
        ? Colors.white
        : Color(int.parse('FF$value', radix: 16));
  }

  Widget addInList() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
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
            key: Key('textfield-${widget.schema.name}'),
            maxLines: 1,
            enabled: false,
            initialValue: '',
            decoration: InputDecoration(
              filled: true,
              labelText: widget.schema.label,
              fillColor: color,
            ),
          ),
        ),
      ),
    );
  }

  void changeColor(Color newColor) {
    setState(() => color = newColor);
    Navigator.of(context).pop();
  }

  Widget addColorPicker(bool visible) {
    return Visibility(
      visible: visible,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: TextFormField(
            enabled: true,
            onTap: () {
              if (bugSuffixOpen == true) return;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: EdgeInsets.zero,
                    contentPadding: EdgeInsets.zero,
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: color ?? Colors.white,
                        onColorChanged: changeColor,
                      ),
                    ),
                  );
                },
              );
            },
            key: const Key('colorfield'),
            decoration: InputDecoration(
              filled: true,
              helperText: widget.schema.help,
              labelText: widget.schema.label,
              prefixIcon: widget.schema.icon != null
                  ? Icon(widget.schema.icon.iconData)
                  : null,
              fillColor: color,
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              errorStyle: const TextStyle(height: 0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  bugSuffixOpen = true;
                  clear();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    bugSuffixOpen = false;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSaved: (v) {
              final Color? currentColor = color;
              if (currentColor == null) {
                widget.onSaved?.call('');
                return;
              }
              widget.onSaved?.call(
                currentColor.red
                        .toRadixString(16)
                        .padLeft(2, '0') +
                    currentColor.green
                        .toRadixString(16)
                        .padLeft(2, '0') +
                    currentColor.blue
                        .toRadixString(16)
                        .padLeft(2, '0'),
              );
            },
          ),
        ),
      ),
    );
  }

  void clear() {
    color = null;
  }

  bool isEdited() {
    return widget.schema.edited;
  }

  bool isVisible() {
    return widget.schema.visible;
  }

  @override
  Widget build(BuildContext context) {
    final bool visible = isVisible();
    final bool edited = isEdited();

    if (widget.inList) {
      return addInList();
    } else if (!edited) {
      return addReadonly(visible);
    }
    return addColorPicker(visible);
  }
}
