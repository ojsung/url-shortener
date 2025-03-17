library;

import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/url_partial_dto.dart';
import 'package:url_shortener_server/dtos/user_dto.dart';
import 'package:url_shortener_server/dtos/user_partial_dto.dart'
    show PartialUserDto;
import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart';
import 'package:url_shortener_server/shared/globals.dart' show getIt;
part 'user_validator.dart';
part 'url_field_validator.dart';
part 'shortened_url_validator.dart';
part 'shortened_url_content_validator.dart';
part 'url_content_validator.dart';
part 'id_field_validator.dart';

sealed class ValidatorLibrary {
  static CustomMiddleware get<Validator extends ValidatorLibrary>() {
    switch (Validator) {
      case const (UserValidator):
        return getIt<UserValidator>();
      case const (UrlFieldValidator):
        return getIt<UrlFieldValidator>();
      case const (ShortenedUrlValidator):
        return getIt<ShortenedUrlValidator>();
      case const (ShortenedUrlContentValidator):
        return getIt<ShortenedUrlContentValidator>();
      case const (UrlContentValidator):
        return getIt<UrlContentValidator>();
      case const (IdFieldValidator):
        return getIt<IdFieldValidator>();
      default:
        throw Exception('Validator not found');
    }
  }
}
