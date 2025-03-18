part of 'validators_library.dart';

class UrlIdParamValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final String id = request.requestedUri.pathSegments.last;
      final int? idInt = int.tryParse(id);
      if (idInt == null) {
        throw InvalidIdException('The id must be a string');
      }
      Request requestWithId = request.change(context: {'urlId': idInt});
      return handler(requestWithId);
    };
  }
}
