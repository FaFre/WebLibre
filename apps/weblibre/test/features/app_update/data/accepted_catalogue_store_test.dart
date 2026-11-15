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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/app_update/data/metadata/catalogue_reader.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/data/store/accepted_catalogue_store.dart';
import 'package:weblibre/features/app_update/data/store/update_file_system.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

import '../fixtures.dart';

/// Stops after a chosen number of completed file replacements, to simulate a
/// crash at that point. With [loseLastRename], the final rename that did
/// complete is undone, as a power cut can do.
class CrashingFileSystem implements UpdateFileSystem {
  CrashingFileSystem({this.crashAfterWrites, this.loseLastRename = false});

  final int? crashAfterWrites;
  final bool loseLastRename;
  final _inner = const IoUpdateFileSystem();
  int writes = 0;

  @override
  Future<List<int>?> readBytes(String path) => _inner.readBytes(path);

  @override
  Future<void> writeAtomic(String path, List<int> bytes) async {
    if (crashAfterWrites != null && writes >= crashAfterWrites!) {
      throw const FileSystemException('simulated crash');
    }
    final previous = await _inner.readBytes(path);
    await _inner.writeAtomic(path, bytes);
    writes++;
    if (loseLastRename &&
        crashAfterWrites != null &&
        writes == crashAfterWrites) {
      if (previous == null) {
        await _inner.delete(path);
      } else {
        await _inner.writeAtomic(path, previous);
      }
    }
  }

  @override
  Future<void> delete(String path) => _inner.delete(path);

  @override
  Future<String?> preserve(String path) => _inner.preserve(path);
}

void main() {
  late Directory dir;
  late TestSigningKey key;
  late CatalogueReader reader;

  setUpAll(() async {
    key = await TestSigningKey.generate('wl-meta-2026a');
    reader = readerFor([key]);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('accepted_store');
  });

  tearDown(() => dir.delete(recursive: true));

  AcceptedCatalogueStore store([UpdateFileSystem? fs]) =>
      AcceptedCatalogueStore(
        stateDir: dir.path,
        reader: reader,
        fs: fs ?? const IoUpdateFileSystem(),
      );

  Future<AcceptedCatalogue> signed(
    int revision, {
    DateTime? issuedAt,
    int sequence = 43,
  }) async => await reader.read(
    await envelope(
      catalogueJson(
        revision: revision,
        issuedAt: issuedAt,
        releases: [releaseJson(sequence: sequence)],
      ),
      keys: [key],
    ),
  );

  File a() => File(p.join(dir.path, 'accepted_a.dsse'));
  File b() => File(p.join(dir.path, 'accepted_b.dsse'));

  int? revisionOf(AcceptedCatalogueRead read) => switch (read) {
    AcceptedCatalogueLoaded(:final accepted) => accepted.revision,
    _ => null,
  };

  test('both absent: a fresh installation', () async {
    expect(await store().open(), isA<NoAcceptedCatalogue>());
  });

  test('accepting writes both copies with the exact envelope bytes', () async {
    final c = await signed(3);
    final s = store();
    await s.open();
    await s.accept(c);
    expect(await a().readAsBytes(), c.envelopeBytes);
    expect(await b().readAsBytes(), c.envelopeBytes);
    expect(revisionOf(await store().open()), 3);
  });

  test('one copy damaged: repaired from the other', () async {
    final s = store();
    await s.open();
    await s.accept(await signed(3));
    await a().writeAsString('garbage');
    expect(revisionOf(await store().open()), 3);
    expect(await a().readAsBytes(), await b().readAsBytes());
  });

  test('one copy absent: rewritten from the other', () async {
    final s = store();
    await s.open();
    await s.accept(await signed(3));
    await b().delete();
    expect(revisionOf(await store().open()), 3);
    expect(await b().exists(), isTrue);
  });

  test(
    'different revisions: the higher wins and the other is rewritten',
    () async {
      final s = store();
      await s.open();
      await s.accept(await signed(3));
      await b().writeAsBytes((await signed(5)).envelopeBytes);
      expect(revisionOf(await store().open()), 5);
      expect(await a().readAsBytes(), await b().readAsBytes());
    },
  );

  test(
    'same revision, different payloads: fails closed and survives restarts',
    () async {
      final s = store();
      await s.open();
      await s.accept(await signed(3));
      await b().writeAsBytes((await signed(3, sequence: 44)).envelopeBytes);
      expect(await store().open(), isA<TrustRecoveryRequired>());
      expect(await store().open(), isA<TrustRecoveryRequired>());
    },
  );

  test(
    'everything damaged: recovery required, never treated as fresh',
    () async {
      await a().writeAsString('x');
      await b().writeAsString('y');
      final s = store();
      expect(await s.open(), isA<TrustRecoveryRequired>());
      await expectLater(
        s.accept(await signed(1)),
        throwsA(
          isA<UpdateFailure>().having(
            (f) => f.kind,
            'kind',
            UpdateFailureKind.stateCorrupt,
          ),
        ),
      );
      expect(await store().open(), isA<TrustRecoveryRequired>());
    },
  );

  test('a copy signed by an untrusted key is invalid', () async {
    final stranger = await TestSigningKey.generate('wl-meta-2026a');
    await a().writeAsBytes(
      await envelope(catalogueJson(revision: 9), keys: [stranger]),
    );
    expect(await store().open(), isA<TrustRecoveryRequired>());
  });

  group('a key retired by a later build (keys are per year)', () {
    late TestSigningKey retired;
    late CatalogueReader retiringReader;

    setUpAll(() async {
      retired = await TestSigningKey.generate('wl-meta-2025a');
      retiringReader = readerFor([key], retiredKeyIds: {retired.keyId});
    });

    AcceptedCatalogueStore store() => AcceptedCatalogueStore(
      stateDir: dir.path,
      reader: retiringReader,
      fs: const IoUpdateFileSystem(),
    );

    Future<List<int>> signedByRetired(int revision) =>
        envelope(catalogueJson(revision: revision), keys: [retired]);

    test('both copies: a fresh start, never recovery', () async {
      final bytes = await signedByRetired(9);
      await a().writeAsBytes(bytes);
      await b().writeAsBytes(bytes);
      final s = store();
      expect(await s.open(), isA<NoAcceptedCatalogue>());
      await s.accept(await signed(1));
      expect(revisionOf(await store().open()), 1);
    });

    test('one copy: the valid one wins and repairs it', () async {
      final s = store();
      await s.open();
      await s.accept(await signed(3));
      await b().writeAsBytes(await signedByRetired(9));
      expect(revisionOf(await store().open()), 3);
      expect(await a().readAsBytes(), await b().readAsBytes());
    });

    test('next to a damaged copy: still recovery', () async {
      await a().writeAsBytes(await signedByRetired(9));
      await b().writeAsString('garbage');
      expect(await store().open(), isA<TrustRecoveryRequired>());
    });

    test('a key ID this build never listed is damage, not absence', () async {
      // A damaged key ID looks like this: the revision floor must survive it.
      final unknown = await TestSigningKey.generate('wl-meta-2O26a');
      final bytes = await envelope(catalogueJson(revision: 9), keys: [unknown]);
      await a().writeAsBytes(bytes);
      await b().writeAsBytes(bytes);
      expect(await store().open(), isA<TrustRecoveryRequired>());
    });
  });

  test('the explicit reset is the one way to lower the floor', () async {
    final s = store();
    await s.open();
    await s.accept(await signed(7));
    await expectLater(
      s.accept(await signed(6)),
      throwsA(
        isA<UpdateFailure>().having(
          (f) => f.kind,
          'kind',
          UpdateFailureKind.metadataRollback,
        ),
      ),
    );
    await s.reset();
    expect(await store().open(), isA<NoAcceptedCatalogue>());
    await s.accept(await signed(6));
    expect(revisionOf(await store().open()), 6);
  });

  test('reset keeps no copy of valid files, only of damaged ones', () async {
    List<String> copies() => [
      for (final e in dir.listSync())
        if (e.path.contains('.damaged.')) e.path,
    ];
    final s = store();
    await s.open();
    await s.accept(await signed(7));
    await s.reset();
    expect(copies(), isEmpty);

    await a().writeAsString('garbage');
    await b().writeAsString('garbage');
    final damaged = store();
    expect(await damaged.open(), isA<TrustRecoveryRequired>());
    await damaged.reset();
    expect(copies(), hasLength(2));
    expect(await store().open(), isA<NoAcceptedCatalogue>());
  });

  test('the earlier replay case is rejected', () async {
    // Build Nov 1, rev 10 accepted, rev 11 accepted, one copy damaged,
    // rev 10 replayed.
    final guard = FreshnessGuard(buildTime: DateTime.utc(2026, 11));
    final s = store();
    await s.open();
    final rev10 = await signed(10);
    await s.accept(rev10);
    await s.accept(await signed(11, issuedAt: DateTime.utc(2026, 12, 2)));
    await a().writeAsString('damaged');

    final reopened = store();
    await reopened.open();
    expect(reopened.accepted!.revision, 11);
    expect(
      guard
          .check(
            candidate: rev10,
            accepted: reopened.accepted,
            deviceNow: DateTime.utc(2026, 12, 3),
          )
          ?.kind,
      UpdateFailureKind.metadataRollback,
    );
  });

  group('crash consistency', () {
    for (final crashAfter in [0, 1]) {
      test('crash after $crashAfter replacement(s) of an acceptance', () async {
        final s = store();
        await s.open();
        await s.accept(await signed(3));

        final crashing = store(
          CrashingFileSystem(crashAfterWrites: crashAfter),
        );
        await crashing.open();
        final next = await signed(4);
        try {
          await crashing.accept(next);
        } catch (_) {}

        final reopened = await store().open();
        final revision = revisionOf(reopened);
        // Never lower than before, always a valid catalogue.
        expect(revision, crashAfter == 0 ? 3 : 4);
        if (crashAfter == 1) {
          // A was committed; B is repaired on open.
          expect(await a().readAsBytes(), await b().readAsBytes());
        }
      });
    }

    test('nothing is acted on before the commit point', () async {
      final s = store();
      await s.open();
      await s.accept(await signed(3));
      final crashing = store(CrashingFileSystem(crashAfterWrites: 0));
      await crashing.open();
      try {
        await crashing.accept(await signed(4));
      } catch (_) {}
      expect(crashing.accepted!.revision, 3);
    });

    test(
      'power loss drops the last rename: the previous catalogue, intact',
      () async {
        final s = store();
        await s.open();
        await s.accept(await signed(3));
        final lossy = store(
          CrashingFileSystem(crashAfterWrites: 1, loseLastRename: true),
        );
        await lossy.open();
        try {
          await lossy.accept(await signed(4));
        } catch (_) {}
        expect(revisionOf(await store().open()), 3);
      },
    );
  });
}
