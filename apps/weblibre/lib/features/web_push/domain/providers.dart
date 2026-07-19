/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GeckoPushService pushService(Ref ref) {
  final service = GeckoPushService();
  service.setUp();

  ref.onDispose(() {
    unawaited(service.dispose());
  });

  return service;
}

/// Current distributor selection and availability.
///
/// Re-reads native state whenever the distributor acknowledges registration or
/// is uninstalled, so a distributor removed while this screen is open does not
/// leave a stale "configured" reading on screen.
///
/// The native event stream is subscribed to *before* the initial snapshot is
/// requested: `statusChanges` does not replay, so a PENDING → READY transition
/// landing between the two would otherwise be lost and leave the screen stale.
/// If an event wins that race the snapshot is discarded rather than emitted
/// after it, since the snapshot is by then the older value.
@riverpod
Stream<PushStatus> pushStatus(Ref ref) {
  final service = ref.watch(pushServiceProvider);

  final controller = StreamController<PushStatus>();
  var sawEvent = false;

  final subscription = service.statusChanges.listen(
    (status) {
      sawEvent = true;
      if (!controller.isClosed) {
        controller.add(status);
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    },
  );

  unawaited(
    service
        .getPushStatus()
        .then((status) {
          if (!sawEvent && !controller.isClosed) {
            controller.add(status);
          }
        })
        .onError<Object>((error, stackTrace) {
          if (!sawEvent && !controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        }),
  );

  ref.onDispose(() {
    unawaited(() async {
      await subscription.cancel();
      await controller.close();
    }());
  });

  return controller.stream;
}

/// Subscriptions Gecko has created, keyed by site origin.
///
/// Read-only: Gecko owns subscription state and exposes no revocation channel
/// to the app, so entries disappear only when the site itself unsubscribes or
/// its notification permission is revoked.
///
/// Refetches only when [pushStatusProvider] emits (distributor change, endpoint
/// assigned, registration failure). There is no event for a subscription that is
/// created but still awaiting an endpoint, so such an entry only appears the next
/// time this provider is rebuilt — e.g. when the screen is reopened.
@riverpod
Future<List<PushSubscription>> pushSubscriptions(Ref ref) {
  final service = ref.watch(pushServiceProvider);

  // A distributor change re-registers every known scope, so refetch alongside it.
  ref.watch(pushStatusProvider);

  return service.getSubscriptions();
}

@riverpod
class PushDistributorMutation extends _$PushDistributorMutation {
  Future<void>? _operation;
  String? _operationKey;
  int _operationToken = 0;

  @override
  Future<void> build() async {}

  Future<void> setDistributor(String packageName) {
    return _mutate(
      'set:$packageName',
      () => ref.read(pushServiceProvider).setDistributor(packageName),
    );
  }

  Future<void> removeDistributor() {
    return _mutate(
      'remove',
      () => ref.read(pushServiceProvider).removeDistributor(),
    );
  }

  /// Runs a distributor mutation, keyed by [key].
  ///
  /// An identical request already in flight (same [key]) shares the running
  /// operation rather than issuing a duplicate native call. A *distinct*
  /// request is serialized behind the in-flight one — never coalesced into it,
  /// which would silently drop it and hand back the wrong operation's result.
  Future<void> _mutate(String key, Future<void> Function() action) {
    final running = _operation;
    if (running != null && _operationKey == key) {
      return running;
    }

    final token = ++_operationToken;
    final operation = _runMutation(running, action, token);
    _operation = operation;
    _operationKey = key;
    return operation;
  }

  Future<void> _runMutation(
    Future<void>? previous,
    Future<void> Function() action,
    int token,
  ) async {
    // Wait for any in-flight mutation to settle (ignoring its outcome) so
    // distinct operations never overlap.
    if (previous != null) {
      await previous.then((_) {}, onError: (_, _) {});
    }

    state = const AsyncLoading();

    try {
      await action();
      if (ref.mounted) {
        state = const AsyncData(null);
      }
    } catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError(error, stackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      // Only clear if no newer mutation has been chained after this one.
      if (_operationToken == token) {
        _operation = null;
        _operationKey = null;
      }
      if (ref.mounted) {
        ref.invalidate(pushStatusProvider);
        ref.invalidate(pushSubscriptionsProvider);
      }
    }
  }
}

class NotificationPermissionService {
  const NotificationPermissionService();

  Future<bool> isGranted() => Permission.notification.isGranted;

  Future<PermissionStatus> request() => Permission.notification.request();

  Future<bool> openSettings() => openAppSettings();
}

@Riverpod(keepAlive: true)
NotificationPermissionService notificationPermissionService(Ref ref) {
  return const NotificationPermissionService();
}

/// Whether the OS-level notification permission is granted. Without it a push
/// message still arrives but Gecko cannot display the resulting notification.
@riverpod
Future<bool> notificationPermissionGranted(Ref ref) {
  return ref.watch(notificationPermissionServiceProvider).isGranted();
}
