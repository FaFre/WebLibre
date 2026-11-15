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
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/services/component_comparator.dart';

/// Combines a target, the component comparison and the security information
/// into an [UpdateAssessment] (plan 7.1 step 5, 5.2).
class UpdateAssessmentService {
  const UpdateAssessmentService();

  static const _comparator = ComponentComparator();

  UpdateAssessment assess({
    required ReleaseCatalogue catalogue,
    required ReleaseEntry release,
    required UpdateTarget target,
    required InstalledBuildInfo installed,
  }) {
    final installedSequence = installed.logicalReleaseSequence;
    final targetSequence = release.logicalReleaseSequence;

    final resolved = <Advisory>[];
    final unresolved = <Advisory>[];
    for (final advisory in catalogue.advisories) {
      if (!advisory.affects(installedSequence)) continue;
      if (advisory.resolvedBy(installedSequence, targetSequence)) {
        resolved.add(advisory);
      } else {
        unresolved.add(advisory);
      }
    }

    return UpdateAssessment(
      targetId: target.id,
      versionCode: target.versionCode,
      logicalReleaseSequence: targetSequence,
      appVersion: release.appVersion,
      target: target,
      componentChanges: _comparator.compareAll(
        installed.components,
        release.componentsFor(target),
      ),
      securityClassification: securityClassification(
        catalogue: catalogue,
        installedSequence: installedSequence,
        targetSequence: targetSequence,
        resolved: resolved,
      ),
      advisories: AdvisorySummary(resolved: resolved, unresolved: unresolved),
      // Newest first, as the catalogue lists them.
      releaseNotes: [
        for (final r in catalogue.releases)
          if (r.logicalReleaseSequence > installedSequence &&
              r.logicalReleaseSequence <= targetSequence &&
              r.releaseNotes.summary.isNotEmpty)
            ReleaseNotesBlock(appVersion: r.appVersion, notes: r.releaseNotes),
      ],
      releaseNotesUrl: release.releaseNotes.url,
    );
  }

  /// Play offered a version the catalogue doesn't describe (8.1): the update
  /// is still offered, with "Details for this version aren't available".
  UpdateAssessment undescribed({required int versionCode}) => UpdateAssessment(
    targetId: 'play:$versionCode',
    versionCode: versionCode,
    logicalReleaseSequence: null,
    appVersion: null,
    target: null,
    componentChanges: null,
    securityClassification: SecurityClassification.unknown,
    advisories: AdvisorySummary.none,
    releaseNotes: const [],
    releaseNotesUrl: null,
  );

  /// The highest of: the severity of advisories resolved by the target, and
  /// the declared classification of every release in (installed, target]. If
  /// that interval reaches below the oldest release still in the catalogue,
  /// releases are missing from the picture: the result is whatever was found.
  /// No evidence at all is `unknown`, never "none".
  SecurityClassification securityClassification({
    required ReleaseCatalogue catalogue,
    required int installedSequence,
    required int targetSequence,
    required List<Advisory> resolved,
  }) {
    var result = SecurityClassification.unknown;
    for (final advisory in resolved) {
      result = result.max(advisory.severity.classification);
    }
    for (final release in catalogue.releases) {
      if (release.logicalReleaseSequence > installedSequence &&
          release.logicalReleaseSequence <= targetSequence) {
        result = result.max(release.security);
      }
    }
    return result;
  }
}
