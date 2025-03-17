/* 
        Router()
          ..get('/', (request) => Response.ok(withMessage('Welcome back user')))
          ..get('/urls', (request) => Response.ok(withMessage('Found', {'urls': List.filled(10, 'b')})))
          ..post('/urls', (request) => Response(201))
          ..put('/urls', (request) => Response.ok('Done'))
          ..delete('/urls', (request) => Response.ok('Deleted'))
          ..get('/urls/<id>', (request, url) => Response.found('Found url: $url'));
*/
import 'package:shelf/shelf.dart' show Request, Response;
import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/url_partial.dart';
import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';

/// Handles requests made by guests to create or retrieve url to shortened url pairs.
class UserController extends Controller {
  /// Guests may create a shortened url
  /// Guests may also retrieve any shortened url. From my experience, any bit.ly link can be used by anyone?
  /// As long as they have the link? So I don't think we should enforce auth here
  Future<Response> getHandler(Request request) async {
    Object? userId = request.context['userId'];
    if (userId! is int) {
      throw BrokenAuthorizationHeaderException();
    }
    final User? user = (await User.read(UserPartial(id: userId as int))).firstOrNull;
    if (user == null) {
      throw UnknownDatabaseException("The user is missing");
    }
    return Response.ok(withMessage('Found', {'username': user.username}));
  }

  Future<Response> urlPostHandler(Request request) async {
    Object? userId = request.context['userId'];
    Object? url = request.context['longUrl'];
    
  }

  Future<Response> postHandler(Request request) async {
    Object? urlString = request.context['longUrl'];
    if ((urlString is String)) {
      // Error handling is handled in our error handler middleware. This looks scary, but isn't
      final url = await Url.create(UrlPartial(url: urlString));
      return Response(201, body: url.toJsonString());
    }
    throw IncompleteDataException('Unable to parse url');
  }
}
