import 'package:url_shortener_server/shared/globals.dart';
import 'package:url_shortener_server/service_implementations/auth_service.dart';
import 'package:url_shortener_server/services/auth_service.dart';
import 'package:url_shortener_server/shared/hash_keys.dart';
import 'package:url_shortener_server/shared/token_manager.dart';
import 'package:url_shortener_server/shared/env.dart';
import 'package:url_shortener_server/services/database_service.dart';
import 'package:url_shortener_server/service_implementations/database/mysql/database_service.dart';

void setupTestInjector() {
  getIt
    ..registerLazySingleton<Env>(() => Env.init())
    ..registerLazySingleton<String>(() {
      final env = getIt<Env>();
      final key = env.createKey;
      return key;
    }, instanceName: 'createKey')
    ..registerLazySingleton<DatabaseService>(() {
      final env = getIt<Env>();
      return DatabaseServiceImpl(
        host: env.mysqlHost,
        port: int.parse(env.mysqlPort),
        user: env.mysqlUser,
        password: env.mysqlPassword,
        database: env.mysqlDatabase,
        migrations: [],
      );
    })
    ..registerLazySingleton<TokenManager>(() {
      final env = getIt<Env>();
      return TokenManager(hashRounds: env.hashRounds);
    })
    ..registerLazySingleton<HashKeys>(
      () => HashKeys(getIt.get<Env>().passwordKey),
      dispose: (service) => service.dispose(),
    )
    ..registerLazySingleton<AuthService>(
      () => AuthServiceImpl(
        getIt.get<TokenManager>(),
        getIt.get<HashKeys>(),
        getIt.get<Env>().createKey,
      ),
    );
}