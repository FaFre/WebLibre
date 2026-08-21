import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_bootstrap.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

const _profileA = '0199a0b1-1111-7111-8111-111111111111';
const _profileB = '0199a0b1-2222-7222-8222-222222222222';

/// Points `path_provider` at a temp tree so `filesystem` can run off-device.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.root);

  final Directory root;

  Directory _sub(String name) =>
      Directory(p.join(root.path, name))..createSync(recursive: true);

  @override
  Future<String?> getApplicationSupportPath() async => _sub('files').path;

  @override
  Future<String?> getTemporaryPath() async => _sub('cache').path;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      _sub('app_flutter').path;
}

/// Stands in for the native arbiter. Records what Dart asked it to do, which is
/// the half of the contract that matters here: Dart must never commit without a
/// lease, nor keep one it did not use.
class _FakeProfileApi implements GeckoProfileApi {
  _FakeProfileApi(
    this.directive, {
    this.commitSucceeds = true,
    this.accessHeldBy,
    this.reArbitrated,
  });

  final ProfileStartupDirective? directive;
  final bool commitSucceeds;

  /// Answer for every `beginStartup` after the first. A refused commit sends
  /// `commitChosenProfile` back to native, and what native says the second time is
  /// the whole question. Null repeats the first answer.
  final ProfileStartupDirective? reArbitrated;

  int beginStartupCalls = 0;

  /// Engine id of a different isolate already holding the access lease.
  String? accessHeldBy;

  final List<String> committed = [];
  final List<String> released = [];
  final List<String> accessClaims = [];
  final List<String> accessReleases = [];
  final List<ProfileStartupPromptMode> promptModes = [];
  final List<String?> armedRestarts = [];

  // Pigeon's generated host API exposes its transport as instance getters; a
  // fake has to satisfy them even though it never sends a message.
  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';

  @override
  Future<ProfileStartupDirective> beginStartup(
    ProfileStartupOwnerType ownerType,
    String engineId,
    ProfileStartupPromptMode promptMode,
  ) async {
    promptModes.add(promptMode);
    beginStartupCalls++;
    final answer = (beginStartupCalls > 1 ? reArbitrated : null) ?? directive;
    if (answer == null) {
      throw StateError('no arbiter in this process');
    }
    return answer;
  }

  @override
  Future<bool> commitSelection(String leaseId, String profileId) async {
    if (commitSucceeds) committed.add(profileId);
    return commitSucceeds;
  }

  @override
  Future<bool> releaseSelection(String leaseId, String reason) async {
    released.add(reason);
    return true;
  }

  @override
  Future<bool> heartbeatSelection(String leaseId) async => true;

  @override
  Future<bool> heartbeatMaintenance(String leaseId) async => true;

  @override
  Future<bool> holdMaintenanceHeartbeat(String leaseId, bool held) async =>
      true;

  @override
  Future<bool> assertMaintenanceLease(
    String leaseId,
    String? taskId,
    String boundary,
  ) async => true;

  @override
  Future<bool> suspendMaintenance(String leaseId, String? taskId) async => true;

  /// Makes `finishMaintenance` fail, which is the one path out of
  /// `finishMaintenanceAndResolve` that halts without re-arbitrating.
  bool finishMaintenanceThrows = false;

  final List<String> maintenanceFinishes = [];

  @override
  Future<bool> finishMaintenance(String leaseId) async {
    maintenanceFinishes.add(leaseId);
    if (finishMaintenanceThrows) {
      throw PlatformException(code: 'no-arbiter');
    }
    return true;
  }

  @override
  Future<bool> armProfileRestart(String? targetProfileId, String reason) async {
    armedRestarts.add(targetProfileId);
    return true;
  }

  @override
  Future<void> completeProfileRestart() async {}

  @override
  Future<int?> getAvailableBytes(String path) async => null;

  @override
  Future<bool> syncDirectory(String path) async => true;

  @override
  Future<List<StartupIntentRecord>> claimStartupIntents(
    String engineId,
  ) async => const [];

  @override
  Future<bool> acknowledgeStartupIntent(
    String entryId,
    String engineId,
  ) async => true;

  @override
  Future<bool> releaseStartupIntent(String entryId, String engineId) async =>
      true;

  @override
  Future<List<String>> listMaintenanceParticipants() async => const [];

  @override
  Future<bool> runMaintenanceParticipantStep(
    String participantId,
    ParticipantStep step,
    String taskId,
    String profileId,
    String journalKind,
    String workDirPath,
  ) async => true;

  @override
  Future<bool> claimProfileAccess(
    ProfileStartupOwnerType ownerType,
    String engineId,
    String? taskId,
  ) async {
    accessClaims.add(engineId);
    final holder = accessHeldBy;
    if (holder != null && holder != engineId) return false;
    accessHeldBy = engineId;
    return true;
  }

  @override
  Future<bool> releaseProfileAccess(
    ProfileStartupOwnerType ownerType,
    String engineId,
    String? taskId,
  ) async {
    accessReleases.add(engineId);
    if (accessHeldBy != engineId) return false;
    accessHeldBy = null;
    return true;
  }

  @override
  Future<String?> getCommittedProfileId() async => null;

  @override
  Future<String?> getBoundProfileFolder() async => null;
}

void main() {
  late Directory root;
  late StartupPaths paths;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    root = await Directory.systemTemp.createTemp('weblibre_startup');
    PathProviderPlatform.instance = _FakePathProvider(root);
    filesystem.resetForTest();

    paths = StartupPaths(Directory(p.join(root.path, 'files')));
    await paths.ensureGlobalDirectories();
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  Future<void> writeProfile(String id) async {
    final dir = Directory(
      p.join(paths.profilesDir.path, '${fs.profileDirPrefix}$id'),
    );
    await dir.create(recursive: true);
    await File(
      p.join(dir.path, fs.profileMetadataFileName),
    ).writeAsString(jsonEncode(Profile(id: id, name: 'Profile').toJson()));
  }

  Future<void> writeIncompleteJournal(String taskId) async {
    final journal = MaintenanceJournal(
      taskId: taskId,
      kindId: MaintenanceJournalKind.restore.name,
      phaseId: RestorePhase.oldMoved.name,
      targetProfileId: _profileA,
      updatedAt: DateTime.utc(2026, 8, 18),
    );
    await paths.journalFile(taskId).writeAsString(jsonEncode(journal.toJson()));
  }

  Future<StartupPhase> run(
    _FakeProfileApi api, {
    ProfileStartupOwnerType ownerType = ProfileStartupOwnerType.ui,
    Duration accessWaitBudget = Duration.zero,
  }) => resolveStartupPhase(
    ownerType: ownerType,
    profileService: GeckoProfileService(api: api),
    engineId: 'engine-1',
    accessWaitBudget: accessWaitBudget,
    accessRetryDelay: const Duration(milliseconds: 1),
  );

  ProfileStartupDirective directive(
    ProfileStartupDirectiveKind kind, {
    String? profileId,
    String? candidateProfileId,
    String? leaseId,
    String? maintenanceTaskId,
    bool recoveryRequired = false,
    String? reason,
    bool showPicker = false,
  }) => ProfileStartupDirective(
    kind: kind,
    showPicker: showPicker,
    profileId: profileId,
    candidateProfileId: candidateProfileId,
    leaseId: leaseId,
    maintenanceTaskId: maintenanceTaskId,
    recoveryRequired: recoveryRequired,
    reason: reason,
  );

  group('filesystem split', () {
    test('initializeGlobalPaths touches no profile directory', () async {
      await filesystem.initializeGlobalPaths();

      expect(paths.profilesDir.existsSync(), isTrue);
      expect(paths.maintenanceJournalsDir.existsSync(), isTrue);
      expect(paths.profilesDir.listSync(), isEmpty);
      expect(paths.currentProfileFile.existsSync(), isFalse);
      expect(filesystem.isActivated, isFalse);
    });

    test('profile-bound getters name the missing precondition', () async {
      await filesystem.initializeGlobalPaths();

      expect(
        () => filesystem.selectedProfile,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('no profile is activated'),
          ),
        ),
      );
    });

    test('discovery refuses to run without a lease', () async {
      await filesystem.initializeGlobalPaths();

      expect(
        () => filesystem.discoverProfiles(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('first-run discovery creates Default but commits nothing', () async {
      await filesystem.initializeGlobalPaths();

      final found = await filesystem.discoverProfiles('lease-1');

      expect(found.profiles, hasLength(1));
      expect(found.profiles.single.name, 'Default');
      // The commit is native's to make, and it is what writes this file.
      expect(paths.currentProfileFile.existsSync(), isFalse);
      expect(filesystem.isActivated, isFalse);
    });

    test('activate binds the profile and its databases directory', () async {
      await filesystem.initializeGlobalPaths();
      await writeProfile(_profileA);

      await filesystem.activate(UuidValue.withValidation(_profileA));

      expect(filesystem.selectedProfile.uuid, _profileA);
      expect(filesystem.profileDatabasesDir.existsSync(), isTrue);
      expect(filesystem.relativeProfilePath, contains(_profileA));
    });

    test('activate refuses to rebind the process', () async {
      await filesystem.initializeGlobalPaths();
      await writeProfile(_profileA);
      await writeProfile(_profileB);

      await filesystem.activate(UuidValue.withValidation(_profileA));

      expect(
        () => filesystem.activate(UuidValue.withValidation(_profileB)),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('immutable'),
          ),
        ),
      );
    });

    test('re-activating the same profile is a no-op', () async {
      await filesystem.initializeGlobalPaths();
      await writeProfile(_profileA);

      await filesystem.activate(UuidValue.withValidation(_profileA));
      await filesystem.activate(UuidValue.withValidation(_profileA));

      expect(filesystem.selectedProfile.uuid, _profileA);
    });
  });

  group('resolveStartupPhase', () {
    test('adopts a profile native already committed', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
      );

      final phase = await run(api);

      expect(phase, isA<StartupActivated>());
      expect(filesystem.selectedProfile.uuid, _profileA);
      expect(api.committed, isEmpty);
    });

    test('commits the native candidate under the lease', () async {
      await writeProfile(_profileA);
      await writeProfile(_profileB);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          candidateProfileId: _profileB,
          leaseId: 'lease-1',
        ),
      );

      final phase = await run(api);

      expect(phase, isA<StartupActivated>());
      expect(api.committed, [_profileB]);
      expect(filesystem.selectedProfile.uuid, _profileB);
    });

    test(
      'falls back to the oldest profile when the candidate is gone',
      () async {
        await writeProfile(_profileA);
        final api = _FakeProfileApi(
          directive(
            ProfileStartupDirectiveKind.select,
            candidateProfileId: _profileB,
            leaseId: 'lease-1',
          ),
        );

        await run(api);

        expect(api.committed, [_profileA]);
      },
    );

    test('creates and commits Default on first run', () async {
      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.select, leaseId: 'lease-1'),
      );

      final phase = await run(api);

      expect(phase, isA<StartupActivated>());
      expect(api.committed, hasLength(1));
      expect(filesystem.selectedProfile.uuid, api.committed.single);
    });

    test('a refused commit halts instead of activating anyway', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          candidateProfileId: _profileA,
          leaseId: 'lease-1',
        ),
        commitSucceeds: false,
      );

      final phase = await run(api);

      expect(
        phase,
        isA<StartupHalted>().having(
          (halt) => halt.kind,
          'kind',
          StartupHaltKind.arbitrationFailed,
        ),
      );
      expect(filesystem.isActivated, isFalse);
    });

    test('a selection without a lease is refused, not improvised', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          candidateProfileId: _profileA,
        ),
      );

      final phase = await run(api);

      expect(phase, isA<StartupHalted>());
      expect(filesystem.isActivated, isFalse);
    });

    test('maintenance becomes a runnable phase, not a dead end', () async {
      await writeProfile(_profileA);
      await writeIncompleteJournal('task-1');
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.maintenance,
          leaseId: 'lease-1',
          maintenanceTaskId: 'task-1',
          recoveryRequired: true,
        ),
      );

      final phase = await run(api);

      expect(
        phase,
        isA<StartupMaintenanceRequired>()
            .having((phase) => phase.leaseId, 'leaseId', 'lease-1')
            .having((phase) => phase.taskId, 'taskId', 'task-1')
            .having((phase) => phase.recoveryRequired, 'recovery', isTrue),
      );
      // The decisive part: nothing bound, created, or healed a profile.
      expect(filesystem.isActivated, isFalse);
      expect(paths.currentProfileFile.existsSync(), isFalse);
      // The lease stays out while the work is pending.
      expect(api.accessHeldBy, 'engine-1');
    });

    test('maintenance without a lease is a halt, not a silent boot', () async {
      await writeProfile(_profileA);
      await writeIncompleteJournal('task-1');
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.maintenance,
          maintenanceTaskId: 'task-1',
        ),
      );

      final phase = await run(api);

      expect(
        phase,
        isA<StartupHalted>().having(
          (halt) => halt.kind,
          'kind',
          StartupHaltKind.maintenance,
        ),
      );
      expect(filesystem.isActivated, isFalse);
    });

    test('a first run under maintenance does not create Default', () async {
      await writeIncompleteJournal('task-1');
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.maintenance,
          leaseId: 'lease-1',
          maintenanceTaskId: 'task-1',
        ),
      );

      await run(api);

      expect(paths.profilesDir.listSync().whereType<Directory>(), isEmpty);
    });

    test(
      'an unavailable decision never falls back to current_profile',
      () async {
        await writeProfile(_profileA);
        await fs.writeStartupProfile(
          paths.profilesDir,
          UuidValue.withValidation(_profileA),
        );
        final api = _FakeProfileApi(
          directive(
            ProfileStartupDirectiveKind.unavailable,
            reason: 'selection owned by engine-2',
          ),
        );

        final phase = await run(api);

        expect(
          phase,
          isA<StartupHalted>().having(
            (halt) => halt.kind,
            'kind',
            StartupHaltKind.unavailable,
          ),
        );
        expect(filesystem.isActivated, isFalse);
      },
    );

    test('an unreachable arbiter fails closed', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(null);

      final phase = await run(api);

      expect(
        phase,
        isA<StartupHalted>().having(
          (halt) => halt.kind,
          'kind',
          StartupHaltKind.arbitrationFailed,
        ),
      );
      expect(filesystem.isActivated, isFalse);
    });
  });

  group('profile access lease', () {
    test('a successful start keeps the lease', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
      );

      await run(api);

      expect(api.accessHeldBy, 'engine-1');
      expect(api.accessReleases, isEmpty);
    });

    test('a halted start gives the lease back', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.unavailable,
          reason: 'selection owned by engine-2',
        ),
      );

      await run(api);

      expect(api.accessHeldBy, isNull);
      expect(api.accessReleases, ['engine-1']);
    });

    test('a busy lease stops startup before it arbitrates', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
        accessHeldBy: 'engine-2',
      );

      final phase = await run(api);

      expect(
        phase,
        isA<StartupHalted>().having(
          (halt) => halt.kind,
          'kind',
          StartupHaltKind.profileAccessBusy,
        ),
      );
      expect(filesystem.isActivated, isFalse);
      // Not even asked: without the lease there is nothing to arbitrate for.
      expect(api.committed, isEmpty);
    });

    test('the UI retries within its budget, a headless run does not', () async {
      await writeProfile(_profileA);

      final headless = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
        accessHeldBy: 'engine-2',
      );
      await run(headless, ownerType: ProfileStartupOwnerType.headless);
      expect(headless.accessClaims, hasLength(1));

      final ui = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
        accessHeldBy: 'engine-2',
      );
      await run(ui, accessWaitBudget: const Duration(milliseconds: 10));
      expect(ui.accessClaims.length, greaterThan(1));
    });
  });

  group('startup picker', () {
    test('a picker directive stops before committing anything', () async {
      await writeProfile(_profileA);
      await writeProfile(_profileB);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          candidateProfileId: _profileB,
          leaseId: 'lease-1',
          showPicker: true,
        ),
      );

      final phase = await run(api);

      expect(
        phase,
        isA<StartupSelectionRequired>()
            .having((phase) => phase.leaseId, 'leaseId', 'lease-1')
            .having((phase) => phase.profiles, 'profiles', hasLength(2))
            .having(
              (phase) => phase.candidateProfileId,
              'candidate',
              _profileB,
            ),
      );
      expect(api.committed, isEmpty);
      expect(filesystem.isActivated, isFalse);
      // The lease is still out: the user has not answered yet.
      expect(api.released, isEmpty);
      expect(api.accessHeldBy, 'engine-1');
    });

    test('one profile is not a choice, so it commits instead', () async {
      // Native counts profiles before discovery may have created the first-run
      // one, so Dart re-checks rather than prompting for a list of one.
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          leaseId: 'lease-1',
          showPicker: true,
        ),
      );

      final phase = await run(api);

      expect(phase, isA<StartupActivated>());
      expect(api.committed, [_profileA]);
    });

    test('the chosen profile is committed and activated', () async {
      await writeProfile(_profileA);
      await writeProfile(_profileB);
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          candidateProfileId: _profileA,
          leaseId: 'lease-1',
          showPicker: true,
        ),
      );

      await run(api);

      final phase = await commitChosenProfile(
        leaseId: 'lease-1',
        profileId: UuidValue.withValidation(_profileB),
        profileService: GeckoProfileService(api: api),
        engineId: 'engine-1',
      );

      expect(phase, isA<StartupActivated>());
      expect(api.committed, [_profileB]);
      expect(filesystem.selectedProfile.uuid, _profileB);
    });

    test('a refused commit adopts the profile native settled on', () async {
      await writeProfile(_profileA);
      await writeProfile(_profileB);
      // Native refuses a commit whose selection is no longer live — the watchdog
      // expired it, or a trusted launch answered it while the picker was up. The
      // decision has still been *made*, so asking again is what turns a dead end
      // into the profile the process should boot.
      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.select,
          leaseId: 'lease-1',
          showPicker: true,
        ),
        commitSucceeds: false,
        reArbitrated: directive(
          ProfileStartupDirectiveKind.committed,
          profileId: _profileA,
        ),
      );

      await run(api);

      final phase = await commitChosenProfile(
        leaseId: 'lease-1',
        profileId: UuidValue.withValidation(_profileB),
        profileService: GeckoProfileService(api: api),
        engineId: 'engine-1',
      );

      expect(phase, isA<StartupActivated>());
      expect(filesystem.selectedProfile.uuid, _profileA);
      // Still held: this process is booting, so it keeps the access lease.
      expect(api.accessHeldBy, 'engine-1');
    });

    test(
      'a refused commit native cannot answer gives the lease back',
      () async {
        await writeProfile(_profileA);
        await writeProfile(_profileB);
        final api = _FakeProfileApi(
          directive(
            ProfileStartupDirectiveKind.select,
            leaseId: 'lease-1',
            showPicker: true,
          ),
          commitSucceeds: false,
          reArbitrated: directive(
            ProfileStartupDirectiveKind.unavailable,
            reason: 'another owner holds the decision',
          ),
        );

        await run(api);

        final phase = await commitChosenProfile(
          leaseId: 'lease-1',
          profileId: UuidValue.withValidation(_profileB),
          profileService: GeckoProfileService(api: api),
          engineId: 'engine-1',
        );

        expect(phase, isA<StartupHalted>());
        expect(filesystem.isActivated, isFalse);
        expect(api.accessHeldBy, isNull);
      },
    );

    test('the prompt setting reaches native', () async {
      await writeProfile(_profileA);
      await filesystem.initializeGlobalPaths();
      await StartupConfigStore(
        filesystem.startupPaths,
      ).setProfilePrompt(ProfilePromptMode.browserOnly);

      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
      );

      await run(api);

      expect(api.promptModes, [ProfileStartupPromptMode.browserOnly]);
    });

    test('finishing maintenance into a halt releases profile access', () async {
      // The lease was taken by the `resolveStartup` that produced the
      // maintenance phase and held across the screen. A re-arbitration that ends
      // in a halt means this process is doing no more work, so keeping it would
      // refuse every headless isolate in the process for the rest of its life.
      await writeProfile(_profileA);
      await filesystem.initializeGlobalPaths();

      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.unavailable,
          reason: 'another owner holds the decision',
        ),
      )..accessHeldBy = 'engine-1';

      final phase = await finishMaintenanceAndResolve(
        leaseId: 'lease-1',
        profileService: GeckoProfileService(api: api),
        engineId: 'engine-1',
      );

      expect(phase, isA<StartupHalted>());
      expect(api.accessReleases, ['engine-1']);
      expect(api.accessHeldBy, isNull);
    });

    test(
      'a maintenance lease that will not release still hands access back',
      () async {
        await writeProfile(_profileA);
        await filesystem.initializeGlobalPaths();

        final api =
            _FakeProfileApi(
                directive(
                  ProfileStartupDirectiveKind.committed,
                  profileId: _profileA,
                ),
              )
              ..accessHeldBy = 'engine-1'
              ..finishMaintenanceThrows = true;

        final phase = await finishMaintenanceAndResolve(
          leaseId: 'lease-1',
          profileService: GeckoProfileService(api: api),
          engineId: 'engine-1',
        );

        expect(
          phase,
          isA<StartupHalted>().having(
            (halt) => halt.kind,
            'kind',
            StartupHaltKind.arbitrationFailed,
          ),
        );
        // Never re-arbitrated: the reservation is still held natively.
        expect(api.beginStartupCalls, 0);
        expect(api.accessHeldBy, isNull);
      },
    );

    test('finishing maintenance into a boot keeps the access lease', () async {
      // The mirror image, and the reason the release cannot simply be
      // unconditional: the process is about to open the profile under it.
      await writeProfile(_profileA);
      await filesystem.initializeGlobalPaths();

      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
      )..accessHeldBy = 'engine-1';

      final phase = await finishMaintenanceAndResolve(
        leaseId: 'lease-1',
        profileService: GeckoProfileService(api: api),
        engineId: 'engine-1',
      );

      expect(phase, isA<StartupActivated>());
      expect(api.accessReleases, isEmpty);
      expect(api.accessHeldBy, 'engine-1');
    });

    test('maintenance handed straight back keeps the access lease', () async {
      // Native refusing to let go of the reservation is not a halt — the screen
      // renders again and goes on working under the same lease.
      await writeProfile(_profileA);
      await filesystem.initializeGlobalPaths();
      await writeIncompleteJournal('task-1');

      final api = _FakeProfileApi(
        directive(
          ProfileStartupDirectiveKind.maintenance,
          leaseId: 'lease-2',
          maintenanceTaskId: 'task-1',
        ),
      )..accessHeldBy = 'engine-1';

      final phase = await finishMaintenanceAndResolve(
        leaseId: 'lease-1',
        profileService: GeckoProfileService(api: api),
        engineId: 'engine-1',
      );

      expect(phase, isA<StartupMaintenanceRequired>());
      expect((phase as StartupMaintenanceRequired).blocking, isTrue);
      expect(api.accessReleases, isEmpty);
      expect(api.accessHeldBy, 'engine-1');
    });

    test('the prompt setting defaults to never asking', () async {
      await writeProfile(_profileA);
      final api = _FakeProfileApi(
        directive(ProfileStartupDirectiveKind.committed, profileId: _profileA),
      );

      await run(api);

      expect(api.promptModes, [ProfileStartupPromptMode.off]);
    });
  });
}
