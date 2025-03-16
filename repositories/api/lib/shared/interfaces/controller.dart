import 'package:url_shortener_server/shared/response_body.dart' as body;

abstract class Controller {
  const Controller();
}

extension Body on Controller {
  String Function(String message, [Map<String, dynamic>? fields]) get withMessage => body.withMessage;
  String Function(String errorMessage, [Map<String, dynamic>? fields]) get withErrorMessage => body.withErrorMessage;
  String Function(Exception errorMessage, [Map<String, dynamic>? fields]) get withError => body.withError;
}
