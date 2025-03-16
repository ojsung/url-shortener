import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/controllers/auth_controller.dart' show AuthController;
import 'package:url_shortener_server/middlewares/authentication_middleware.dart';
import 'package:url_shortener_server/migrations/001_create_users_table.dart';
import 'package:url_shortener_server/migrations/002_create_urls_table.dart';
import 'package:url_shortener_server/migrations/003_create_users_urls_table.dart';
import 'package:url_shortener_server/routes/auth_routes.dart';
import 'package:url_shortener_server/service_implementations/auth_service.dart';
import 'package:url_shortener_server/services/auth_service.dart' show AuthService;
import 'package:url_shortener_server/shared/hash_keys.dart';
import 'package:url_shortener_server/shared/token_manager.dart';
import 'package:url_shortener_server/validators/user_validator.dart';
import 'package:url_shortener_server/shared/globals.dart' show getIt;
import 'package:url_shortener_server/services/database_service.dart' show DatabaseService;
import 'package:url_shortener_server/service_implementations/database/mysql/database_service.dart';
import 'package:url_shortener_server/shared/env.dart';

void setupInjector() {
  getIt
    //Register Migrations
    ..registerLazySingleton(() => const CreateUsersTable())
    ..registerLazySingleton(() => const CreateUrlsTable())
    ..registerLazySingleton(() => const CreateUsersUrlsTable())
    // Register Services
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
        migrations: [getIt.get<CreateUsersTable>(), getIt.get<CreateUrlsTable>(), getIt.get<CreateUsersUrlsTable>()],
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
      () => AuthServiceImpl(getIt.get<TokenManager>(), getIt.get<HashKeys>(), getIt.get<Env>().createKey),
    )
    // Register middlewares
    ..registerLazySingleton<AuthenticationMiddleware>(() => AuthenticationMiddleware(getIt.get<AuthService>()))
    // Register validators
    ..registerLazySingleton<UserValidator>(() => UserValidator())
    // Register controllers
    ..registerLazySingleton<AuthController>(() => AuthController(getIt.get<AuthService>()))
    // Register routers
    ..registerLazySingleton<Router>(() => Router())
    ..registerLazySingleton<AuthRoutes>(
      () => AuthRoutes(
        namespace: '/auth',
        middlewares: [getIt.get<UserValidator>().middleware],
        controller: getIt.get<AuthController>(),
      ),
    );
}
