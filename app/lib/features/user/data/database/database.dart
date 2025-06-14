import 'package:drift/drift.dart';
import 'package:weblibre/features/user/data/database/daos/cache.dart';
import 'package:weblibre/features/user/data/database/daos/onboarding.dart';
import 'package:weblibre/features/user/data/database/daos/setting.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [SettingDao, CacheDao, OnboardingDao],
)
class UserDatabase extends _$UserDatabase {
  @override
  final int schemaVersion = 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  UserDatabase(super.e);
}
