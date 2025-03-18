import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/controllers/auth_controller.dart'
    show AuthController;
import 'package:url_shortener_server/controllers/url_controller.dart';
import 'package:url_shortener_server/controllers/user_controller.dart';
import 'package:url_shortener_server/middlewares/middlewares_library.dart'
    show
        AuthExceptionMiddleware,
        AuthenticationMiddleware,
        CorsMiddleware,
        SetRequestStringMiddleware,
        UrlExceptionMiddleware;
import 'package:url_shortener_server/migrations/001_create_users_table.dart';
import 'package:url_shortener_server/migrations/002_create_urls_table.dart';
import 'package:url_shortener_server/migrations/003_create_users_urls_table.dart';
import 'package:url_shortener_server/routes/auth_routes.dart';
import 'package:url_shortener_server/routes/shortened_url_routes.dart';
import 'package:url_shortener_server/routes/url_routes.dart';
import 'package:url_shortener_server/routes/user_routes.dart';
import 'package:url_shortener_server/service_implementations/auth_service.dart';
import 'package:url_shortener_server/services/auth_service.dart'
    show AuthService;
import 'package:url_shortener_server/shared/hash_keys.dart';
import 'package:url_shortener_server/shared/token_manager.dart';
import 'package:url_shortener_server/shared/globals.dart' show getIt;
import 'package:url_shortener_server/services/database_service.dart'
    show DatabaseService;
import 'package:url_shortener_server/service_implementations/database/mysql/database_service.dart';
import 'package:url_shortener_server/shared/env.dart';
import 'package:url_shortener_server/validators/validators_library.dart'
    show
        IdFieldValidator,
        UrlIdParamValidator,
        ShortenedUrlContentValidator,
        ShortenedUrlValidator,
        UrlContentValidator,
        UrlFieldValidator,
        UserValidator;

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
        migrations: [
          getIt.get<CreateUsersTable>(),
          getIt.get<CreateUrlsTable>(),
          getIt.get<CreateUsersUrlsTable>(),
        ],
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
    )
    // Register middlewares
    ..registerLazySingleton<AuthExceptionMiddleware>(
      () => AuthExceptionMiddleware(),
    )
    ..registerLazySingleton<AuthenticationMiddleware>(
      () => AuthenticationMiddleware(getIt.get<AuthService>()),
    )
    ..registerLazySingleton<CorsMiddleware>(() => CorsMiddleware())
    ..registerLazySingleton<SetRequestStringMiddleware>(
      () => SetRequestStringMiddleware(),
    )
    ..registerLazySingleton<UrlExceptionMiddleware>(
      () => UrlExceptionMiddleware(),
    )
    // Register validators
    ..registerLazySingleton<IdFieldValidator>(() => IdFieldValidator())
    ..registerLazySingleton<UrlIdParamValidator>(() => UrlIdParamValidator())
    ..registerLazySingleton<ShortenedUrlContentValidator>(
      () => ShortenedUrlContentValidator(),
    )
    ..registerLazySingleton<ShortenedUrlValidator>(
      () => ShortenedUrlValidator(),
    )
    ..registerLazySingleton<UrlContentValidator>(() => UrlContentValidator())
    ..registerLazySingleton<UrlFieldValidator>(() => UrlFieldValidator())
    ..registerLazySingleton<UserValidator>(() => UserValidator())
    // Register controllers
    ..registerLazySingleton<AuthController>(
      () => AuthController(getIt.get<AuthService>()),
    )
    ..registerLazySingleton<UrlController>(() => UrlController())
    ..registerLazySingleton<UserController>(() => UserController())
    // Register routers
    ..registerLazySingleton<Router>(() => Router())
    ..registerLazySingleton<AuthRoutes>(
      () => AuthRoutes(
        namespace: '/auth',
        exceptionHandlers: [getIt.get<AuthExceptionMiddleware>()],
        middlewares: [
          getIt.get<CorsMiddleware>(),
          getIt.get<SetRequestStringMiddleware>(),
        ],
        validators: [getIt.get<UserValidator>()],
        controller: getIt.get<AuthController>(),
      ),
    )
    ..registerLazySingleton<UrlRoutes>(
      () => UrlRoutes(
        namespace: '/shorten',
        exceptionHandlers: [getIt.get<UrlExceptionMiddleware>()],
        middlewares: [
          getIt.get<CorsMiddleware>(),
          getIt.get<SetRequestStringMiddleware>(),
        ],
        validators: [
          getIt.get<UrlFieldValidator>(),
          getIt.get<UrlContentValidator>(),
        ],
        controller: getIt.get<UrlController>(),
      ),
    )
    ..registerLazySingleton<ShortenedUrlRoutes>(
      () => ShortenedUrlRoutes(
        // I know this is a horrible name space but we're trying to shorten a url. gotta make it short
        namespace: '/r',
        exceptionHandlers: [getIt.get<UrlExceptionMiddleware>()],
        middlewares: [
          getIt.get<CorsMiddleware>(),
          getIt.get<SetRequestStringMiddleware>(),
        ],
        validators: [
          getIt.get<ShortenedUrlValidator>(),
          getIt.get<ShortenedUrlContentValidator>(),
        ],
        controller: getIt.get<UrlController>(),
      ),
    )
    ..registerLazySingleton<UserRoutes>(
      () => UserRoutes(
        namespace: '/user',
        exceptionHandlers: [
          getIt.get<AuthExceptionMiddleware>(),
          getIt.get<UrlExceptionMiddleware>(),
        ],
        middlewares: [
          getIt.get<CorsMiddleware>(),
          getIt.get<SetRequestStringMiddleware>(),
        ],
        validators: [],
        controller: getIt.get<UserController>(),
      ),
    );
}
