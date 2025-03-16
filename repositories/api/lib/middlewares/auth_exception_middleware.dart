part of 'middlewares_library.dart';

class AuthExceptionMiddleware extends MiddlewareLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      try {
        return await handler(request);
      } catch (e) {
        if (e is DuplicateUserException) {
          return Response(409, body: withError(e));
        } else if (e is MissingIdException) {
          print('User experienced a login error: $e');
          return Response.badRequest(body: withError(e));
        } else if (e is IncompleteDataException) {
          return Response.badRequest(body: withError(e));
        } else if (e is UnknownInsertException || e is UnknownDatabaseException) {
          return Response.internalServerError(body: withErrorMessage('An error occurred while creating user. Please try again later'));
        }  else {
          print('Unknown and unhandled exception: $e');
          return Response.internalServerError(body: withErrorMessage('An unexpected error occurred'));
        }
      }
    };
  }
}
