part of 'validators_library.dart';

class ShortenedUrlValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final String? shortenedUrl = request.requestedUri.pathSegments.elementAtOrNull(1);
      if (shortenedUrl == null || !_isValidShortenedUrl(shortenedUrl)) {
        throw NotFoundException();
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
