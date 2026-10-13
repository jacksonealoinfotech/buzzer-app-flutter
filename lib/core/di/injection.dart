import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:buzzer_app/core/di/injection.config.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configures dependency injection using Injectable code generator.
///
/// Order of registration:
/// 1. Asynchronous pre-resolved singletons (SharedPreferences).
/// 2. Database & DAOs.
/// 3. Token management & Hardware secure storage.
/// 4. Network client (DioClient) with security adapters and interceptors.
/// 5. System services (Notifications, Analytics, Crash reporting).
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies([String? environment]) async {
  await getIt.init(environment: environment);
}

/// Helper resetting all registered instances for unit tests.
Future<void> resetDependencies() async {
  await getIt.reset();
}
