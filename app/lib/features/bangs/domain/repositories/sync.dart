import 'package:drift/isolate.dart';
import 'package:exceptions/exceptions.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/database/database.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/features/bangs/data/services/data_source.dart';

part 'sync.g.dart';

@Riverpod(keepAlive: true)
class BangSyncRepository extends _$BangSyncRepository {
  static Future<Result<void>> _fetchAndSyncRemote({
    required BangDataSourceService sourceService,
    required BangDatabase db,
    required Uri url,
    required BangGroup group,
    required Duration? syncInterval,
  }) async {
    if (syncInterval != null) {
      final lastSync = await db.syncDao
          .getLastSyncOfGroup(group)
          .getSingleOrNull();

      if (lastSync != null &&
          DateTime.now().difference(lastSync) < syncInterval) {
        return Result.success(null);
      }
    }

    final result = await sourceService.fetchRemoteBangs(url, group);
    return result.flatMapAsync((remoteBangs) async {
      await db.syncDao.syncBangs(
        group: group,
        remoteBangs: remoteBangs,
        syncTime: DateTime.now(),
      );
      await db.optimizeFtsIndex();
    });
  }

  static Future<Result<void>> _fetchAndSyncBundled({
    required BangDataSourceService sourceService,
    required BangDatabase db,
    required BangGroup group,
  }) async {
    final lastSync = await db.syncDao
        .getLastSyncOfGroup(group)
        .getSingleOrNull();

    final sourceDate = await sourceService.getBundledBangDate(
      'assets/bangs/last_sync.txt',
    );

    if (lastSync != null &&
        (sourceDate == lastSync ||
            sourceDate.difference(lastSync).isNegative)) {
      return Result.success(null);
    }

    final result = await sourceService.getBundledBangs(group.bundled, group);
    return result.flatMapAsync((remoteBangs) async {
      await db.syncDao.syncBangs(
        group: group,
        remoteBangs: remoteBangs,
        syncTime: sourceDate,
      );
      await db.optimizeFtsIndex();
    });
  }

  Future<Result<void>> syncRemoteBangGroup(
    BangGroup group,
    Duration? syncInterval,
  ) async {
    try {
      return Result.success(
        await ref
            .read(bangDatabaseProvider)
            .computeWithDatabase(
              connect: BangDatabase.new,
              computation: (db) async {
                final ref = ProviderContainer();
                final result = await _fetchAndSyncRemote(
                  sourceService: ref.read(
                    bangDataSourceServiceProvider.notifier,
                  ),
                  db: db,
                  url: Uri.parse(group.remote),
                  group: group,
                  syncInterval: syncInterval,
                );

                //Throw if necessary
                return result.value;
              },
            ),
      );
    } catch (e) {
      return Result.failure(
        ErrorMessage(
          message: "Failed to sync Bangs (${group.name})",
          source: 'BangSync',
          details: e,
        ),
      );
    }
  }

  Future<Result<void>> syncBundledBangGroup(BangGroup group) async {
    try {
      final db = ref.read(bangDatabaseProvider);

      final result = await _fetchAndSyncBundled(
        sourceService: ref.read(bangDataSourceServiceProvider.notifier),
        db: db,
        group: group,
      );

      //Throw if necessary
      return result;
    } catch (e) {
      return Result.failure(
        ErrorMessage(
          message: "Failed to sync Bangs (${group.name})",
          source: 'BangSync',
          details: e,
        ),
      );
    }
  }

  Stream<DateTime?> watchLastSyncOfGroup(BangGroup group) {
    return ref
        .read(bangDatabaseProvider)
        .syncDao
        .getLastSyncOfGroup(group)
        .watchSingleOrNull();
  }

  Future<Map<BangGroup, Result<void>>> syncBundledBangGroups({
    Set<BangGroup>? groups,
  }) async {
    //Default to all sources
    groups ??= BangGroup.values.toSet();

    //Run isolated operations
    final futures = groups.map(
      (source) => syncBundledBangGroup(
        source,
      ).then((result) => MapEntry(source, result)),
    );

    return Map.fromEntries(await Future.wait(futures));
  }

  @override
  void build() {}
}
