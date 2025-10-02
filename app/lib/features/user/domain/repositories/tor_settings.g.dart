// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TorSettingsRepository)
const torSettingsRepositoryProvider = TorSettingsRepositoryProvider._();

final class TorSettingsRepositoryProvider
    extends $StreamNotifierProvider<TorSettingsRepository, TorSettings> {
  const TorSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'torSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$torSettingsRepositoryHash();

  @$internal
  @override
  TorSettingsRepository create() => TorSettingsRepository();
}

String _$torSettingsRepositoryHash() =>
    r'341730ed58b49ab3d721583e0f2d5ac650018918';

abstract class _$TorSettingsRepository extends $StreamNotifier<TorSettings> {
  Stream<TorSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<TorSettings>, TorSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TorSettings>, TorSettings>,
              AsyncValue<TorSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(torSettingsWithDefaults)
const torSettingsWithDefaultsProvider = TorSettingsWithDefaultsProvider._();

final class TorSettingsWithDefaultsProvider
    extends $FunctionalProvider<TorSettings, TorSettings, TorSettings>
    with $Provider<TorSettings> {
  const TorSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'torSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$torSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<TorSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TorSettings create(Ref ref) {
    return torSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TorSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TorSettings>(value),
    );
  }
}

String _$torSettingsWithDefaultsHash() =>
    r'501a7ed7f14870d40b8f60303d3c385a45d9f542';
