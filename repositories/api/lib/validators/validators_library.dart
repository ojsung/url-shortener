library;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/url_partial_dto.dart';
import 'package:url_shortener_server/dtos/user_dto.dart';
import 'package:url_shortener_server/dtos/user_partial_dto.dart' show PartialUserDto;
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart';
part 'user_validator.dart';
part 'url_validator.dart';

enum Validator {
  url(UrlValidator),
  user(UserValidator);

  const Validator(this.type);
  final Type type;
}

sealed class ValidatorLibrary {}
