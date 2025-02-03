import 'dart:typed_data';

import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/user/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache.g.dart';

@Riverpod(keepAlive: true)
class CacheRepository extends _$CacheRepository {
  Future<void> clearCache() {
    return ref.read(userDatabaseProvider).cacheDao.clearIconCache();
  }

  Future<void> cacheIcon(Uri url, Uint8List bytes) {
    return ref.read(userDatabaseProvider).cacheDao.cacheIcon(url.origin, bytes);
  }

  Future<Uint8List?> getCachedIcon(String origin) {
    return ref
        .read(userDatabaseProvider)
        .cacheDao
        .getCachedIcon(origin)
        .getSingleOrNull();
  }

  @override
  void build() {
    final eventService = ref.watch(eventServiceProvider);

    final db = ref.watch(userDatabaseProvider);

    final sub = eventService.iconUpdateEvents.listen((event) async {
      if (Uri.tryParse(event.url) case final Uri url) {
        await db.cacheDao.cacheIcon(url.origin, event.bytes);
      }
    });

    ref.onDispose(() async {
      await sub.cancel();
    });
  }
}
