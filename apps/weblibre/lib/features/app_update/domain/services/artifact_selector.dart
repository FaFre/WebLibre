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
import 'package:collection/collection.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';

sealed class SelectionResult {
  const SelectionResult();
}

final class TargetSelected extends SelectionResult {
  const TargetSelected(this.release, this.target);

  final ReleaseEntry release;
  final UpdateTarget target;
}

/// No newer release exists.
final class NothingNewer extends SelectionResult {
  const NothingNewer();
}

/// A newer release exists, but none has a target for this build.
final class NoCompatibleTarget extends SelectionResult {
  const NoCompatibleTarget();
}

/// Picks the update for this exact build (plan 7.1 step 3). File names are
/// never inspected; every identity field must match.
class ArtifactSelector {
  const ArtifactSelector();

  SelectionResult selectGithub(
    ReleaseCatalogue catalogue,
    InstalledBuildInfo installed,
  ) {
    if (catalogue.packageId != installed.packageId) return const NothingNewer();

    bool newer(ReleaseEntry release) =>
        release.logicalReleaseSequence > installed.logicalReleaseSequence;

    // Releases are newest first (the codec orders them), so the first match
    // is the newest target this build can install.
    if (catalogue.allTargets.firstWhereOrNull(
          (entry) => newer(entry.$1) && matchesGithub(entry.$2, installed),
        )
        case (final release, final target)) {
      return TargetSelected(release, target);
    }
    final newest = catalogue.releases.firstOrNull;
    return newest != null && newer(newest)
        ? const NoCompatibleTarget()
        : const NothingNewer();
  }

  /// Whether this build could install [target] (also used to decide which
  /// staged files still belong to something, 6.3).
  bool matchesGithub(UpdateTarget target, InstalledBuildInfo installed) =>
      installed.distribution == Distribution.github &&
      target.distribution == Distribution.github &&
      target.track != null &&
      target.track == installed.track &&
      target.renderer != null &&
      target.renderer == installed.renderer &&
      target.abi != null &&
      target.abi == installed.abi &&
      target.minSdk <= installed.sdkInt &&
      target.versionCode > installed.versionCode &&
      target.artifact != null;

  /// Play offers [availableVersionCode]; describe it only on an exact match
  /// (Phase 5). Null means the catalogue doesn't describe it.
  TargetSelected? describePlay(
    ReleaseCatalogue catalogue,
    InstalledBuildInfo installed,
    int availableVersionCode,
  ) {
    if (catalogue.packageId != installed.packageId) return null;
    return switch (catalogue.allTargets.firstWhereOrNull(
      (entry) =>
          entry.$2.distribution == Distribution.play &&
          entry.$2.track == installed.track &&
          entry.$2.renderer == installed.renderer &&
          entry.$2.versionCode == availableVersionCode,
    )) {
      (final release, final target) => TargetSelected(release, target),
      null => null,
    };
  }
}
