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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_codec.dart';
import 'package:weblibre/features/app_update/data/providers.dart';
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';
import 'package:weblibre/features/app_update/domain/services/update_assessment_service.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';
import 'package:weblibre/features/app_update/presentation/screens/app_update_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

import '../fixtures.dart';

/// A Filled/Text button labelled [label].
Finder button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

/// Records what the status entry asks the updater to do.
class RecordingController extends AppUpdateController {
  final calls = <String>[];

  @override
  UpdateSnapshot? build() => null;

  @override
  Future<void> checkNow() async => calls.add('check');

  @override
  Future<void> download(String targetId) async => calls.add('download');

  @override
  Future<void> continueInstallation() async => calls.add('continue');

  @override
  Future<void> cancel() async => calls.add('cancel');
}

void main() {
  final installed = installedBuild();
  late UpdateAssessment assessment;

  setUpAll(() {
    final release = releaseJson(
      sequence: 43,
      security: 'fixesIncluded',
      notes: {
        'url': 'https://github.com/FaFre/WebLibre/releases/tag/v0.43.0',
        'summary': {
          'en': '- [Click me](https://evil.example)\n<b>bold</b> ![x](y)',
        },
      },
    );
    final catalogue = const CatalogueCodec(
      packageId: packageId,
    ).decode(utf8.encode(jsonEncode(catalogueJson(releases: [release]))));
    final selection =
        const ArtifactSelector().selectGithub(catalogue, installed)
            as TargetSelected;
    assessment = const UpdateAssessmentService().assess(
      catalogue: catalogue,
      release: selection.release,
      target: selection.target,
      installed: installed,
    );
  });

  Future<void> pump(
    WidgetTester tester,
    UpdateState state, {
    UpdatePreferences? preferences,
    DistributionPolicy policy = const GithubUpdates(),
    InstalledBuildInfo? build,
    RecordingController? controller,
    bool trustDamaged = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No native host in widget tests: there is no coordinator.
          appUpdateCoordinatorProvider.overrideWith((ref) => null),
          // The settings rows' hidden-feature gates, without a database.
          displayedGeneralSettingsProvider.overrideWithValue(
            GeneralSettings.withDefaults(),
          ),
          if (controller != null)
            appUpdateControllerProvider.overrideWith(() => controller),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppUpdateSettingsBody(
              snapshot: UpdateSnapshot.initial.copyWith(
                state: state,
                preferences: preferences ?? UpdatePreferences.defaults,
                lastSuccess: DateTime.utc(2026, 11, 12, 6),
                trustDamaged: trustDamaged,
              ),
              policy: policy,
              installed: build ?? installed,
              onOpenUrl: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // Every row of the 8.1 status table: headline and action.
  final rows = <String, (UpdateState Function(), String, String?)>{
    'idle': (() => UpdateIdle(), 'Not checked yet', 'Check now'),
    'upToDate': (() => UpdateUpToDate(), 'WebLibre is up to date', 'Check now'),
    'checking': (() => UpdateChecking(), 'Checking for updates…', null),
    'available': (
      () => UpdateAvailable(assessment),
      'Version 0.43.0 is available',
      'Download',
    ),
    'available, partial': (
      () => UpdateAvailable(assessment, partialBytes: 400),
      'Version 0.43.0 is available',
      'Continue download',
    ),
    'downloading': (
      () => UpdateDownloading(assessment, received: 10, total: 100),
      'Downloading 0.43.0',
      'Cancel',
    ),
    'verifying': (
      () => UpdateVerifying(assessment),
      'Verifying download…',
      null,
    ),
    'readyToInstall': (
      () => UpdateReadyToInstall(assessment),
      'Update ready: 0.43.0',
      'Install',
    ),
    'awaitingPermission': (
      () => UpdateAwaitingPermission(assessment),
      'Allow WebLibre to install updates',
      'Allow…',
    ),
    'awaitingUserAction': (
      () => UpdateAwaitingUserAction(assessment),
      'Waiting for confirmation',
      'Continue',
    ),
    'installing after restart': (
      () => UpdateInstalling(assessment, foundAfterRestart: true),
      'Installing…',
      'Cancel installation',
    ),
    'failed, retryable': (
      () => UpdateFailed(
        UpdateFailure(UpdateFailureKind.network),
        returnTo: UpdateAvailable(assessment),
        operation: UpdateOperation.check,
      ),
      "Couldn't reach the update server. Check the connection and try again.",
      'Retry',
    ),
    'failed, not retryable': (
      () => UpdateFailed(
        UpdateFailure(UpdateFailureKind.noCompatibleTarget),
        returnTo: UpdateUpToDate(),
        operation: UpdateOperation.check,
      ),
      'A new version exists, but not for this device or build.',
      'Check now',
    ),
    'failed, trust damaged': (
      () => UpdateFailed(
        UpdateFailure(UpdateFailureKind.stateCorrupt),
        returnTo: UpdateIdle(),
        operation: UpdateOperation.check,
      ),
      'Update verification data was damaged. Reset it to check again.',
      'Reset and check again',
    ),
  };

  for (final MapEntry(key: name, value: (state, headline, action))
      in rows.entries) {
    testWidgets('status entry: $name', (tester) async {
      await pump(tester, state());
      expect(find.text(headline), findsOneWidget);
      if (action != null) {
        expect(button(action), findsOneWidget);
      }
    });
  }

  group('a failure is headed by the step that failed, its reason below', () {
    final cases = <UpdateOperation, String>{
      UpdateOperation.check: "Couldn't check for updates",
      UpdateOperation.download: "Couldn't download the update",
      UpdateOperation.install: "Couldn't install the update",
      UpdateOperation.cancelInstallation: "Couldn't cancel the installation",
    };

    for (final MapEntry(key: operation, value: headline) in cases.entries) {
      testWidgets(operation.name, (tester) async {
        await pump(
          tester,
          UpdateFailed(
            UpdateFailure(UpdateFailureKind.network),
            returnTo: UpdateAvailable(assessment),
            operation: operation,
          ),
        );
        expect(find.text(headline), findsOneWidget);
        expect(
          find.text(
            "Couldn't reach the update server. Check the connection and try "
            'again.',
          ),
          findsOneWidget,
        );
      });
    }
  });

  testWidgets('the status names the installed version', (tester) async {
    await pump(tester, UpdateUpToDate());
    expect(find.text('Installed: ${installed.versionName}'), findsOneWidget);
  });

  group('Retry repeats the operation that failed', () {
    final network = UpdateFailure(UpdateFailureKind.network);

    final cases = <String, (UpdateFailed Function(), List<String>)>{
      'a failed check over an available update checks again': (
        () => UpdateFailed(
          network,
          returnTo: UpdateAvailable(assessment),
          operation: UpdateOperation.check,
        ),
        ['check'],
      ),
      'a failed check over a staged update checks again': (
        () => UpdateFailed(
          network,
          returnTo: UpdateReadyToInstall(assessment),
          operation: UpdateOperation.check,
        ),
        ['check'],
      ),
      'a failed download downloads again': (
        () => UpdateFailed(
          network,
          returnTo: UpdateAvailable(assessment, partialBytes: 10),
          operation: UpdateOperation.download,
        ),
        ['download'],
      ),
      'a failed Continue continues the waiting session': (
        () => UpdateFailed(
          UpdateFailure(UpdateFailureKind.installUnknown),
          returnTo: UpdateAwaitingUserAction(assessment),
          operation: UpdateOperation.install,
        ),
        ['continue'],
      ),
      'a failed cancel cancels again': (
        () => UpdateFailed(
          UpdateFailure(UpdateFailureKind.installUnknown),
          returnTo: UpdateInstalling(assessment, foundAfterRestart: true),
          operation: UpdateOperation.cancelInstallation,
        ),
        ['cancel'],
      ),
    };

    for (final MapEntry(key: name, value: (state, calls)) in cases.entries) {
      testWidgets(name, (tester) async {
        final controller = RecordingController();
        await pump(tester, state(), controller: controller);
        await tester.tap(button('Retry'));
        await tester.pump();
        expect(controller.calls, calls);
      });
    }

    testWidgets('a waiting session beneath a failure can be cancelled', (
      tester,
    ) async {
      final controller = RecordingController();
      await pump(
        tester,
        UpdateFailed(
          UpdateFailure(UpdateFailureKind.installUnknown),
          returnTo: UpdateAwaitingUserAction(assessment),
          operation: UpdateOperation.install,
        ),
        controller: controller,
      );
      await tester.tap(button('Cancel'));
      await tester.pump();
      expect(controller.calls, ['cancel']);
    });
  });

  testWidgets('Play: damaged descriptions keep Restart beside the reset', (
    tester,
  ) async {
    await pump(
      tester,
      UpdateReadyToInstall(assessment),
      policy: const PlayUpdates(),
      trustDamaged: true,
    );
    expect(button('Restart'), findsOneWidget);
    expect(button('Reset and check again'), findsOneWidget);
  });

  testWidgets('an updater that could not be set up says so, with Retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          distributionPolicyProvider.overrideWithValue(
            const AsyncData(GithubUpdates()),
          ),
          installedBuildInfoProvider.overrideWithValue(AsyncData(installed)),
          appUpdateCoordinatorProvider.overrideWith(
            (ref) => Future.error(StateError('no directories')),
          ),
          displayedGeneralSettingsProvider.overrideWithValue(
            GeneralSettings.withDefaults(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppUpdateSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });

  group('a non-retryable failure over a session that holds the slot', () {
    UpdateFailed over(UpdateState session) => UpdateFailed(
      UpdateFailure(UpdateFailureKind.apkInvalid),
      returnTo: session,
      operation: UpdateOperation.install,
    );

    testWidgets('a waiting session offers Continue, not Check now', (
      tester,
    ) async {
      final controller = RecordingController();
      await pump(
        tester,
        over(UpdateAwaitingUserAction(assessment)),
        controller: controller,
      );
      expect(button('Check now'), findsNothing);
      await tester.tap(button('Continue'));
      expect(controller.calls, ['continue']);
    });

    testWidgets('a running installation offers no check', (tester) async {
      await pump(tester, over(UpdateInstalling(assessment)));
      expect(button('Check now'), findsNothing);
    });
  });

  testWidgets('installing without a restart offers no cancel', (tester) async {
    await pump(tester, UpdateInstalling(assessment));
    expect(find.text('Cancel installation'), findsNothing);
  });

  testWidgets('Play: ready means Restart', (tester) async {
    await pump(
      tester,
      UpdateReadyToInstall(assessment),
      policy: const PlayUpdates(),
    );
    expect(button('Restart'), findsOneWidget);
  });

  testWidgets('security fixes and component changes are shown', (tester) async {
    await pump(tester, UpdateAvailable(assessment));
    expect(find.text('Includes security fixes'), findsOneWidget);
    expect(find.text('What changes'), findsOneWidget);
    expect(find.text('Gecko'), findsOneWidget);
  });

  testWidgets('no verified description: details unavailable, still offered', (
    tester,
  ) async {
    final undescribed = const UpdateAssessmentService().undescribed(
      versionCode: 43,
    );
    await pump(
      tester,
      UpdateAvailable(undescribed),
      policy: const PlayUpdates(),
    );
    expect(
      find.text("Details for this version aren't available"),
      findsOneWidget,
    );
    expect(button('Download'), findsOneWidget);
  });

  testWidgets(
    'release notes are literal text and nothing in them is tappable',
    (tester) async {
      await pump(tester, UpdateAvailable(assessment));
      final notes = find.byKey(const ValueKey('release-notes-0.43.0'));
      expect(notes, findsOneWidget);
      expect(
        tester.widget<Text>(notes).data,
        '- [Click me](https://evil.example)\n<b>bold</b> ![x](y)',
      );
      expect(
        find.descendant(of: notes, matching: find.byType(GestureDetector)),
        findsNothing,
      );
      expect(find.text('Full release notes'), findsOneWidget);
    },
  );

  testWidgets('unreadable preferences ask, with both answers', (tester) async {
    await pump(tester, UpdateIdle(), preferences: UpdatePreferences.recovered);
    expect(
      find.text(
        "Update settings couldn't be read, so automatic checks are off.",
      ),
      findsOneWidget,
    );
    expect(find.text('Turn on automatic checks'), findsOneWidget);
    expect(find.text('Keep off'), findsOneWidget);
  });

  group('installed by another app (8.1)', () {
    const line = ValueKey('installed-by-other');

    testWidgets('shown for a third-party installer', (tester) async {
      await pump(
        tester,
        UpdateIdle(),
        build: installedBuild(installerPackage: 'dev.imranr.obtainium'),
      );
      expect(find.byKey(line), findsOneWidget);
    });

    for (final (name, build) in [
      (
        'self',
        installedBuild(installerPackage: packageId, installerIsSelf: true),
      ),
      ('unknown', installedBuild()),
      (
        'the system installer',
        installedBuild(
          installerPackage: 'com.google.android.packageinstaller',
          installerIsSystem: true,
        ),
      ),
    ]) {
      testWidgets('absent for $name', (tester) async {
        await pump(tester, UpdateIdle(), build: build);
        expect(find.byKey(line), findsNothing);
      });
    }

    testWidgets('absent on Play builds', (tester) async {
      await pump(
        tester,
        UpdateIdle(),
        policy: const PlayUpdates(),
        build: installedBuild(installerPackage: 'com.android.vending'),
      );
      expect(find.byKey(line), findsNothing);
    });
  });
}
