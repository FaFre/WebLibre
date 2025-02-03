import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/user/domain/services/local_authentication.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_container.g.dart';

@Riverpod(keepAlive: true)
class SelectedContainer extends _$SelectedContainer {
  Future<ContainerData?> fetchData() async {
    if (state != null) {
      return ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(state!);
    }

    return null;
  }

  Future<void> setContainerId(String id) async {
    final container = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerData(id);

    if (container != null) {
      if (container.metadata.authSettings.authenticationRequired) {
        final authResult = await ref
            .read(localAuthenticationServiceProvider.notifier)
            .authenticate(
              authKey: 'container_access::${container.id}',
              localizedReason:
                  'Require authentication for container ${container.name ?? 'New Container'}',
              settings: container.metadata.authSettings,
              useAuthCache: true,
            );

        if (authResult) {
          state = id;
        }
      } else {
        state = id;
      }
    }
  }

  Future<void> toggleContainer(String id) async {
    if (state == id) {
      clearContainer();
    } else {
      await setContainerId(id);
    }
  }

  void clearContainer() {
    state = null;
  }

  @override
  String? build() {
    ref.listen(
      containersWithCountProvider,
      (previous, next) {
        if (state != null && next.valueOrNull != null) {
          if (!next.value!.any((container) => container.id == state)) {
            clearContainer();
          }
        }
      },
    );

    return null;
  }
}

@Riverpod()
Stream<ContainerData?> selectedContainerData(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  final selectedContainer = ref.watch(selectedContainerProvider);

  if (selectedContainer != null) {
    return db.containerDao
        .getContainerData(selectedContainer)
        .watchSingleOrNull();
  }

  return Stream.value(null);
}
