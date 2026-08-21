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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// Converts a queued launch into the shape the ordinary intent pipeline reads.
///
/// The same [Intent] the plugin delivers, so a replayed launch goes through
/// exactly the handlers a live one does. Anything else would mean two
/// definitions of what a share or a deep link is, drifting apart at whatever
/// pace the two paths are edited.
Intent brokeredIntentFrom(StartupIntentRecord record) => Intent(
  // The caller native resolved when the launch arrived, not one derived now:
  // `getReferrer()` answers about the activity that is running at the moment it
  // is asked, which by replay time is this app. Reporting that — or nothing —
  // told the gatekeeper the launch was internal, so an unknown external app
  // that sent an intent during startup got in without the prompt it would have
  // faced a second later. Null still means unestablished, exactly as it does on
  // a live intent.
  fromPackageName: record.callerPackage,
  action: record.action,
  data: record.dataUri,
  categories: record.categories,
  mimeType: record.mimeType,
  extra: record.extras,
);

/// Drains the native broker, oldest launch first.
///
/// Each record has its staged bytes taken over by this process, is handed to
/// [deliver], and is acknowledged only once that returns. A delivery that throws
/// leaves the claim in place to expire, so the launch is retried rather than
/// quietly retired.
///
/// The order of those first two steps is the whole point of [BrokeredPayloads].
/// Acknowledging is what tells native to delete the entry's payload directory,
/// and the consumers downstream of [deliver] are asynchronous: the sharing
/// transformer awaits the gatekeeper and the settings repository before it ever
/// looks at the file, and a page loaded from it is read later still. Handing them
/// a path inside a directory this function is about to have deleted is how a
/// queued PDF arrived as a share of nothing. So the bytes move somewhere this
/// process owns *before* the intent is published, and what native then deletes is
/// an empty directory.
///
/// Acknowledging after the sink accepts remains an approximation of §7.1's "after
/// the final app service takes ownership" for the *entry*: the intent pipeline is
/// a stream, so acceptance is the last synchronous moment this code can observe.
/// It errs towards replaying a launch rather than dropping one.
Future<int> drainBrokeredIntents({
  required String engineId,
  required Future<void> Function(Intent intent) deliver,
  GeckoProfileService? service,
  StartupPaths? startupPaths,
  Future<Directory> Function()? payloadHome,
}) async {
  final api = service ?? GeckoProfileService();

  final List<StartupIntentRecord> records;
  try {
    records = await api.claimStartupIntents(engineId);
  } catch (error, stackTrace) {
    logger.w(
      'Could not claim queued launches',
      error: error,
      stackTrace: stackTrace,
    );
    return 0;
  }

  final payloads = BrokeredPayloads(
    claimedEntryIds: records.map((record) => record.id).toSet(),
    startupPaths: startupPaths,
    home: payloadHome,
  );

  var delivered = 0;
  for (final record in records) {
    try {
      final intent = brokeredIntentFrom(record);
      await payloads.adopt(record.id, intent);
      await deliver(intent);
    } catch (error, stackTrace) {
      logger.e(
        'Could not deliver queued launch ${record.id}',
        error: error,
        stackTrace: stackTrace,
      );
      // Handed back rather than left claimed: waiting out the claim would leave
      // the user looking at a link that does nothing for a minute.
      await _releaseQuietly(api, record.id, engineId);
      continue;
    }

    if (await api.acknowledgeStartupIntent(record.id, engineId)) {
      delivered++;
    }
  }

  if (delivered > 0) {
    logger.i(
      'Delivered $delivered launch(es) that arrived before the app was ready',
    );
  }

  return delivered;
}

/// Where a queued share keeps the bytes it carries.
///
/// Mirrors Kotlin's `StartupIntentPayloads.EXTRA_STREAM`.
const _extraStream = 'android.intent.extra.STREAM';

/// Directory name under the app's temporary directory that adopted payloads
/// land in. Its own directory so the sweep below can never reach anything else.
const _adoptedPayloadsDirName = 'brokered_launches';

/// Takes over the bytes a queued launch points at, before the broker deletes them.
///
/// The broker stages a shared file because the `content://` grant it arrived
/// under dies with the process, and it deletes those bytes the moment the entry
/// is acknowledged. Acknowledgement happens as soon as the intent is published,
/// which is many awaits before any consumer reads the file — so without this the
/// staged copy could be, and was, deleted first.
///
/// **Copied, not moved.** A rename would be cheaper and was the first shape of
/// this, but it destroys the only thing a retry has: delivery can throw, and the
/// process can die before the acknowledgement, and in both cases the entry stays
/// in the native queue still naming the staged path. Having moved that file away,
/// the retry replays a URI pointing at nothing. Copying leaves the broker's copy
/// authoritative until the entry is actually retired, and re-running the copy is
/// how a retry recovers. The duplicate lasts from here to the acknowledgement a
/// few awaits later, and is capped by the broker's 32 MB staging limit.
///
/// Only files that actually live under the broker's payload root are touched;
/// anything else is left exactly as it arrived, because a `file:` URI this process
/// did not stage is not this process's to copy.
class BrokeredPayloads {
  BrokeredPayloads({
    required this.claimedEntryIds,
    StartupPaths? startupPaths,
    Future<Directory> Function()? home,
  }) : _startupPaths = startupPaths,
       _home = home ?? _defaultHome;

  /// Entries this drain is responsible for. Anything else found in the adopted
  /// directory belongs to a run that is over, and is swept.
  final Set<String> claimedEntryIds;

  final StartupPaths? _startupPaths;
  final Future<Directory> Function() _home;

  Directory? _resolvedHome;

  static Future<Directory> _defaultHome() async => Directory(
    p.join((await getTemporaryDirectory()).path, _adoptedPayloadsDirName),
  );

  /// Rewrites [intent]'s file references to point at bytes this process owns.
  ///
  /// Nothing is resolved, created or swept for a launch that references no staged
  /// file, which is nearly all of them — so the common path never touches the
  /// filesystem at all.
  Future<void> adopt(String entryId, Intent intent) async {
    final data = intent.data;
    final stream = intent.extra[_extraStream];

    final adoptedData = await _adopt(entryId, data, 'data');
    final adoptedStream = await _adopt(
      entryId,
      stream is String ? stream : null,
      'stream',
    );

    if (adoptedData != null) {
      intent.data = adoptedData;
    }
    if (adoptedStream != null) {
      intent.extra = {...intent.extra, _extraStream: adoptedStream};
    }
  }

  Future<String?> _adopt(String entryId, String? uri, String name) async {
    final source = _stagedFile(uri);
    if (source == null) return null;

    final directory = Directory(p.join((await _entryHome()).path, entryId));
    await directory.create(recursive: true);

    // Overwrites whatever a previous attempt left, so a retry converges rather
    // than having to reason about what the last one got through.
    final target = await source.copy(p.join(directory.path, name));

    return target.uri.toString();
  }

  /// The file [uri] names, if the broker staged it.
  File? _stagedFile(String? uri) {
    if (uri == null) return null;

    final parsed = Uri.tryParse(uri);
    if (parsed == null || !parsed.isScheme('file')) return null;

    final paths =
        _startupPaths ??
        (filesystem.isGlobalPathsReady ? filesystem.startupPaths : null);
    if (paths == null) return null;

    // A `file:` URI with an authority is not a local path, and asking for one
    // would throw rather than answer.
    if (parsed.host.isNotEmpty) return null;

    final path = parsed.toFilePath();
    if (!p.isWithin(paths.startupIntentPayloadsDir.path, path)) return null;

    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// Resolves the adopted-payload root, sweeping it the first time.
  ///
  /// Everything already in there predates this drain: this process has adopted
  /// nothing yet, so any directory present belongs to a run that has ended. The
  /// entries this drain claimed are spared, because a claim that survived a crash
  /// is about to be adopted again under the same id.
  Future<Directory> _entryHome() async {
    final resolved = _resolvedHome;
    if (resolved != null) return resolved;

    final home = await _home();
    _resolvedHome = home;

    if (home.existsSync()) {
      await for (final entity in home.list(followLinks: false)) {
        if (claimedEntryIds.contains(p.basename(entity.path))) continue;
        try {
          await entity.delete(recursive: true);
        } catch (error) {
          logger.w('Could not sweep an abandoned payload: $error');
        }
      }
    }

    return home;
  }
}

Future<void> _releaseQuietly(
  GeckoProfileService api,
  String entryId,
  String engineId,
) async {
  try {
    await api.releaseStartupIntent(entryId, engineId);
  } catch (error, stackTrace) {
    logger.w(
      'Could not release queued launch $entryId',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
