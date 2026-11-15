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
import 'package:flutter/widgets.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension UpdateFailureL10n on UpdateFailure {
  /// One whole sentence per failure kind (8.8).
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (kind) {
      UpdateFailureKind.network => l10n.appUpdate_failureNetwork,
      UpdateFailureKind.routingUnavailable =>
        l10n.appUpdate_failureRoutingUnavailable,
      UpdateFailureKind.metadataInvalid =>
        l10n.appUpdate_failureMetadataInvalid,
      UpdateFailureKind.metadataClientTooOld =>
        l10n.appUpdate_failureClientTooOld,
      UpdateFailureKind.metadataExpired =>
        l10n.appUpdate_failureMetadataExpired,
      UpdateFailureKind.metadataRollback =>
        l10n.appUpdate_failureMetadataRollback,
      UpdateFailureKind.metadataPredatesBuild =>
        l10n.appUpdate_failureMetadataPredatesBuild,
      UpdateFailureKind.clockSuspect => l10n.appUpdate_failureClockSuspect,
      UpdateFailureKind.noCompatibleTarget =>
        l10n.appUpdate_failureNoCompatibleTarget,
      UpdateFailureKind.insufficientStorage =>
        l10n.appUpdate_failureInsufficientStorage,
      UpdateFailureKind.downloadTooLarge =>
        l10n.appUpdate_failureDownloadTooLarge,
      UpdateFailureKind.downloadMismatch =>
        l10n.appUpdate_failureDownloadMismatch,
      UpdateFailureKind.apkInvalid => l10n.appUpdate_failureApkInvalid,
      UpdateFailureKind.apkIdentityMismatch =>
        l10n.appUpdate_failureApkIdentityMismatch,
      UpdateFailureKind.signerUntrusted =>
        l10n.appUpdate_failureSignerUntrusted,
      UpdateFailureKind.authorizationStale =>
        l10n.appUpdate_failureAuthorizationStale,
      UpdateFailureKind.targetWithdrawn =>
        l10n.appUpdate_failureTargetWithdrawn,
      UpdateFailureKind.stateCorrupt => l10n.appUpdate_failureStateCorrupt,
      UpdateFailureKind.installPermissionDenied =>
        l10n.appUpdate_failureInstallPermissionDenied,
      UpdateFailureKind.installCancelled =>
        l10n.appUpdate_failureInstallCancelled,
      UpdateFailureKind.installConflict =>
        l10n.appUpdate_failureInstallConflict,
      UpdateFailureKind.installIncompatible =>
        l10n.appUpdate_failureInstallIncompatible,
      UpdateFailureKind.installStorage => l10n.appUpdate_failureInstallStorage,
      UpdateFailureKind.installBlocked => l10n.appUpdate_failureInstallBlocked,
      UpdateFailureKind.installUnknown => l10n.appUpdate_failureInstallUnknown,
      UpdateFailureKind.playNotOwned => l10n.appUpdate_failurePlayNotOwned,
      UpdateFailureKind.playUnavailable =>
        l10n.appUpdate_failurePlayUnavailable,
      UpdateFailureKind.playError => l10n.appUpdate_failurePlayError,
    };
  }
}
