import 'dart:async';

import 'package:buzzer_app/core/database/tables/cached_items_table.dart';
import 'package:sqflite/sqflite.dart';

/// DAO providing queries and change streams for [CachedItemsTable].
class ItemsDao {
  ItemsDao(Future<Database> database) : _database = database;

  final Future<Database> _database;
  final Set<StreamController<List<CachedItemEntity>>> _watchers = {};

  /// Reactive watch stream of all items ordered by creation time.
  Stream<List<CachedItemEntity>> watchAllItems() {
    late final StreamController<List<CachedItemEntity>> controller;
    controller = StreamController<List<CachedItemEntity>>.broadcast(
      onListen: () {
        _watchers.add(controller);
        unawaited(_emitTo(controller));
      },
      onCancel: () {
        _watchers.remove(controller);
      },
    );
    return controller.stream;
  }

  /// Single item query by primary key.
  Future<CachedItemEntity?> getItemById(String id) async {
    final rows = await (await _database).query(
      CachedItemsTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : CachedItemEntity.fromDatabaseMap(rows.first);
  }

  /// Returns all items ordered by creation time, newest first.
  Future<List<CachedItemEntity>> getAllItems() async {
    final rows = await (await _database).query(
      CachedItemsTable.tableName,
      orderBy: 'created_at DESC',
    );
    return rows.map(CachedItemEntity.fromDatabaseMap).toList();
  }

  /// Upserts a single entity.
  Future<int> insertOrUpdateItem(CachedItemEntity item) async {
    final changed = await (await _database).insert(
      CachedItemsTable.tableName,
      item.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyWatchers();
    return changed;
  }

  /// Replaces all entities atomically in a database transaction.
  Future<void> replaceItemsBatch(List<CachedItemEntity> items) async {
    final database = await _database;
    await database.transaction((transaction) async {
      await transaction.delete(CachedItemsTable.tableName);
      final batch = transaction.batch();
      for (final item in items) {
        batch.insert(
          CachedItemsTable.tableName,
          item.toDatabaseMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    await _notifyWatchers();
  }

  /// Deletes one item.
  Future<int> deleteItem(String id) async {
    final deleted = await (await _database).delete(
      CachedItemsTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _notifyWatchers();
    return deleted;
  }

  /// Clears the table.
  Future<int> clearAll() async {
    final deleted = await (await _database).delete(CachedItemsTable.tableName);
    await _notifyWatchers();
    return deleted;
  }

  Future<void> _notifyWatchers() async {
    await Future.wait(_watchers.map(_emitTo));
  }

  Future<void> _emitTo(
    StreamController<List<CachedItemEntity>> controller,
  ) async {
    if (controller.isClosed) return;
    try {
      controller.add(await getAllItems());
    } catch (error, stackTrace) {
      if (!controller.isClosed) controller.addError(error, stackTrace);
    }
  }

  Future<void> close() async {
    await Future.wait(_watchers.map((watcher) => watcher.close()));
    _watchers.clear();
  }
}
