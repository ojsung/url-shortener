import 'dart:convert' show json;

String withMessage(String message, [Map<String, dynamic>? fields]) {
  return json.encode({'message': message, ...(fields ?? {})});
}

String withErrorMessage(String errorMessage, [Map<String, dynamic>? fields]) {
  return json.encode({'error': errorMessage, ...(fields ?? {})});
}

String withError(Exception error, [Map<String, dynamic>? fields]) {
  return json.encode({'error': error.toString(), ...(fields ?? {})});
}
