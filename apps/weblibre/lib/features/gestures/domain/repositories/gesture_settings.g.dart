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
    r'f9e06ffae01c0046a7ba7353f2774cf366d04b7a';

abstract class _$GestureSettingsRepository
    extends $StreamNotifier<GestureSettings> {
  Stream<GestureSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GestureSettings>, GestureSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GestureSettings>, GestureSettings>,
              AsyncValue<GestureSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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

/// What [gesture] currently does, or null when the user switched it off.

@ProviderFor(builtInGestureBinding)
final builtInGestureBindingProvider = BuiltInGestureBindingFamily._();

/// What [gesture] currently does, or null when the user switched it off.

final class BuiltInGestureBindingProvider
    extends $FunctionalProvider<BrowserAction?, BrowserAction?, BrowserAction?>
    with $Provider<BrowserAction?> {
  /// What [gesture] currently does, or null when the user switched it off.
  BuiltInGestureBindingProvider._({
    required BuiltInGestureBindingFamily super.from,
    required BuiltInGesture super.argument,
  }) : super(
         retry: null,
         name: r'builtInGestureBindingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$builtInGestureBindingHash();

  @override
  String toString() {
    return r'builtInGestureBindingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<BrowserAction?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BrowserAction? create(Ref ref) {
    final argument = this.argument as BuiltInGesture;
    return builtInGestureBinding(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrowserAction? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrowserAction?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BuiltInGestureBindingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$builtInGestureBindingHash() =>
    r'ddab40f20e349bf99066153a6c3e74ee13522299';

/// What [gesture] currently does, or null when the user switched it off.

final class BuiltInGestureBindingFamily extends $Family
    with $FunctionalFamilyOverride<BrowserAction?, BuiltInGesture> {
  BuiltInGestureBindingFamily._()
    : super(
        retry: null,
        name: r'builtInGestureBindingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// What [gesture] currently does, or null when the user switched it off.

  BuiltInGestureBindingProvider call(BuiltInGesture gesture) =>
      BuiltInGestureBindingProvider._(argument: gesture, from: this);

  @override
  String toString() => r'builtInGestureBindingProvider';
}
