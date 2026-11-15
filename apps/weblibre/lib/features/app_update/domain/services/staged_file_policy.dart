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
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';

/// A file in the staging directory, named `<sha256>.part` or `<sha256>.apk`.
///
/// `.apk`: downloaded, verified and promoted natively. `.part`: partial.
class StagedFile {
  const StagedFile({required this.sha256, required this.modified});

  final String sha256;
  final DateTime modified;

  static final _name = RegExp(r'^([0-9a-f]{64})\.(part|apk)$');

  /// Native names files the same way (`UpdatePaths.kt`) and promotes the one
  /// to the other.
  static String partName(String sha256) => '$sha256.part';
  static String apkName(String sha256) => '$sha256.apk';

  /// The digest a staged file is named by, or null for any name the updater
  /// doesn't own.
  static String? parseName(String name) => _name.firstMatch(name)?.group(1);
}

enum StagedFileVerdict { keep, delete }

/// The one staged-file policy (plan 6.3), used by authorization, recovery and
/// cleanup alike. A staged file is cached bytes, not authority: it belongs to
/// whatever target of the accepted catalogue has its digest, so keeping one is
/// always safe and deleting one is only ever housekeeping.
class StagedFilePolicy {
  const StagedFilePolicy();

  static const _selector = ArtifactSelector();

  /// Kept and unused for one catalogue validity period.
  static const maxIdle = Duration(days: 30);

  /// [decidable] is the accepted catalogue when it is usable right now, or
  /// null when nothing can be decided (none accepted, expired, offline,
  /// recovery required). A file that failed verification is deleted by the
  /// caller, whatever this says.
  StagedFileVerdict decide(
    StagedFile file, {
    required ReleaseCatalogue? decidable,
    required InstalledBuildInfo installed,
    required DateTime now,
  }) {
    if (now.difference(file.modified) > maxIdle) {
      return StagedFileVerdict.delete;
    }
    if (decidable == null) return StagedFileVerdict.keep;
    return targetFor(file.sha256, decidable, installed) == null
        ? StagedFileVerdict.delete
        : StagedFileVerdict.keep;
  }

  /// The selectable target with this digest, if any. A target the installed
  /// version code has reached is no longer selectable.
  UpdateTarget? targetFor(
    String sha256,
    ReleaseCatalogue catalogue,
    InstalledBuildInfo installed,
  ) => catalogue.allTargets
      .map((entry) => entry.$2)
      .firstWhereOrNull(
        (target) =>
            target.artifact?.sha256 == sha256 &&
            _selector.matchesGithub(target, installed),
      );
}
