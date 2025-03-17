part of 'middlewares_library.dart';

class UrlExceptionMiddleware extends MiddlewareLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      try {
        return await handler(request);
      } on IncompleteDataException catch (e) {
        return Response.badRequest(body: withError(e));
      } on InvalidUrlException catch (e) {
        return Response.badRequest(body: withError(e));
      } on NotFoundException catch (e) {
        return Response.notFound(withError(e));
      } on UnknownInsertException {
        return Response.internalServerError(
          body: withErrorMessage('An error occurred while creating user. Please try again later'),
        );
      } on UnknownDatabaseException {
        return Response.internalServerError(
          body: withErrorMessage('An error occurred while creating user. Please try again later'),
        );
      } catch (e) {
        return Response.internalServerError(body: withErrorMessage('An unexpected error occurred: $e'));
      }
    };
  }
}
