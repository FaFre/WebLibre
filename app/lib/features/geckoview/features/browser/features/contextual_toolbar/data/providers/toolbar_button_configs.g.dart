// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_button_configs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(toolbarButtonConfigs)
final toolbarButtonConfigsProvider = ToolbarButtonConfigsProvider._();

final class ToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ToolbarButtonConfig>>,
          List<ToolbarButtonConfig>,
          Stream<List<ToolbarButtonConfig>>
        >
    with
        $FutureModifier<List<ToolbarButtonConfig>>,
        $StreamProvider<List<ToolbarButtonConfig>> {
  ToolbarButtonConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toolbarButtonConfigsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toolbarButtonConfigsHash();

  @$internal
  @override
  $StreamProviderElement<List<ToolbarButtonConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ToolbarButtonConfig>> create(Ref ref) {
    return toolbarButtonConfigs(ref);
  }
}

String _$toolbarButtonConfigsHash() =>
    r'02f79c2087a3a5413fe879405c05f4a4d1eaffeb';

@ProviderFor(effectiveToolbarButtonConfigs)
final effectiveToolbarButtonConfigsProvider =
    EffectiveToolbarButtonConfigsProvider._();

final class EffectiveToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>
        >
    with $Provider<EquatableValue<List<ToolbarButtonConfig>>> {
  EffectiveToolbarButtonConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveToolbarButtonConfigsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveToolbarButtonConfigsHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<List<ToolbarButtonConfig>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<ToolbarButtonConfig>> create(Ref ref) {
    return effectiveToolbarButtonConfigs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<ToolbarButtonConfig>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<ToolbarButtonConfig>>>(value),
    );
  }
}

String _$effectiveToolbarButtonConfigsHash() =>
    r'dd876160f586c64237a42a29eb63cb119f962b02';
