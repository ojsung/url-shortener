part of 'validators_library.dart';

class UrlContentValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final Object? url = request.context['longUrl'];
      if (url is String) {
        // Borrowing this regexp from the internet
        final RegExp urlRegExp = RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$', caseSensitive: false);
        if (!urlRegExp.hasMatch(url)) {
          throw InvalidUrlException('Url does not conform to expected format');
        } else {
          return handler(request);
        }
      } else {
        throw InvalidUrlException('Bad url?');
      }
    };
  }
}
