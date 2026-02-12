// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileAuthState)
final profileAuthStateProvider = ProfileAuthStateProvider._();

final class ProfileAuthStateProvider
    extends $NotifierProvider<ProfileAuthState, bool> {
  ProfileAuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileAuthStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileAuthStateHash();

  @$internal
  @override
  ProfileAuthState create() => ProfileAuthState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$profileAuthStateHash() => r'9eb65fdb76baa0b088fc12a8063ea4ee63d54ac4';

abstract class _$ProfileAuthState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(profileAuthNotifier)
final profileAuthProvider = ProfileAuthNotifierProvider._();

final class ProfileAuthNotifierProvider
    extends
        $FunctionalProvider<
          Raw<ProfileAuthNotifier>,
          Raw<ProfileAuthNotifier>,
          Raw<ProfileAuthNotifier>
        >
    with $Provider<Raw<ProfileAuthNotifier>> {
  ProfileAuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileAuthNotifierHash();

  @$internal
  @override
  $ProviderElement<Raw<ProfileAuthNotifier>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<ProfileAuthNotifier> create(Ref ref) {
    return profileAuthNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<ProfileAuthNotifier> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<ProfileAuthNotifier>>(value),
    );
  }
}

String _$profileAuthNotifierHash() =>
    r'795f47b1494e4a9cdd74f5ff22d431b2bc59ffbd';
