part of 'validators_library.dart';

class ShortenedUrlContentValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final String shortenedUrl = request.requestedUri.pathSegments.elementAt(1);
      if (!_isValidShortenedUrl(shortenedUrl)) {
        return Response.notFound(withMessage('Url does not match any records'));
      }
      return handler(request);
    };
  }

  bool _isValidShortenedUrl(String url) {
    // up to 8 alphanumeric characters
    final regex = RegExp(r'^[a-zA-Z0-9]{1,8}$');
    return regex.hasMatch(url.trim());
  }
}
