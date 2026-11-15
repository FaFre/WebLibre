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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';
import 'package:weblibre/features/app_update/domain/services/update_assessment_service.dart';

import '../fixtures.dart';

void main() {
  const service = UpdateAssessmentService();

  Map<String, Object?> advisory({
    int? introduced,
    required int fixed,
    String severity = 'high',
  }) => {
    'id': 'WL-$fixed',
    'severity': severity,
    'affected': {'introducedInSequence': ?introduced, 'fixedInSequence': fixed},
  };

  ReleaseCatalogue withAdvisories(
    List<Map<String, Object?>> releases,
    List<Map<String, Object?>> advisories,
  ) => catalogue(releases, advisories: advisories);

  test('a fix inside the offered interval is resolved', () {
    final c = withAdvisories(
      [releaseJson(sequence: 44)],
      [advisory(fixed: 44)],
    );
    final selection =
        const ArtifactSelector().selectGithub(c, installedBuild())
            as TargetSelected;
    final a = service.assess(
      catalogue: c,
      release: selection.release,
      target: selection.target,
      installed: installedBuild(),
    );
    expect(a.advisories.resolved, hasLength(1));
    expect(a.advisories.unresolved, isEmpty);
    expect(a.securityClassification, SecurityClassification.fixesIncluded);
  });

  test('a fix beyond the offered target affects, but is not resolved', () {
    final c = withAdvisories(
      [releaseJson(sequence: 43)],
      [advisory(fixed: 48, severity: 'critical')],
    );
    final selection =
        const ArtifactSelector().selectGithub(c, installedBuild())
            as TargetSelected;
    final a = service.assess(
      catalogue: c,
      release: selection.release,
      target: selection.target,
      installed: installedBuild(),
    );
    expect(a.advisories.resolved, isEmpty);
    expect(a.advisories.unresolved, hasLength(1));
    // Not claimed as fixed by this update.
    expect(a.securityClassification, SecurityClassification.unknown);
  });

  test('an advisory that does not affect the installation is ignored', () {
    final c = withAdvisories(
      [releaseJson(sequence: 44)],
      [advisory(introduced: 43, fixed: 44)],
    );
    final selection =
        const ArtifactSelector().selectGithub(c, installedBuild())
            as TargetSelected;
    final a = service.assess(
      catalogue: c,
      release: selection.release,
      target: selection.target,
      installed: installedBuild(),
    );
    expect(a.advisories.resolved, isEmpty);
    expect(a.advisories.unresolved, isEmpty);
  });

  test('an advisory outliving its release entry still applies', () {
    // The fixing release (38) has left the catalogue; the installed build is
    // older still.
    final c = withAdvisories(
      [releaseJson(sequence: 44)],
      [advisory(fixed: 38)],
    );
    final old = installedBuild(sequence: 30);
    final selection =
        const ArtifactSelector().selectGithub(c, old) as TargetSelected;
    final a = service.assess(
      catalogue: c,
      release: selection.release,
      target: selection.target,
      installed: old,
    );
    expect(a.advisories.resolved, hasLength(1));
  });

  test(
    'the highest declared classification across (installed, target] wins',
    () {
      final c = catalogue([
        releaseJson(sequence: 43, security: 'critical'),
        releaseJson(sequence: 44, security: 'unknown'),
      ]);
      final selection =
          const ArtifactSelector().selectGithub(c, installedBuild())
              as TargetSelected;
      final a = service.assess(
        catalogue: c,
        release: selection.release,
        target: selection.target,
        installed: installedBuild(),
      );
      expect(a.securityClassification, SecurityClassification.critical);
      expect(a.includesSecurityFixes, isTrue);
    },
  );

  test('no evidence is unknown, never none', () {
    final c = catalogue([releaseJson(sequence: 43)]);
    final selection =
        const ArtifactSelector().selectGithub(c, installedBuild())
            as TargetSelected;
    final a = service.assess(
      catalogue: c,
      release: selection.release,
      target: selection.target,
      installed: installedBuild(),
    );
    expect(a.securityClassification, SecurityClassification.unknown);
    expect(a.includesSecurityFixes, isFalse);
  });

  test(
    'release notes for every release in (installed, target], newest first',
    () {
      final c = catalogue([
        releaseJson(
          sequence: 42,
          notes: {
            'summary': {'en': 'installed'},
          },
        ),
        releaseJson(
          sequence: 43,
          notes: {
            'summary': {'en': 'a'},
          },
        ),
        releaseJson(sequence: 44),
        releaseJson(
          sequence: 45,
          notes: {
            'summary': {'en': 'c'},
          },
        ),
      ]);
      final selection =
          const ArtifactSelector().selectGithub(c, installedBuild())
              as TargetSelected;
      final a = service.assess(
        catalogue: c,
        release: selection.release,
        target: selection.target,
        installed: installedBuild(),
      );
      expect(a.releaseNotes.map((b) => b.appVersion), ['0.45.0', '0.43.0']);
    },
  );
}
