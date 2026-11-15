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
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';

/// What this installation's updater may do (plan 3.5). Derived once from the
/// installed build and immutable for the process.
///
/// Installer of record, account state and preferences are never inputs: who
/// installed the app decides nothing here (7.7).
sealed class DistributionPolicy {
  const DistributionPolicy();

  /// [trustedKeysCompiled] is false while the build carries no metadata key.
  /// A GitHub build can't verify anything then, so it has no updater at all
  /// rather than one that can only fail.
  factory DistributionPolicy.derive(
    InstalledBuildInfo build, {
    required bool trustedKeysCompiled,
  }) {
    if (build.debugBuild || !build.signerTrusted) {
      return const NoUpdates();
    }
    // A build whose identity can't be read can't be matched to a target.
    if (build.track == null || build.renderer == null) return const NoUpdates();

    return switch (build.distribution) {
      Distribution.github when trustedKeysCompiled && build.abi != null =>
        const GithubUpdates(),
      Distribution.play => const PlayUpdates(),
      _ => const NoUpdates(),
    };
  }

  bool get hasUpdater => this is! NoUpdates;
}

/// Debug builds, F-Droid, forks and anything not signed by the production
/// certificate (D8). The Updates screen and its settings row are not built.
final class NoUpdates extends DistributionPolicy {
  const NoUpdates();
}

/// Check, download and install, all verified on device.
final class GithubUpdates extends DistributionPolicy {
  const GithubUpdates();
}

/// Google Play's flexible in-app update.
final class PlayUpdates extends DistributionPolicy {
  const PlayUpdates();
}
