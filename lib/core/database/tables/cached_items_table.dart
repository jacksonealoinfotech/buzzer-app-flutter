import 'dart:convert';

/// Name of the cached item table in SQLite.
abstract final class CachedItemsTable {
  static const String tableName = 'cached_items_table';
}

/// A typed representation of a row in [CachedItemsTable].
class CachedItemEntity {
  CachedItemEntity({
    required this.id,
    required this.title,
    this.subtitle,
    this.category = 'general',
    DateTime? createdAt,
    this.updatedAt,
    Map<String, dynamic> metadata = const {},
    this.isSynced = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        metadata = Map.unmodifiable(metadata);

  final String id;
  final String title;
  final String? subtitle;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;
  final bool isSynced;

  Map<String, Object?> toDatabaseMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'metadata': jsonEncode(metadata),
        'is_synced': isSynced ? 1 : 0,
      };

  factory CachedItemEntity.fromDatabaseMap(Map<String, Object?> map) {
    final encodedMetadata = map['metadata'] as String? ?? '{}';
    final decodedMetadata = jsonDecode(encodedMetadata);

    return CachedItemEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      category: map['category'] as String? ?? 'general',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: (map['updated_at'] as String?) == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      metadata: decodedMetadata is Map<String, dynamic>
          ? decodedMetadata
          : const {},
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
    );
  }
}
