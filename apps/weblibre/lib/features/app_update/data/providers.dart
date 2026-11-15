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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/pending_writes.dart';
import 'package:weblibre/features/app_update/data/github/allowlisted_fetcher.dart';
import 'package:weblibre/features/app_update/data/github/apk_download_service.dart';
import 'package:weblibre/features/app_update/data/github/github_update_backend.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_codec.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_reader.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/data/metadata/signed_envelope.dart';
import 'package:weblibre/features/app_update/data/metadata/static_release_metadata_repository.dart';
import 'package:weblibre/features/app_update/data/metadata/trusted_metadata_keys.dart';
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/data/play/play_update_backend.dart';
import 'package:weblibre/features/app_update/data/store/accepted_catalogue_store.dart';
import 'package:weblibre/features/app_update/data/store/installation_update_state_store.dart';
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/routed_http_client.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppUpdateHost appUpdateHost(Ref ref) => PigeonAppUpdateHost();

/// Fixed for the life of the process.
@Riverpod(keepAlive: true)
Future<InstalledBuildInfo> installedBuildInfo(Ref ref) =>
    ref.watch(appUpdateHostProvider).getInstalledBuildInfo();

/// Derived once and immutable for the process (3.5). Anything that goes
/// wrong reading the build resolves to no updater: an updater failure never
/// blocks browsing.
@Riverpod(keepAlive: true)
Future<DistributionPolicy> distributionPolicy(Ref ref) async {
  try {
    final build = await ref.watch(installedBuildInfoProvider.future);
    return DistributionPolicy.derive(
      build,
      trustedKeysCompiled: productionMetadataKeys.isNotEmpty,
    );
  } catch (e, s) {
    logger.w(
      'App updater disabled: build info unreadable',
      error: e,
      stackTrace: s,
    );
    return const NoUpdates();
  }
}

/// The coordinator for this build's distribution, or null when it has no
/// updater. Created on first use, which only happens once a profile is
/// committed (the browser and settings exist only then), so nothing runs
/// during the startup profile picker.
@Riverpod(keepAlive: true)
Future<UpdateCoordinator?> appUpdateCoordinator(Ref ref) async {
  final policy = await ref.watch(distributionPolicyProvider.future);
  if (policy is NoUpdates) return null;

  final host = ref.watch(appUpdateHostProvider);
  final installed = await ref.watch(installedBuildInfoProvider.future);
  final dirs = await host.getDirs();
  final repository = InstallationUpdateStateStore(stateDir: dirs.stateDir);

  final fetcher = AllowlistedFetcher(
    client: ref.watch(routedHttpClientProvider),
    awaitRouting: () => awaitAppRoutingSettled(
      ref,
      generalContextId,
      timeout: const Duration(seconds: 30),
    ),
  );

  StaticReleaseMetadataRepository? metadata() {
    if (productionMetadataKeys.isEmpty) return null;
    final reader = CatalogueReader(
      verifier: SignedEnvelopeVerifier(
        productionMetadataKeys,
        retiredKeyIds: retiredMetadataKeyIds,
      ),
      codec: CatalogueCodec(packageId: installed.packageId),
    );
    return StaticReleaseMetadataRepository(
      packageId: installed.packageId,
      fetcher: fetcher,
      reader: reader,
      store: AcceptedCatalogueStore(stateDir: dirs.stateDir, reader: reader),
      guard: FreshnessGuard(buildTime: installed.buildTime),
    );
  }

  Future<void> flushPendingWrites() =>
      ref.read(pendingWritesProvider).flushAll();

  final backend = switch (policy) {
    GithubUpdates() => GithubUpdateBackend(
      host: host,
      installed: installed,
      stagingDir: dirs.stagingDir,
      metadata: metadata()!,
      download: ApkDownloadService(
        fetcher: fetcher,
        stagingDir: dirs.stagingDir,
      ),
      flushPendingWrites: flushPendingWrites,
    ),
    PlayUpdates() => PlayUpdateBackend(
      host: host,
      installed: installed,
      metadata: metadata(),
      flushPendingWrites: flushPendingWrites,
    ),
    NoUpdates() => throw StateError('unreachable'),
  };

  final coordinator = UpdateCoordinator(
    backend: backend,
    repository: repository,
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
}
