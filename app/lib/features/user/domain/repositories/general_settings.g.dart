// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GeneralSettingsRepository)
const generalSettingsRepositoryProvider = GeneralSettingsRepositoryProvider._();

final class GeneralSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<GeneralSettingsRepository, GeneralSettings> {
  const GeneralSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generalSettingsRepositoryHash();

  @$internal
  @override
  GeneralSettingsRepository create() => GeneralSettingsRepository();
}

String _$generalSettingsRepositoryHash() =>
    r'a9b21f9c5ef50bb8a8761995ed2fea723375b80e';

abstract class _$GeneralSettingsRepository
    extends $StreamNotifier<GeneralSettings> {
  Stream<GeneralSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<GeneralSettings>, GeneralSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GeneralSettings>, GeneralSettings>,
              AsyncValue<GeneralSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(generalSettingsWithDefaults)
const generalSettingsWithDefaultsProvider =
    GeneralSettingsWithDefaultsProvider._();

final class GeneralSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  const GeneralSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generalSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<GeneralSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeneralSettings create(Ref ref) {
    return generalSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneralSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneralSettings>(value),
    );
  }
}

String _$generalSettingsWithDefaultsHash() =>
    r'9da4a00a3500286fbf515ee319fa911bfacab40e';
