// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything a visibility switch can stop from applying, as stored
/// ([SettingsSnapshot]). Containers count as using nothing until they load.

@ProviderFor(storedSettingsSnapshot)
final storedSettingsSnapshotProvider = StoredSettingsSnapshotProvider._();

/// Everything a visibility switch can stop from applying, as stored
/// ([SettingsSnapshot]). Containers count as using nothing until they load.

final class StoredSettingsSnapshotProvider
    extends
        $FunctionalProvider<
          SettingsSnapshot,
          SettingsSnapshot,
          SettingsSnapshot
        >
    with $Provider<SettingsSnapshot> {
  /// Everything a visibility switch can stop from applying, as stored
  /// ([SettingsSnapshot]). Containers count as using nothing until they load.
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
    r'abf27ce1ef57d28345e0eabefc1a90aa204182a4';

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".

@ProviderFor(SuspendedSettings)
final suspendedSettingsProvider = SuspendedSettingsProvider._();

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".
final class SuspendedSettingsProvider
    extends $NotifierProvider<SuspendedSettings, Set<HiddenSetting>> {
  /// The changes that are not applied while their feature is hidden
  /// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
  /// hidden".
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

String _$suspendedSettingsHash() => r'afaff86bdbd5baa06902c514f6c2af4eebf97c52';

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".

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
