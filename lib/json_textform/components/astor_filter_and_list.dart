import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:provider/provider.dart';

import '../../model/AstorProvider.dart';
import '../JSONForm.dart';

class AstorFilterAndList extends StatelessWidget {
  final AstorComponente zoneRow;
  final OnBuildBody onBuildBody;
  final OnRefereshForm? onRefreshForm;

  const AstorFilterAndList({
    super.key,
    required this.zoneRow,
    required this.onBuildBody,
    this.onRefreshForm,
  });


  /// Búsqueda recursiva usando el helper del modelo
  AstorComponente? _findChild(bool Function(AstorComponente child) test) {
    return zoneRow.findFirst(test);
  }

  /// Detecta una lista / tabla válida
  bool _isListComponent(AstorComponente component) {
    final type = component.type;
    final name = (component.name ?? '').toLowerCase();

    // 1) Si es una lista procesada (AstorList / AstorTree), reviso class_table_responsive
    if (component is AstorList) {
      final tableClass = component.classTableResponsive.toLowerCase();
      if (tableClass.contains('table')) {
        return true;
      }
    }

    // 2) Tipos explícitos
    if (type == 'win_list') return true;
    if (type == 'tree_responsive') return true;

    // 3) Heurísticas Web clásicas
    if (name.contains('_list_pane')) return true;
    if (type == 'dgf_list_responsive') return true;
    if (type == 'dgf_list_mobile') return true;
    if (type.contains('list_responsive')) return true;

    return false;
  }

  /// Detecta componente de paginación
  bool _isPaginationComponent(AstorComponente component) {
    final lowerName = (component.name ?? '').toLowerCase();
    final type = component.type;
    return lowerName.contains('pagination_bar') ||
        type.contains('pagination_bar') ||
        component.hasCssClass('pagination-bar');
  }

  @override
  @override
  Widget build(BuildContext context) {
    final filterForm = _findChild((c) => c.isFilterForm);
    final listPane = _findChild(_isListComponent);
    final pagination = _findChild(_isPaginationComponent);

    if (filterForm != null && listPane != null) {
      final filter = AstorFilterPanel(
        form: filterForm,
        onBuildBody: onBuildBody,
        onRefreshForm: onRefreshForm,
      );

      final list = AstorListPanel(
        listPane: listPane,
        pagination: pagination,
        onBuildBody: onBuildBody,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final media = MediaQuery.of(context);
          final isLandscape = media.orientation == Orientation.landscape;
          final isWide = constraints.maxWidth > 900;

          // 👉 En horizontal siempre apilado: filtros arriba, lista abajo
          if (!isLandscape && isWide) {
            // Solo en pantallas grandes y en vertical uso layout lado a lado
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex: 2, child: filter),
                const SizedBox(width: 16),
                Flexible(flex: 3, child: list),
              ],
            );
          }

          // Portrait normal o landscape: filtros arriba, lista 100% ancho
          return Column(
            children: [
              filter,
              const SizedBox(height: 16),
              list,
            ],
          );
        },
      );
    }

    if (filterForm != null && listPane == null) {
      return AstorFilterPanel(
        form: filterForm,
        onBuildBody: onBuildBody,
        onRefreshForm: onRefreshForm,
      );
    }

    if (listPane != null && filterForm == null) {
      return AstorListPanel(
        listPane: listPane,
        pagination: pagination,
        onBuildBody: onBuildBody,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: zoneRow.components.map(onBuildBody).toList(),
    );
  }
}

class AstorFilterPanel extends StatefulWidget {
  final AstorComponente form;
  final OnBuildBody onBuildBody;
  final OnRefereshForm? onRefreshForm;

  const AstorFilterPanel({
    super.key,
    required this.form,
    required this.onBuildBody,
    this.onRefreshForm,
  });

  @override
  State<AstorFilterPanel> createState() => _AstorFilterPanelState();
}

class _AstorFilterPanelState extends State<AstorFilterPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final components = widget.form.components;

    // ---- localizar +Filtros original -----------------------------------
    AstorComponente? toggleFilter;
    for (final c in components) {
      if (c.type == 'check_box_responsive_noform' &&
          c.name.contains('hideshow_filter')) {
        toggleFilter = c;
        break;
      }
    }

    final hasToggle = toggleFilter != null;

    // lo ocultamos del render normal
    if (toggleFilter != null) {
      toggleFilter!.forceVisible = false;
    }

    final bool isExpanded = toggleFilter?.valueChecked ?? false;

    // ---- separar campos del form ---------------------------------------
    final fieldComponents = components.where((c) => c != toggleFilter).toList();

    final inlineFields =
    fieldComponents.where((c) => c.inline == true).toList();
    final normalFields =
    fieldComponents.where((c) => c.inline != true).toList();

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: theme.cardTheme.elevation ?? 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text('Filtros', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (hasToggle)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? 'Ocultar' : 'Ver más',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: isExpanded,
                        onChanged: (value) {
                          if (toggleFilter == null) return;

                          // mismo flujo que JSONCheckboxField
                           toggleFilter!.value = value;

                          if (toggleFilter!.refreshForm &&
                              widget.onRefreshForm != null) {
                            widget.onRefreshForm!(toggleFilter!, context);
                          }

                          setState(() {});
                        },
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // --------------- CUERPO FILTROS ----------------
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final children = <Widget>[];

                // 1) Campos inline_component
                if (inlineFields.isNotEmpty) {
                  if (inlineFields.length == 1) {
                    // único inline -> ocupa el 100%
                    children.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: maxWidth,
                          child: widget.onBuildBody(inlineFields.first),
                        ),
                      ),
                    );
                  } else {
                    // varios inline -> en fila tipo web
                    children.add(
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: inlineFields.map((c) {
                          // cálculo de ancho por item según ancho total
                          double itemWidth;
                          if (maxWidth < 600) {
                            // mobile -> uno por fila
                            itemWidth = maxWidth;
                          } else if (maxWidth < 1000) {
                            // tablet -> 2 por fila aprox
                            itemWidth = (maxWidth - 12) / 2;
                          } else {
                            // escritorio -> 3 por fila aprox
                            itemWidth = (maxWidth - 24) / 3;
                          }

                          return SizedBox(
                            width: itemWidth,
                            child: widget.onBuildBody(c),
                          );
                        }).toList(),
                      ),
                    );
                    children.add(const SizedBox(height: 12));
                  }
                }

                // 2) Campos normales, siempre 100% ancho
                for (final c in normalFields) {
                  children.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: widget.onBuildBody(c),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}




class AstorListPanel extends StatelessWidget {
  final AstorComponente listPane;
  final AstorComponente? pagination;
  final OnBuildBody onBuildBody;

  const AstorListPanel({
    super.key,
    required this.listPane,
    required this.onBuildBody,
    this.pagination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Resultados', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          /// La lista real (JSONWinList)
          Padding(
            padding: const EdgeInsets.all(16),
            child: onBuildBody(listPane),
          ),

          /// Paginación
          if (pagination != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: onBuildBody(pagination!),
            ),
          ],
        ],
      ),
    );
  }
}
