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
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/services/staged_file_policy.dart';
import 'package:weblibre/features/app_update/domain/services/update_assessment_service.dart';
import 'package:weblibre/features/app_update/domain/services/update_surface_policy.dart';

import '../fixtures.dart';

void main() {
  group('distribution policy (3.5)', () {
    DistributionPolicy derive(InstalledBuildInfo build, {bool keys = true}) =>
        DistributionPolicy.derive(build, trustedKeysCompiled: keys);

    test('github → github, play → play', () {
      expect(derive(installedBuild()), isA<GithubUpdates>());
      expect(
        derive(installedBuild(distribution: Distribution.play)),
        isA<PlayUpdates>(),
      );
    });

    test('debug, fdroid and foreign-signed builds have no updater (D8)', () {
      expect(derive(installedBuild(debugBuild: true)), isA<NoUpdates>());
      expect(
        derive(installedBuild(distribution: Distribution.fdroid)),
        isA<NoUpdates>(),
      );
      expect(derive(installedBuild(signerTrusted: false)), isA<NoUpdates>());
      expect(
        derive(
          installedBuild(distribution: Distribution.play, signerTrusted: false),
        ),
        isA<NoUpdates>(),
      );
    });

    test('a GitHub build without compiled metadata keys has no updater', () {
      expect(derive(installedBuild(), keys: false), isA<NoUpdates>());
      expect(
        derive(installedBuild(distribution: Distribution.play), keys: false),
        isA<PlayUpdates>(),
      );
    });

    test('the installer of record is never an input', () {
      for (final installer in [
        null,
        'com.android.vending',
        'dev.imranr.obtainium',
      ]) {
        expect(
          derive(installedBuild(installerPackage: installer)),
          isA<GithubUpdates>(),
        );
      }
    });
  });

  group('staged-file policy (6.3)', () {
    const policy = StagedFilePolicy();
    final c = catalogue([releaseJson(sequence: 43)]);
    final now = DateTime.utc(2026, 12, 2);
    StagedFile file(String sha, {DateTime? modified}) =>
        StagedFile(sha256: sha, modified: modified ?? now);

    test('a file the catalogue still selects is kept', () {
      expect(
        policy.decide(
          file(githubSha(43)),
          decidable: c,
          installed: installedBuild(),
          now: now,
        ),
        StagedFileVerdict.keep,
      );
    });

    test('withdrawn or superseded: deleted', () {
      expect(
        policy.decide(
          file(githubSha(41)),
          decidable: c,
          installed: installedBuild(),
          now: now,
        ),
        StagedFileVerdict.delete,
      );
    });

    test(
      'a digest this build could not select (other renderer) is deleted',
      () {
        expect(
          policy.decide(
            file(githubSha(43, impeller: true)),
            decidable: c,
            installed: installedBuild(),
            now: now,
          ),
          StagedFileVerdict.delete,
        );
      },
    );

    test('the installed version reached the target: deleted', () {
      expect(
        policy.decide(
          file(githubSha(43)),
          decidable: c,
          installed: installedBuild(sequence: 43),
          now: now,
        ),
        StagedFileVerdict.delete,
      );
    });

    test('nothing decidable (none, expired, offline, recovery): kept', () {
      expect(
        policy.decide(
          file(githubSha(41)),
          decidable: null,
          installed: installedBuild(),
          now: now,
        ),
        StagedFileVerdict.keep,
      );
    });

    test('kept and unused for 30 days: deleted', () {
      expect(
        policy.decide(
          file(githubSha(43), modified: now.subtract(const Duration(days: 31))),
          decidable: null,
          installed: installedBuild(),
          now: now,
        ),
        StagedFileVerdict.delete,
      );
    });

    test("only digest-named files are the updater's", () {
      expect(StagedFile.parseName('${githubSha(43)}.apk'), githubSha(43));
      expect(StagedFile.parseName('${githubSha(43)}.part'), githubSha(43));
      expect(StagedFile.parseName('../evil.apk'), isNull);
      expect(
        StagedFile.parseName('${githubSha(43).toUpperCase()}.apk'),
        isNull,
      );
    });
  });

  group('surfaces and the switch (8.2, 8.3)', () {
    const policy = UpdateSurfacePolicy();
    final assessment = const UpdateAssessmentService().undescribed(
      versionCode: 43,
    );
    final on = UpdatePreferences.defaults;
    final off = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );

    final rows = <UpdateState, (UpdateMenuRow, bool)>{
      UpdateAvailable(assessment): (UpdateMenuRow.available, true),
      UpdateDownloading(assessment, received: 1, total: 2): (
        UpdateMenuRow.downloading,
        false,
      ),
      UpdateVerifying(assessment): (UpdateMenuRow.downloading, false),
      UpdateReadyToInstall(assessment): (UpdateMenuRow.readyToInstall, true),
      UpdateAwaitingPermission(assessment): (
        UpdateMenuRow.finishInstalling,
        true,
      ),
      UpdateAwaitingUserAction(assessment): (
        UpdateMenuRow.finishInstalling,
        true,
      ),
      UpdateInstalling(assessment): (UpdateMenuRow.installing, false),
      UpdateIdle(): (UpdateMenuRow.none, false),
      UpdateChecking(): (UpdateMenuRow.none, false),
      UpdateUpToDate(): (UpdateMenuRow.none, false),
      // A failure shows what the state it returns to shows.
      UpdateFailed(
        UpdateFailure(UpdateFailureKind.network),
        returnTo: UpdateReadyToInstall(assessment),
        operation: UpdateOperation.check,
      ): (
        UpdateMenuRow.readyToInstall,
        true,
      ),
      UpdateFailed(
        UpdateFailure(UpdateFailureKind.network),
        returnTo: UpdateUpToDate(),
        operation: UpdateOperation.check,
      ): (
        UpdateMenuRow.none,
        false,
      ),
    };

    for (final MapEntry(key: state, value: (row, dot)) in rows.entries) {
      test('switch on: ${state.runtimeType}', () {
        final surface = policy.surfaceFor(state, preferences: on);
        expect(surface.row, row);
        expect(surface.dot, dot);
      });

      test('switch off: ${state.runtimeType}', () {
        final surface = policy.surfaceFor(state, preferences: off);
        if (state is UpdateAvailable) {
          // No signal for a new version.
          expect(surface, UpdateSurface.none);
        } else {
          expect(surface.row, row);
          expect(surface.dot, dot);
        }
      });
    }

    test('unreadable preferences: the row and the dot ask', () {
      final surface = policy.surfaceFor(
        UpdateIdle(),
        preferences: UpdatePreferences.recovered,
      );
      expect(surface.row, UpdateMenuRow.preferencesUnreadable);
      expect(surface.dot, isTrue);
    });

    test('progress rides along while downloading', () {
      final surface = policy.surfaceFor(
        UpdateDownloading(assessment, received: 50, total: 200),
        preferences: on,
      );
      expect(surface.progress, 0.25);
    });

    test('a description without metadata is still an update', () {
      expect(assessment.target, isNull);
      expect(assessment.componentChanges, isNull);
    });
  });
}
