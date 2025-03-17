/* 
        Router()
          ..delete('/urls', (request) => Response.ok('Deleted'))
*/
import 'package:shelf/shelf.dart' show Request, Response;
import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/url_partial.dart';
import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart';
import 'package:url_shortener_server/models/user_url_model.dart';
import 'package:url_shortener_server/models/user_url_partial.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';

/// Handles requests made by users to create or modify their own urls
class UserController extends Controller {
  /// The user may retrieve their own information
  Future<Response> getHandler(Request request) async {
    Object? userId = request.context['userId'];
    if (userId is! int) {
      throw BrokenAuthorizationHeaderException();
    }
    final User? user = (await User.read(UserPartial(id: userId))).firstOrNull;
    if (user == null) {
      throw UnknownDatabaseException("The user is missing");
    }
    return Response.ok(withMessage('Found', {'username': user.username}));
  }

  /// The user may create urls
  Future<Response> urlPostHandler(Request request) async {
    Object? userId = request.context['userId'];
    Object? url = request.context['longUrl'];
    if (userId is! int) {
      throw BrokenAuthorizationHeaderException();
    }
    if (url is! String) {
      throw IncompleteDataException('Unable to parse url');
    }
    final urlModel = await Url.create(UrlPartial(url: url));
    await UserUrl.create(UserUrlPartial(userId: userId, urlId: urlModel.id));
    return Response(201, body: urlModel.toJsonString());
  }

  /// The user may retrieve their own urls
  Future<Response> urlGetHandler(Request request) async {
    Object? userId = request.context['userId'];
    if (userId is! int) {
      throw BrokenAuthorizationHeaderException();
    }
    final List<Url> urlList = await UserUrl.getUrlsByUserId(userId);
    return Response.ok(
      withMessage('Found', {
        'urls': urlList.map((e) => e.toJson()).toList(),
      }),
    );
  }

  /// The user may update their own urls
  Future<Response> urlPutHandler(Request request) async {
    Object? userId = request.context['userId'];
    Object? urlId = request.context['urlId'];
    Object? url = request.context['longUrl'];
    if (userId is! int) {
      throw BrokenAuthorizationHeaderException();
    }
    if (urlId is! int) {
      throw MissingIdException('Url id is required to update a record');
    }
    if (url is! String) {
      throw IncompleteDataException('Unable to parse url');
    }
    await Url.update(UrlPartial(id: urlId, url: url));
    return Response.ok(withMessage('Updated', {'urlId': urlId, 'url': url}));
  }

  /// The user may soft-delete their own urls
  Future<Response> urlDeleteHandler(Request request) async {
    Object? userId = request.context['userId'];
    Object? urlId = request.context['urlId'];
    if (userId is! int) {
      throw BrokenAuthorizationHeaderException();
    }
    if (urlId is! int) {
      throw MissingIdException('Url id is required to delete a record');
    }
    await Url.delete(UrlPartial(id: urlId));
    return Response.ok(withMessage('Deleted', {'urlId': urlId}));
  }
}
