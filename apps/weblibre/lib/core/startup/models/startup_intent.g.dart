// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_intent.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartupIntentClaimCWProxy {
  StartupIntentClaim processInstanceId(String processInstanceId);

  StartupIntentClaim engineId(String engineId);

  StartupIntentClaim claimedAt(DateTime claimedAt);

  StartupIntentClaim expiresAt(DateTime expiresAt);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupIntentClaim(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupIntentClaim(...).copyWith(id: 12, name: "My name")
  /// ```
  StartupIntentClaim call({
    String processInstanceId,
    String engineId,
    DateTime claimedAt,
    DateTime expiresAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfStartupIntentClaim.copyWith(...)` or call `instanceOfStartupIntentClaim.copyWith.fieldName(value)` for a single field.
class _$StartupIntentClaimCWProxyImpl implements _$StartupIntentClaimCWProxy {
  const _$StartupIntentClaimCWProxyImpl(this._value);

  final StartupIntentClaim _value;

  @override
  StartupIntentClaim processInstanceId(String processInstanceId) =>
      call(processInstanceId: processInstanceId);

  @override
  StartupIntentClaim engineId(String engineId) => call(engineId: engineId);

  @override
  StartupIntentClaim claimedAt(DateTime claimedAt) =>
      call(claimedAt: claimedAt);

  @override
  StartupIntentClaim expiresAt(DateTime expiresAt) =>
      call(expiresAt: expiresAt);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupIntentClaim(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupIntentClaim(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  StartupIntentClaim call({
    Object? processInstanceId = const $CopyWithPlaceholder(),
    Object? engineId = const $CopyWithPlaceholder(),
    Object? claimedAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return StartupIntentClaim(
      processInstanceId:
          processInstanceId == const $CopyWithPlaceholder() ||
              processInstanceId == null
          ? _value.processInstanceId
          // ignore: cast_nullable_to_non_nullable
          : processInstanceId as String,
      engineId: engineId == const $CopyWithPlaceholder() || engineId == null
          ? _value.engineId
          // ignore: cast_nullable_to_non_nullable
          : engineId as String,
      claimedAt: claimedAt == const $CopyWithPlaceholder() || claimedAt == null
          ? _value.claimedAt
          // ignore: cast_nullable_to_non_nullable
          : claimedAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $StartupIntentClaimCopyWith on StartupIntentClaim {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfStartupIntentClaim.copyWith(...)` or `instanceOfStartupIntentClaim.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartupIntentClaimCWProxy get copyWith =>
      _$StartupIntentClaimCWProxyImpl(this);
}

abstract class _$StartupIntentEntryCWProxy {
  StartupIntentEntry sequence(int sequence);

  StartupIntentEntry classificationId(String classificationId);

  StartupIntentEntry createdAt(DateTime createdAt);

  StartupIntentEntry expiresAt(DateTime expiresAt);

  StartupIntentEntry action(String? action);

  StartupIntentEntry dataUri(String? dataUri);

  StartupIntentEntry mimeType(String? mimeType);

  StartupIntentEntry categories(List<String> categories);

  StartupIntentEntry flags(List<String> flags);

  StartupIntentEntry extras(Map<String, Object?> extras);

  StartupIntentEntry trustedProfileId(String? trustedProfileId);

  StartupIntentEntry callerPackage(String? callerPackage);

  StartupIntentEntry payloadDirName(String? payloadDirName);

  StartupIntentEntry claim(StartupIntentClaim? claim);

  StartupIntentEntry acknowledged(bool acknowledged);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupIntentEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupIntentEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  StartupIntentEntry call({
    int sequence,
    String classificationId,
    DateTime createdAt,
    DateTime expiresAt,
    String? action,
    String? dataUri,
    String? mimeType,
    List<String> categories,
    List<String> flags,
    Map<String, Object?> extras,
    String? trustedProfileId,
    String? callerPackage,
    String? payloadDirName,
    StartupIntentClaim? claim,
    bool acknowledged,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfStartupIntentEntry.copyWith(...)` or call `instanceOfStartupIntentEntry.copyWith.fieldName(value)` for a single field.
class _$StartupIntentEntryCWProxyImpl implements _$StartupIntentEntryCWProxy {
  const _$StartupIntentEntryCWProxyImpl(this._value);

  final StartupIntentEntry _value;

  @override
  StartupIntentEntry sequence(int sequence) => call(sequence: sequence);

  @override
  StartupIntentEntry classificationId(String classificationId) =>
      call(classificationId: classificationId);

  @override
  StartupIntentEntry createdAt(DateTime createdAt) =>
      call(createdAt: createdAt);

  @override
  StartupIntentEntry expiresAt(DateTime expiresAt) =>
      call(expiresAt: expiresAt);

  @override
  StartupIntentEntry action(String? action) => call(action: action);

  @override
  StartupIntentEntry dataUri(String? dataUri) => call(dataUri: dataUri);

  @override
  StartupIntentEntry mimeType(String? mimeType) => call(mimeType: mimeType);

  @override
  StartupIntentEntry categories(List<String> categories) =>
      call(categories: categories);

  @override
  StartupIntentEntry flags(List<String> flags) => call(flags: flags);

  @override
  StartupIntentEntry extras(Map<String, Object?> extras) =>
      call(extras: extras);

  @override
  StartupIntentEntry trustedProfileId(String? trustedProfileId) =>
      call(trustedProfileId: trustedProfileId);

  @override
  StartupIntentEntry callerPackage(String? callerPackage) =>
      call(callerPackage: callerPackage);

  @override
  StartupIntentEntry payloadDirName(String? payloadDirName) =>
      call(payloadDirName: payloadDirName);

  @override
  StartupIntentEntry claim(StartupIntentClaim? claim) => call(claim: claim);

  @override
  StartupIntentEntry acknowledged(bool acknowledged) =>
      call(acknowledged: acknowledged);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupIntentEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupIntentEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  StartupIntentEntry call({
    Object? sequence = const $CopyWithPlaceholder(),
    Object? classificationId = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
    Object? dataUri = const $CopyWithPlaceholder(),
    Object? mimeType = const $CopyWithPlaceholder(),
    Object? categories = const $CopyWithPlaceholder(),
    Object? flags = const $CopyWithPlaceholder(),
    Object? extras = const $CopyWithPlaceholder(),
    Object? trustedProfileId = const $CopyWithPlaceholder(),
    Object? callerPackage = const $CopyWithPlaceholder(),
    Object? payloadDirName = const $CopyWithPlaceholder(),
    Object? claim = const $CopyWithPlaceholder(),
    Object? acknowledged = const $CopyWithPlaceholder(),
  }) {
    return StartupIntentEntry(
      id: _value.id,
      sequence: sequence == const $CopyWithPlaceholder() || sequence == null
          ? _value.sequence
          // ignore: cast_nullable_to_non_nullable
          : sequence as int,
      classificationId:
          classificationId == const $CopyWithPlaceholder() ||
              classificationId == null
          ? _value.classificationId
          // ignore: cast_nullable_to_non_nullable
          : classificationId as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as String?,
      dataUri: dataUri == const $CopyWithPlaceholder()
          ? _value.dataUri
          // ignore: cast_nullable_to_non_nullable
          : dataUri as String?,
      mimeType: mimeType == const $CopyWithPlaceholder()
          ? _value.mimeType
          // ignore: cast_nullable_to_non_nullable
          : mimeType as String?,
      categories:
          categories == const $CopyWithPlaceholder() || categories == null
          ? _value.categories
          // ignore: cast_nullable_to_non_nullable
          : categories as List<String>,
      flags: flags == const $CopyWithPlaceholder() || flags == null
          ? _value.flags
          // ignore: cast_nullable_to_non_nullable
          : flags as List<String>,
      extras: extras == const $CopyWithPlaceholder() || extras == null
          ? _value.extras
          // ignore: cast_nullable_to_non_nullable
          : extras as Map<String, Object?>,
      trustedProfileId: trustedProfileId == const $CopyWithPlaceholder()
          ? _value.trustedProfileId
          // ignore: cast_nullable_to_non_nullable
          : trustedProfileId as String?,
      callerPackage: callerPackage == const $CopyWithPlaceholder()
          ? _value.callerPackage
          // ignore: cast_nullable_to_non_nullable
          : callerPackage as String?,
      payloadDirName: payloadDirName == const $CopyWithPlaceholder()
          ? _value.payloadDirName
          // ignore: cast_nullable_to_non_nullable
          : payloadDirName as String?,
      claim: claim == const $CopyWithPlaceholder()
          ? _value.claim
          // ignore: cast_nullable_to_non_nullable
          : claim as StartupIntentClaim?,
      acknowledged:
          acknowledged == const $CopyWithPlaceholder() || acknowledged == null
          ? _value.acknowledged
          // ignore: cast_nullable_to_non_nullable
          : acknowledged as bool,
    );
  }
}

extension $StartupIntentEntryCopyWith on StartupIntentEntry {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfStartupIntentEntry.copyWith(...)` or `instanceOfStartupIntentEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartupIntentEntryCWProxy get copyWith =>
      _$StartupIntentEntryCWProxyImpl(this);
}

abstract class _$StartupIntentQueueCWProxy {
  StartupIntentQueue version(int version);

  StartupIntentQueue nextSequence(int nextSequence);

  StartupIntentQueue entries(List<StartupIntentEntry> entries);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupIntentQueue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupIntentQueue(...).copyWith(id: 12, name: "My name")
  /// ```
  StartupIntentQueue call({
    int version,
    int nextSequence,
    List<StartupIntentEntry> entries,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfStartupIntentQueue.copyWith(...)` or call `instanceOfStartupIntentQueue.copyWith.fieldName(value)` for a single field.
class _$StartupIntentQueueCWProxyImpl implements _$StartupIntentQueueCWProxy {
  const _$StartupIntentQueueCWProxyImpl(this._value);

  final StartupIntentQueue _value;

  @override
  StartupIntentQueue version(int version) => call(version: version);

  @override
  StartupIntentQueue nextSequence(int nextSequence) =>
      call(nextSequence: nextSequence);

  @override
  StartupIntentQueue entries(List<StartupIntentEntry> entries) =>
      call(entries: entries);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupIntentQueue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupIntentQueue(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  StartupIntentQueue call({
    Object? version = const $CopyWithPlaceholder(),
    Object? nextSequence = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
  }) {
    return StartupIntentQueue(
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      nextSequence:
          nextSequence == const $CopyWithPlaceholder() || nextSequence == null
          ? _value.nextSequence
          // ignore: cast_nullable_to_non_nullable
          : nextSequence as int,
      entries: entries == const $CopyWithPlaceholder() || entries == null
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<StartupIntentEntry>,
    );
  }
}

extension $StartupIntentQueueCopyWith on StartupIntentQueue {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfStartupIntentQueue.copyWith(...)` or `instanceOfStartupIntentQueue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartupIntentQueueCWProxy get copyWith =>
      _$StartupIntentQueueCWProxyImpl(this);
}
