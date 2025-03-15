import 'dart:convert';

import 'package:url_shortener_server/shared/interfaces/partial.dart';

class UserDto {
  final String username;
  final String password;
  UserDto({required this.username, required this.password});
}

class PartialUserDto<UserDto> extends Partial<UserDto, PartialUserDto<UserDto>> {
  final String? username;
  final String? password;
  PartialUserDto({this.username, this.password});
  PartialUserDto.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        password = json['password'];
  PartialUserDto.fromString(String string) : this.fromJson(json.decode(string));

  @override
  PartialUserDto<UserDto> toPartial() {
    return this;
  }
}