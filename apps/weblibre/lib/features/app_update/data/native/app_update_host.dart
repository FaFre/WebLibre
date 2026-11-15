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
import 'package:weblibre/features/app_update/data/native/pigeons/app_update.g.dart'
    as native;
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

export 'package:weblibre/features/app_update/data/native/pigeons/app_update.g.dart'
    show
        ApkVerificationResult,
        BuildDistribution,
        BuildRenderer,
        BuildTrack,
        ExpectedArtifact,
        InstallCommitResult,
        InstallerPhase,
        InstallerReconciliation,
        InstallerStatusEvent,
        NativeFailure,
        PlayAvailability,
        PlayFailure,
        PlayFlowResult,
        PlayInstallStateEvent,
        PlayInstallStatus,
        PlayUpdateInfo,
        ReconcileResult,
        UpdateDirs;

/// The native updater, behind an interface the backends and their tests
/// share. A thin wrapper over the generated Pigeon API (plan 3.1).
abstract interface class AppUpdateHost {
  Future<InstalledBuildInfo> getInstalledBuildInfo();
  Future<native.UpdateDirs> getDirs();
  Future<int> usableStagingBytes();

  Future<bool> canRequestPackageInstalls();
  Future<void> openInstallPermissionSettings();
  Future<native.ApkVerificationResult> verifyAndPromote(
    native.ExpectedArtifact expected,
  );
  Future<native.InstallCommitResult> commitInstall(
    native.ExpectedArtifact expected,
  );
  Future<bool> continuePendingUserAction(int authorizedUntilEpochMs);
  Future<void> abandonInstall();
  Future<native.InstallerReconciliation> reconcileInstaller();

  /// The state now shows the failure event for this session: native retires
  /// it, and reconciliation no longer reports it.
  Future<void> acknowledgeInstallerFailure(int sessionId, String nonce);

  Future<native.PlayUpdateInfo> playCheck();
  Future<native.PlayFlowResult> playStartFlexible();
  Future<void> playCompleteFlexible();

  Stream<native.InstallerStatusEvent> get installerEvents;
  Stream<native.PlayInstallStateEvent> get playEvents;
}

class PigeonAppUpdateHost implements AppUpdateHost {
  PigeonAppUpdateHost([native.AppUpdateHostApi? api])
    : _api = api ?? native.AppUpdateHostApi();

  final native.AppUpdateHostApi _api;

  // One stream per channel for the life of the wrapper: every call to the
  // generated `streamX()` makes a new EventChannel, and Android keeps one
  // listener per channel.
  @override
  late final Stream<native.InstallerStatusEvent> installerEvents = native
      .streamInstallerEvents()
      .asBroadcastStream();

  @override
  late final Stream<native.PlayInstallStateEvent> playEvents = native
      .streamPlayEvents()
      .asBroadcastStream();

  @override
  Future<InstalledBuildInfo> getInstalledBuildInfo() async =>
      installedBuildInfoFromMessage(await _api.getInstalledBuildInfo());

  @override
  Future<native.UpdateDirs> getDirs() => _api.getDirs();

  @override
  Future<int> usableStagingBytes() => _api.usableStagingBytes();

  @override
  Future<bool> canRequestPackageInstalls() => _api.canRequestPackageInstalls();

  @override
  Future<void> openInstallPermissionSettings() =>
      _api.openInstallPermissionSettings();

  @override
  Future<native.ApkVerificationResult> verifyAndPromote(
    native.ExpectedArtifact expected,
  ) => _api.verifyAndPromote(expected);

  @override
  Future<native.InstallCommitResult> commitInstall(
    native.ExpectedArtifact expected,
  ) => _api.commitInstall(expected);

  @override
  Future<bool> continuePendingUserAction(int authorizedUntilEpochMs) =>
      _api.continuePendingUserAction(authorizedUntilEpochMs);

  @override
  Future<void> abandonInstall() => _api.abandonInstall();

  @override
  Future<native.InstallerReconciliation> reconcileInstaller() =>
      _api.reconcileInstaller();

  @override
  Future<void> acknowledgeInstallerFailure(int sessionId, String nonce) =>
      _api.acknowledgeInstallerFailure(sessionId, nonce);

  @override
  Future<native.PlayUpdateInfo> playCheck() => _api.playCheck();

  @override
  Future<native.PlayFlowResult> playStartFlexible() => _api.playStartFlexible();

  @override
  Future<void> playCompleteFlexible() => _api.playCompleteFlexible();
}

InstalledBuildInfo installedBuildInfoFromMessage(native.InstalledBuildInfo m) {
  ComponentIdentity component(native.ComponentIdentityMessage c) =>
      switch (c.status) {
        native.ComponentStatus.known
            when c.version != null && c.version!.isNotEmpty =>
          ComponentKnown(c.version!, buildId: c.buildId, revision: c.revision),
        native.ComponentStatus.notBundled => ComponentNotBundled(),
        _ => ComponentUnknown(),
      };

  return InstalledBuildInfo(
    packageId: m.packageId,
    versionCode: m.versionCode,
    versionName: m.versionName,
    distribution: switch (m.distribution) {
      native.BuildDistribution.github => Distribution.github,
      native.BuildDistribution.play => Distribution.play,
      native.BuildDistribution.fdroid => Distribution.fdroid,
      null => Distribution.unknown,
    },
    track: m.track?.domain,
    renderer: m.renderer?.domain,
    abi: m.abi,
    debugBuild: m.debugBuild,
    signerTrusted: m.signerTrusted,
    installerPackage: m.installerPackage,
    installerLabel: m.installerLabel,
    installerIsSystem: m.installerIsSystem,
    installerIsSelf: m.installerIsSelf,
    logicalReleaseSequence: m.logicalReleaseSequence,
    buildTime: m.buildTimeEpochMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(m.buildTimeEpochMs, isUtc: true)
        : null,
    sdkInt: m.sdkInt,
    components: {for (final c in m.components) c.id.domain: component(c)},
  );
}

extension on native.BuildComponent {
  ComponentId get domain => switch (this) {
    native.BuildComponent.gecko => ComponentId.gecko,
    native.BuildComponent.androidComponents => ComponentId.androidComponents,
    native.BuildComponent.applicationServices =>
      ComponentId.applicationServices,
    native.BuildComponent.tor => ComponentId.tor,
    native.BuildComponent.snowflake => ComponentId.snowflake,
    native.BuildComponent.lyrebird => ComponentId.lyrebird,
    native.BuildComponent.singbox => ComponentId.singbox,
  };
}

extension on native.BuildTrack {
  ReleaseTrack get domain => switch (this) {
    native.BuildTrack.stable => ReleaseTrack.stable,
    native.BuildTrack.alpha => ReleaseTrack.alpha,
  };
}

extension on native.BuildRenderer {
  Renderer get domain => switch (this) {
    native.BuildRenderer.skia => Renderer.skia,
    native.BuildRenderer.impeller => Renderer.impeller,
  };
}

extension ReleaseTrackNative on ReleaseTrack {
  native.BuildTrack get pigeon => switch (this) {
    ReleaseTrack.stable => native.BuildTrack.stable,
    ReleaseTrack.alpha => native.BuildTrack.alpha,
  };
}

extension RendererNative on Renderer {
  native.BuildRenderer get pigeon => switch (this) {
    Renderer.skia => native.BuildRenderer.skia,
    Renderer.impeller => native.BuildRenderer.impeller,
  };
}

extension NativeFailureKind on native.NativeFailure? {
  /// No failure named is [UpdateFailureKind.installUnknown].
  UpdateFailureKind get kind => switch (this) {
    native.NativeFailure.downloadMismatch => UpdateFailureKind.downloadMismatch,
    native.NativeFailure.apkInvalid => UpdateFailureKind.apkInvalid,
    native.NativeFailure.signerUntrusted => UpdateFailureKind.signerUntrusted,
    native.NativeFailure.apkIdentityMismatch =>
      UpdateFailureKind.apkIdentityMismatch,
    native.NativeFailure.authorizationStale =>
      UpdateFailureKind.authorizationStale,
    native.NativeFailure.installPermissionDenied =>
      UpdateFailureKind.installPermissionDenied,
    native.NativeFailure.installCancelled => UpdateFailureKind.installCancelled,
    native.NativeFailure.installConflict => UpdateFailureKind.installConflict,
    native.NativeFailure.installIncompatible =>
      UpdateFailureKind.installIncompatible,
    native.NativeFailure.installStorage => UpdateFailureKind.installStorage,
    native.NativeFailure.installBlocked => UpdateFailureKind.installBlocked,
    // Callers recover on a held reservation before mapping a failure.
    native.NativeFailure.reservationActive ||
    native.NativeFailure.installUnknown ||
    null => UpdateFailureKind.installUnknown,
  };
}
