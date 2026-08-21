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
 */
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:simple_intent_receiver/simple_intent_receiver.dart' as sir;
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/features/share_intent/domain/services/brokered_intents.dart';

/// Records what the broker was asked to do.
class _FakeProfileApi implements GeckoProfileApi {
  _FakeProfileApi(this.pending);

  List<StartupIntentRecord> pending;
  final acknowledged = <String>[];
  final released = <String>[];
  int claimCalls = 0;
  bool claimThrows = false;

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';

  @override
  Future<List<StartupIntentRecord>> claimStartupIntents(String engineId) async {
    claimCalls++;
    if (claimThrows) throw PlatformException(code: 'unavailable');
    return pending;
  }

  @override
  Future<bool> acknowledgeStartupIntent(String entryId, String engineId) async {
    acknowledged.add(entryId);
    return true;
  }

  @override
  Future<bool> releaseStartupIntent(String entryId, String engineId) async {
    released.add(entryId);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

StartupIntentRecord record(
  String id, {
  int sequence = 1,
  String? action = 'android.intent.action.VIEW',
  String? dataUri = 'https://example.org',
  Map<String, Object?> extras = const {},
  String? callerPackage,
}) => StartupIntentRecord(
  id: id,
  sequence: sequence,
  action: action,
  dataUri: dataUri,
  mimeType: null,
  categories: const [],
  extras: extras,
  trustedProfileId: null,
  callerPackage: callerPackage,
);

const _extraStream = 'android.intent.extra.STREAM';

void main() {
  group('draining queued launches', () {
    test('delivers each launch and acknowledges it', () async {
      final api = _FakeProfileApi([record('a'), record('b', sequence: 2)]);
      final seen = <String?>[];

      final delivered = await drainBrokeredIntents(
        engineId: 'engine-1',
        service: GeckoProfileService(api: api),
        deliver: (intent) async => seen.add(intent.data),
      );

      expect(delivered, 2);
      expect(seen, ['https://example.org', 'https://example.org']);
      expect(api.acknowledged, ['a', 'b']);
    });

    test('a launch that fails to deliver is handed back, not retired', () async {
      // Acknowledging it would retire a launch that never reached the user, with
      // no record that it existed.
      final api = _FakeProfileApi([record('a')]);

      final delivered = await drainBrokeredIntents(
        engineId: 'engine-1',
        service: GeckoProfileService(api: api),
        deliver: (intent) async => throw StateError('no route'),
      );

      expect(delivered, 0);
      expect(api.acknowledged, isEmpty);
      expect(api.released, ['a']);
    });

    test('one bad launch does not stop the rest', () async {
      final api = _FakeProfileApi([
        record('a'),
        record('b', sequence: 2),
        record('c', sequence: 3),
      ]);

      await drainBrokeredIntents(
        engineId: 'engine-1',
        service: GeckoProfileService(api: api),
        deliver: (intent) async {
          if (intent.extra['fail'] == true) throw StateError('no route');
        },
      );

      expect(api.acknowledged, ['a', 'b', 'c']);
    });

    test('an unreachable broker is not an error the app has to handle', () async {
      // The native half may not be there at all in some builds; a missing broker
      // means no queued launches, not a failed startup.
      final api = _FakeProfileApi([])..claimThrows = true;

      final delivered = await drainBrokeredIntents(
        engineId: 'engine-1',
        service: GeckoProfileService(api: api),
        deliver: (intent) async {},
      );

      expect(delivered, 0);
    });

    test('nothing queued means nothing delivered', () async {
      final api = _FakeProfileApi([]);

      expect(
        await drainBrokeredIntents(
          engineId: 'engine-1',
          service: GeckoProfileService(api: api),
          deliver: (intent) async {},
        ),
        0,
      );
      expect(api.claimCalls, 1);
    });
  });

  group('taking ownership of staged bytes', () {
    late Directory root;
    late StartupPaths paths;
    late Directory home;

    /// Stages bytes exactly where the native broker puts them, and returns the
    /// `file:` URI the queued entry would carry.
    Future<String> stage(String entryId, String name, String contents) async {
      final directory = paths.startupIntentPayloadDir(entryId);
      await directory.create(recursive: true);

      final file = File(p.join(directory.path, name));
      await file.writeAsString(contents);
      return file.uri.toString();
    }

    Future<int> drain(
      _FakeProfileApi api,
      Future<void> Function(sir.Intent intent) deliver,
    ) => drainBrokeredIntents(
      engineId: 'engine-1',
      service: GeckoProfileService(api: api),
      startupPaths: paths,
      payloadHome: () async => home,
      deliver: deliver,
    );

    setUp(() async {
      root = await Directory.systemTemp.createTemp('brokered-payloads');
      paths = StartupPaths(Directory(p.join(root.path, 'files')));
      home = Directory(p.join(root.path, 'adopted'));
    });

    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    test('a staged share survives the acknowledgement that deletes it', () async {
      // The bug: acknowledging tells native to delete the payload directory, and
      // the consumers downstream of `deliver` are asynchronous — the sharing
      // transformer awaits the gatekeeper before it opens the file, and a page
      // loaded from it is read later still. The file has to outlive the ack.
      final uri = await stage('a', 'stream', '%PDF-1.7');
      final api = _FakeProfileApi([
        record('a', dataUri: null, extras: {_extraStream: uri}),
      ]);

      String? delivered;
      await drain(api, (intent) async {
        delivered = intent.extra[_extraStream] as String?;
      });

      expect(api.acknowledged, ['a']);
      expect(delivered, isNot(uri));

      // What native deletes on acknowledgement is an empty directory.
      final adopted = File(Uri.parse(delivered!).toFilePath());
      expect(adopted.readAsStringSync(), '%PDF-1.7');
      expect(p.isWithin(home.path, adopted.path), isTrue);
    });

    test('a staged data URI is adopted the same way', () async {
      final uri = await stage('a', 'data', 'bytes');
      final api = _FakeProfileApi([record('a', dataUri: uri)]);

      String? delivered;
      await drain(api, (intent) async => delivered = intent.data);

      expect(delivered, isNot(uri));
      expect(
        File(Uri.parse(delivered!).toFilePath()).readAsStringSync(),
        'bytes',
      );
    });

    test('the broker keeps its copy until the entry is retired', () async {
      // Acknowledgement is what deletes the staged bytes. Taking them away any
      // earlier destroys the only thing a retry has to work from.
      final uri = await stage('a', 'stream', '%PDF-1.7');
      final api = _FakeProfileApi([
        record('a', dataUri: null, extras: {_extraStream: uri}),
      ]);

      await drain(api, (intent) async {
        expect(File(Uri.parse(uri).toFilePath()).existsSync(), isTrue);
      });

      expect(api.acknowledged, ['a']);
    });

    test('a launch that failed to deliver can still be retried', () async {
      // The entry goes back on the queue still naming the staged path, so that
      // path has to still resolve — including after a crash between the copy and
      // the acknowledgement.
      final uri = await stage('a', 'stream', '%PDF-1.7');
      final api = _FakeProfileApi([
        record('a', dataUri: null, extras: {_extraStream: uri}),
      ]);

      await drain(api, (intent) async => throw StateError('no route'));

      expect(api.released, ['a']);
      expect(File(Uri.parse(uri).toFilePath()).existsSync(), isTrue);

      // The same entry, claimed again by a later run.
      final retry = _FakeProfileApi([
        record('a', dataUri: null, extras: {_extraStream: uri}),
      ]);

      String? delivered;
      await drain(retry, (intent) async {
        delivered = intent.extra[_extraStream] as String?;
      });

      expect(retry.acknowledged, ['a']);
      expect(
        File(Uri.parse(delivered!).toFilePath()).readAsStringSync(),
        '%PDF-1.7',
      );
    });

    test('a file this process did not stage is left where it is', () async {
      // Moving it would take a file away from whoever does own it.
      final outside = File(p.join(root.path, 'elsewhere.pdf'));
      await outside.writeAsString('not ours');

      final api = _FakeProfileApi([
        record('a', dataUri: outside.uri.toString()),
      ]);

      String? delivered;
      await drain(api, (intent) async => delivered = intent.data);

      expect(delivered, outside.uri.toString());
      expect(outside.existsSync(), isTrue);
    });

    test('ordinary launches never touch the filesystem', () async {
      final api = _FakeProfileApi([record('a')]);

      await drain(api, (intent) async {});

      expect(home.existsSync(), isFalse);
    });

    test('payloads adopted by a run that is over are swept', () async {
      final stale = Directory(p.join(home.path, 'from-a-previous-run'));
      await stale.create(recursive: true);
      await File(p.join(stale.path, 'stream')).writeAsString('garbage');

      final uri = await stage('a', 'stream', 'current');
      final api = _FakeProfileApi([
        record('a', dataUri: null, extras: {_extraStream: uri}),
      ]);

      await drain(api, (intent) async {});

      expect(stale.existsSync(), isFalse);
    });
  });

  group('converting a queued launch', () {
    test('carries action, data and extras into the ordinary intent', () {
      final intent = brokeredIntentFrom(
        record(
          'a',
          action: 'android.intent.action.SEND',
          dataUri: 'https://example.org/x',
          extras: const {'shortcut_container_mode': 'isolated'},
        ),
      );

      expect(intent.action, 'android.intent.action.SEND');
      expect(intent.data, 'https://example.org/x');
      expect(intent.extra['shortcut_container_mode'], 'isolated');
    });

    test('carries the caller native resolved when it arrived', () {
      // Deriving it at replay time is not an option — getReferrer() answers
      // about the activity running now — and answering "unknown" is not neutral:
      // the gatekeeper reads null as internal and never prompts, so a queued
      // launch from an unknown app would slip past the prompt a live one meets.
      expect(
        brokeredIntentFrom(
          record('a', callerPackage: 'com.example.sender'),
        ).fromPackageName,
        'com.example.sender',
      );
    });

    test('an unestablished caller stays unestablished', () {
      expect(brokeredIntentFrom(record('a')).fromPackageName, isNull);
    });

    test('is the same type the live path delivers', () {
      // So a replayed launch meets exactly the handlers a live one does, rather
      // than a second definition of what a share is.
      expect(brokeredIntentFrom(record('a')), isA<sir.Intent>());
    });
  });
}
