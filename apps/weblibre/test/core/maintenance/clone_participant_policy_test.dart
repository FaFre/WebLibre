import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/backup_manifest.dart';
import 'package:weblibre/core/maintenance/clone_participant_policy.dart';

void main() {
  late Directory clone;

  setUp(() async {
    clone = await Directory.systemTemp.createTemp('weblibre_clone');
  });

  tearDown(() async {
    if (clone.existsSync()) {
      await clone.delete(recursive: true);
    }
  });

  Directory participantDir(String category) =>
      Directory(p.join(clone.path, participantStagingDirName, category))
        ..createSync(recursive: true);

  test('the staged credentials never reach the cloned profile', () async {
    // The archive carries the *source* profile's secure records as plain JSON —
    // refresh token, end-to-end sync key, proxy secrets. That is safe inside a
    // password-encrypted archive and not safe unpacked into a profile directory,
    // where it would sit unencrypted for the life of the clone.
    final secrets = File(
      p.join(participantDir('secureStorage').path, 'secure_storage.json'),
    )..writeAsStringSync('{"account_auth_data@p:abc":"refresh-token"}');

    await applyCloneParticipantPolicy(clone);

    expect(secrets.existsSync(), isFalse);
  });

  test('the whole participant tree is gone, not just its contents', () async {
    // A leftover directory would be re-archived by the next backup of the clone
    // — `backup_operation` skips it precisely because it can only be a leftover.
    participantDir('sharedPreferences');
    participantDir('pwaShortcuts');

    await applyCloneParticipantPolicy(clone);

    expect(
      Directory(p.join(clone.path, participantStagingDirName)).existsSync(),
      isFalse,
    );
  });

  test('a category this build does not know is dropped too', () async {
    // From an archive written by a newer version. A clone has no participant
    // that would ever read it, so keeping it is dead weight in the profile and
    // in every future backup of it.
    File(p.join(participantDir('somethingNewer').path, 'state.json'))
      ..createSync(recursive: true)
      ..writeAsStringSync('{}');

    await applyCloneParticipantPolicy(clone);

    expect(
      Directory(p.join(clone.path, participantStagingDirName)).existsSync(),
      isFalse,
    );
  });

  test('the profile data itself is untouched', () async {
    final databases = Directory(p.join(clone.path, 'databases'))
      ..createSync(recursive: true);
    File(p.join(databases.path, 'tab.db')).writeAsStringSync('tabs');
    File(p.join(clone.path, 'metadata.json')).writeAsStringSync('{}');
    participantDir('secureStorage');

    await applyCloneParticipantPolicy(clone);

    expect(File(p.join(databases.path, 'tab.db')).readAsStringSync(), 'tabs');
    expect(File(p.join(clone.path, 'metadata.json')).existsSync(), isTrue);
  });

  test('staged credentials that cannot be removed abort the clone', () async {
    // The failure this used to log and walk past. The staged payload is the
    // source profile's refresh token, sync key and proxy credentials in plain
    // JSON; carrying on would leave them unencrypted inside a brand-new profile
    // the user is told was created successfully. The caller unpacks into a
    // scratch directory and renames it into place afterwards, so throwing here
    // creates nothing at all.
    final staged = Directory(p.join(clone.path, participantStagingDirName));
    participantDir('secureStorage');
    File(
      p.join(staged.path, 'secureStorage', 'secure_storage.json'),
    ).writeAsStringSync('{"account_auth_data@p:abc":"refresh-token"}');

    // Read+execute only: the entries stay listable, and deleting them fails.
    final chmod = await Process.run('chmod', ['a-w', staged.path]);
    expect(chmod.exitCode, 0, reason: 'test needs a POSIX chmod');
    addTearDown(() => Process.run('chmod', ['u+w', staged.path]));

    await expectLater(
      applyCloneParticipantPolicy(clone),
      throwsA(isA<CloneParticipantPolicyFailure>()),
    );
  }, skip: Platform.isWindows ? 'needs POSIX permissions' : null);

  test('an archive with no participant payload is a no-op', () async {
    // Predates participants entirely.
    File(p.join(clone.path, 'metadata.json')).writeAsStringSync('{}');

    await applyCloneParticipantPolicy(clone);

    expect(File(p.join(clone.path, 'metadata.json')).existsSync(), isTrue);
  });
}
