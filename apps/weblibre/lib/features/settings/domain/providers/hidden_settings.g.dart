// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything a visibility switch can stop from applying, as the profile
/// stores it ([SettingsSnapshot]); never the onboarding draft. Containers
/// count as using nothing until they load.
///
/// The profile layer: what a reveal from a gesture or shortcut, which writes
/// the profile, lists as applying again.

@ProviderFor(profileSettingsSnapshot)
final profileSettingsSnapshotProvider = ProfileSettingsSnapshotProvider._();

/// Everything a visibility switch can stop from applying, as the profile
/// stores it ([SettingsSnapshot]); never the onboarding draft. Containers
/// count as using nothing until they load.
///
/// The profile layer: what a reveal from a gesture or shortcut, which writes
/// the profile, lists as applying again.

final class ProfileSettingsSnapshotProvider
    extends
        $FunctionalProvider<
          SettingsSnapshot,
          SettingsSnapshot,
          SettingsSnapshot
        >
    with $Provider<SettingsSnapshot> {
  /// Everything a visibility switch can stop from applying, as the profile
  /// stores it ([SettingsSnapshot]); never the onboarding draft. Containers
  /// count as using nothing until they load.
  ///
  /// The profile layer: what a reveal from a gesture or shortcut, which writes
  /// the profile, lists as applying again.
  ProfileSettingsSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileSettingsSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileSettingsSnapshotHash();

  @$internal
  @override
  $ProviderElement<SettingsSnapshot> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsSnapshot create(Ref ref) {
    return profileSettingsSnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsSnapshot>(value),
    );
  }
}

String _$profileSettingsSnapshotHash() =>
    r'3738a70d039d0aafc74d7f5770e37c9223b2d1b4';

/// Everything a visibility switch can stop from applying, as the screens that
/// edit settings show it ([SettingsSnapshot]): in the onboarding with the
/// draft applied, otherwise the profile's ([profileSettingsSnapshot]).
///
/// The edit layer: Settings' "Not applied while hidden" and Feature Control
/// read it. Reads the draft and the profile's providers, never the layout
/// editors, which are auto-disposed.

@ProviderFor(storedSettingsSnapshot)
final storedSettingsSnapshotProvider = StoredSettingsSnapshotProvider._();

/// Everything a visibility switch can stop from applying, as the screens that
/// edit settings show it ([SettingsSnapshot]): in the onboarding with the
/// draft applied, otherwise the profile's ([profileSettingsSnapshot]).
///
/// The edit layer: Settings' "Not applied while hidden" and Feature Control
/// read it. Reads the draft and the profile's providers, never the layout
/// editors, which are auto-disposed.

final class StoredSettingsSnapshotProvider
    extends
        $FunctionalProvider<
          SettingsSnapshot,
          SettingsSnapshot,
          SettingsSnapshot
        >
    with $Provider<SettingsSnapshot> {
  /// Everything a visibility switch can stop from applying, as the screens that
  /// edit settings show it ([SettingsSnapshot]): in the onboarding with the
  /// draft applied, otherwise the profile's ([profileSettingsSnapshot]).
  ///
  /// The edit layer: Settings' "Not applied while hidden" and Feature Control
  /// read it. Reads the draft and the profile's providers, never the layout
  /// editors, which are auto-disposed.
  StoredSettingsSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedSettingsSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedSettingsSnapshotHash();

  @$internal
  @override
  $ProviderElement<SettingsSnapshot> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsSnapshot create(Ref ref) {
    return storedSettingsSnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsSnapshot>(value),
    );
  }
}

String _$storedSettingsSnapshotHash() =>
    r'26a842386969201e6b079c3af892970f4d2c9e75';

/// Whether the streams [profileSettingsSnapshot] reads have loaded. Until
/// then it counts the toolbars and containers as defaults.

@ProviderFor(profileSettingsSnapshotLoaded)
final profileSettingsSnapshotLoadedProvider =
    ProfileSettingsSnapshotLoadedProvider._();

/// Whether the streams [profileSettingsSnapshot] reads have loaded. Until
/// then it counts the toolbars and containers as defaults.

final class ProfileSettingsSnapshotLoadedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the streams [profileSettingsSnapshot] reads have loaded. Until
  /// then it counts the toolbars and containers as defaults.
  ProfileSettingsSnapshotLoadedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileSettingsSnapshotLoadedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileSettingsSnapshotLoadedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return profileSettingsSnapshotLoaded(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$profileSettingsSnapshotLoadedHash() =>
    r'ed5ea027feba36f38889a71fe8eed3c64efdd726';

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".
///
/// None in the onboarding: a fresh install has nothing changed for a hidden
/// feature to stop applying, and the draft's own changes are not marked.

@ProviderFor(SuspendedSettings)
final suspendedSettingsProvider = SuspendedSettingsProvider._();

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".
///
/// None in the onboarding: a fresh install has nothing changed for a hidden
/// feature to stop applying, and the draft's own changes are not marked.
final class SuspendedSettingsProvider
    extends $NotifierProvider<SuspendedSettings, Set<HiddenSetting>> {
  /// The changes that are not applied while their feature is hidden
  /// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
  /// hidden".
  ///
  /// None in the onboarding: a fresh install has nothing changed for a hidden
  /// feature to stop applying, and the draft's own changes are not marked.
  SuspendedSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suspendedSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suspendedSettingsHash();

  @$internal
  @override
  SuspendedSettings create() => SuspendedSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<HiddenSetting> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<HiddenSetting>>(value),
    );
  }
}

String _$suspendedSettingsHash() => r'53a7ba42522c5fdf7ee3aba1f30578a45cbca820';

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".
///
/// None in the onboarding: a fresh install has nothing changed for a hidden
/// feature to stop applying, and the draft's own changes are not marked.

abstract class _$SuspendedSettings extends $Notifier<Set<HiddenSetting>> {
  Set<HiddenSetting> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<HiddenSetting>, Set<HiddenSetting>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<HiddenSetting>, Set<HiddenSetting>>,
              Set<HiddenSetting>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
