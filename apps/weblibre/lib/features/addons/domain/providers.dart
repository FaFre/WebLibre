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
import 'dart:convert';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'providers.g.dart';

sealed class AddonUpdateOutcome {
  const AddonUpdateOutcome();
}

class AddonUpdateOutcomeAvailable extends AddonUpdateOutcome {
  final AddonInfo addon;
  final String availableVersion;

  const AddonUpdateOutcomeAvailable({
    required this.addon,
    required this.availableVersion,
  });
}

class AddonUpdateOutcomeUpToDate extends AddonUpdateOutcome {
  const AddonUpdateOutcomeUpToDate();
}

class AddonUpdateOutcomeMissing extends AddonUpdateOutcome {
  const AddonUpdateOutcomeMissing();
}

sealed class AddonUpdateRunResult {
  const AddonUpdateRunResult();
}

class AddonUpdateRunDone extends AddonUpdateRunResult {
  final String? message;

  const AddonUpdateRunDone(this.message);
}

class AddonUpdateRunNoRemoteSource extends AddonUpdateRunResult {
  const AddonUpdateRunNoRemoteSource();
}

class AddonUpdateRunFailed extends AddonUpdateRunResult {
  const AddonUpdateRunFailed();
}

String _resolveAvailableVersion(AddonInfo addon, AddonStoreInfo? storeInfo) {
  final latest = storeInfo?.latestVersion.trim();
  return (latest != null && latest.isNotEmpty) ? latest : addon.version;
}

@Riverpod()
class AddonDetails extends _$AddonDetails {
  GeckoAddonService get _service => ref.read(addonServiceProvider);

  Future<void> _run(Future<AddonInfo?> Function() action) async {
    state = const AsyncLoading<AddonInfo?>();
    state = await AsyncValue.guard(action);

    ref.invalidate(addonListProvider);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> install() async {
    final current = state.value;
    if (current == null) return;

    await _run(() async {
      await _service.installAddon(Uri.parse(current.downloadUrl));
      return _service.getAddonById(addonId);
    });
  }

  Future<void> uninstall() async {
    await _run(() async {
      await _service.uninstallAddon(addonId);
      return null;
    });
  }

  Future<void> setEnabled({required bool enabled}) async {
    await _run(
      () => enabled
          ? _service.enableAddon(addonId)
          : _service.disableAddon(addonId),
    );
  }

  Future<void> setAllowedInPrivateBrowsing({required bool allowed}) async {
    await _run(
      () => _service.setAddonAllowedInPrivateBrowsing(addonId, allowed),
    );
  }

  Future<void> setAutoUpdateEnabled({required bool enabled}) async {
    await _run(
      () => _service.setAddonAutoUpdateEnabledForAddon(addonId, enabled),
    );
  }

  @override
  Future<AddonInfo?> build(String addonId) {
    return _service.getAddonById(addonId);
  }
}

@Riverpod()
Future<AddonStoreInfo?> addonStoreInfo(Ref ref, String addonId) {
  return ref.read(addonServiceProvider).getAddonStoreInfo(addonId);
}

@Riverpod()
Future<AddonUpdateAttemptInfo?> lastAddonUpdateAttempt(
  Ref ref,
  String addonId,
) {
  return ref.read(addonServiceProvider).getLastAddonUpdateAttempt(addonId);
}

@Riverpod()
class AddonUpdateCheck extends _$AddonUpdateCheck {
  /// Refreshes store info and returns whether an update is available.
  Future<AddonUpdateOutcome> resolveAvailableUpdate() async {
    final storeInfo = await ref
        .read(addonServiceProvider)
        .getAddonStoreInfo(addonId);
    final fresh = await ref
        .read(addonServiceProvider)
        .getAddonById(addonId, allowCache: false);

    if (fresh == null) return const AddonUpdateOutcomeMissing();

    final available = _resolveAvailableVersion(fresh, storeInfo);
    final hasUpdate =
        fresh.installedVersion != null &&
        available.isNotEmpty &&
        fresh.installedVersion != available;

    return hasUpdate
        ? AddonUpdateOutcomeAvailable(addon: fresh, availableVersion: available)
        : const AddonUpdateOutcomeUpToDate();
  }

  /// Triggers a remote update and awaits completion. Invalidates dependent
  /// providers on completion.
  Future<AddonUpdateRunResult> triggerAndAwait() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard<AddonUpdateRunResult>(() async {
      final AddonUpdateAttemptInfo? attempt;
      try {
        attempt = await ref
            .read(addonServiceProvider)
            .triggerAddonUpdate(addonId);
      } catch (error) {
        final noRemote = error.toString().contains(
          'No remote update source is available for this locally installed extension.',
        );
        return noRemote
            ? const AddonUpdateRunNoRemoteSource()
            : const AddonUpdateRunFailed();
      }

      return attempt?.status == AddonUpdateStatus.error
          ? const AddonUpdateRunFailed()
          : AddonUpdateRunDone(attempt?.message);
    });

    state = result;
    ref.invalidate(addonDetailsProvider(addonId));
    ref.invalidate(lastAddonUpdateAttemptProvider(addonId));

    return result.value ?? const AddonUpdateRunFailed();
  }

  @override
  AsyncValue<AddonUpdateRunResult> build(String addonId) =>
      const AsyncData(AddonUpdateRunDone(null));
}

@Riverpod()
class AddonList extends _$AddonList {
  GeckoAddonService get _service => ref.read(addonServiceProvider);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> install(AddonInfo addon) async {
    ref.read(addonBusyIdsProvider.notifier).add(addon.id);
    try {
      await _service.installAddon(Uri.parse(addon.downloadUrl));
      ref.invalidate(addonDetailsProvider(addon.id));
      ref.invalidateSelf();
      await future;
    } finally {
      ref.read(addonBusyIdsProvider.notifier).remove(addon.id);
    }
  }

  Future<void> uninstall(AddonInfo addon) async {
    ref.read(addonBusyIdsProvider.notifier).add(addon.id);
    try {
      await _service.uninstallAddon(addon.id);
      ref.invalidate(addonDetailsProvider(addon.id));
      ref.invalidateSelf();
      await future;
    } finally {
      ref.read(addonBusyIdsProvider.notifier).remove(addon.id);
    }
  }

  @override
  Future<List<AddonInfo>> build() {
    return _service.getAddons();
  }
}

@Riverpod()
class AddonBusyIds extends _$AddonBusyIds {
  void add(String id) => state = {...state, id};
  void remove(String id) => state = {...state}..remove(id);

  @override
  Set<String> build() => const {};
}

@Riverpod(keepAlive: true)
class PinnedAddonIds extends _$PinnedAddonIds {
  void setPinned(String addonId, {required bool pinned}) {
    if (pinned) {
      if (!state.contains(addonId)) {
        state = {...state, addonId};
      }
    } else if (state.contains(addonId)) {
      state = {...state}..remove(addonId);
    }
  }

  @override
  Set<String> build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'PinnedAddonIds',
      encode: (state) => jsonEncode(state.toList()),
      decode: (encoded) =>
          (jsonDecode(encoded) as List<dynamic>).cast<String>().toSet(),
    );

    return stateOrNull ?? const {};
  }
}

@Riverpod()
class BulkAddonUpdate extends _$BulkAddonUpdate {
  Future<void> triggerAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addonServiceProvider).triggerAllAddonUpdates();
    });
  }

  @override
  AsyncValue<void> build() => const AsyncData(null);
}
