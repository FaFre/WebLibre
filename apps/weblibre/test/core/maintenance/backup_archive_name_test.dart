import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/maintenance/backup_archive_name.dart';
import 'package:weblibre/core/maintenance/backup_manifest.dart';

void main() {
  _manifestTolerance();

  test('a produced name parses back to what produced it', () {
    // The regression this guards: the runner and the backup list each had their
    // own idea of the format, so every archive listed without a profile or date.
    final at = DateTime(2026, 8, 19, 13, 1, 45);
    final name = backupArchiveName(profileName: 'Default', at: at);

    expect(name, 'backup_Default_2026-08-19_130145.weblibre');

    final parsed = BackupArchiveName.tryParse(name)!;
    expect(parsed.profileName, 'Default');
    expect(parsed.createdAt, at);
  });

  test('a profile name containing underscores survives the round trip', () {
    final at = DateTime(2026, 8, 19, 13, 1, 45);
    final name = backupArchiveName(profileName: 'work_and_home', at: at);

    final parsed = BackupArchiveName.tryParse(name)!;
    expect(parsed.profileName, 'work_and_home');
    expect(parsed.createdAt, at);
  });

  test('the timestamp is local, not UTC', () {
    // The name is read by a person looking for the backup they took at four.
    final at = DateTime(2026, 1, 2, 16, 30);
    expect(backupArchiveName(profileName: 'p', at: at), contains('_163000.'));
  });

  test('names that are not backups do not parse', () {
    expect(BackupArchiveName.tryParse('notes.txt'), isNull);
    expect(BackupArchiveName.tryParse('backup_Default.weblibre'), isNull);
    // The shape the runner used to emit.
    expect(
      BackupArchiveName.tryParse(
        'backup_Default_2026-08-19_13-01-45-123Z.weblibre',
      ),
      isNull,
    );
  });
}

/// The manifest is read out of an archive the user supplies, so the same rule
/// as the journal applies: a wrong-typed field degrades to a default rather
/// than throwing in the middle of a restore.
void _manifestTolerance() {
  group('malformed manifest fields', () {
    test('wrong-typed scalars fall back instead of throwing', () {
      final manifest = BackupManifest.fromJson({
        'version': '1',
        'profileId': 7,
        'profileName': false,
        'createdAt': 12345,
        'sourceBytes': '900',
        'entryCount': null,
        'archiveSha256': 42,
      });

      expect(manifest.version, backupManifestVersion);
      expect(manifest.profileId, '');
      expect(manifest.profileName, '');
      expect(manifest.sourceBytes, 0);
      expect(manifest.entryCount, 0);
      expect(manifest.archiveSha256, isNull);
      expect(
        manifest.createdAt,
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    });

    test('a wrong-typed exclusion entry falls back instead of throwing', () {
      final manifest = BackupManifest.fromJson({
        'profileId': 'p',
        'profileName': 'n',
        'createdAt': DateTime.utc(2026).toIso8601String(),
        'sourceBytes': 1,
        'entryCount': 1,
        'exclusions': [
          {'path': 5, 'reason': null, 'recreatedOnRestore': 'yes'},
        ],
      });

      final exclusion = manifest.exclusions.single;
      expect(exclusion.path, '');
      expect(exclusion.reason, '');
      expect(exclusion.recreatedOnRestore, isFalse);
    });
  });
}
