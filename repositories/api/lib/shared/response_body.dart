import 'dart:convert' show json;
/// Create a JSON string with a message and optional fields
String withMessage(String message, [Map<String, dynamic>? fields]) {
  return json.encode({'message': message, ...(fields ?? {})});
}
/// Create a JSON string with an error message and optional fields
String withErrorMessage(String errorMessage, [Map<String, dynamic>? fields]) {
  return json.encode({'error': errorMessage, ...(fields ?? {})});
}
/// Create a JSON string based on an error message. Allow optional fields
String withError(Exception error, [Map<String, dynamic>? fields]) {
  return json.encode({'error': error.toString(), ...(fields ?? {})});
}
