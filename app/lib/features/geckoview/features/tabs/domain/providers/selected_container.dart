import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';

part 'selected_container.g.dart';

enum SetContainerResult { failed, success, successHasProxy }

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
              localizedReason: 'Require authentication for container',
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
        if (container.metadata.useProxy) {
          final proxyPluginHealthy = await GeckoContainerProxyService()
              .healthcheck();

          if (proxyPluginHealthy) {
            state = id;
            return SetContainerResult.successHasProxy;
          }
        } else {
          state = id;
          return SetContainerResult.success;
        }
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
      fireImmediately: true,
      containersWithCountProvider,
      (previous, next) {
        if (stateOrNull != null && next.valueOrNull != null) {
          if (!next.value!.any((container) => container.id == state)) {
            clearContainer();
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to containersWithCountProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      selectedTabProvider,
      (previous, next) async {
        if (next != null) {
          final tabContainerId = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getContainerTabId(next);

          if (tabContainerId != stateOrNull) {
            if (tabContainerId != null) {
              await setContainerId(tabContainerId);
            } else {
              clearContainer();
            }
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to selectedTabProvider',
          error: error,
          stackTrace: stackTrace,
        );
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

@Riverpod()
AsyncValue<int> selectedContainerTabCount(Ref ref) {
  final selectedContainer = ref.watch(selectedContainerProvider);
  final tabCount = ref.watch(
    // ignore: provider_parameters
    containerTabCountProvider(ContainerFilter.from(selectedContainer)),
  );

  return tabCount;
}
