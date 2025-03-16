import 'dart:convert' show json;

import 'package:url_shortener_server/dtos/url_dto.dart' show UrlDto;
import 'package:url_shortener_server/shared/interfaces/partial.dart';

class PartialUrlDto implements Partial<UrlDto, PartialUrlDto> {
  final String? longUrl;
  final String? shortenedUrl;
  const PartialUrlDto({
    required this.longUrl, required this.shortenedUrl,
  });
  PartialUrlDto.fromJson(Map<String, dynamic> json) : longUrl = json['longUrl'], shortenedUrl = json['shortenedUrl'];
  PartialUrlDto.fromString(String string) : this.fromJson(json.decode(string));
  @override
  PartialUrlDto toPartial() {
    return this;
  }
}
