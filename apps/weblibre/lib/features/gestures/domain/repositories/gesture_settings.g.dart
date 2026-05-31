// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gesture_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GestureSettingsRepository)
final gestureSettingsRepositoryProvider = GestureSettingsRepositoryProvider._();

final class GestureSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<GestureSettingsRepository, GestureSettings> {
  GestureSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gestureSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gestureSettingsRepositoryHash();

  @$internal
  @override
  GestureSettingsRepository create() => GestureSettingsRepository();
}

String _$gestureSettingsRepositoryHash() =>
    r'fc898b669a484fe45f89024d8456190f08d56085';

abstract class _$GestureSettingsRepository
    extends $StreamNotifier<GestureSettings> {
  Stream<GestureSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GestureSettings>, GestureSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GestureSettings>, GestureSettings>,
              AsyncValue<GestureSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(gestureSettingsWithDefaults)
final gestureSettingsWithDefaultsProvider =
    GestureSettingsWithDefaultsProvider._();

final class GestureSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<GestureSettings, GestureSettings, GestureSettings>
    with $Provider<GestureSettings> {
  GestureSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gestureSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gestureSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<GestureSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GestureSettings create(Ref ref) {
    return gestureSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GestureSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GestureSettings>(value),
    );
  }
}

String _$gestureSettingsWithDefaultsHash() =>
    r'f9f242b81ef9d4d0594ae1700fa11db503583672';
