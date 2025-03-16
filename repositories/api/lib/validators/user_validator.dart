part of 'validators_library.dart';

class UserValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request, [String?]) middleware(Handler handler) {
    return (Request request, [_]) async {
      final user = PartialUserDto.fromString(await request.readAsString());
      final String? username = user.username;
      final String? password = user.password;
      if (username == null || username.isEmpty || password == null || password.isEmpty) {
        return Response.badRequest(body: json.encode({'message': 'Username and password are required'}));
      }
      final requestWithUser = request.change(context: {'user': UserDto(username: username, password: password)});

      // If validation passes, call the next handler
      return handler(requestWithUser);
    };
  }
}
