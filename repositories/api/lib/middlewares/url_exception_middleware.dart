part of 'middlewares_library.dart';

class UrlExceptionMiddleware extends MiddlewareLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      try {
        return await handler(request);
      } catch (e) {
        if (e is IncompleteDataException) {
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
