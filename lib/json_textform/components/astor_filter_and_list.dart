import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';

class AstorFilterAndList extends StatelessWidget {
  final AstorComponente zoneRow;
  final OnBuildBody onBuildBody;

  const AstorFilterAndList({
    super.key,
    required this.zoneRow,
    required this.onBuildBody,
  });

  AstorComponente? _findChild(bool Function(AstorComponente child) test) {
    for (final child in zoneRow.components) {
      if (test(child)) {
        return child;
      }
    }
    return null;
  }

  bool _isListComponent(AstorComponente component) {
    final type = component.type;
    final name = component.name.toLowerCase();
    return name.contains('_list_pane') ||
        type == 'dgf_list_responsive' ||
        type == 'dgf_list_mobile' ||
        type.contains('list_responsive');
  }

  bool _isPaginationComponent(AstorComponente component) {
    final lowerName = component.name.toLowerCase();
    final type = component.type;
    return lowerName.contains('pagination_bar') ||
        type.contains('pagination_bar') ||
        component.hasCssClass('pagination-bar');
  }

  @override
  Widget build(BuildContext context) {
    final filterForm = _findChild((c) => c.isFilterForm);
    final listPane = _findChild(_isListComponent);
    final pagination = _findChild(_isPaginationComponent);

    if (listPane == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: zoneRow.components.map(onBuildBody).toList(),
      );
    }

    final list = AstorListPanel(
      listPane: listPane,
      pagination: pagination,
      onBuildBody: onBuildBody,
    );

    if (filterForm == null) {
      return list;
    }

    final filter = AstorFilterPanel(
      form: filterForm,
      onBuildBody: onBuildBody,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(flex: 2, child: filter),
              const SizedBox(width: 16),
              Flexible(flex: 3, child: list),
            ],
          );
        }
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
}

class AstorFilterPanel extends StatefulWidget {
  final AstorComponente form;
  final OnBuildBody onBuildBody;

  const AstorFilterPanel({
    super.key,
    required this.form,
    required this.onBuildBody,
  });

  @override
  State<AstorFilterPanel> createState() => _AstorFilterPanelState();
}

class _AstorFilterPanelState extends State<AstorFilterPanel> {
  bool _filtersVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final components = widget.form.components;
    AstorComponente? hideShow;
    for (final component in components) {
      if (component.type == 'check_box_responsive_noform' &&
          component.hasCssClass('hideshow-filter')) {
        hideShow = component;
        break;
      }
    }

    final fieldComponents = components.where(
      (c) =>
          c.type != 'check_box_responsive_noform' &&
          !c.name.toLowerCase().endsWith('_button'),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: theme.cardTheme.elevation ?? 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text('Filtros', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (hideShow != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _filtersVisible = !_filtersVisible;
                      });
                    },
                    icon: Icon(
                      _filtersVisible
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    label: Text(_filtersVisible ? 'Ocultar' : 'Mostrar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_filtersVisible) ...[
              const Divider(),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final fieldWidgets = fieldComponents.map((c) {
                    final width = isWide
                        ? (constraints.maxWidth / 2) - 24
                        : constraints.maxWidth;
                    return SizedBox(
                      width: width,
                      child: widget.onBuildBody(c),
                    );
                  }).toList();

                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: fieldWidgets,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Limpiar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    label: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: onBuildBody(listPane),
          ),
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
