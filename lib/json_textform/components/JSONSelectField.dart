import 'package:astor_mobile/json_textform/components/pages/NewPage.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JSONForm.dart';
import '../components/pages/SelectionPage.dart';
import '../utils-components/OutlineButtonContainer.dart';
import 'JSONIcon.dart';

typedef OnChange = void Function(List<AstorItem> choice);

class JSONSelectField extends StatelessWidget implements InterfaceProvider {
  final AstorCombo schema;
  final OnChange? onSaved;

  /// implementation. Default is false
  final bool useDropdownButton;
  final bool useRadioButton;
  final bool useCheckButton;
  final bool useGridButton;
  final OnBuildBody? onBuildBody;
  final OnRefereshForm? onRefreshForm;

  const JSONSelectField({
    Key? key,
    required this.schema,
    required this.useRadioButton,
    required this.useDropdownButton,
    required this.useCheckButton,
    required this.useGridButton,
    this.onRefreshForm,
    this.onBuildBody,
    this.onSaved,
  }) : super(key: key);

  List<AstorItem> _selectedValues() {
    return schema.choices.whereType<AstorItem>().toList();
  }

  AstorItem? _selectedValue() {
    return schema.choices.isNotEmpty ? schema.choices.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final bool visible = schema.visible;
    final bool edited = schema.edited;
    if (!edited) {
      return buildReadOnly(visible, context);
    }

    if (useCheckButton) {
      return buildMultiCheck(visible, context);
    }
    if (useRadioButton) {
      if (schema.orientation == 'toogle') {
        return buildRabioButtonToggle(visible, context);
      }
      if (schema.orientation == 'horizontal') {
        return buildRabioButtonHorizontal(visible, context);
      }
      return buildRabioButtonVertical(visible, context);
    }
    if (useGridButton) {
      return buildGridButton(visible, context);
    }
    if (useDropdownButton) {
      return buildCombo(visible, context);
    }
    return buildWinLov(visible, context);
  }

  Widget buildReadOnly(bool visible, BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: TextFormField(
          key: Key('textfield-${schema.name}'),
          maxLines: 1,
          enabled: false,
          initialValue: getDescripcion(),
          decoration: InputDecoration(
            filled: false,
            labelText: schema.label,
          ),
        ),
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context) {
    return Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 18) ??
        const TextStyle(fontSize: 18);
  }

  Widget buildRabioButtonVertical(bool visible, BuildContext context) {
    final AstorItem? selectedValue = _selectedValue();

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
              Text(
                schema.label,
                style: _titleStyle(context),
              ),
              for (final AstorItem choice in schema.items)
                RadioListTile<AstorItem?>(
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    onSaved?.call([value]);
                    if (schema.refreshForm) {
                      onRefreshForm?.call(schema, context);
                    }
                  },
                  groupValue: selectedValue,
                  value: choice,
                  title: Text(choice.descripcion),
                ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRabioButtonHorizontal(bool visible, BuildContext context) {
    final AstorItem? selectedValue = _selectedValue();

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
              Text(
                schema.label,
                style: _titleStyle(context),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                children: [
                  for (final AstorItem choice in schema.items)
                    SizedBox(
                      width: 50,
                      child: RadioListTile<AstorItem?>(
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          onSaved?.call([value]);
                          if (schema.refreshForm) {
                            onRefreshForm?.call(schema, context);
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
          ),
        ),
      ),
    );
  }

  Widget buildRabioButtonToggle(bool visible, BuildContext context) {
    final AstorItem? selectedValue = _selectedValue();

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
              if (schema.label != '')
                Text(
                  schema.label,
                  style: _titleStyle(context),
                ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                children: [
                  for (final AstorItem choice in schema.items)
                    TextButton(
                      onPressed: () {
                        onSaved?.call([choice]);
                        if (schema.refreshForm) {
                          onRefreshForm?.call(schema, context);
                        }
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          selectedValue == choice ? Colors.blue : Colors.white,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          selectedValue == choice ? Colors.white : Colors.blue,
                        ),
                      ),
                      child: Text(
                        choice.descripcion,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridButton(bool visible, BuildContext context) {
    final AstorItem? selectedValue = _selectedValue();
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined: schema.items.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schema.label,
                style: _titleStyle(context),
              ),
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    for (final AstorItem choice in schema.items)
                      InkWell(
                        onTap: () {
                          onSaved?.call([choice]);
                          if (schema.refreshForm) {
                            onRefreshForm?.call(schema, context);
                          }
                        },
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: OutlineButtonContainer(
                            isFilled: selectedValue == choice,
                            isOutlined: true,
                            child: Column(
                              children: [
                                Text(choice.descripcion),
                                JSONIcon(schema: choice),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
    final AstorItem? selectedValue = _selectedValue();
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        child: GestureDetector(
          onLongPress: () {
            if (schema.components.isEmpty) {
              return;
            }
            showDialog(
              context: context,
              builder: (context) => buildFormAlta(context),
            );
          },
          child: OutlineButtonContainer(
            isFilled: false,
            isOutlined: true,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: DropdownButton<AstorItem>(
                    key: const Key('Dropdown'),
                    hint: Text(schema.label),
                    isExpanded: true,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      onSaved?.call([value]);
                      if (schema.refreshForm) {
                        onRefreshForm?.call(schema, context);
                      }
                    },
                    value: selectedValue,
                    items: schema.items
                        .map(
                          (e) => DropdownMenuItem<AstorItem>(
                            key: Key('Dropdown-${e.id}'),
                            value: e,
                            child: Text(e.descripcion),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMultiCheck(bool visible, BuildContext context) {
    final List<AstorItem> selectValues = _selectedValues();
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined: schema.items.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schema.label,
                style: _titleStyle(context),
              ),
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    for (final AstorItem choice in schema.items)
                      SizedBox(
                        width: 200,
                        child: OutlineButtonContainer(
                          isFilled: false,
                          isOutlined: true,
                          child: SwitchListTile(
                            title: Text(choice.descripcion),
                            value: selectValues.contains(choice),
                            onChanged: (value) {
                              if (value) {
                                if (!selectValues.contains(choice)) {
                                  selectValues.add(choice);
                                }
                              } else {
                                selectValues.remove(choice);
                              }

                              onSaved?.call(List<AstorItem>.from(selectValues));
                              if (schema.refreshForm) {
                                onRefreshForm?.call(schema, context);
                              }
                            },
                            activeTrackColor: Colors.lightBlueAccent,
                            activeColor: Colors.blue,
                            inactiveTrackColor: Colors.grey,
                            inactiveThumbColor: Colors.black45,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWinLov(bool visible, BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        child: GestureDetector(
          onLongPress: () {
            if (schema.components.isEmpty) {
              return;
            }
            showDialog(
              context: context,
              builder: (context) => buildFormAlta(context),
            );
          },
          child: OutlineButtonContainer(
            isFilled: false,
            isOutlined: true,
            child: ListTile(
              key: const Key('selection-field'),
              leading: schema.icon != null
                  ? Icon(
                      schema.icon!.iconData,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : null,
              trailing: Icon(
                Icons.expand_more,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: schema.items.isEmpty
                  ? null
                  : () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        builder: (context) => buildSelectionPage(context),
                      );
                    },
              title: Text('${schema.label}'),
              subtitle: Text(getDescripcion()),
            ),
          ),
        ),
      ),
    );
  }

  String getDescripcion() {
    final selectValues = _selectedValues();
    String out = '';
    for (final element in selectValues) {
      out += (out == '' ? '' : ',') + element.descripcion;
    }
    return out;
  }

  SelectionPage buildSelectionPage(BuildContext context) {
    final AstorProvider provider =
        Provider.of<AstorProvider>(context, listen: false);
    return SelectionPage(
      schema: schema,
      onSearch: provider.winLovOpen,
      multiple: schema.multiple,
      useDialog: true,
      onSelected: (value) {
        onSaved?.call(value);
        if (schema.refreshForm) {
          onRefreshForm?.call(schema, context);
        }
      },
      title: '${schema.label}',
      selections: schema.items,
      value: _selectedValues(),
    );
  }

  @override
  bool getClearSelection() {
    return false;
  }

  @override
  String? getCurrentActionOwner() {
    return schema.actionOwner;
  }

  @override
  String? getCurrentActionOwnerFromSelect() {
    return schema.actionOwner;
  }

  @override
  String? getMultipleActionOwnerList() {
    return '';
  }

  @override
  String? getMultipleCurrentActionOwnerDest() {
    return null;
  }

  @override
  String? getSelectedCell() {
    return '';
  }

  @override
  String? getSelectedRow() {
    return '';
  }

  @override
  String? getSelection() {
    return '';
  }

  @override
  String? getSelectionSpecial(String specialselector) {
    return '';
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
