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

/// The engine settings as stored, hidden features included.
///
/// For the screens that show and edit settings, the onboarding draft and
/// Feature Control. Behavior reads [engineSettingsWithDefaults].
///
/// Kept alive like its `storedGeneralSettings` counterpart: it is a pure
/// projection of the keep-alive repository, so caching it costs a single
/// derived value and lets keep-alive consumers read it without pinning an
/// auto-disposed provider.

@ProviderFor(storedEngineSettings)
final storedEngineSettingsProvider = StoredEngineSettingsProvider._();

/// The engine settings as stored, hidden features included.
///
/// For the screens that show and edit settings, the onboarding draft and
/// Feature Control. Behavior reads [engineSettingsWithDefaults].
///
/// Kept alive like its `storedGeneralSettings` counterpart: it is a pure
/// projection of the keep-alive repository, so caching it costs a single
/// derived value and lets keep-alive consumers read it without pinning an
/// auto-disposed provider.

final class StoredEngineSettingsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// The engine settings as stored, hidden features included.
  ///
  /// For the screens that show and edit settings, the onboarding draft and
  /// Feature Control. Behavior reads [engineSettingsWithDefaults].
  ///
  /// Kept alive like its `storedGeneralSettings` counterpart: it is a pure
  /// projection of the keep-alive repository, so caching it costs a single
  /// derived value and lets keep-alive consumers read it without pinning an
  /// auto-disposed provider.
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
    r'7141e96af4012556971396d6ecacb602d5982352';

/// The engine settings as they apply: the settings of hidden features at
/// their hidden values ([EngineSettings.effective]).

@ProviderFor(engineSettingsWithDefaults)
final engineSettingsWithDefaultsProvider =
    EngineSettingsWithDefaultsProvider._();

/// The engine settings as they apply: the settings of hidden features at
/// their hidden values ([EngineSettings.effective]).

final class EngineSettingsWithDefaultsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// The engine settings as they apply: the settings of hidden features at
  /// their hidden values ([EngineSettings.effective]).
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
    r'996d289176331b134588a6d6fb4aa3d020067920';

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
