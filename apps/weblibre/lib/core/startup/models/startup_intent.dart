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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/core/startup/models/json_read.dart';

part 'startup_intent.g.dart';

const startupIntentQueueVersion = 1;

/// How native classified the launch *before* any component was created.
///
/// Only native code that authenticated the launch source may produce a
/// `trusted*` value. Dart never derives one from raw intent extras, so a
/// spoofed `pwa_profile_uuid` on a `MainActivity` intent can never select a
/// profile.
enum LaunchClassification {
  trustedPwa,
  trustedShortcut,
  legacyPwa,
  customTab,
  shareUrl,
  regular,
  accountCallback,
  widget,
  quickAction,

  /// A classification this build does not know. Treated exactly like
  /// [regular]: never trusted, never profile selecting.
  unknown;

  /// Whether this classification may answer an open profile selection.
  bool get isTrusted =>
      this == LaunchClassification.trustedPwa ||
      this == LaunchClassification.trustedShortcut ||
      this == LaunchClassification.accountCallback;
}

/// A process-instance-scoped claim on an entry, so two engines cannot deliver
/// the same intent twice. Claims expire; a new process can take over an expired
/// one, but an acknowledged entry is never replayed.
@CopyWith()
class StartupIntentClaim with FastEquatable {
  final String processInstanceId;
  final String engineId;
  final DateTime claimedAt;
  final DateTime expiresAt;

  StartupIntentClaim({
    required this.processInstanceId,
    required this.engineId,
    required this.claimedAt,
    required this.expiresAt,
  });

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  static StartupIntentClaim? tryFromJson(Map<String, Object?> json) {
    final processInstanceId = json['processInstanceId'];
    final engineId = json['engineId'];
    final claimedAt = dateTimeOrNull(json['claimedAt']);
    final expiresAt = dateTimeOrNull(json['expiresAt']);

    if (processInstanceId is! String || processInstanceId.isEmpty) return null;
    if (claimedAt == null || expiresAt == null) return null;

    return StartupIntentClaim(
      processInstanceId: processInstanceId,
      engineId: engineId is String ? engineId : '',
      claimedAt: claimedAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, Object?> toJson() => {
    'processInstanceId': processInstanceId,
    'engineId': engineId,
    'claimedAt': claimedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get hashParameters => [
    processInstanceId,
    engineId,
    claimedAt,
    expiresAt,
  ];
}

/// One queued launch, in the allowlisted representation that can survive a
/// process restart.
///
/// Arbitrary `Parcelable` extras are deliberately not representable. Content
/// that must survive restart is either covered by a persistable URI grant or
/// staged as bytes under [payloadDirName]; when neither is possible the restart
/// flow is blocked rather than promising a replay it cannot deliver.
@CopyWith()
class StartupIntentEntry with FastEquatable {
  @CopyWithField(immutable: true)
  final String id;

  /// Durable monotonic order. Initial and live intents share one sequence, so
  /// total ordering survives engine and process replacement.
  final int sequence;

  final String classificationId;
  final String? action;
  final String? dataUri;
  final String? mimeType;
  final List<String> categories;
  final List<String> flags;

  /// Primitive-only extras. See [sanitizeExtras].
  final Map<String, Object?> extras;

  /// Set only by native trusted-launch validation.
  final String? trustedProfileId;

  /// The app that sent the launch, resolved when it arrived.
  ///
  /// Recorded rather than re-derived: `getReferrer()` answers about the activity
  /// running at the moment it is asked, so by replay time it names this app. A
  /// queued launch that forgot its caller replays as internal, which is exactly
  /// the answer that skips the gatekeeper prompt.
  final String? callerPackage;

  /// Relative name of this entry's staged payload directory, when content had
  /// to be copied out of a transient grant.
  final String? payloadDirName;

  final DateTime createdAt;
  final DateTime expiresAt;
  final StartupIntentClaim? claim;
  final bool acknowledged;

  StartupIntentEntry({
    required this.id,
    required this.sequence,
    required this.classificationId,
    required this.createdAt,
    required this.expiresAt,
    this.action,
    this.dataUri,
    this.mimeType,
    this.categories = const [],
    this.flags = const [],
    this.extras = const {},
    this.trustedProfileId,
    this.callerPackage,
    this.payloadDirName,
    this.claim,
    this.acknowledged = false,
  });

  LaunchClassification get classification =>
      LaunchClassification.values.tryByName(classificationId) ??
      LaunchClassification.unknown;

  /// A trusted profile hint only counts when the classification itself is
  /// trusted; otherwise the field is ignored entirely.
  String? get effectiveTrustedProfileId =>
      classification.isTrusted ? trustedProfileId : null;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  /// Whether [engineId] in [processInstanceId] may take this entry.
  ///
  /// The engine is part of the identity, not decoration. `MainActivity` destroys
  /// its cached engine after a non-finishing destroy and can build another in
  /// the *same* process, so matching on the process alone would let the
  /// replacement engine re-deliver an entry the previous one already claimed and
  /// is still working on. A replacement takes over by waiting for the claim to
  /// expire, or by the owner releasing it — never by sharing its identity.
  bool isDeliverableAt(
    DateTime now,
    String processInstanceId,
    String engineId,
  ) {
    if (acknowledged || isExpiredAt(now)) return false;

    final claim = this.claim;
    if (claim == null || claim.isExpiredAt(now)) return true;

    return claim.processInstanceId == processInstanceId &&
        claim.engineId == engineId;
  }

  static StartupIntentEntry? tryFromJson(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) return null;

    final sequence = json['sequence'];
    if (sequence is! int) return null;

    final createdAt = dateTimeOrNull(json['createdAt']);
    final expiresAt = dateTimeOrNull(json['expiresAt']);
    if (createdAt == null || expiresAt == null) return null;

    final rawClaim = json['claim'];

    return StartupIntentEntry(
      id: id,
      sequence: sequence,
      classificationId: json['classification'] is String
          ? json['classification']! as String
          : LaunchClassification.unknown.name,
      action: stringOrNull(json['action']),
      dataUri: stringOrNull(json['dataUri']),
      mimeType: stringOrNull(json['mimeType']),
      categories: stringList(json['categories']),
      flags: stringList(json['flags']),
      extras: sanitizeExtras(json['extras']),
      trustedProfileId: stringOrNull(json['trustedProfileId']),
      callerPackage: stringOrNull(json['callerPackage']),
      payloadDirName: stringOrNull(json['payloadDirName']),
      createdAt: createdAt,
      expiresAt: expiresAt,
      claim: rawClaim is Map
          ? StartupIntentClaim.tryFromJson(
              rawClaim.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
      acknowledged: json['acknowledged'] == true,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'sequence': sequence,
    'classification': classificationId,
    'action': action,
    'dataUri': dataUri,
    'mimeType': mimeType,
    'categories': categories,
    'flags': flags,
    'extras': extras,
    'trustedProfileId': trustedProfileId,
    'callerPackage': callerPackage,
    'payloadDirName': payloadDirName,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'claim': claim?.toJson(),
    'acknowledged': acknowledged,
  };

  @override
  List<Object?> get hashParameters => [
    id,
    sequence,
    classificationId,
    action,
    dataUri,
    mimeType,
    categories,
    flags,
    extras,
    trustedProfileId,
    callerPackage,
    payloadDirName,
    createdAt,
    expiresAt,
    claim,
    acknowledged,
  ];
}

/// The persisted, ordered queue of unacknowledged launches.
@CopyWith()
class StartupIntentQueue with FastEquatable {
  final int version;

  /// Next sequence number to hand out. Persisted so ordering survives restart.
  final int nextSequence;
  final List<StartupIntentEntry> entries;

  StartupIntentQueue({
    this.version = startupIntentQueueVersion,
    this.nextSequence = 1,
    this.entries = const [],
  });

  static final empty = StartupIntentQueue();

  factory StartupIntentQueue.fromJson(Map<String, Object?> json) {
    final rawEntries = json['entries'];
    final entries = <StartupIntentEntry>[];
    final seen = <String>{};

    if (rawEntries is List) {
      for (final raw in rawEntries) {
        if (raw is! Map) continue;
        final entry = StartupIntentEntry.tryFromJson(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        );
        if (entry == null) continue;
        if (!seen.add(entry.id)) continue;
        entries.add(entry);
      }
    }

    entries.sort((a, b) => a.sequence.compareTo(b.sequence));

    final version = json['version'];
    final nextSequence = json['nextSequence'];
    final highest = entries.isEmpty ? 0 : entries.last.sequence;

    return StartupIntentQueue(
      version: version is int ? version : startupIntentQueueVersion,
      // Never hand out a sequence at or below one already on disk, even if the
      // stored counter was truncated or rolled back.
      nextSequence: nextSequence is int && nextSequence > highest
          ? nextSequence
          : highest + 1,
      entries: List.unmodifiable(entries),
    );
  }

  Map<String, Object?> toJson() => {
    'version': version,
    'nextSequence': nextSequence,
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };

  @override
  List<Object?> get hashParameters => [version, nextSequence, entries];
}

/// Keeps only JSON-safe primitives and string lists.
///
/// Anything else — nested objects, byte arrays, `Parcelable` stand-ins — is
/// dropped rather than best-effort encoded, because a partially reconstructed
/// extra is worse than a missing one: the consumer cannot tell the difference.
Map<String, Object?> sanitizeExtras(Object? raw) {
  if (raw is! Map) return const {};

  final result = <String, Object?>{};
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    final value = entry.value;

    if (value is bool || value is int || value is double || value is String) {
      result[key] = value;
    } else if (value is List && value.every((item) => item is String)) {
      result[key] = List<String>.unmodifiable(value.cast<String>());
    }
  }

  return Map.unmodifiable(result);
}
