import 'package:astor_mobile/json_textform/components/pages/NewPage.dart';
import 'package:astor_mobile/json_textform/components/pages/astor_input_decoration.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JSONForm.dart';
import '../components/pages/SelectionPage.dart';
import '../utils-components/OutlineButtonContainer.dart';
import 'JSONIcon.dart';

typedef OnChange = void Function(List<AstorItem> choice);

class JSONSelectField extends StatefulWidget implements InterfaceProvider {
  final AstorCombo schema;
  final OnChange? onSaved;
  final OnRefereshForm? onRefreshForm;

  final bool useDropdownButton;
  final bool useRadioButton;
  final bool useCheckButton;
  final bool useGridButton;

  final OnBuildBody? onBuildBody;

  const JSONSelectField({
    super.key,
    required this.schema,
    this.onSaved,
    this.onRefreshForm,
    this.useDropdownButton = false,
    this.useRadioButton = false,
    this.useCheckButton = false,
    this.useGridButton = false,
    this.onBuildBody,
  });

  // ---- InterfaceProvider (forward a schema) -----------------------------
  @override
  bool getClearSelection() => false;

  @override
  String? getCurrentActionOwner() => schema.actionOwner;

  @override
  String? getCurrentActionOwnerFromSelect() => schema.actionOwner;

  @override
  String? getMultipleActionOwnerList() => '';

  @override
  String? getMultipleCurrentActionOwnerDest() => null;

  @override
  String? getSelectedCell() => '';

  @override
  String? getSelectedRow() => '';

  @override
  String? getSelection() => '';

  @override
  String? getSelectionSpecial(String specialselector) => '';

  @override
  bool hasMoreSelections() => false;

  @override
  bool hasMultipleSelect() => false;

  @override
  bool hasMultipleSelectSpecial(String specialselector) => false;

  @override
  State<JSONSelectField> createState() => _JSONSelectFieldState();
}

class _JSONSelectFieldState extends State<JSONSelectField> {
  // ---- LOV RESPONSIVE (win_lov_responsive) ------------------------------
  late final TextEditingController _lovController;
  List<AstorItem> _lovResults = <AstorItem>[];
  bool _isLoadingLov = false;

  bool get _isLovResponsive =>
      widget.schema.type == 'win_lov_responsive';

  @override
  void initState() {
    super.initState();
    _lovController = TextEditingController(
      text: widget.schema.choices.isNotEmpty
          ? widget.schema.choices.first?.descripcion
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant JSONSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // si se actualiza la elección desde afuera, sincronizamos el texto
    if (widget.schema != oldWidget.schema) {
      final desc = widget.schema.choices.isNotEmpty
          ? widget.schema.choices.first?.descripcion
          : '';
      _lovController.text = desc!;
    }
  }

  @override
  void dispose() {
    _lovController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------

  List<AstorItem> _selectedValues() {
    return widget.schema.choices.whereType<AstorItem>().toList();
  }

  AstorItem? _selectedValue() {
    return widget.schema.choices.isNotEmpty
        ? widget.schema.choices.first
        : null;
  }

  TextStyle _titleStyle(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontSize: 18) ??
        const TextStyle(fontSize: 18);
  }

  @override
  Widget build(BuildContext context) {
    final bool visible = widget.schema.visible;
    final bool edited = widget.schema.edited;

    // Modo solo lectura
    if (!edited) {
      return buildReadOnly(visible, context);
    }

    // Modo especial: win_lov_responsive (editable + búsqueda remota)
    if (_isLovResponsive) {
      return buildLovResponsive(visible, context);
    }

    // Resto de modos existentes
    if (widget.useCheckButton) {
      return buildMultiCheck(visible, context);
    }
    if (widget.useRadioButton) {
      if (widget.schema.orientation == 'toogle') {
        return buildRabioButtonToggle(visible, context);
      }
      if (widget.schema.orientation == 'horizontal') {
        return buildRabioButtonHorizontal(visible, context);
      }
      return buildRabioButtonVertical(visible, context);
    }
    if (widget.useGridButton) {
      return buildGridButton(visible, context);
    }
    if (widget.useDropdownButton) {
      return buildCombo(visible, context);
    }
    return buildWinLov(visible, context);
  }

  // ----------------------------------------------------------------------
  //  READ ONLY
  // ----------------------------------------------------------------------
// ----------------------------------------------------------------------
//  READ ONLY
// ----------------------------------------------------------------------
  Widget buildReadOnly(bool visible, BuildContext context) {
    final theme = Theme.of(context);
    final baseDecoration = buildAstorInputDecoration(context, widget.schema);

    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: TextFormField(
          key: Key('textfield-${widget.schema.name}'),
          maxLines: 1,
          // 👇 se ve normal pero no se puede editar
          enabled: true,
          readOnly: true,
          initialValue: getDescripcion(),
          style: theme.textTheme.bodyMedium,
          decoration: baseDecoration.copyWith(
            // fondo suave para readonly, igual que en los otros campos
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            // opcional: candadito para marcar que es solo lectura
            suffixIcon: const Icon(Icons.lock_outline, size: 18),
          ),
        ),
      ),
    );
  }


  // ----------------------------------------------------------------------
  //  LOV RESPONSIVE (win_lov_responsive)  -> campo editable + lista abajo
  // ----------------------------------------------------------------------
  Widget buildLovResponsive(bool visible, BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _lovController,
              decoration: buildAstorInputDecoration(context, widget.schema)
                  .copyWith(labelText: widget.schema.label),
              onChanged: (text) async {
                // cada cambio dispara búsqueda remota
                final provider = Provider.of<AstorProvider>(
                  context,
                  listen: false,
                );
                setState(() => _isLoadingLov = true);

                final future = provider.winLovOpen(widget.schema, text);
                final result = await (future ?? Future.value(<AstorItem>[]));
                if (!mounted) return;

                setState(() {
                  _lovResults = result ?? <AstorItem>[];
                  _isLoadingLov = false;
                });
              },
            ),
            if (_isLoadingLov)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_lovResults.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _lovResults.length,
                  itemBuilder: (context, index) {
                    final item = _lovResults[index];
                    return ListTile(
                      title: Text(item.descripcion),
                      onTap: () {
                        setState(() {
                          _lovController.text = item.descripcion;
                          widget.schema.value = item.id;
                          widget.schema.choices = [item];
                          _lovResults = <AstorItem>[];
                        });

                        widget.onSaved?.call([item]);
                        if (widget.schema.refreshForm &&
                            widget.onRefreshForm != null) {
                          widget.onRefreshForm!(widget.schema, context);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  //  RADIO (vertical / horizontal / toggle)
  // ----------------------------------------------------------------------
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
              Text(widget.schema.label, style: _titleStyle(context)),
              for (final AstorItem choice in widget.schema.items)
                RadioListTile<AstorItem?>(
                  onChanged: (value) {
                    if (value == null) return;
                    widget.onSaved?.call([value]);
                    if (widget.schema.refreshForm &&
                        widget.onRefreshForm != null) {
                      widget.onRefreshForm!(widget.schema, context);
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
              Text(widget.schema.label, style: _titleStyle(context)),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                children: [
                  for (final AstorItem choice in widget.schema.items)
                    SizedBox(
                      width: 50,
                      child: RadioListTile<AstorItem?>(
                        onChanged: (value) {
                          if (value == null) return;
                          widget.onSaved?.call([value]);
                          if (widget.schema.refreshForm &&
                              widget.onRefreshForm != null) {
                            widget.onRefreshForm!(widget.schema, context);
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final borderColor =
        theme.colorScheme.outlineVariant; // borde suave tipo M3
    const radius = 999.0; // bien redondeado

    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.schema.label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.schema.label,
                    style: _titleStyle(context),
                  ),
                ),

              // Píldora completa
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: borderColor),
                  color: theme.colorScheme.surface,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (final AstorItem choice in widget.schema.items)
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(radius),
                          onTap: () {
                            widget.onSaved?.call([choice]);
                            if (widget.schema.refreshForm &&
                                widget.onRefreshForm != null) {
                              widget.onRefreshForm!(widget.schema, context);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius),
                              color: selectedValue == choice
                                  ? primary
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                choice.descripcion,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selectedValue == choice
                                      ? onPrimary
                                      : primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ----------------------------------------------------------------------
  //  GRID BUTTON
  // ----------------------------------------------------------------------
  Widget buildGridButton(bool visible, BuildContext context) {
    final AstorItem? selectedValue = _selectedValue();
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined: widget.schema.items.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.schema.label, style: _titleStyle(context)),
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    for (final AstorItem choice in widget.schema.items)
                      InkWell(
                        onTap: () {
                          widget.onSaved?.call([choice]);
                          if (widget.schema.refreshForm &&
                              widget.onRefreshForm != null) {
                            widget.onRefreshForm!(widget.schema, context);
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

  // ----------------------------------------------------------------------
  //  COMBO DROPDOWN
  // ----------------------------------------------------------------------
  Widget buildFormAlta(BuildContext context) {
    return NewPage(
      schema: widget.schema,
      onBuildBody:
      widget.onBuildBody ?? (comp) => const SizedBox.shrink(),
      title: widget.schema.label,
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
            if (widget.schema.components.isEmpty) return;
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
                    hint: Text(widget.schema.label),
                    isExpanded: true,
                    onChanged: (value) {
                      if (value == null) return;
                      widget.onSaved?.call([value]);
                      if (widget.schema.refreshForm &&
                          widget.onRefreshForm != null) {
                        widget.onRefreshForm!(widget.schema, context);
                      }
                    },
                    value: selectedValue,
                    items: widget.schema.items
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

  // ----------------------------------------------------------------------
  //  MULTI CHECK
  // ----------------------------------------------------------------------
  Widget buildMultiCheck(bool visible, BuildContext context) {
    final List<AstorItem> selectValues = _selectedValues();
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: OutlineButtonContainer(
          isFilled: false,
          isOutlined: widget.schema.items.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.schema.label, style: _titleStyle(context)),
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    for (final AstorItem choice in widget.schema.items)
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

                              widget.onSaved
                                  ?.call(List<AstorItem>.from(selectValues));
                              if (widget.schema.refreshForm &&
                                  widget.onRefreshForm != null) {
                                widget.onRefreshForm!(
                                    widget.schema, context);
                              }
                            },
                            activeTrackColor: Colors.lightBlueAccent,
                            activeThumbColor: Colors.blue,
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

  // ----------------------------------------------------------------------
  //  WIN LOV CLÁSICO (dialog SelectionPage)
  // ----------------------------------------------------------------------
  Widget buildWinLov(bool visible, BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        child: GestureDetector(
          onLongPress: () {
            if (widget.schema.components.isEmpty) return;
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
              leading: widget.schema.icon != null
                  ? Icon(
                widget.schema.icon!.iconData,
                color: Theme.of(context).iconTheme.color,
              )
                  : null,
              trailing: Icon(
                Icons.expand_more,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: widget.schema.items.isEmpty
                  ? null
                  : () {
                FocusScope.of(context)
                    .requestFocus(FocusNode());
                showDialog(
                  context: context,
                  builder: (context) =>
                      buildSelectionPage(context),
                );
              },
              title: Text(widget.schema.label),
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
      schema: widget.schema,
      onSearch: (combo, text) async {
        final future = provider.winLovOpen(combo, text);
        if (future == null) return <AstorItem>[];
        final result = await future;
        return result ?? <AstorItem>[];
      },
      multiple: widget.schema.multiple,
      useDialog: true,
      onSelected: (value) {
        widget.onSaved?.call(value);
        if (widget.schema.refreshForm &&
            widget.onRefreshForm != null) {
          widget.onRefreshForm!(widget.schema, context);
        }
      },
      title: widget.schema.label,
      selections: widget.schema.items,
      value: _selectedValues(),
    );
  }
}
