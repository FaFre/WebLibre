import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/user/domain/services/local_authentication.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_container.g.dart';

enum SetContainerResult {
  failed,
  success,
  successHasProxy,
}

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

  Future<SetContainerResult> setContainerId(String id) async {
    final container = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerData(id);

    if (container != null) {
      var passAuth = false;
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
          passAuth = true;
        }
      } else {
        passAuth = true;
      }

      if (passAuth) {
        state = id;

        if (container.metadata.useProxy) {
          return SetContainerResult.successHasProxy;
        }

        return SetContainerResult.success;
      }
    }

    return SetContainerResult.failed;
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
