// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineSettingsRepository)
final engineSettingsRepositoryProvider = EngineSettingsRepositoryProvider._();

final class EngineSettingsRepositoryProvider
    extends $StreamNotifierProvider<EngineSettingsRepository, EngineSettings> {
  EngineSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSettingsRepositoryHash();

  @$internal
  @override
  EngineSettingsRepository create() => EngineSettingsRepository();
}

String _$engineSettingsRepositoryHash() =>
    r'4d5d39de1b7122ce3af8ef4ce3c153bf126ac428';

abstract class _$EngineSettingsRepository
    extends $StreamNotifier<EngineSettings> {
  Stream<EngineSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EngineSettings>, EngineSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EngineSettings>, EngineSettings>,
              AsyncValue<EngineSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The engine settings of the profile as stored, hidden features included.
/// Never the onboarding draft.
///
/// The profile layer, like `profileGeneralSettings`: what
/// [engineSettingsWithDefaults] applies. Kept alive: it is a pure projection
/// of the keep-alive repository, so caching it costs a single derived value
/// and lets keep-alive consumers read it without pinning an auto-disposed
/// provider.

@ProviderFor(profileEngineSettings)
final profileEngineSettingsProvider = ProfileEngineSettingsProvider._();

/// The engine settings of the profile as stored, hidden features included.
/// Never the onboarding draft.
///
/// The profile layer, like `profileGeneralSettings`: what
/// [engineSettingsWithDefaults] applies. Kept alive: it is a pure projection
/// of the keep-alive repository, so caching it costs a single derived value
/// and lets keep-alive consumers read it without pinning an auto-disposed
/// provider.

final class ProfileEngineSettingsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// The engine settings of the profile as stored, hidden features included.
  /// Never the onboarding draft.
  ///
  /// The profile layer, like `profileGeneralSettings`: what
  /// [engineSettingsWithDefaults] applies. Kept alive: it is a pure projection
  /// of the keep-alive repository, so caching it costs a single derived value
  /// and lets keep-alive consumers read it without pinning an auto-disposed
  /// provider.
  ProfileEngineSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEngineSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEngineSettingsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings create(Ref ref) {
    return profileEngineSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings>(value),
    );
  }
}

String _$profileEngineSettingsHash() =>
    r'9e8a0345d0231a188ce07bffc9bf684c72d05a88';

/// The engine settings as stored, hidden features included, for the screens
/// that show and edit them: in the onboarding the draft's
/// (`draftEngineSettings`), otherwise the profile's
/// ([profileEngineSettings]).
///
/// The edit layer. Behavior reads [engineSettingsWithDefaults].

@ProviderFor(storedEngineSettings)
final storedEngineSettingsProvider = StoredEngineSettingsProvider._();

/// The engine settings as stored, hidden features included, for the screens
/// that show and edit them: in the onboarding the draft's
/// (`draftEngineSettings`), otherwise the profile's
/// ([profileEngineSettings]).
///
/// The edit layer. Behavior reads [engineSettingsWithDefaults].

final class StoredEngineSettingsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// The engine settings as stored, hidden features included, for the screens
  /// that show and edit them: in the onboarding the draft's
  /// (`draftEngineSettings`), otherwise the profile's
  /// ([profileEngineSettings]).
  ///
  /// The edit layer. Behavior reads [engineSettingsWithDefaults].
  StoredEngineSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedEngineSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedEngineSettingsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings create(Ref ref) {
    return storedEngineSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings>(value),
    );
  }
}

String _$storedEngineSettingsHash() =>
    r'119d7d82f6578c3314d3d2c08e23dd7a2a4950c5';

/// The engine settings as they apply: the profile's settings with those of
/// hidden features at their hidden values ([EngineSettings.effective]).
///
/// The live layer. It follows the profile, never the onboarding draft.

@ProviderFor(engineSettingsWithDefaults)
final engineSettingsWithDefaultsProvider =
    EngineSettingsWithDefaultsProvider._();

/// The engine settings as they apply: the profile's settings with those of
/// hidden features at their hidden values ([EngineSettings.effective]).
///
/// The live layer. It follows the profile, never the onboarding draft.

final class EngineSettingsWithDefaultsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// The engine settings as they apply: the profile's settings with those of
  /// hidden features at their hidden values ([EngineSettings.effective]).
  ///
  /// The live layer. It follows the profile, never the onboarding draft.
  EngineSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings create(Ref ref) {
    return engineSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings>(value),
    );
  }
}

String _$engineSettingsWithDefaultsHash() =>
    r'b2225c4e5ee6afcddba0f1fb8b46002b1d9f4ad0';

/// [engineSettingsWithDefaults] once both the engine and the general settings
/// have loaded, null before: what the engine is told. The placeholder
/// defaults are no input for it, and neither are stored values whose
/// visibility is not known yet.

@ProviderFor(loadedEngineSettings)
final loadedEngineSettingsProvider = LoadedEngineSettingsProvider._();

/// [engineSettingsWithDefaults] once both the engine and the general settings
/// have loaded, null before: what the engine is told. The placeholder
/// defaults are no input for it, and neither are stored values whose
/// visibility is not known yet.

final class LoadedEngineSettingsProvider
    extends
        $FunctionalProvider<EngineSettings?, EngineSettings?, EngineSettings?>
    with $Provider<EngineSettings?> {
  /// [engineSettingsWithDefaults] once both the engine and the general settings
  /// have loaded, null before: what the engine is told. The placeholder
  /// defaults are no input for it, and neither are stored values whose
  /// visibility is not known yet.
  LoadedEngineSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadedEngineSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadedEngineSettingsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings? create(Ref ref) {
    return loadedEngineSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings?>(value),
    );
  }
}

String _$loadedEngineSettingsHash() =>
    r'731c8e90eb7ad24853ea8de7d39994f4e9f9b2e0';

/// The engine settings as the widgets that render settings draw them: in the
/// onboarding the draft's as they would apply, otherwise the live ones
/// ([engineSettingsWithDefaults]). The displayed layer, like
/// `displayedGeneralSettings`.

@ProviderFor(displayedEngineSettings)
final displayedEngineSettingsProvider = DisplayedEngineSettingsProvider._();

/// The engine settings as the widgets that render settings draw them: in the
/// onboarding the draft's as they would apply, otherwise the live ones
/// ([engineSettingsWithDefaults]). The displayed layer, like
/// `displayedGeneralSettings`.

final class DisplayedEngineSettingsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// The engine settings as the widgets that render settings draw them: in the
  /// onboarding the draft's as they would apply, otherwise the live ones
  /// ([engineSettingsWithDefaults]). The displayed layer, like
  /// `displayedGeneralSettings`.
  DisplayedEngineSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedEngineSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedEngineSettingsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings create(Ref ref) {
    return displayedEngineSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings>(value),
    );
  }
}

String _$displayedEngineSettingsHash() =>
    r'e4f03d0417a8e4fd5739886f3290ed93ae8e0add';
