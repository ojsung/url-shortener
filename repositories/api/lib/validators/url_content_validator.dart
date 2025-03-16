part of 'validators_library.dart';

class UrlContentValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final PartialUrlDto urlDto = PartialUrlDto.fromString(await request.readAsString());
      final String? url = urlDto.longUrl;
      // Borrowing this from the internet
      final RegExp urlRegExp = RegExp(
        r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
        caseSensitive: false,
      );

      if (url == null || !urlRegExp.hasMatch(url)) {
        return Response.badRequest(body: 'Invalid URL format');
      }

      return handler(request);
    };
  }
}
