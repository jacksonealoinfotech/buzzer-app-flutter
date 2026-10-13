import 'dart:async';

import 'package:buzzer_app/core/error/failure.dart';
import 'package:buzzer_app/core/result/result.dart';

/// Sealed state of a resource being loaded through offline-first synchronization.
sealed class Resource<T> {
  const Resource();
}

/// Emitted while retrieving cached data or waiting for fresh remote data.
final class ResourceLoading<T> extends Resource<T> {
  const ResourceLoading([this.cachedData]);
  final T? cachedData;
}

/// Emitted when data is successfully resolved (either cache or remote).
final class ResourceSuccess<T> extends Resource<T> {
  const ResourceSuccess(this.data, {this.isFromCache = false});
  final T data;
  final bool isFromCache;
}

/// Emitted when both network fetch failed and local cache cannot satisfy the request.
final class ResourceFailure<T> extends Resource<T> {
  const ResourceFailure(this.failure, {this.cachedData});
  final Failure failure;
  final T? cachedData;
}

/// Coordinates single-source-of-truth offline-first queries.
///
/// Workflow:
/// 1. Immediately emit local cached data (if available).
/// 2. If [shouldFetch] returns `true`, fire remote network query.
/// 3. Save remote result into local database via [saveFetchResult].
/// 4. Re-query local database and emit fresh data.
/// 5. If network query fails, emit [ResourceFailure] while preserving cached data.
abstract final class NetworkBoundResource {
  static Stream<Resource<ResultType>> asStream<ResultType, RequestType>({
    required Stream<ResultType> Function() loadFromDb,
    required Future<Result<RequestType>> Function() createCall,
    required Future<void> Function(RequestType item) saveFetchResult,
    bool Function(ResultType? data)? shouldFetch,
  }) async* {
    yield const ResourceLoading();

    // 1. Observe local database
    final dbStream = loadFromDb();
    ResultType? currentCachedData;

    try {
      await for (final cached in dbStream.take(1)) {
        currentCachedData = cached;
        yield ResourceSuccess(cached, isFromCache: true);
      }
    } catch (_) {
      // Local database might be empty initially
    }

    final needRemote = shouldFetch == null || shouldFetch(currentCachedData);
    if (!needRemote) return;

    yield ResourceLoading(currentCachedData);

    // 2. Fetch from remote API
    final networkResult = await createCall();

    switch (networkResult) {
      case Success(:final data):
        // 3. Persist fresh network payload to local source of truth
        await saveFetchResult(data);
        // 4. Yield fresh local data from DB
        await for (final fresh in loadFromDb().take(1)) {
          yield ResourceSuccess(fresh, isFromCache: false);
        }

      case FailureResult(:final failure):
        // 5. Yield failure with stale cache fallback
        yield ResourceFailure(failure, cachedData: currentCachedData);
    }
  }
}

// ---------------------------------------------------------------------------
// OPTIONAL: Pending Offline Operations Sync Queue (Outbox Pattern)
// ---------------------------------------------------------------------------
// class OfflineSyncQueue {
//   // Stores pending mutations (POST/PUT/DELETE) in sqflite when network is unavailable.
//   // When ConnectivityCubit reports connection restored, flushes pending jobs sequentially.
// }
