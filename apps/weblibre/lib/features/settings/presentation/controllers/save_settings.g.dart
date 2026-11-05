// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether what the settings screens save lands in the profile at once:
/// false in the onboarding, whose draft is committed only at Done. Effects
/// that only make sense for a live change (a restart offer, forgetting a
/// declined reveal) wait while it is false.

@ProviderFor(settingsEditsAreLive)
final settingsEditsAreLiveProvider = SettingsEditsAreLiveProvider._();

/// Whether what the settings screens save lands in the profile at once:
/// false in the onboarding, whose draft is committed only at Done. Effects
/// that only make sense for a live change (a restart offer, forgetting a
/// declined reveal) wait while it is false.

final class SettingsEditsAreLiveProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether what the settings screens save lands in the profile at once:
  /// false in the onboarding, whose draft is committed only at Done. Effects
  /// that only make sense for a live change (a restart offer, forgetting a
  /// declined reveal) wait while it is false.
  SettingsEditsAreLiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsEditsAreLiveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsEditsAreLiveHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return settingsEditsAreLive(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$settingsEditsAreLiveHash() =>
    r'e2ec0242f7d79a7ac23a7bcccf6d8e8cb4211380';

/// How the settings screens save general settings: into the profile, or in
/// the onboarding into its draft, as a settings edit ([save]) or a visibility
/// edit ([saveVisibility]), which a preset change drops. Only settings UI
/// writes through here; the browser writes the repository, so nothing it
/// does lands in a draft.

@ProviderFor(SaveGeneralSettingsController)
final saveGeneralSettingsControllerProvider =
    SaveGeneralSettingsControllerProvider._();

/// How the settings screens save general settings: into the profile, or in
/// the onboarding into its draft, as a settings edit ([save]) or a visibility
/// edit ([saveVisibility]), which a preset change drops. Only settings UI
/// writes through here; the browser writes the repository, so nothing it
/// does lands in a draft.
final class SaveGeneralSettingsControllerProvider
    extends $AsyncNotifierProvider<SaveGeneralSettingsController, void> {
  /// How the settings screens save general settings: into the profile, or in
  /// the onboarding into its draft, as a settings edit ([save]) or a visibility
  /// edit ([saveVisibility]), which a preset change drops. Only settings UI
  /// writes through here; the browser writes the repository, so nothing it
  /// does lands in a draft.
  SaveGeneralSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveGeneralSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveGeneralSettingsControllerHash();

  @$internal
  @override
  SaveGeneralSettingsController create() => SaveGeneralSettingsController();
}

String _$saveGeneralSettingsControllerHash() =>
    r'aa295055e3d38e52b854221798c802f0f6df7df0';

/// How the settings screens save general settings: into the profile, or in
/// the onboarding into its draft, as a settings edit ([save]) or a visibility
/// edit ([saveVisibility]), which a preset change drops. Only settings UI
/// writes through here; the browser writes the repository, so nothing it
/// does lands in a draft.

abstract class _$SaveGeneralSettingsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Like [SaveGeneralSettingsController], for the engine settings.

@ProviderFor(SaveEngineSettingsController)
final saveEngineSettingsControllerProvider =
    SaveEngineSettingsControllerProvider._();

/// Like [SaveGeneralSettingsController], for the engine settings.
final class SaveEngineSettingsControllerProvider
    extends $AsyncNotifierProvider<SaveEngineSettingsController, void> {
  /// Like [SaveGeneralSettingsController], for the engine settings.
  SaveEngineSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveEngineSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveEngineSettingsControllerHash();

  @$internal
  @override
  SaveEngineSettingsController create() => SaveEngineSettingsController();
}

String _$saveEngineSettingsControllerHash() =>
    r'8c885eb8130b03b10e54f4abd0b98d14b6b83273';

/// Like [SaveGeneralSettingsController], for the engine settings.

abstract class _$SaveEngineSettingsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SaveTorSettingsController)
final saveTorSettingsControllerProvider = SaveTorSettingsControllerProvider._();

final class SaveTorSettingsControllerProvider
    extends $AsyncNotifierProvider<SaveTorSettingsController, void> {
  SaveTorSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveTorSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveTorSettingsControllerHash();

  @$internal
  @override
  SaveTorSettingsController create() => SaveTorSettingsController();
}

String _$saveTorSettingsControllerHash() =>
    r'bc8bac2f2d777025fa3e2c85badcbc095a9e3ad1';

abstract class _$SaveTorSettingsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
