part of 'validators_library.dart';

class UrlFieldValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final PartialUrlDto urlDto = PartialUrlDto.fromString(await request.readAsString());
      final String? url = urlDto.longUrl;
      if (url == null || url.isEmpty) {
        return Response.badRequest(body: json.encode({'message': 'Url must not be empty'}));
      }
      final requestWithUrl = request.change(context: {'longUrl': url});

      // If validation passes, call the next handler
      return handler(requestWithUrl);
    };
  }
}
