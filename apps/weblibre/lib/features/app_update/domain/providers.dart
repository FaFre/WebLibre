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

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/app_update/data/providers.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';
import 'package:weblibre/features/app_update/domain/services/update_surface_policy.dart';

part 'providers.g.dart';

/// The updater as the UI sees it. Null while the build has no updater (the
/// Updates screen and its row are then not built).
@Riverpod(keepAlive: true)
class AppUpdateController extends _$AppUpdateController {
  StreamSubscription<UpdateSnapshot>? _subscription;

  @override
  UpdateSnapshot? build() {
    ref.onDispose(() => _subscription?.cancel());
    // Only a new coordinator resubscribes and starts again, never a loading
    // or error transition of the provider around the same one.
    final coordinator = ref.watch(
      appUpdateCoordinatorProvider.select((value) => value.value),
    );
    if (coordinator == null) return null;

    unawaited(_subscription?.cancel());
    // Skips the replayed value: it is what build returns.
    _subscription = coordinator.snapshots
        .skip(1)
        .listen((snapshot) => state = snapshot);
    unawaited(coordinator.start());
    return coordinator.snapshot;
  }

  UpdateCoordinator? get _coordinator =>
      ref.read(appUpdateCoordinatorProvider).value;

  Future<void> onResume() async {
    await _coordinator?.onResume();
  }

  Future<void> checkNow() async {
    await _coordinator?.checkForUpdate(manual: true);
  }

  Future<void> download(String targetId) async {
    await _coordinator?.prepareUpdate(targetId);
  }

  Future<void> install(String targetId) async {
    await _coordinator?.requestInstallation(targetId);
  }

  Future<void> continueInstallation() async {
    await _coordinator?.continueInstallation();
  }

  Future<void> cancel() async {
    await _coordinator?.cancelUpdate();
  }

  Future<void> setAutomaticChecks({required bool enabled}) async {
    await _coordinator?.setAutomaticChecks(enabled: enabled);
  }

  Future<void> resetTrustAndCheck() async {
    await _coordinator?.resetTrustAndCheck();
  }

  Future<void> acknowledgeAnnouncement() async {
    await _coordinator?.acknowledgeAnnouncement();
  }

  void acknowledgeUpdatedNotice() => _coordinator?.acknowledgeUpdatedNotice();
}

/// What the browser menu row and the dot show (8.2, 8.3). Derived UI state:
/// the controller above it is what stays alive.
@Riverpod()
UpdateSurface appUpdateSurface(Ref ref) {
  final snapshot = ref.watch(appUpdateControllerProvider);
  if (snapshot == null) return UpdateSurface.none;
  return const UpdateSurfacePolicy().surfaceFor(
    snapshot.state,
    preferences: snapshot.preferences,
  );
}

/// Shorthand for widgets that only need the state.
@Riverpod()
UpdateState? appUpdateState(Ref ref) =>
    ref.watch(appUpdateControllerProvider.select((s) => s?.state));

/// Whether this installation has an updater, at runtime (3.5): false until
/// the policy is read, and for builds that compile one in but may not use it
/// (foreign-signed, universal APK). Settings build the Updates section only
/// while this holds.
@Riverpod()
bool appUpdaterAvailable(Ref ref) => ref.watch(
  distributionPolicyProvider.select((p) => p.value?.hasUpdater ?? false),
);
