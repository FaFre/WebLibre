// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_profile_draft_controller.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProxyProfileDraftStateCWProxy {
  ProxyProfileDraftState profileId(String? profileId);

  ProxyProfileDraftState existingProfile(ProxyProfile? existingProfile);

  ProxyProfileDraftState loadError(String? loadError);

  ProxyProfileDraftState name(String name);

  ProxyProfileDraftState type(SingboxProxyProfileType type);

  ProxyProfileDraftState values(Map<String, String> values);

  ProxyProfileDraftState dnsOverrideJson(String? dnsOverrideJson);

  ProxyProfileDraftState customConfigJson(String customConfigJson);

  ProxyProfileDraftState customSecretJson(String customSecretJson);

  ProxyProfileDraftState isSaving(bool isSaving);

  ProxyProfileDraftState secretLoaded(bool secretLoaded);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProxyProfileDraftState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyProfileDraftState(...).copyWith(id: 12, name: "My name")
  /// ```
  ProxyProfileDraftState call({
    String? profileId,
    ProxyProfile? existingProfile,
    String? loadError,
    String name,
    SingboxProxyProfileType type,
    Map<String, String> values,
    String? dnsOverrideJson,
    String customConfigJson,
    String customSecretJson,
    bool isSaving,
    bool secretLoaded,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProxyProfileDraftState.copyWith(...)` or call `instanceOfProxyProfileDraftState.copyWith.fieldName(value)` for a single field.
class _$ProxyProfileDraftStateCWProxyImpl
    implements _$ProxyProfileDraftStateCWProxy {
  const _$ProxyProfileDraftStateCWProxyImpl(this._value);

  final ProxyProfileDraftState _value;

  @override
  ProxyProfileDraftState profileId(String? profileId) =>
      call(profileId: profileId);

  @override
  ProxyProfileDraftState existingProfile(ProxyProfile? existingProfile) =>
      call(existingProfile: existingProfile);

  @override
  ProxyProfileDraftState loadError(String? loadError) =>
      call(loadError: loadError);

  @override
  ProxyProfileDraftState name(String name) => call(name: name);

  @override
  ProxyProfileDraftState type(SingboxProxyProfileType type) => call(type: type);

  @override
  ProxyProfileDraftState values(Map<String, String> values) =>
      call(values: values);

  @override
  ProxyProfileDraftState dnsOverrideJson(String? dnsOverrideJson) =>
      call(dnsOverrideJson: dnsOverrideJson);

  @override
  ProxyProfileDraftState customConfigJson(String customConfigJson) =>
      call(customConfigJson: customConfigJson);

  @override
  ProxyProfileDraftState customSecretJson(String customSecretJson) =>
      call(customSecretJson: customSecretJson);

  @override
  ProxyProfileDraftState isSaving(bool isSaving) => call(isSaving: isSaving);

  @override
  ProxyProfileDraftState secretLoaded(bool secretLoaded) =>
      call(secretLoaded: secretLoaded);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProxyProfileDraftState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyProfileDraftState(...).copyWith(id: 12, name: "My name")
  /// ```
  ProxyProfileDraftState call({
    Object? profileId = const $CopyWithPlaceholder(),
    Object? existingProfile = const $CopyWithPlaceholder(),
    Object? loadError = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? values = const $CopyWithPlaceholder(),
    Object? dnsOverrideJson = const $CopyWithPlaceholder(),
    Object? customConfigJson = const $CopyWithPlaceholder(),
    Object? customSecretJson = const $CopyWithPlaceholder(),
    Object? isSaving = const $CopyWithPlaceholder(),
    Object? secretLoaded = const $CopyWithPlaceholder(),
  }) {
    return ProxyProfileDraftState(
      profileId: profileId == const $CopyWithPlaceholder()
          ? _value.profileId
          // ignore: cast_nullable_to_non_nullable
          : profileId as String?,
      existingProfile: existingProfile == const $CopyWithPlaceholder()
          ? _value.existingProfile
          // ignore: cast_nullable_to_non_nullable
          : existingProfile as ProxyProfile?,
      loadError: loadError == const $CopyWithPlaceholder()
          ? _value.loadError
          // ignore: cast_nullable_to_non_nullable
          : loadError as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as SingboxProxyProfileType,
      values: values == const $CopyWithPlaceholder() || values == null
          ? _value.values
          // ignore: cast_nullable_to_non_nullable
          : values as Map<String, String>,
      dnsOverrideJson: dnsOverrideJson == const $CopyWithPlaceholder()
          ? _value.dnsOverrideJson
          // ignore: cast_nullable_to_non_nullable
          : dnsOverrideJson as String?,
      customConfigJson:
          customConfigJson == const $CopyWithPlaceholder() ||
              customConfigJson == null
          ? _value.customConfigJson
          // ignore: cast_nullable_to_non_nullable
          : customConfigJson as String,
      customSecretJson:
          customSecretJson == const $CopyWithPlaceholder() ||
              customSecretJson == null
          ? _value.customSecretJson
          // ignore: cast_nullable_to_non_nullable
          : customSecretJson as String,
      isSaving: isSaving == const $CopyWithPlaceholder() || isSaving == null
          ? _value.isSaving
          // ignore: cast_nullable_to_non_nullable
          : isSaving as bool,
      secretLoaded:
          secretLoaded == const $CopyWithPlaceholder() || secretLoaded == null
          ? _value.secretLoaded
          // ignore: cast_nullable_to_non_nullable
          : secretLoaded as bool,
    );
  }
}

extension $ProxyProfileDraftStateCopyWith on ProxyProfileDraftState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProxyProfileDraftState.copyWith(...)` or `instanceOfProxyProfileDraftState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProxyProfileDraftStateCWProxy get copyWith =>
      _$ProxyProfileDraftStateCWProxyImpl(this);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProxyProfileDraft)
final proxyProfileDraftProvider = ProxyProfileDraftFamily._();

final class ProxyProfileDraftProvider
    extends $NotifierProvider<ProxyProfileDraft, ProxyProfileDraftState> {
  ProxyProfileDraftProvider._({
    required ProxyProfileDraftFamily super.from,
    required ({String? profileId, ProxyProfileSeed? seed}) super.argument,
  }) : super(
         retry: null,
         name: r'proxyProfileDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyProfileDraftHash();

  @override
  String toString() {
    return r'proxyProfileDraftProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ProxyProfileDraft create() => ProxyProfileDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyProfileDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyProfileDraftState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyProfileDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyProfileDraftHash() => r'88dccb74624a8257f77646ab6755dce4e0de465a';

final class ProxyProfileDraftFamily extends $Family
    with
        $ClassFamilyOverride<
          ProxyProfileDraft,
          ProxyProfileDraftState,
          ProxyProfileDraftState,
          ProxyProfileDraftState,
          ({String? profileId, ProxyProfileSeed? seed})
        > {
  ProxyProfileDraftFamily._()
    : super(
        retry: null,
        name: r'proxyProfileDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyProfileDraftProvider call({String? profileId, ProxyProfileSeed? seed}) =>
      ProxyProfileDraftProvider._(
        argument: (profileId: profileId, seed: seed),
        from: this,
      );

  @override
  String toString() => r'proxyProfileDraftProvider';
}

abstract class _$ProxyProfileDraft extends $Notifier<ProxyProfileDraftState> {
  late final _$args = ref.$arg as ({String? profileId, ProxyProfileSeed? seed});
  String? get profileId => _$args.profileId;
  ProxyProfileSeed? get seed => _$args.seed;

  ProxyProfileDraftState build({String? profileId, ProxyProfileSeed? seed});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ProxyProfileDraftState, ProxyProfileDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProxyProfileDraftState, ProxyProfileDraftState>,
              ProxyProfileDraftState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(profileId: _$args.profileId, seed: _$args.seed),
    );
  }
}
