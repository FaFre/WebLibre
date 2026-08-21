// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_manifest.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BackupManifestCWProxy {
  BackupManifest profileId(String profileId);

  BackupManifest profileName(String profileName);

  BackupManifest createdAt(DateTime createdAt);

  BackupManifest sourceBytes(int sourceBytes);

  BackupManifest entryCount(int entryCount);

  BackupManifest version(int version);

  BackupManifest exclusions(List<BackupExclusion> exclusions);

  BackupManifest undeclaredCategories(List<String>? undeclaredCategories);

  BackupManifest includedParticipantCategories(
    List<String>? includedParticipantCategories,
  );

  BackupManifest archiveSha256(String? archiveSha256);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BackupManifest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BackupManifest(...).copyWith(id: 12, name: "My name")
  /// ```
  BackupManifest call({
    String profileId,
    String profileName,
    DateTime createdAt,
    int sourceBytes,
    int entryCount,
    int version,
    List<BackupExclusion> exclusions,
    List<String>? undeclaredCategories,
    List<String>? includedParticipantCategories,
    String? archiveSha256,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBackupManifest.copyWith(...)` or call `instanceOfBackupManifest.copyWith.fieldName(value)` for a single field.
class _$BackupManifestCWProxyImpl implements _$BackupManifestCWProxy {
  const _$BackupManifestCWProxyImpl(this._value);

  final BackupManifest _value;

  @override
  BackupManifest profileId(String profileId) => call(profileId: profileId);

  @override
  BackupManifest profileName(String profileName) =>
      call(profileName: profileName);

  @override
  BackupManifest createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  BackupManifest sourceBytes(int sourceBytes) => call(sourceBytes: sourceBytes);

  @override
  BackupManifest entryCount(int entryCount) => call(entryCount: entryCount);

  @override
  BackupManifest version(int version) => call(version: version);

  @override
  BackupManifest exclusions(List<BackupExclusion> exclusions) =>
      call(exclusions: exclusions);

  @override
  BackupManifest undeclaredCategories(List<String>? undeclaredCategories) =>
      call(undeclaredCategories: undeclaredCategories);

  @override
  BackupManifest includedParticipantCategories(
    List<String>? includedParticipantCategories,
  ) => call(includedParticipantCategories: includedParticipantCategories);

  @override
  BackupManifest archiveSha256(String? archiveSha256) =>
      call(archiveSha256: archiveSha256);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BackupManifest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BackupManifest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  BackupManifest call({
    Object? profileId = const $CopyWithPlaceholder(),
    Object? profileName = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? sourceBytes = const $CopyWithPlaceholder(),
    Object? entryCount = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? exclusions = const $CopyWithPlaceholder(),
    Object? undeclaredCategories = const $CopyWithPlaceholder(),
    Object? includedParticipantCategories = const $CopyWithPlaceholder(),
    Object? archiveSha256 = const $CopyWithPlaceholder(),
  }) {
    return BackupManifest(
      profileId: profileId == const $CopyWithPlaceholder() || profileId == null
          ? _value.profileId
          // ignore: cast_nullable_to_non_nullable
          : profileId as String,
      profileName:
          profileName == const $CopyWithPlaceholder() || profileName == null
          ? _value.profileName
          // ignore: cast_nullable_to_non_nullable
          : profileName as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      sourceBytes:
          sourceBytes == const $CopyWithPlaceholder() || sourceBytes == null
          ? _value.sourceBytes
          // ignore: cast_nullable_to_non_nullable
          : sourceBytes as int,
      entryCount:
          entryCount == const $CopyWithPlaceholder() || entryCount == null
          ? _value.entryCount
          // ignore: cast_nullable_to_non_nullable
          : entryCount as int,
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      exclusions:
          exclusions == const $CopyWithPlaceholder() || exclusions == null
          ? _value.exclusions
          // ignore: cast_nullable_to_non_nullable
          : exclusions as List<BackupExclusion>,
      undeclaredCategories: undeclaredCategories == const $CopyWithPlaceholder()
          ? _value.undeclaredCategories
          // ignore: cast_nullable_to_non_nullable
          : undeclaredCategories as List<String>?,
      includedParticipantCategories:
          includedParticipantCategories == const $CopyWithPlaceholder()
          ? _value.includedParticipantCategories
          // ignore: cast_nullable_to_non_nullable
          : includedParticipantCategories as List<String>?,
      archiveSha256: archiveSha256 == const $CopyWithPlaceholder()
          ? _value.archiveSha256
          // ignore: cast_nullable_to_non_nullable
          : archiveSha256 as String?,
    );
  }
}

extension $BackupManifestCopyWith on BackupManifest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBackupManifest.copyWith(...)` or `instanceOfBackupManifest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BackupManifestCWProxy get copyWith => _$BackupManifestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupExclusion _$BackupExclusionFromJson(Map<String, dynamic> json) =>
    BackupExclusion(
      path: stringOrEmpty(json['path']),
      reason: stringOrEmpty(json['reason']),
      recreatedOnRestore: _recreatedFromJson(json['recreatedOnRestore']),
    );

Map<String, dynamic> _$BackupExclusionToJson(BackupExclusion instance) =>
    <String, dynamic>{
      'path': instance.path,
      'reason': instance.reason,
      'recreatedOnRestore': instance.recreatedOnRestore,
    };

BackupManifest _$BackupManifestFromJson(Map<String, dynamic> json) =>
    BackupManifest(
      profileId: stringOrEmpty(json['profileId']),
      profileName: stringOrEmpty(json['profileName']),
      createdAt: _createdAtFromJson(json['createdAt']),
      sourceBytes: _countFromJson(json['sourceBytes']),
      entryCount: _countFromJson(json['entryCount']),
      version: json['version'] == null
          ? backupManifestVersion
          : _versionFromJson(json['version']),
      exclusions: json['exclusions'] == null
          ? BackupExclusions.entries
          : _exclusionsFromJson(json['exclusions']),
      undeclaredCategories: stringList(json['undeclaredCategories']),
      includedParticipantCategories: stringList(
        json['includedParticipantCategories'],
      ),
      archiveSha256: stringOrNull(json['archiveSha256']),
    );

Map<String, dynamic> _$BackupManifestToJson(BackupManifest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'profileId': instance.profileId,
      'profileName': instance.profileName,
      'createdAt': _createdAtToJson(instance.createdAt),
      'sourceBytes': instance.sourceBytes,
      'entryCount': instance.entryCount,
      'exclusions': instance.exclusions.map((e) => e.toJson()).toList(),
      'undeclaredCategories': instance.undeclaredCategories,
      'includedParticipantCategories': instance.includedParticipantCategories,
      'archiveSha256': ?instance.archiveSha256,
    };
