
// import 'package:astor_mobile/model/astorSchema.dart';
import 'package:astor_mobile/model/astorSchema.dart';

import 'components/JSONDiv.dart';

/// Will return the json like object base on the
/// schema's value and name in [schemaList].
/// For example {name: 'abc'} for textfield.
/// {'author': 1} for foreignkey field, where 1 is the id of the author.
///
Map<String, dynamic> getMap(List<AstorComponente> schemaList, bool uploadData) {
  List<Map<String, dynamic>> json = schemaList
      .map((schema) => schema.onSubmit(uploadData))
      .where((schema) => schema != null)
      .toList();
  // Map<String, dynamic> ret = Map.fromIterables(
  //     json.map((j) => j['key'] as String).toList(),
  //     json.map((j) {
  //       return j['value'];
  //     }).toList());
  return json.first;

}
