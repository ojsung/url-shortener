import 'package:shelf/shelf.dart' show Request, Response;
import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/url_partial.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';

/// Handles requests made by guests to create or retrieve url to shortened url pairs.
class UrlController extends Controller {
  /// Guests may create a shortened url
  Future<Response> postHandler(Request request) async {
    Object? urlString = request.context['longUrl'];
    if ((urlString is String)) {
      // Error handling is handled in our error handler middleware. This looks scary, but isn't
      final url = await Url.create(UrlPartial(url: urlString));
      return Response(201, body: url.toJsonString());
    }
    throw IncompleteDataException('Unable to parse url');
  }

  /// Guests may also retrieve any shortened url. From my experience, any bit.ly link can be used by anyone?
  /// As long as they have the link? So I don't think we should enforce auth here
  Future<Response> getHandler(Request request, String? shortenedUrl) async {
    if (shortenedUrl != null) {
      final List<Url> urlList = await Url.read(UrlPartial(shortenedUrl: shortenedUrl));
      final Url? url = urlList.firstOrNull;
      if (url == null) {
        throw NotFoundException('The corresponding url was not found');
      }
      return Response(302, headers: {'location': url.url});
    }
    throw UnknownDatabaseException();
  }
}
