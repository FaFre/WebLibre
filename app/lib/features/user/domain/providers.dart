import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lensai/features/user/data/providers.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

const _authKey = 'pb_auth';

@Riverpod()
Stream<double> iconCacheSizeMegabytes(Ref ref) {
  final repository = ref.watch(userDatabaseProvider);
  return repository.cacheDao.iconCacheSize().watchSingle();
}

@Riverpod()
Future<String?> _storedAuthData(Ref ref) {
  const secureStorage = FlutterSecureStorage();
  return secureStorage.read(key: _authKey);
}

@Riverpod(keepAlive: true)
AsyncAuthStore authStore(Ref ref) {
  const secureStorage = FlutterSecureStorage();

  final intial = ref.watch(
    _storedAuthDataProvider.select((value) => value.valueOrNull),
  );

  return AsyncAuthStore(
    initial: intial,
    save: (data) async {
      await secureStorage.write(key: _authKey, value: data);
    },
  );
}

@Riverpod()
Stream<AuthStoreEvent> authState(Ref ref) {
  final authStore = ref.watch(authStoreProvider);
  return authStore.onChange;
}

@Riverpod(keepAlive: true)
PocketBase pocketBase(Ref ref) {
  final authStore = ref.watch(authStoreProvider);

  return PocketBase('http://192.168.2.104:8090', authStore: authStore);
}

@Riverpod()
bool incognitoModeEnabled(Ref ref) {
  return ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.deleteBrowsingDataOnQuit != null,
    ),
  );
}
