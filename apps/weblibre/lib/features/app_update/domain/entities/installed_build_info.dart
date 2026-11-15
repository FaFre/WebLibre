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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';

enum Distribution { github, play, fdroid, unknown }

enum ReleaseTrack { stable, alpha }

enum Renderer { skia, impeller }

/// The installed build, as native code read it from compiled configuration,
/// PackageManager and the embedded build manifest (plan 3.4).
class InstalledBuildInfo with FastEquatable {
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
    required this.buildTime,
    required this.sdkInt,
    required this.components,
  });

  final String packageId;
  final int versionCode;
  final String versionName;
  final Distribution distribution;
  final ReleaseTrack? track;
  final Renderer? renderer;
  final String? abi;
  final bool debugBuild;
  final bool signerTrusted;
  final String? installerPackage;
  final String? installerLabel;
  final bool installerIsSystem;
  final bool installerIsSelf;
  final int logicalReleaseSequence;

  /// Compiled build time; `null` when the manifest couldn't be read.
  final DateTime? buildTime;
  final int sdkInt;
  final Map<ComponentId, ComponentIdentity> components;

  /// "Installed by another app" (8.1): a third party, not WebLibre, not the
  /// system installer, not unknown.
  String? get otherInstallerLabel {
    if (installerPackage == null || installerIsSelf || installerIsSystem) {
      return null;
    }
    return installerLabel ?? installerPackage;
  }

  @override
  List<Object?> get hashParameters => [
    packageId,
    versionCode,
    versionName,
    distribution,
    track,
    renderer,
    abi,
    debugBuild,
    signerTrusted,
    installerPackage,
    installerLabel,
    installerIsSystem,
    installerIsSelf,
    logicalReleaseSequence,
    buildTime,
    sdkInt,
    components,
  ];
}
