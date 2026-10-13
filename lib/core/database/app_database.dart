import 'package:buzzer_app/core/database/daos/items_dao.dart';
import 'package:buzzer_app/core/database/tables/cached_items_table.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// SQLite database using sqflite, with schema migrations and test injection.
class AppDatabase {
  AppDatabase() : this._(_openDatabase(databaseFactory));

  /// Creates an in-memory database using the provided sqflite-compatible factory.
  AppDatabase.forTesting(DatabaseFactory factory)
    : this._(_openDatabase(factory, inMemoryDatabasePath));

  AppDatabase._(Future<Database> database)
    : _database = database,
      itemsDao = ItemsDao(database);

  static const int _schemaVersion = 1;

  final Future<Database> _database;

  final ItemsDao itemsDao;

  static Future<Database> _openDatabase(
    DatabaseFactory factory, [
    String? databasePath,
  ]) async {
    final resolvedPath =
        databasePath ?? path.join(await getDatabasesPath(), 'app_database.db');
    return factory.openDatabase(
      resolvedPath,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE ${CachedItemsTable.tableName} (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL CHECK(length(title) BETWEEN 1 AND 255),
              subtitle TEXT,
              category TEXT NOT NULL DEFAULT 'general',
              created_at TEXT NOT NULL,
              updated_at TEXT,
              metadata TEXT NOT NULL DEFAULT '{}',
              is_synced INTEGER NOT NULL DEFAULT 1 CHECK(is_synced IN (0, 1))
            )
          ''');
        },
        onUpgrade: (database, oldVersion, newVersion) async {
          // Add step-by-step migrations here when _schemaVersion increases.
        },
      ),
    );
  }

  /// Wipes all database tables (invoked during security wipe or user logout).
  Future<void> wipeAllData() async {
    await itemsDao.clearAll();
  }

  Future<void> close() async {
    await itemsDao.close();
    await (await _database).close();
  }
}
