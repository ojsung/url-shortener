import 'dart:convert' show json;

import 'package:url_shortener_server/dtos/user_dto.dart' show UserDto;
import 'package:url_shortener_server/shared/interfaces/partial.dart' show Partial;

class PartialUserDto implements Partial<UserDto, PartialUserDto> {
  final String? username;
  final String? password;
  PartialUserDto({this.username, this.password});
  PartialUserDto.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        password = json['password'];
  PartialUserDto.fromString(String string) : this.fromJson(json.decode(string));

  @override
  PartialUserDto toPartial() {
    return this;
  }
}