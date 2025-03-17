part of 'validators_library.dart';

class UserValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final Object? requestString = request.context['requestString'];
      if (requestString is! String) {
        throw Exception('UserValidator. Request string is missing. Did you forget to add SetRequestStringMiddleware?');
      }
      final user = PartialUserDto.fromString(requestString);
      final String? username = user.username;
      final String? password = user.password;
      if (username == null ||
          username.isEmpty ||
          password == null ||
          password.isEmpty) {
        throw IncompleteDataException('Username and password are required');
      }
      final requestWithUser = request.change(
        context: {'user': UserDto(username: username, password: password)},
      );

      // If validation passes, call the next handler
      return handler(requestWithUser);
    };
  }
}
