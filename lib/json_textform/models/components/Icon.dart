
import 'package:flutter/cupertino.dart';

import '../../../model/astorSchema.dart';

abstract class Field<T> {
  /// This should match the schema's name
  String? schemaName;

  /// When this value is null,
  /// then the icon will be for the main schema and all its
  /// foreignkey schema's field;
  /// If this field is set, then only the related name's field will be set icon.
  String? schemaFor;

  /// If this is true and schemaFor is null, then use the icon/action globally,
  /// otherwise, only main screen will use the icon/action
  bool useGlobally=false;

  /// Merge with schema
  List<AstorComponente> merge(
      List<AstorComponente> schemas, List<T> fields, String name);
}

class FieldIcon implements Field<FieldIcon> {
  final IconData? iconData;

  @override
  late String? schemaName;

  @override
  late String? schemaFor;

  @override
  late bool useGlobally;

  FieldIcon(
      {this.iconData,
      String? schemaName,
      String? schemaFor,
      bool useGlobally = true}) {
    this.schemaName = schemaName;
    this.schemaFor = schemaFor;
    this.useGlobally = useGlobally;
  }

  @override
  List<AstorComponente> merge(
      List<AstorComponente> schemas, List<FieldIcon> fields, String name) {
    return schemas.map((s) {
      for (final f in fields) {
        if (f.schemaName == s.name) {
          if ((f.schemaFor == null && f.useGlobally) || f.schemaFor == name) {
            s.icon = f;
          } else if ((!f.useGlobally && f.schemaFor == null) &&
              f.schemaFor == null) {
            s.icon = f;
          }
        }
      }
      return s;
    }).toList();
  }
}
