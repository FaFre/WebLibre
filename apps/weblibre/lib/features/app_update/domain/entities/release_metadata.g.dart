// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_metadata.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReleaseNotesCWProxy {
  ReleaseNotes url(Uri? url);

  ReleaseNotes summary(Map<String, String> summary);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReleaseNotes(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReleaseNotes(...).copyWith(id: 12, name: "My name")
  /// ```
  ReleaseNotes call({Uri? url, Map<String, String> summary});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfReleaseNotes.copyWith(...)` or call `instanceOfReleaseNotes.copyWith.fieldName(value)` for a single field.
class _$ReleaseNotesCWProxyImpl implements _$ReleaseNotesCWProxy {
  const _$ReleaseNotesCWProxyImpl(this._value);

  final ReleaseNotes _value;

  @override
  ReleaseNotes url(Uri? url) => call(url: url);

  @override
  ReleaseNotes summary(Map<String, String> summary) => call(summary: summary);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReleaseNotes(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReleaseNotes(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ReleaseNotes call({
    Object? url = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
  }) {
    return ReleaseNotes(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri?,
      summary: summary == const $CopyWithPlaceholder() || summary == null
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as Map<String, String>,
    );
  }
}

extension $ReleaseNotesCopyWith on ReleaseNotes {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfReleaseNotes.copyWith(...)` or `instanceOfReleaseNotes.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReleaseNotesCWProxy get copyWith => _$ReleaseNotesCWProxyImpl(this);
}

abstract class _$ReleaseEntryCWProxy {
  ReleaseEntry releaseId(String releaseId);

  ReleaseEntry appVersion(String appVersion);

  ReleaseEntry logicalReleaseSequence(int logicalReleaseSequence);

  ReleaseEntry targets(List<UpdateTarget> targets);

  ReleaseEntry components(Map<ComponentId, ComponentIdentity> components);

  ReleaseEntry security(SecurityClassification security);

  ReleaseEntry releaseNotes(ReleaseNotes releaseNotes);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReleaseEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReleaseEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  ReleaseEntry call({
    String releaseId,
    String appVersion,
    int logicalReleaseSequence,
    List<UpdateTarget> targets,
    Map<ComponentId, ComponentIdentity> components,
    SecurityClassification security,
    ReleaseNotes releaseNotes,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfReleaseEntry.copyWith(...)` or call `instanceOfReleaseEntry.copyWith.fieldName(value)` for a single field.
class _$ReleaseEntryCWProxyImpl implements _$ReleaseEntryCWProxy {
  const _$ReleaseEntryCWProxyImpl(this._value);

  final ReleaseEntry _value;

  @override
  ReleaseEntry releaseId(String releaseId) => call(releaseId: releaseId);

  @override
  ReleaseEntry appVersion(String appVersion) => call(appVersion: appVersion);

  @override
  ReleaseEntry logicalReleaseSequence(int logicalReleaseSequence) =>
      call(logicalReleaseSequence: logicalReleaseSequence);

  @override
  ReleaseEntry targets(List<UpdateTarget> targets) => call(targets: targets);

  @override
  ReleaseEntry components(Map<ComponentId, ComponentIdentity> components) =>
      call(components: components);

  @override
  ReleaseEntry security(SecurityClassification security) =>
      call(security: security);

  @override
  ReleaseEntry releaseNotes(ReleaseNotes releaseNotes) =>
      call(releaseNotes: releaseNotes);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReleaseEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReleaseEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ReleaseEntry call({
    Object? releaseId = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
    Object? logicalReleaseSequence = const $CopyWithPlaceholder(),
    Object? targets = const $CopyWithPlaceholder(),
    Object? components = const $CopyWithPlaceholder(),
    Object? security = const $CopyWithPlaceholder(),
    Object? releaseNotes = const $CopyWithPlaceholder(),
  }) {
    return ReleaseEntry(
      releaseId: releaseId == const $CopyWithPlaceholder() || releaseId == null
          ? _value.releaseId
          // ignore: cast_nullable_to_non_nullable
          : releaseId as String,
      appVersion:
          appVersion == const $CopyWithPlaceholder() || appVersion == null
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String,
      logicalReleaseSequence:
          logicalReleaseSequence == const $CopyWithPlaceholder() ||
              logicalReleaseSequence == null
          ? _value.logicalReleaseSequence
          // ignore: cast_nullable_to_non_nullable
          : logicalReleaseSequence as int,
      targets: targets == const $CopyWithPlaceholder() || targets == null
          ? _value.targets
          // ignore: cast_nullable_to_non_nullable
          : targets as List<UpdateTarget>,
      components:
          components == const $CopyWithPlaceholder() || components == null
          ? _value.components
          // ignore: cast_nullable_to_non_nullable
          : components as Map<ComponentId, ComponentIdentity>,
      security: security == const $CopyWithPlaceholder() || security == null
          ? _value.security
          // ignore: cast_nullable_to_non_nullable
          : security as SecurityClassification,
      releaseNotes:
          releaseNotes == const $CopyWithPlaceholder() || releaseNotes == null
          ? _value.releaseNotes
          // ignore: cast_nullable_to_non_nullable
          : releaseNotes as ReleaseNotes,
    );
  }
}

extension $ReleaseEntryCopyWith on ReleaseEntry {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfReleaseEntry.copyWith(...)` or `instanceOfReleaseEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReleaseEntryCWProxy get copyWith => _$ReleaseEntryCWProxyImpl(this);
}

abstract class _$ReleaseCatalogueCWProxy {
  ReleaseCatalogue packageId(String packageId);

  ReleaseCatalogue revision(int revision);

  ReleaseCatalogue issuedAt(DateTime issuedAt);

  ReleaseCatalogue expiresAt(DateTime expiresAt);

  ReleaseCatalogue releases(List<ReleaseEntry> releases);

  ReleaseCatalogue advisories(List<Advisory> advisories);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReleaseCatalogue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReleaseCatalogue(...).copyWith(id: 12, name: "My name")
  /// ```
  ReleaseCatalogue call({
    String packageId,
    int revision,
    DateTime issuedAt,
    DateTime expiresAt,
    List<ReleaseEntry> releases,
    List<Advisory> advisories,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfReleaseCatalogue.copyWith(...)` or call `instanceOfReleaseCatalogue.copyWith.fieldName(value)` for a single field.
class _$ReleaseCatalogueCWProxyImpl implements _$ReleaseCatalogueCWProxy {
  const _$ReleaseCatalogueCWProxyImpl(this._value);

  final ReleaseCatalogue _value;

  @override
  ReleaseCatalogue packageId(String packageId) => call(packageId: packageId);

  @override
  ReleaseCatalogue revision(int revision) => call(revision: revision);

  @override
  ReleaseCatalogue issuedAt(DateTime issuedAt) => call(issuedAt: issuedAt);

  @override
  ReleaseCatalogue expiresAt(DateTime expiresAt) => call(expiresAt: expiresAt);

  @override
  ReleaseCatalogue releases(List<ReleaseEntry> releases) =>
      call(releases: releases);

  @override
  ReleaseCatalogue advisories(List<Advisory> advisories) =>
      call(advisories: advisories);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReleaseCatalogue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReleaseCatalogue(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ReleaseCatalogue call({
    Object? packageId = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? issuedAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? releases = const $CopyWithPlaceholder(),
    Object? advisories = const $CopyWithPlaceholder(),
  }) {
    return ReleaseCatalogue(
      packageId: packageId == const $CopyWithPlaceholder() || packageId == null
          ? _value.packageId
          // ignore: cast_nullable_to_non_nullable
          : packageId as String,
      revision: revision == const $CopyWithPlaceholder() || revision == null
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      issuedAt: issuedAt == const $CopyWithPlaceholder() || issuedAt == null
          ? _value.issuedAt
          // ignore: cast_nullable_to_non_nullable
          : issuedAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      releases: releases == const $CopyWithPlaceholder() || releases == null
          ? _value.releases
          // ignore: cast_nullable_to_non_nullable
          : releases as List<ReleaseEntry>,
      advisories:
          advisories == const $CopyWithPlaceholder() || advisories == null
          ? _value.advisories
          // ignore: cast_nullable_to_non_nullable
          : advisories as List<Advisory>,
    );
  }
}

extension $ReleaseCatalogueCopyWith on ReleaseCatalogue {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfReleaseCatalogue.copyWith(...)` or `instanceOfReleaseCatalogue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReleaseCatalogueCWProxy get copyWith => _$ReleaseCatalogueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtifactRef _$ArtifactRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ArtifactRef', json, ($checkedConvert) {
      final val = ArtifactRef(
        url: $checkedConvert('url', (v) => _httpsUri(v)),
        byteLength: $checkedConvert('byteLength', (v) => _positiveInt(v)),
        sha256: $checkedConvert('sha256', (v) => _sha256Hex(v)),
      );
      return val;
    });

UpdateTarget _$UpdateTargetFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateTarget', json, ($checkedConvert) {
      final val = UpdateTarget(
        id: $checkedConvert('id', (v) => requiredString(v)),
        distribution: $checkedConvert(
          'distribution',
          (v) => $enumDecode(
            _$DistributionEnumMap,
            v,
            unknownValue: Distribution.unknown,
          ),
        ),
        track: $checkedConvert(
          'track',
          (v) => $enumDecodeNullable(
            _$ReleaseTrackEnumMap,
            v,
            unknownValue: JsonKey.nullForUndefinedEnumValue,
          ),
        ),
        renderer: $checkedConvert(
          'renderer',
          (v) => $enumDecodeNullable(
            _$RendererEnumMap,
            v,
            unknownValue: JsonKey.nullForUndefinedEnumValue,
          ),
        ),
        abi: $checkedConvert('abi', (v) => _stringOrNull(v)),
        versionCode: $checkedConvert('versionCode', (v) => _nonNegativeInt(v)),
        minSdk: $checkedConvert('minSdk', (v) => _nonNegativeInt(v)),
        artifact: $checkedConvert(
          'artifact',
          (v) => v == null
              ? null
              : ArtifactRef.fromJson(v as Map<String, dynamic>),
        ),
        components: $checkedConvert('components', (v) => _componentsOrNull(v)),
      );
      return val;
    });

const _$DistributionEnumMap = {
  Distribution.github: 'github',
  Distribution.play: 'play',
  Distribution.fdroid: 'fdroid',
  Distribution.unknown: 'unknown',
};

const _$ReleaseTrackEnumMap = {
  ReleaseTrack.stable: 'stable',
  ReleaseTrack.alpha: 'alpha',
};

const _$RendererEnumMap = {
  Renderer.skia: 'skia',
  Renderer.impeller: 'impeller',
};

ReleaseNotes _$ReleaseNotesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReleaseNotes', json, ($checkedConvert) {
      final val = ReleaseNotes(
        url: $checkedConvert('url', (v) => _uriOrNull(v)),
        summary: $checkedConvert('summary', (v) => _summary(v)),
      );
      return val;
    });

ReleaseEntry _$ReleaseEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReleaseEntry', json, ($checkedConvert) {
      final val = ReleaseEntry(
        releaseId: $checkedConvert('releaseId', (v) => requiredString(v)),
        appVersion: $checkedConvert('appVersion', (v) => requiredString(v)),
        logicalReleaseSequence: $checkedConvert(
          'logicalReleaseSequence',
          (v) => _nonNegativeInt(v),
        ),
        targets: $checkedConvert(
          'targets',
          (v) => (v as List<dynamic>)
              .map((e) => UpdateTarget.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        components: $checkedConvert('components', (v) => _componentsOrEmpty(v)),
        security: $checkedConvert(
          'security',
          (v) =>
              $enumDecodeNullable(
                _$SecurityClassificationEnumMap,
                v,
                unknownValue: SecurityClassification.unknown,
              ) ??
              SecurityClassification.unknown,
          readValue: _classification,
        ),
        releaseNotes: $checkedConvert('releaseNotes', (v) => _releaseNotes(v)),
      );
      return val;
    });

const _$SecurityClassificationEnumMap = {
  SecurityClassification.unknown: 'unknown',
  SecurityClassification.fixesIncluded: 'fixesIncluded',
  SecurityClassification.critical: 'critical',
};

Advisory _$AdvisoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Advisory', json, ($checkedConvert) {
      final val = Advisory(
        id: $checkedConvert('id', (v) => requiredString(v)),
        url: $checkedConvert('url', (v) => _httpsUriOrNull(v)),
        severity: $checkedConvert(
          'severity',
          (v) =>
              $enumDecodeNullable(
                _$AdvisorySeverityEnumMap,
                v,
                unknownValue: AdvisorySeverity.unknown,
              ) ??
              AdvisorySeverity.unknown,
        ),
        introducedInSequence: $checkedConvert(
          'introducedInSequence',
          (v) => _nonNegativeIntOrNull(v),
          readValue: _affected,
        ),
        fixedInSequence: $checkedConvert(
          'fixedInSequence',
          (v) => _nonNegativeInt(v),
          readValue: _affected,
        ),
      );
      return val;
    });

const _$AdvisorySeverityEnumMap = {
  AdvisorySeverity.unknown: 'unknown',
  AdvisorySeverity.low: 'low',
  AdvisorySeverity.moderate: 'moderate',
  AdvisorySeverity.high: 'high',
  AdvisorySeverity.critical: 'critical',
};

ReleaseCatalogue _$ReleaseCatalogueFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReleaseCatalogue', json, ($checkedConvert) {
      final val = ReleaseCatalogue(
        packageId: $checkedConvert(
          'packageId',
          (v) => requiredString(v),
          readValue: _scope,
        ),
        revision: $checkedConvert('revision', (v) => _nonNegativeInt(v)),
        issuedAt: $checkedConvert('issuedAt', (v) => _utcTimestamp(v)),
        expiresAt: $checkedConvert('expiresAt', (v) => _utcTimestamp(v)),
        releases: $checkedConvert(
          'releases',
          (v) => (v as List<dynamic>)
              .map((e) => ReleaseEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        advisories: $checkedConvert(
          'advisories',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => Advisory.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        ),
      );
      return val;
    });
