import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/user_dto.dart';
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart' show CustomMiddleware;

class UserValidator implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final user = PartialUserDto<UserDto>.fromString(
        await request.readAsString(),
      );
      final String? username = user.username;
      final String? password = user.password;
      if (username == null || password == null) {
        return Response.badRequest(
          body: json.encode({'message': 'Username and password are required'}),
        );
      }
      final requestWithUser = request.change(
        context: {'user': UserDto(username: username, password: password)},
      );

      // If validation passes, call the next handler
      return handler(requestWithUser);
    };
  }
}
