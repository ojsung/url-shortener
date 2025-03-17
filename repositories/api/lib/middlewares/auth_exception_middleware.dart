part of 'middlewares_library.dart';

class AuthExceptionMiddleware extends MiddlewareLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      try {
        return await handler(request);
      } on DuplicateUserException catch (e) {
        return Response(409, body: withError(e));
      } on MissingIdException catch (e) {
        return Response.badRequest(body: withError(e));
      } on IncompleteDataException catch (e) {
        return Response.badRequest(body: withError(e));
      } on BrokenAuthorizationHeaderException catch (e) {
        return Response.unauthorized(withError(e));
      } on InvalidAuthorizationHeaderException catch (e) {
        return Response.unauthorized(withError(e));
      } on UnknownInsertException {
        return Response.internalServerError(
          body: withErrorMessage('An error occurred while creating user. Please try again later'),
        );
      } on UnknownDatabaseException {
        return Response.internalServerError(
          body: withErrorMessage('An error occurred while creating user. Please try again later'),
        );
      } catch (e) {
        return Response.internalServerError(body: withErrorMessage('An unexpected error occurred'));
      }
    };
  }
}
