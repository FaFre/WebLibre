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
import 'package:pigeon/pigeon.dart';

/// The app updater's bridge (plans/APP_UPDATER_IMPLEMENTATION_PLAN.md, 3.4).
///
/// No method takes a path or a URL. Staged files are named by their digest,
/// and native code derives both names from [ExpectedArtifact.sha256] itself, so
/// Dart can never point the installer at an arbitrary file.
///
/// Closed sets of values cross as enums. Dart and Kotlin are generated from
/// this file into the same APK, so neither side can see a value the other
/// lacks; strings remain only where a file is read (BuildConfig, the build
/// manifest, the installer journal), and Kotlin parses those once.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/features/app_update/data/native/pigeons/app_update.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/eu/weblibre/gecko/update/AppUpdateApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'eu.weblibre.gecko.update'),
  ),
)
/// A distribution channel (BuildConfig.DISTRIBUTION).
enum BuildDistribution { github, play, fdroid }

enum BuildTrack { stable, alpha }

enum BuildRenderer { skia, impeller }

/// A bundled component of the build manifest.
enum BuildComponent {
  gecko,
  androidComponents,
  applicationServices,
  tor,
  singbox,
}

enum ComponentStatus { known, unknown, notBundled }

/// Why native verification or installation failed. Dart maps each to an
/// `UpdateFailureKind`.
enum NativeFailure {
  downloadMismatch,
  apkInvalid,
  signerUntrusted,
  apkIdentityMismatch,
  authorizationStale,
  installPermissionDenied,
  installCancelled,
  installConflict,
  installIncompatible,
  installStorage,
  installBlocked,
  installUnknown,

  /// A live session holds the reservation (7.5 step 7); nothing failed.
  reservationActive,
}

/// Installer journal phases (7.5), also the phases of a status event.
enum InstallerPhase {
  none,
  sessionCreated,
  commitRequested,
  pendingUserAction,
  abandonRequested,
  succeeded,
  failed,
  abandoned,
}

/// What stage 1 of recovery found Android doing (7.6).
enum ReconcileResult { none, succeeded, inProgress, awaitingUserAction, failed }

enum PlayAvailability { notAvailable, available, inProgress, unknown, error }

/// What a Play `InstallErrorCode` means for the user, mapped natively where
/// the codes are defined (8.7).
enum PlayFailure { notOwned, unavailable, other }

/// How the flexible flow's consent sheet was answered: the flow's result
/// code (`RESULT_OK`, `RESULT_CANCELED`, `RESULT_IN_APP_UPDATE_FAILED`).
enum PlayFlowResult { accepted, declined, failed }

/// Play's install status.
enum PlayInstallStatus {
  unknown,
  pending,
  downloading,
  downloaded,
  installing,
  installed,
  failed,
  canceled,
}

/// One bundled component, from the build manifest.
class ComponentIdentityMessage {
  ComponentIdentityMessage({
    required this.id,
    required this.status,
    this.version,
    this.buildId,
    this.revision,
  });

  final BuildComponent id;
  final ComponentStatus status;
  final String? version;
  final String? buildId;
  final String? revision;
}

/// What is installed, read natively from BuildConfig, PackageManager and the
/// embedded build manifest. Never from anything Dart supplied.
class InstalledBuildInfo {
  InstalledBuildInfo({
    required this.packageId,
    required this.versionCode,
    required this.versionName,
    required this.distribution,
    required this.track,
    required this.renderer,
    required this.abi,
    required this.debugBuild,
    required this.signerTrusted,
    required this.installerPackage,
    required this.installerLabel,
    required this.installerIsSystem,
    required this.installerIsSelf,
    required this.logicalReleaseSequence,
    required this.buildTimeEpochMs,
    required this.sdkInt,
    required this.components,
  });

  final String packageId;
  final int versionCode;
  final String versionName;

  /// Null only if BuildConfig names a value these enums lack.
  final BuildDistribution? distribution;
  final BuildTrack? track;
  final BuildRenderer? renderer;

  /// The ABI this build was split for, or null for a universal build.
  final String? abi;
  final bool debugBuild;

  /// The installed signer is exactly the compiled production certificate.
  final bool signerTrusted;

  /// The installer of record, for display only (8.1). Never a policy input.
  final String? installerPackage;
  final String? installerLabel;
  final bool installerIsSystem;
  final bool installerIsSelf;

  final int logicalReleaseSequence;

  /// The compiled build time (UTC), a floor for metadata freshness (5.3).
  final int buildTimeEpochMs;
  final int sdkInt;

  /// Every component is unknown when the build manifest could not be read.
  final List<ComponentIdentityMessage> components;
}

class UpdateDirs {
  UpdateDirs({required this.stateDir, required this.stagingDir});

  /// `noBackupFilesDir/app_update`: never backed up, never transferred.
  final String stateDir;

  /// `cacheDir/app_update`: staged downloads, named by digest.
  final String stagingDir;
}

/// Everything the authenticated target says about an APK, plus the expiry of
/// the catalogue that authorizes it.
class ExpectedArtifact {
  ExpectedArtifact({
    required this.sha256,
    required this.byteLength,
    required this.versionCode,
    required this.logicalReleaseSequence,
    required this.distribution,
    required this.track,
    required this.renderer,
    required this.abi,
    required this.authorizedUntilEpochMs,
  });

  /// 64 lower-case hex characters; anything else is refused before any file
  /// access.
  final String sha256;
  final int byteLength;
  final int versionCode;
  final int logicalReleaseSequence;
  final BuildDistribution distribution;
  final BuildTrack track;
  final BuildRenderer renderer;
  final String abi;

  /// Native refuses to commit once the device clock is past this.
  final int authorizedUntilEpochMs;
}

/// Outcome of [AppUpdateHostApi.verifyAndPromote] and the verification inside
/// [AppUpdateHostApi.commitInstall].
class ApkVerificationResult {
  ApkVerificationResult({required this.verified, this.failure, this.detail});

  final bool verified;
  final NativeFailure? failure;

  /// Raw detail for logs, never shown as is.
  final String? detail;
}

/// Outcome of [AppUpdateHostApi.commitInstall].
class InstallCommitResult {
  InstallCommitResult({
    required this.committed,
    this.phase,
    this.failure,
    this.detail,
    this.sessionId,
    this.nonce,
  });

  final bool committed;

  /// For a committed session: the phase the journal holds when commit
  /// returns. A status callback may have arrived already, a terminal one
  /// included.
  final InstallerPhase? phase;
  final NativeFailure? failure;

  /// Raw detail for logs, never shown as is.
  final String? detail;

  /// Set while a `failed` [phase] is still in the journal: Dart shows it and
  /// acknowledges it ([AppUpdateHostApi.acknowledgeInstallerFailure]).
  final int? sessionId;
  final String? nonce;
}

/// Stage 1 of recovery (7.6): what Android is doing, from the journal, the
/// installed version code and Android's own session list only.
class InstallerReconciliation {
  InstallerReconciliation({
    required this.result,
    required this.ours,
    this.failure,
    this.detail,
    this.expected,
  });

  final ReconcileResult result;

  /// For `succeeded`: the installation was ours (the journal reached
  /// `commitRequested`), so "Updated to X" may be shown.
  final bool ours;
  final NativeFailure? failure;
  final String? detail;
  final ExpectedArtifact? expected;
}

class PlayUpdateInfo {
  PlayUpdateInfo({
    required this.availability,
    required this.installStatus,
    this.availableVersionCode,
    this.bytesDownloaded,
    this.totalBytesToDownload,
    this.failure,
    this.errorCode,
  });

  final PlayAvailability availability;
  final PlayInstallStatus installStatus;
  final int? availableVersionCode;
  final int? bytesDownloaded;
  final int? totalBytesToDownload;

  /// Set when [availability] is `error`.
  final PlayFailure? failure;

  /// Play's raw `InstallErrorCode`, for logs.
  final int? errorCode;
}

class InstallerStatusEvent {
  InstallerStatusEvent({
    required this.sessionId,
    required this.nonce,
    required this.phase,
    this.failure,
    this.message,
  });

  final int sessionId;
  final String nonce;

  /// `pendingUserAction`, `succeeded` or `failed`.
  final InstallerPhase phase;
  final NativeFailure? failure;
  final String? message;
}

class PlayInstallStateEvent {
  PlayInstallStateEvent({
    required this.installStatus,
    required this.bytesDownloaded,
    required this.totalBytesToDownload,
    this.failure,
    this.errorCode,
  });

  final PlayInstallStatus installStatus;
  final int bytesDownloaded;
  final int totalBytesToDownload;

  /// Set when Play reported an error.
  final PlayFailure? failure;

  /// Play's raw `InstallErrorCode`, for logs.
  final int? errorCode;
}

@HostApi()
abstract class AppUpdateHostApi {
  // Async so PackageManager's binder calls, the manifest read and the
  // directory work stay off the main thread at cold start.
  @async
  InstalledBuildInfo getInstalledBuildInfo();
  @async
  UpdateDirs getDirs();
  @async
  int usableStagingBytes();

  // GitHub distribution. Elsewhere every call answers "unsupported".
  bool canRequestPackageInstalls();
  void openInstallPermissionSettings();

  /// Reads `<stagingDir>/<sha256>.part`, runs every check of 7.4 and renames
  /// it to `<sha256>.apk` on success. A failure deletes the `.part` file.
  @async
  ApkVerificationResult verifyAndPromote(ExpectedArtifact expected);

  /// Reads `<stagingDir>/<sha256>.apk` only, verifies it again and commits a
  /// session. Refuses while a live reservation exists (7.5 step 7).
  @async
  InstallCommitResult commitInstall(ExpectedArtifact expected);

  /// Starts the system confirmation for a session that is waiting for it,
  /// under the bound Dart's authorization just returned (7.5): past it,
  /// native refuses as `commitInstall` does. False when the confirmation
  /// can't be shown any more or the bound has passed.
  bool continuePendingUserAction(int authorizedUntilEpochMs);

  @async
  void abandonInstall();

  // Async so the journal's fsync'd writes, PackageInstaller IPC and the
  // installer's lock (held by a running commit) stay off the main thread.
  @async
  InstallerReconciliation reconcileInstaller();

  /// Dart's state shows the failure event of this session. Native retires a
  /// failure only then: an event sent to a listener that dropped it, or to
  /// an engine that was already gone, stays for reconciliation.
  @async
  void acknowledgeInstallerFailure(int sessionId, String nonce);

  // Play distribution. Elsewhere every call answers "unsupported".
  @async
  PlayUpdateInfo playCheck();
  /// Shows Play's consent sheet and answers once it was accepted, declined
  /// or closed.
  @async
  PlayFlowResult playStartFlexible();
  @async
  void playCompleteFlexible();
}

@EventChannelApi()
abstract class AppUpdateEventsApi {
  InstallerStatusEvent streamInstallerEvents();
  PlayInstallStateEvent streamPlayEvents();
}
