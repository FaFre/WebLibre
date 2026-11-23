// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the profile is open in the browser.
///
/// The lock is decided when the app leaves and again at the first sign of it
/// coming back, not once it is in front: Flutter reports `resumed` only when
/// the window has focus, which can be half a second after it is on screen,
/// and it draws meanwhile. Deciding on leaving means the first frame drawn on
/// the way back is already the lock screen. What the window and the system
/// show before that frame, native covers (`BrowserLockCover`): this arms it
/// while the profile is open and a lock applies on some return, and lifts it
/// once the decision is drawn.

@ProviderFor(ProfileAuthState)
final profileAuthStateProvider = ProfileAuthStateProvider._();

/// Whether the profile is open in the browser.
///
/// The lock is decided when the app leaves and again at the first sign of it
/// coming back, not once it is in front: Flutter reports `resumed` only when
/// the window has focus, which can be half a second after it is on screen,
/// and it draws meanwhile. Deciding on leaving means the first frame drawn on
/// the way back is already the lock screen. What the window and the system
/// show before that frame, native covers (`BrowserLockCover`): this arms it
/// while the profile is open and a lock applies on some return, and lifts it
/// once the decision is drawn.
final class ProfileAuthStateProvider
    extends $NotifierProvider<ProfileAuthState, bool> {
  /// Whether the profile is open in the browser.
  ///
  /// The lock is decided when the app leaves and again at the first sign of it
  /// coming back, not once it is in front: Flutter reports `resumed` only when
  /// the window has focus, which can be half a second after it is on screen,
  /// and it draws meanwhile. Deciding on leaving means the first frame drawn on
  /// the way back is already the lock screen. What the window and the system
  /// show before that frame, native covers (`BrowserLockCover`): this arms it
  /// while the profile is open and a lock applies on some return, and lifts it
  /// once the decision is drawn.
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

String _$profileAuthStateHash() => r'0d3778afe60bb47e4a490fd9ae06ef9b126f595e';

/// Whether the profile is open in the browser.
///
/// The lock is decided when the app leaves and again at the first sign of it
/// coming back, not once it is in front: Flutter reports `resumed` only when
/// the window has focus, which can be half a second after it is on screen,
/// and it draws meanwhile. Deciding on leaving means the first frame drawn on
/// the way back is already the lock screen. What the window and the system
/// show before that frame, native covers (`BrowserLockCover`): this arms it
/// while the profile is open and a lock applies on some return, and lifts it
/// once the decision is drawn.

abstract class _$ProfileAuthState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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
