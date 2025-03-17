import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/service_implementations/auth_service.dart';
import 'package:url_shortener_server/services/auth_service.dart';
import 'package:url_shortener_server/shared/hash_keys.dart';
import 'package:url_shortener_server/shared/token_manager.dart';

import 'fixtures/di_fixtures.dart';
import 'fixtures/url_fixtures.dart';
import 'fixtures/user_fixtures.dart';

void main() {
  final port = '5010';
  final host = 'http://0.0.0.0:$port';
  setupTestInjector();
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {
        'PORT': port,
        'MYSQL_USER': 'mysql',
        'MYSQL_PASSWORD': 'flimsy',
        'MYSQL_DATABASE': 'url_shortener',
        'MYSQL_HOST': 'localhost',
        'MYSQL_PORT': '3306',
        'ENV': 'production',
        'HASH_ROUNDS': '5',
        'CREATE_KEY': 'supersecretkey',
        'PASSWORD_KEY': 'very-safe-very-secure',
      },
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
    await Future.delayed(Duration(seconds: 1));
  });

  tearDown(() => p.kill());

  test('POST /auth/signup', () async {
    // Arrange
    String username = 'test';
    String password = 'test';
    // Act
    final response = await post(
      Uri.parse('$host/auth/signup'),
      body: {'username': username, 'password': password},
    );
    // Assert
    expect(response.statusCode, 201);
  });

  test('POST /auth/login', () async {
    // Arrange
    String username = 'test';
    String password = 'test';
    // Act
    final response = await post(
      Uri.parse('$host/auth/login'),
      body: {'username': username, 'password': password},
    );
    // Assert
    expect(response.statusCode, 200);
    expect(json.decode(response.body)['token'], isNotNull);
  });

  test('POST /auth/login 401', () async {
    // Arrange
    User user = await createUser(
      username: TokenManager.generateRandomString(12),
    );
    final response = await post(
      Uri.parse('$host/auth/login'),
      body: {'username': user.username, 'password': 'wrong'},
    );
    expect(response.statusCode, 401);
  });

  test('GET /r', () async {
    // Arrange
    Url url = await createUrl();
    final response = await get(Uri.parse('$host/r/${url.shortenedUrl}'));
    expect(response.statusCode, 301);
  });

  test('GET /r 404', () async {
    // Act
    final response = await get(Uri.parse('$host/r/invalid'));
    // Assert
    expect(response.statusCode, 404);
  });
  test('POST /shorten', () async {
    // Arrange
    String longUrl = 'https://example.com';
    // Act
    final response = await post(
      Uri.parse('$host/shorten'),
      body: {'longUrl': longUrl},
    );
    // Assert
    expect(response.statusCode, 201);
    expect(json.decode(response.body)['shortenedUrl'], isNotNull);
  });

  test('GET /user/urls', () async {
    // Arrange
    User user = await createUser();
    await createUrl('https://www.google.com');
    await createUrl('https://www.example.com');
    AuthService auth = AuthServiceImpl(
      TokenManager(hashRounds: 5),
      HashKeys('test-key'),
      'test-create-key',
    );
    String token = auth.generateAuthToken(user.username, user.id);
    // Act
    final response = await get(
      Uri.parse('$host/user/urls'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    // Assert
    expect(response.statusCode, 200);
    expect(json.decode(response.body)['urls'], hasLength(2));
  });
  test('POST /user/urls', () async {
    // Arrange
    User user = await createUser();
    AuthService auth = AuthServiceImpl(
      TokenManager(hashRounds: 5),
      HashKeys('test-key'),
      'test-create-key',
    );
    String token = auth.generateAuthToken(user.username, user.id);
    // Act
    final response = await post(
      Uri.parse('$host/user/urls'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      body: {'longUrl': 'https://www.google.com'},
    );
    // Assert
    expect(response.statusCode, 201);
  });
  test('PUT /user/urls', () async {
    // Arrange
    User user = await createUser();
    Url url = await createUrl();
    AuthService auth = AuthServiceImpl(
      TokenManager(hashRounds: 5),
      HashKeys('test-key'),
      'test-create-key',
    );
    String token = auth.generateAuthToken(user.username, user.id);
    String newUrl = 'https://www.fake-place.com';
    // Act
    final response = await put(
      Uri.parse('$host/user/urls'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      body: {'urlId': url.id, 'longUrl': newUrl},
    );
    final body = json.decode(response.body);
    // Assert
    expect(response.statusCode, 200);
    expect(body['urlId'], url.id);
    expect(body['url'], newUrl);
  });

  test('PUT /user/urls 404', () async {
    // Arrange
    User user = await createUser();
    AuthService auth = AuthServiceImpl(
      TokenManager(hashRounds: 5),
      HashKeys('test-key'),
      'test-create-key',
    );
    String token = auth.generateAuthToken(user.username, user.id);
    // Act
    final response = await put(
      Uri.parse('$host/user/urls'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      body: {'urlId': 1, 'longUrl': 'https://www.fake-place.com'},
    );
    // Assert
    expect(response.statusCode, 404);
  });
  test('DELETE /user/urls', () async {
    // Arrange
    User user = await createUser();
    Url url = await createUrl();
    AuthService auth = AuthServiceImpl(
      TokenManager(hashRounds: 5),
      HashKeys('test-key'),
      'test-create-key',
    );
    String token = auth.generateAuthToken(user.username, user.id);
    // Act
    final response = await delete(
      Uri.parse('$host/user/urls'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      body: {'urlId': url.id},
    );
    final verifyDeleted = await get(Uri.parse('$host/r/${url.shortenedUrl}'));
    // Assert
    expect(response.statusCode, 200);
    expect(verifyDeleted.statusCode, 404);
  });
}
