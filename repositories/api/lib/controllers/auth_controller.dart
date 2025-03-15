import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/user_dto.dart';
import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart';
import 'package:url_shortener_server/services/auth_service.dart'
    show AuthService;
import 'package:url_shortener_server/shared/interfaces/controller.dart';

class AuthController extends Controller {
  final AuthService authService;
  const AuthController(this.authService);

  Future<Response> postSignupHandler(Request request) async {
    final Object? user = request.context['user'];
    if (user is UserDto) {
      final UserPartial newUser = UserPartial(
        username: user.username, // Replace with actual username
        password: user.password, // Replace with actual password
      );

      try {
        List<User> createdUsers = await User.create(newUser);

        // Success
        return Response(
          201,
          body: json.encode({
            'message': 'User created successfully',
            'user': createdUsers.first.toJsonString(),
          }),
        );
      } catch (e) {
        // Failed with error
        // Someday, I'll have a real logger. But for now, we will print
        print(e);
        return Response.internalServerError(
          body: json.encode({'message': 'Error creating user'}),
        );
      }
    }
    return Response.badRequest(
      body: json.encode({'message': 'Invalid user data'}),
    );
  }

  Future<Response> postLoginHandler(Request request) async {
    final Object? requestUser = request.context['user'];
    if (requestUser is UserDto) {
      final UserPartial userToLogin = UserPartial(
        username: requestUser.username,
      );

      try {
        List<User> users = await User.read(userToLogin);
        if (users.isNotEmpty) {
          final User user = users.first;
          if (authService.verifyPassword(user.password, requestUser.password)) {
            return Response.ok(
              json.encode({
                'message': 'Login successful',
                'token': authService.generateAuthToken(user.username),
              }),
            );
          } else {
            return Response.forbidden(
              json.encode({'message': 'Invalid username or password'}),
            );
          }
        } else {
          return Response.forbidden(
            json.encode({'message': 'Invalid username or password'}),
          );
        }
      } catch (e) {
        print('User experienced a login error: $e');
        return Response.internalServerError(
          body: json.encode({'message': 'Error logging in'}),
        );
      }
    } else {
      return Response.badRequest(
        body: json.encode({'message': 'Invalid user data'}),
      );
    }
  }
}
