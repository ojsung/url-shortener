import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/user_dto.dart';
import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart';
import 'package:url_shortener_server/services/auth_service.dart' show AuthService;
import 'package:url_shortener_server/shared/interfaces/controller.dart';
import 'package:url_shortener_server/shared/multi_part_string.dart';
import 'package:url_shortener_server/shared/query_result.dart' show QueryResult;

class AuthController extends Controller {
  final AuthService authService;
  const AuthController(this.authService);
  /// Create an account for the user. Checks for duplicates
  Future<Response> signupPostHandler(Request request) async {
    final Object? user = request.context['user'];
    if (user is UserDto) {
      MultiPartString hashedPassword = authService.hashPassword(user.password);
      final UserPartial newUser = UserPartial(username: user.username, password: hashedPassword.toString());
      try {
        QueryResult createdUsers = await User.create(newUser);

        // Success
        return Response(
          201,
          body: withMessage('User created successfully', {'userId': createdUsers.lastInsertId.toInt()}),
        );
      } catch (e) {
        // Failed with error. I'm interested to see what errors get caught here
        // Someday, I'll have a real logger. But for now, we will print
        print(e);
        return Response.internalServerError(body: withErrorMessage('Error creating user'));
      }
    }
    return Response.badRequest(body: withErrorMessage('Invalid user data'));
  }

  Future<Response> loginPostHandler(Request request) async {
    final Object? requestUser = request.context['user'];
    if (requestUser is UserDto) {
      final UserPartial userToLogin = UserPartial(username: requestUser.username);

      List<User> users = await User.read(userToLogin);
      if (users.isNotEmpty) {
        final User user = users.first;
        final String hashedPassword = user.password;
        if (authService.verifyPassword(hashedPassword, requestUser.password)) {
        // Successfully verified password with db password
          return Response.ok(withMessage('Login successful', {'token': authService.generateAuthToken(user.username)}));
        } else {
          // Password did not match. We don't have to tell them the password was the problem
          return Response.forbidden(withErrorMessage('Invalid username or password'));
        }
      } else {
        // Didnt' find a user by that name
        return Response.forbidden(withErrorMessage('Invalid username or password'));
      }
    } else {
      return Response.badRequest(body: withErrorMessage('Invalid user data'));
    }
  }
}
