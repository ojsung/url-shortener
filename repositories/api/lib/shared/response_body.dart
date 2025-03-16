import 'dart:convert' show json;

String withMessage(String message, [Map<String, dynamic>? fields]) {
  return json.encode({'message': message, ...(fields ?? {})});
}

String withError(String errorMessage, [Map<String, dynamic>? fields]) {
  return json.encode({'message': errorMessage, ...(fields ?? {})});
}
