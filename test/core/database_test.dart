import 'package:buzzer_app/core/database/app_database.dart';
import 'package:buzzer_app/core/database/tables/cached_items_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() {
    database = AppDatabase.forTesting(databaseFactoryFfi);
  });

  tearDown(() async {
    await database.close();
  });

  group('sqflite In-Memory AppDatabase & ItemsDao Tests', () {
    test('Insert and single item query', () async {
      final item = CachedItemEntity(
        id: 'item_1',
        title: 'Initial Title',
        subtitle: 'Test Subtitle',
      );

      await database.itemsDao.insertOrUpdateItem(item);

      final storedItem = await database.itemsDao.getItemById('item_1');
      expect(storedItem, isNotNull);
      expect(storedItem?.id, equals('item_1'));
      expect(storedItem?.title, equals('Initial Title'));
      expect(storedItem?.subtitle, equals('Test Subtitle'));
    });

    test('Reactive watch stream emits updates', () async {
      final stream = database.itemsDao.watchAllItems();

      final futureExpectation = expectLater(
        stream,
        emitsInOrder([isEmpty, hasLength(1)]),
      );

      await database.itemsDao.insertOrUpdateItem(
        CachedItemEntity(id: 'reactive_1', title: 'Stream Item'),
      );

      await futureExpectation;
    });

    test('Batch replace in isolated transaction', () async {
      await database.itemsDao.replaceItemsBatch([
        CachedItemEntity(id: 'batch_1', title: 'Batch Item 1'),
        CachedItemEntity(id: 'batch_2', title: 'Batch Item 2'),
      ]);

      final all = await database.itemsDao.getAllItems();
      expect(all.length, equals(2));
    });

    test('wipeAllData empties the table', () async {
      await database.itemsDao.insertOrUpdateItem(
        CachedItemEntity(id: 'wipe_me', title: 'Delete Item'),
      );

      await database.wipeAllData();

      final all = await database.itemsDao.getAllItems();
      expect(all, isEmpty);
    });

    test('serializes metadata and boolean values', () async {
      final item = CachedItemEntity(
        id: 'mapped',
        title: 'Mapped Item',
        metadata: {'source': 'test'},
        isSynced: false,
      );
      await database.itemsDao.insertOrUpdateItem(item);

      final storedItem = await database.itemsDao.getItemById('mapped');
      expect(storedItem?.metadata, equals({'source': 'test'}));
      expect(storedItem?.isSynced, isFalse);
    });
  });
}
