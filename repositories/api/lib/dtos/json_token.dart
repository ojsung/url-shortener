import 'dart:convert';

class JsonToken {
  final int? userId;
  final String? token;
  // this redirecting constructor is a little messy. But we create the base64->utf8 codec to decode our bearer token. The
  // decode it again with our json codec. Then we pass it as a Map<String, dynamic> to our private constructor to assign the values
  JsonToken.fromBearerToken(String bearerToken) : this._(json.decode(utf8.fuse(base64).decode(bearerToken)));
  JsonToken._(Map<String, dynamic> json) : userId = json['userId'], token = json['token'];
}
