// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$engineSettingsWithDefaultsHash() =>
    r'018e37f31f893e203b86038e84b0ddf5e72454d4';

/// See also [engineSettingsWithDefaults].
@ProviderFor(engineSettingsWithDefaults)
final engineSettingsWithDefaultsProvider =
    AutoDisposeProvider<EngineSettings>.internal(
      engineSettingsWithDefaults,
      name: r'engineSettingsWithDefaultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$engineSettingsWithDefaultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineSettingsWithDefaultsRef = AutoDisposeProviderRef<EngineSettings>;
String _$engineSettingsRepositoryHash() =>
    r'd0c2fbe060b5eaee7189f6cb0dd58c97cf5987b5';

/// See also [EngineSettingsRepository].
@ProviderFor(EngineSettingsRepository)
final engineSettingsRepositoryProvider =
    StreamNotifierProvider<EngineSettingsRepository, EngineSettings>.internal(
      EngineSettingsRepository.new,
      name: r'engineSettingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$engineSettingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EngineSettingsRepository = StreamNotifier<EngineSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
