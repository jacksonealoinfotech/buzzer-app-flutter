import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buzzer_app/core/database/app_database.dart';
import 'package:buzzer_app/core/database/daos/items_dao.dart';
import 'package:buzzer_app/core/services/storage/local_storage_service.dart';

@module
abstract class StorageModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  @lazySingleton
  ItemsDao itemsDao(AppDatabase db) => db.itemsDao;

  @lazySingleton
  LocalStorageService localStorageService(SharedPreferences prefs) =>
      DefaultLocalStorageService(preferences: prefs);
}
