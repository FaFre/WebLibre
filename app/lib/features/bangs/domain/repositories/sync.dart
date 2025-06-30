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
  static Future<Result<void>> _fetchAndSync({
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

    final result = await sourceService.getBangs(url, group);
    return result.flatMapAsync((remoteBangs) async {
      await db.syncDao.syncBangs(
        group: group,
        remoteBangs: remoteBangs,
        syncTime: DateTime.now(),
      );
      await db.optimizeFtsIndex();
    });
  }

  Future<Result<void>> syncBangGroup(
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
                final result = await _fetchAndSync(
                  sourceService: ref.read(
                    bangDataSourceServiceProvider.notifier,
                  ),
                  db: db,
                  url: Uri.parse(group.url),
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

  Stream<DateTime?> watchLastSyncOfGroup(BangGroup group) {
    return ref
        .read(bangDatabaseProvider)
        .syncDao
        .getLastSyncOfGroup(group)
        .watchSingleOrNull();
  }

  Future<Map<BangGroup, Result<void>>> syncBangGroups({
    Set<BangGroup>? groups,
    Duration? syncInterval,
  }) async {
    //Default to all sources
    groups ??= BangGroup.values.toSet();

    //Run isolated operations
    final futures = groups.map(
      (source) => syncBangGroup(
        source,
        syncInterval,
      ).then((result) => MapEntry(source, result)),
    );

    return Map.fromEntries(await Future.wait(futures));
  }

  @override
  void build() {}
}
