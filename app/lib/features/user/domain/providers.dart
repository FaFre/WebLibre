import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'providers.g.dart';

const _authKey = 'pb_auth';

@Riverpod()
Future<String?> _storedAuthData(Ref ref) {
  const secureStorage = FlutterSecureStorage();
  return secureStorage.read(key: _authKey);
}

@Riverpod()
Stream<double> iconCacheSizeMegabytes(Ref ref) {
  final repository = ref.watch(userDatabaseProvider);
  return repository.cacheDao.getIconCacheSize().watchSingle();
}

@Riverpod()
bool incognitoModeEnabled(Ref ref) {
  return ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.deleteBrowsingDataOnQuit != null,
    ),
  );
}
