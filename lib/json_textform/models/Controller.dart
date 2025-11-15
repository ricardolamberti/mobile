
import 'package:flutter/material.dart';

typedef OnControllerSubmit = Future<Map<String, dynamic>> Function(
    [BuildContext? context]);

class JSONSchemaController {
  OnControllerSubmit? onSubmit;
}
