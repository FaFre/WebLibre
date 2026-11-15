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
import 'package:json_annotation/json_annotation.dart';
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
@JsonSerializable(checked: true)
class StartupIntentClaim with FastEquatable {
  @JsonKey(fromJson: requiredString)
  final String processInstanceId;
  @JsonKey(fromJson: stringOrEmpty)
  final String engineId;
  @JsonKey(fromJson: requiredDateTime, toJson: utcIso)
  final DateTime claimedAt;
  @JsonKey(fromJson: requiredDateTime, toJson: utcIso)
  final DateTime expiresAt;

  StartupIntentClaim({
    required this.processInstanceId,
    required this.engineId,
    required this.claimedAt,
    required this.expiresAt,
  });

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  static StartupIntentClaim? tryFromJson(Map<String, Object?> json) =>
      tryCheckedFromJson(json, _$StartupIntentClaimFromJson);

  Map<String, Object?> toJson() => _$StartupIntentClaimToJson(this);

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
///
/// Fields are declared in the order the file lists them.
@CopyWith()
@JsonSerializable(checked: true, explicitToJson: true)
class StartupIntentEntry with FastEquatable {
  @CopyWithField(immutable: true)
  @JsonKey(fromJson: requiredString)
  final String id;

  /// Durable monotonic order. Initial and live intents share one sequence, so
  /// total ordering survives engine and process replacement.
  @JsonKey(fromJson: requiredInt)
  final int sequence;

  @JsonKey(name: 'classification', fromJson: _classification)
  final String classificationId;
  @JsonKey(fromJson: stringOrNull)
  final String? action;
  @JsonKey(fromJson: stringOrNull)
  final String? dataUri;
  @JsonKey(fromJson: stringOrNull)
  final String? mimeType;
  @JsonKey(fromJson: stringList)
  final List<String> categories;
  @JsonKey(fromJson: stringList)
  final List<String> flags;

  /// Primitive-only extras. See [sanitizeExtras].
  @JsonKey(fromJson: sanitizeExtras)
  final Map<String, Object?> extras;

  /// Set only by native trusted-launch validation.
  @JsonKey(fromJson: stringOrNull)
  final String? trustedProfileId;

  /// The app that sent the launch, resolved when it arrived.
  ///
  /// Recorded rather than re-derived: `getReferrer()` answers about the activity
  /// running at the moment it is asked, so by replay time it names this app. A
  /// queued launch that forgot its caller replays as internal, which is exactly
  /// the answer that skips the gatekeeper prompt.
  @JsonKey(fromJson: stringOrNull)
  final String? callerPackage;

  /// Relative name of this entry's staged payload directory, when content had
  /// to be copied out of a transient grant.
  @JsonKey(fromJson: stringOrNull)
  final String? payloadDirName;

  @JsonKey(fromJson: requiredDateTime, toJson: utcIso)
  final DateTime createdAt;
  @JsonKey(fromJson: requiredDateTime, toJson: utcIso)
  final DateTime expiresAt;

  /// An unreadable claim is no claim.
  @JsonKey(fromJson: _claim)
  final StartupIntentClaim? claim;
  @JsonKey(fromJson: _acknowledged)
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

  /// Null for an entry without an id, a sequence or its times: it can't be
  /// ordered or expired. Every other field degrades (`json_read.dart`).
  static StartupIntentEntry? tryFromJson(Map<String, Object?> json) =>
      tryCheckedFromJson(json, _$StartupIntentEntryFromJson);

  Map<String, Object?> toJson() => _$StartupIntentEntryToJson(this);

  static String _classification(Object? value) =>
      value is String ? value : LaunchClassification.unknown.name;

  static StartupIntentClaim? _claim(Object? value) => value is Map
      ? StartupIntentClaim.tryFromJson(
          value.map((key, value) => MapEntry(key.toString(), value)),
        )
      : null;

  static bool _acknowledged(Object? value) => boolOr(value, false);

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
@JsonSerializable(explicitToJson: true)
class StartupIntentQueue with FastEquatable {
  @JsonKey(fromJson: _queueVersion)
  final int version;

  /// Next sequence number to hand out. Persisted so ordering survives restart.
  @JsonKey(fromJson: _storedSequence)
  final int nextSequence;
  @JsonKey(fromJson: _entries)
  final List<StartupIntentEntry> entries;

  StartupIntentQueue({
    this.version = startupIntentQueueVersion,
    this.nextSequence = 1,
    this.entries = const [],
  });

  static final empty = StartupIntentQueue();

  factory StartupIntentQueue.fromJson(Map<String, Object?> json) {
    final parsed = _$StartupIntentQueueFromJson(json);
    final highest = parsed.entries.lastOrNull?.sequence ?? 0;
    // Never hand out a sequence at or below one already on disk, even if the
    // stored counter was truncated or rolled back.
    return parsed.nextSequence > highest
        ? parsed
        : parsed.copyWith(nextSequence: highest + 1);
  }

  Map<String, Object?> toJson() => _$StartupIntentQueueToJson(this);

  static int _queueVersion(Object? value) =>
      intOr(value, startupIntentQueueVersion);

  /// Corrected against the entries in [StartupIntentQueue.fromJson].
  static int _storedSequence(Object? value) => intOr(value, 0);

  /// In sequence order, without entries that can't be read or repeat an id.
  static List<StartupIntentEntry> _entries(Object? value) {
    final seen = <String>{};
    final entries = recordsFromJson(
      value,
      StartupIntentEntry.tryFromJson,
    ).where((entry) => seen.add(entry.id)).toList();
    entries.sort((a, b) => a.sequence.compareTo(b.sequence));
    return List.unmodifiable(entries);
  }

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
