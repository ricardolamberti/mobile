import 'package:astor_mobile/json_textform/components/JSONIcon.dart';
import 'package:astor_mobile/json_textform/components/JSONDiv.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';

import '../JSONForm.dart';

class JSONLabel extends StatelessWidget {
  final AstorComponente schema;
  final OnBuildBody onBuildBody;

  const JSONLabel({
    super.key,
    required this.schema,
    required this.onBuildBody,
  });

  bool get _isHeadingType =>
      schema.type == 'h1_responsive' ||
          schema.type == 'h2_responsive' ||
          schema.type == 'h3_responsive' ||
          schema.type == 'h4_responsive';

  @override
  Widget build(BuildContext context) {
    if (!schema.isVisibleInContext(context)) {
      return const SizedBox.shrink();
    }

    final bool composite = schema.composite;

    if (_isHeadingType) {
      // Títulos H1–H4
      if (composite) {
        // título + contenido debajo (como antes) → evita overflow
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeadingLine(context),
            JSONDiv(
              schema: schema,
              useBootstrap: false,
              actionBar: false,
              onBuildBody: onBuildBody,
            ),
          ],
        );
      } else {
        return _buildHeadingLine(context);
      }
    }

    // Label normal
    if (composite) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSimpleLabelLine(context),
          JSONDiv(
            schema: schema,
            useBootstrap: false,
            actionBar: false,
            onBuildBody: onBuildBody,
          ),
        ],
      );
    } else {
      return _buildSimpleLabelLine(context);
    }
  }

  // ---------- HEADINGS (línea sola) ----------

  Widget _buildHeadingLine(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle baseStyle;
    switch (schema.type) {
      case 'h1_responsive':
        baseStyle = theme.textTheme.headlineSmall ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
        break;
      case 'h2_responsive':
        baseStyle = theme.textTheme.titleLarge ??
            const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
        break;
      case 'h3_responsive':
        baseStyle = theme.textTheme.titleMedium ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
        break;
      case 'h4_responsive':
      default:
        baseStyle = theme.textTheme.titleSmall ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
        break;
    }

    final bool alignRight =
    schema.classResponsive.contains('one-line-right');

    final text = _resolveText();

    final leadingIcon =
    schema.hasIcon ? JSONIcon(schema: schema) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.4),
              width: 2,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Align(
                alignment: alignRight
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: baseStyle.copyWith(letterSpacing: 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- LABEL SIMPLE (línea sola) ----------

  Widget _buildSimpleLabelLine(BuildContext context) {
    final theme = Theme.of(context);
    final text = _resolveText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        children: [
          if (schema.hasIcon) ...[
            JSONIcon(schema: schema),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helper para obtener texto ----------

  String _resolveText() {
    if (schema.type == 'text_label_responsive' && schema.value != null) {
      return schema.value.toString();
    }
    if (schema.label.isNotEmpty) return schema.label;
    if (schema.text.isNotEmpty) return schema.text;
    if (schema.title.isNotEmpty) return schema.title;
    return '';
  }
}
