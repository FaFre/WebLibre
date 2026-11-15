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
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/startup/models/json_read.dart';
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';

part 'release_metadata.g.dart';

/// The app's shipped UI languages. Release-note summaries in any other
/// language are dropped (5.2); a test keeps this in step with
/// `AppLocalizations.supportedLocales`.
const shippedSummaryLanguages = {'en', 'de', 'es', 'id', 'ru', 'zh'};

/// Limits on release-note summaries (5.2).
const maxSummaryChars = 2000;
const maxSummaryUtf8Bytes = 3 * 1024;

// The catalogue payload (5.2), read by generated `fromJson`s in checked mode:
// a structure error anywhere throws `CheckedFromJsonException` naming the
// class and key, and rejects the whole catalogue. Unknown fields are ignored,
// unknown enum values make only their target unselectable, and release notes
// never reject anything. Rules that need the reader's context (package,
// compiled URL prefix, shipped languages) are `CatalogueCodec`'s.

/// Publisher-declared security classification of one release (5.2).
enum SecurityClassification {
  unknown,
  fixesIncluded,
  critical;

  SecurityClassification max(SecurityClassification other) =>
      index >= other.index ? this : other;
}

enum AdvisorySeverity {
  unknown,
  low,
  moderate,
  high,
  critical;

  /// What an advisory resolved by the target says about the update.
  SecurityClassification get classification => switch (this) {
    critical => SecurityClassification.critical,
    unknown => SecurityClassification.unknown,
    _ => SecurityClassification.fixesIncluded,
  };
}

/// A GitHub release asset, exactly as the signed metadata describes it.
@JsonSerializable(createToJson: false, checked: true)
class ArtifactRef with FastEquatable {
  ArtifactRef({
    required this.url,
    required this.byteLength,
    required this.sha256,
  });

  factory ArtifactRef.fromJson(Map<String, dynamic> json) =>
      _$ArtifactRefFromJson(json);

  @JsonKey(fromJson: _httpsUri)
  final Uri url;
  @JsonKey(fromJson: _positiveInt)
  final int byteLength;

  /// 64 lower-case hex characters.
  @JsonKey(fromJson: _sha256Hex)
  final String sha256;

  @override
  List<Object?> get hashParameters => [url, byteLength, sha256];
}

@JsonSerializable(createToJson: false, checked: true)
class UpdateTarget with FastEquatable {
  UpdateTarget({
    required this.id,
    required this.distribution,
    required this.track,
    required this.renderer,
    required this.abi,
    required this.versionCode,
    required this.minSdk,
    required this.artifact,
    this.components,
  });

  factory UpdateTarget.fromJson(Map<String, dynamic> json) =>
      _$UpdateTargetFromJson(json);

  @JsonKey(fromJson: requiredString)
  final String id;

  /// Unknown or null for a value this client does not know: the target is
  /// then never selectable (5.2).
  @JsonKey(unknownEnumValue: Distribution.unknown)
  final Distribution distribution;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ReleaseTrack? track;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final Renderer? renderer;
  @JsonKey(fromJson: _stringOrNull)
  final String? abi;
  @JsonKey(fromJson: _nonNegativeInt)
  final int versionCode;
  @JsonKey(fromJson: _nonNegativeInt)
  final int minSdk;

  /// GitHub only; Play targets have none.
  final ArtifactRef? artifact;

  /// A target built from other pins than its release (5.2).
  @JsonKey(fromJson: _componentsOrNull)
  final Map<ComponentId, ComponentIdentity>? components;

  @override
  List<Object?> get hashParameters => [
    id,
    distribution,
    track,
    renderer,
    abi,
    versionCode,
    minSdk,
    artifact,
    components,
  ];
}

@CopyWith()
@JsonSerializable(createToJson: false, checked: true)
class ReleaseNotes with FastEquatable {
  ReleaseNotes({required this.url, required this.summary});

  factory ReleaseNotes.fromJson(Map<String, dynamic> json) =>
      _$ReleaseNotesFromJson(json);

  static final none = ReleaseNotes(url: null, summary: {});

  /// Only kept when it matches the compiled prefix (8.1).
  @JsonKey(fromJson: _uriOrNull)
  final Uri? url;

  /// Locale → plain text. Empty when absent or rejected.
  @JsonKey(fromJson: _summary)
  final Map<String, String> summary;

  /// The UI locale, then `en`.
  String? summaryFor(String languageCode) =>
      summary[languageCode] ?? summary['en'];

  @override
  List<Object?> get hashParameters => [url, summary];
}

@CopyWith()
@JsonSerializable(createToJson: false, checked: true)
class ReleaseEntry with FastEquatable {
  ReleaseEntry({
    required this.releaseId,
    required this.appVersion,
    required this.logicalReleaseSequence,
    required this.targets,
    required this.components,
    required this.security,
    required this.releaseNotes,
  });

  factory ReleaseEntry.fromJson(Map<String, dynamic> json) =>
      _$ReleaseEntryFromJson(json);

  @JsonKey(fromJson: requiredString)
  final String releaseId;
  @JsonKey(fromJson: requiredString)
  final String appVersion;
  @JsonKey(fromJson: _nonNegativeInt)
  final int logicalReleaseSequence;
  final List<UpdateTarget> targets;
  @JsonKey(fromJson: _componentsOrEmpty)
  final Map<ComponentId, ComponentIdentity> components;

  /// `security.classification`.
  @JsonKey(
    readValue: _classification,
    unknownEnumValue: SecurityClassification.unknown,
    defaultValue: SecurityClassification.unknown,
  )
  final SecurityClassification security;
  @JsonKey(fromJson: _releaseNotes)
  final ReleaseNotes releaseNotes;

  Map<ComponentId, ComponentIdentity> componentsFor(UpdateTarget target) =>
      target.components ?? components;

  @override
  List<Object?> get hashParameters => [
    releaseId,
    appVersion,
    logicalReleaseSequence,
    targets,
    components,
    security,
    releaseNotes,
  ];
}

@JsonSerializable(createToJson: false, checked: true)
class Advisory with FastEquatable {
  Advisory({
    required this.id,
    required this.url,
    required this.severity,
    required this.introducedInSequence,
    required this.fixedInSequence,
  });

  factory Advisory.fromJson(Map<String, dynamic> json) =>
      _$AdvisoryFromJson(json);

  @JsonKey(fromJson: requiredString)
  final String id;
  @JsonKey(fromJson: _httpsUriOrNull)
  final Uri? url;
  @JsonKey(
    unknownEnumValue: AdvisorySeverity.unknown,
    defaultValue: AdvisorySeverity.unknown,
  )
  final AdvisorySeverity severity;

  /// `affected.introducedInSequence`. Absent means "all earlier builds".
  @JsonKey(readValue: _affected, fromJson: _nonNegativeIntOrNull)
  final int? introducedInSequence;

  /// `affected.fixedInSequence`.
  @JsonKey(readValue: _affected, fromJson: _nonNegativeInt)
  final int fixedInSequence;

  bool affects(int installedSequence) =>
      (introducedInSequence ?? 0) <= installedSequence &&
      installedSequence < fixedInSequence;

  bool resolvedBy(int installedSequence, int targetSequence) =>
      affects(installedSequence) && targetSequence >= fixedInSequence;

  @override
  List<Object?> get hashParameters => [
    id,
    url,
    severity,
    introducedInSequence,
    fixedInSequence,
  ];
}

/// One verified catalogue payload (5.2).
@CopyWith()
@JsonSerializable(createToJson: false, checked: true)
class ReleaseCatalogue with FastEquatable {
  ReleaseCatalogue({
    required this.packageId,
    required this.revision,
    required this.issuedAt,
    required this.expiresAt,
    required this.releases,
    required this.advisories,
  });

  factory ReleaseCatalogue.fromJson(Map<String, dynamic> json) =>
      _$ReleaseCatalogueFromJson(json);

  /// `scope.packageId`.
  @JsonKey(readValue: _scope, fromJson: requiredString)
  final String packageId;
  @JsonKey(fromJson: _nonNegativeInt)
  final int revision;
  @JsonKey(fromJson: _utcTimestamp)
  final DateTime issuedAt;
  @JsonKey(fromJson: _utcTimestamp)
  final DateTime expiresAt;

  /// Newest first.
  final List<ReleaseEntry> releases;
  @JsonKey(defaultValue: <Advisory>[])
  final List<Advisory> advisories;

  /// Every target of every release, for staged-file adoption (6.3).
  Iterable<(ReleaseEntry, UpdateTarget)> get allTargets sync* {
    for (final release in releases) {
      for (final target in release.targets) {
        yield (release, target);
      }
    }
  }

  (ReleaseEntry, UpdateTarget)? targetById(String id) =>
      allTargets.firstWhereOrNull((entry) => entry.$2.id == id);

  @override
  List<Object?> get hashParameters => [
    packageId,
    revision,
    issuedAt,
    expiresAt,
    releases,
    advisories,
  ];
}

/// A catalogue accepted under signature, with what was read from it.
///
/// Equal by revision and payload digest: the catalogue is parsed from that
/// payload, and the envelope around it may carry other signatures of it.
class AcceptedCatalogue with FastEquatable {
  AcceptedCatalogue({
    required this.catalogue,
    required this.payloadDigest,
    required this.envelopeBytes,
  });

  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  final ReleaseCatalogue catalogue;

  /// SHA-256 of the exact payload bytes, hex.
  final String payloadDigest;

  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  /// The envelope as it was signed; what the store keeps (6.1).
  final Uint8List envelopeBytes;

  int get revision => catalogue.revision;

  @override
  List<Object?> get hashParameters => [catalogue.revision, payloadDigest];
}

// Field readers for the generated `fromJson`s. A `FormatException` is a
// structure error.

String? _stringOrNull(Object? value) => value is String ? value : null;

int _nonNegativeInt(Object? value) => value is int && value >= 0
    ? value
    : throw const FormatException('not a non-negative integer');

int? _nonNegativeIntOrNull(Object? value) =>
    value == null ? null : _nonNegativeInt(value);

int _positiveInt(Object? value) => _nonNegativeInt(value) > 0
    ? value! as int
    : throw const FormatException('empty');

final _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');

String _sha256Hex(Object? value) =>
    _sha256Pattern.hasMatch(requiredString(value))
    ? value! as String
    : throw const FormatException('not a sha256');

Uri? _uriOrNull(Object? value) => value is String ? Uri.tryParse(value) : null;

Uri _httpsUri(Object? value) =>
    _httpsUriOrNull(requiredString(value)) ??
    (throw const FormatException('not an https URL'));

Uri? _httpsUriOrNull(Object? value) {
  final uri = _uriOrNull(value);
  return uri != null && uri.scheme == 'https' ? uri : null;
}

/// RFC 3339 in UTC, with the `Z`.
DateTime _utcTimestamp(Object? value) {
  final text = requiredString(value);
  final parsed = DateTime.tryParse(text);
  if (parsed == null || !parsed.isUtc || !text.endsWith('Z')) {
    throw const FormatException('not a UTC timestamp');
  }
  return parsed;
}

Object? _nested(Map json, String parent, String key) {
  final object = json[parent];
  if (object is! Map) throw FormatException('$parent is not an object');
  return object[key];
}

Object? _scope(Map json, String key) => _nested(json, 'scope', key);

Object? _affected(Map json, String key) => _nested(json, 'affected', key);

/// Tolerant: a missing or malformed `security` is `unknown`.
Object? _classification(Map json, String key) {
  final security = json['security'];
  return security is Map ? security['classification'] : null;
}

Map<ComponentId, ComponentIdentity>? _componentsOrNull(Object? json) {
  if (json == null) return null;
  if (json is! Map) throw const FormatException('not an object');
  return {
    for (final id in ComponentId.values)
      id: json.containsKey(id.name)
          ? componentIdentityFromJson(json[id.name])
          : ComponentUnknown(),
  };
}

Map<ComponentId, ComponentIdentity> _componentsOrEmpty(Object? json) =>
    _componentsOrNull(json) ?? const {};

/// Notes never reject anything: malformed notes are no notes.
ReleaseNotes _releaseNotes(Object? json) => json is Map<String, dynamic>
    ? ReleaseNotes.fromJson(json)
    : ReleaseNotes.none;

/// All or nothing (5.2): `en` is required, and a value in a shipped
/// language that is not non-blank text within the limits drops the whole
/// summary. Other languages are left out.
Map<String, String> _summary(Object? json) {
  if (json is! Map<String, Object?> || json['en'] is! String) return const {};
  final result = <String, String>{};
  for (final MapEntry(:key, :value) in json.entries) {
    if (!shippedSummaryLanguages.contains(key)) continue;
    if (value is! String ||
        value.trim().isEmpty ||
        value.length > maxSummaryChars ||
        utf8.encode(value).length > maxSummaryUtf8Bytes) {
      return const {};
    }
    result[key] = value;
  }
  return result;
}
