import 'package:lensai/features/user/domain/repositories/engine_settings.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_settings.g.dart';

@Riverpod(keepAlive: true)
class SaveGeneralSettingsController extends _$SaveGeneralSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> save(UpdateGeneralSettingsFunc updateSettings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );
  }
}

@Riverpod(keepAlive: true)
class SaveEngineSettingsController extends _$SaveEngineSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> save(UpdateEngineSettingsFunc updateSettings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );
  }
}
