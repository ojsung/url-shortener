import 'package:shelf/shelf.dart' show Request, Response;
import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/url_partial.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';

/// Handles requests made by guests to create or retrieve url to shortened url pairs.
class UrlController extends Controller {
  /// Guests may create a shortened url
  Future<Response> postHandler(Request request) async {
    Object? urlString = request.context['longUrl'];
    if ((urlString is String)) {
      try {
        final url = await Url.create(UrlPartial(url: urlString));
        return Response(201, body: url.toJsonString());
      } catch (e) {
        print('Unexpected failure to create url: $e');
        return Response.internalServerError(body: withError('Failed to create url'));
      }
    }
    return Response.badRequest(body: withError('Failed to parse url'));
  }

  /// Guests may also retrieve any shortened url. From my experience, any bit.ly link can be used by anyone?
  /// As long as they have the link? So I don't think we should enforce auth here
  Future<Response> getHandler(Request request, String? shortenedUrl) async {
    if (shortenedUrl != null && _isValidShortenedUrl(shortenedUrl)) {
      try {
        final List<Url> urlList = await Url.read(UrlPartial(shortenedUrl: shortenedUrl));
        final Url? url = urlList.firstOrNull;
        if (url == null) {
          return Response.notFound(withError('Corresponding url was not found'));
        }
        return Response(302, headers: {'location': url.url});
      } catch (e) {
        return Response.internalServerError(body: withError('Url was unable to be retrieved'));
      }
    }
    return Response.internalServerError(body: withError('Unable to get url'));
  }

  bool _isValidShortenedUrl(String url) {
    print(url);
    // up to 8 alphanumeric characters
    final regex = RegExp(r'^[a-zA-Z0-9]{1,8}$');
    return regex.hasMatch(url.trim());
  }
}
