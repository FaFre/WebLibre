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
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';

import '../fixtures.dart';

void main() {
  const selector = ArtifactSelector();

  UpdateTarget? selected(SelectionResult result) =>
      result is TargetSelected ? result.target : null;

  test('picks the exact target for package, track, renderer and ABI', () {
    final c = catalogue([releaseJson(sequence: 43)]);
    for (final abi in ['x86_64', 'armeabi-v7a', 'arm64-v8a']) {
      for (final renderer in Renderer.values) {
        final target = selected(
          selector.selectGithub(
            c,
            installedBuild(abi: abi, renderer: renderer),
          ),
        )!;
        expect(target.abi, abi);
        expect(target.renderer, renderer);
        expect(target.distribution, Distribution.github);
      }
    }
  });

  test('the highest newer release with a matching target wins', () {
    final c = catalogue([
      releaseJson(sequence: 43),
      releaseJson(sequence: 45),
      releaseJson(sequence: 44),
    ]);
    expect(
      selected(selector.selectGithub(c, installedBuild()))!.versionCode,
      453,
    );
  });

  test('nothing newer is up to date', () {
    final c = catalogue([releaseJson(sequence: 42)]);
    expect(selector.selectGithub(c, installedBuild()), isA<NothingNewer>());
  });

  test(
    'a newer release without a target for this build is noCompatibleTarget',
    () {
      final c = catalogue([releaseJson(sequence: 43, track: 'alpha')]);
      expect(
        selector.selectGithub(c, installedBuild()),
        isA<NoCompatibleTarget>(),
      );
    },
  );

  test('rejects targets above the device SDK', () {
    final c = catalogue([releaseJson(sequence: 43, minSdk: 35)]);
    expect(
      selector.selectGithub(c, installedBuild(sdkInt: 34)),
      isA<NoCompatibleTarget>(),
    );
  });

  test('never the other distribution, track or renderer', () {
    final c = catalogue([releaseJson(sequence: 43)]);
    final play = installedBuild(distribution: Distribution.play);
    final target = selected(selector.selectGithub(c, installedBuild()))!;
    expect(selector.matchesGithub(target, play), isFalse);
    expect(
      selector.matchesGithub(target, installedBuild(track: ReleaseTrack.alpha)),
      isFalse,
    );
    expect(
      selector.matchesGithub(
        target,
        installedBuild(renderer: Renderer.impeller),
      ),
      isFalse,
    );
    expect(
      selector.matchesGithub(target, installedBuild(abi: 'x86_64')),
      isFalse,
    );
  });

  test('equal version codes are never an update', () {
    final c = catalogue([releaseJson(sequence: 43)]);
    expect(
      selector.selectGithub(c, installedBuild(sequence: 42, versionCode: 433)),
      isA<NoCompatibleTarget>(),
    );
  });

  test('42x to 43x keeps the ABI digit (D4)', () {
    final c = catalogue([releaseJson(sequence: 43)]);
    for (final (abi, digit) in [
      ('x86_64', 1),
      ('armeabi-v7a', 2),
      ('arm64-v8a', 3),
    ]) {
      final installed = installedBuild(abi: abi);
      expect(installed.versionCode, 420 + digit);
      expect(
        selected(selector.selectGithub(c, installed))!.versionCode,
        430 + digit,
      );
    }
  });

  test('Play is described only on an exact version-code match', () {
    final c = catalogue([releaseJson(sequence: 43), releaseJson(sequence: 44)]);
    final play = installedBuild(distribution: Distribution.play);
    expect(
      selector.describePlay(c, play, 43)!.release.logicalReleaseSequence,
      43,
    );
    expect(selector.describePlay(c, play, 46), isNull);
  });
}
