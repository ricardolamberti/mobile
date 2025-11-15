import 'dart:io';

import 'package:astor_mobile/model/astorSchema.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/components/FileFieldValue.dart';
import '../utils-components/OutlineButtonContainer.dart';
import '../JSONForm.dart';

typedef OnChange = void Function(FileFieldValue value);

class JSONFileField extends StatelessWidget {
  /// Callback opcional para subir el archivo de forma personalizada
  final OnFileUpload? onFileUpload;

  final AstorComponente schema;
  final OnChange? onSaved;
  final bool showIcon;
  final bool isOutlined;
  final bool filled;

  const JSONFileField({
    super.key,
    required this.schema,
    this.onFileUpload,
    this.onSaved,
    this.showIcon = true,
    this.isOutlined = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    FileFieldValue value;
    if (schema.value == null) {
      value = FileFieldValue();
    } else if (schema.value is! FileFieldValue) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Text(
          "Value is not supported",
          style: TextStyle(color: Colors.red),
        ),
      );
    } else {
      value = schema.value as FileFieldValue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: OutlineButtonContainer(
        isFilled: filled,
        isOutlined: isOutlined,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(schema.label),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      children: <Widget>[
                        if (value.path != null && value.path!.isNotEmpty)
                          Chip(
                            label: Text(
                              "Old: ${value.path}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                decoration: value.willClear
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            deleteIcon: !value.willClear
                                ? const Icon(
                                    Icons.cancel,
                                    key: Key("Delete Old"),
                                  )
                                : const Icon(
                                    Icons.restore,
                                    key: Key("Restore"),
                                  ),
                            onDeleted: () {
                              if (value.willClear) {
                                value.restoreOld();
                              } else {
                                value.clearOld();
                              }
                              onSaved?.call(value);
                            },
                          ),
                        const SizedBox(width: 10),
                        if (value.file != null)
                          Chip(
                            label: Text(
                              "New: ${value.file!.path}",
                              maxLines: 1,
                            ),
                            deleteIcon: const Icon(
                              Icons.cancel,
                              key: Key("Delete New"),
                            ),
                            onDeleted: () {
                              value.clearNew();
                              onSaved?.call(value);
                            },
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key("Upload"),
                    icon: const Icon(Icons.file_upload),
                    onPressed: () async {
                      File? file;

                      // Si el caller provee su propio uploader, lo usamos
                      if (onFileUpload != null) {
                        file = await onFileUpload!(schema.name);
                      } else {
                        // Fallback usando file_picker
                        try {
                          final result =
                              await FilePicker.platform.pickFiles();

                          if (result == null || result.files.isEmpty) {
                            return;
                          }

                          final picked = result.files.first;

                          // En móvil deberías tener path; en web puede ser sólo bytes
                          if (picked.path == null) {
                            // Si querés soportar web con bytes, acá habría que adaptar FileFieldValue
                            return;
                          }

                          file = File(picked.path!);
                        } catch (err) {
                          // podrías loguear el error si querés
                          return;
                        }
                      }

                      if (file == null) {
                        return;
                      }

                      value.file = file;
                      onSaved?.call(value);
                    },
                  ),
                ],
              ),
              Divider(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
