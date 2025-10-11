// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineSettingsRepository)
const engineSettingsRepositoryProvider = EngineSettingsRepositoryProvider._();

final class EngineSettingsRepositoryProvider
    extends $StreamNotifierProvider<EngineSettingsRepository, EngineSettings> {
  const EngineSettingsRepositoryProvider._()
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
    r'33acd89e783d8d91b9b56e86411fdfcab24a2c54';

abstract class _$EngineSettingsRepository
    extends $StreamNotifier<EngineSettings> {
  Stream<EngineSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<EngineSettings>, EngineSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EngineSettings>, EngineSettings>,
              AsyncValue<EngineSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(engineSettingsWithDefaults)
const engineSettingsWithDefaultsProvider =
    EngineSettingsWithDefaultsProvider._();

final class EngineSettingsWithDefaultsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  const EngineSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSettingsWithDefaultsProvider',
        isAutoDispose: true,
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
    r'd47fa79c0ad87a2357de58133585b4f6b097b068';
