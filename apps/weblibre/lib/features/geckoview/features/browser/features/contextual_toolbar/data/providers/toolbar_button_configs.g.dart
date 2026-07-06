// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_button_configs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(toolbarButtonConfigs)
final toolbarButtonConfigsProvider = ToolbarButtonConfigsFamily._();

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
  ToolbarButtonConfigsProvider._({
    required ToolbarButtonConfigsFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'toolbarButtonConfigsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toolbarButtonConfigsHash();

  @override
  String toString() {
    return r'toolbarButtonConfigsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ToolbarButtonConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ToolbarButtonConfig>> create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return toolbarButtonConfigs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ToolbarButtonConfigsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toolbarButtonConfigsHash() =>
    r'913d2c8ca3b8b3f39f2247cafac068dc26abc566';

final class ToolbarButtonConfigsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  ToolbarButtonConfigsFamily._()
    : super(
        retry: null,
        name: r'toolbarButtonConfigsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ToolbarButtonConfigsProvider call(ToolbarConfigLocation location) =>
      ToolbarButtonConfigsProvider._(argument: location, from: this);

  @override
  String toString() => r'toolbarButtonConfigsProvider';
}

@ProviderFor(effectiveToolbarButtonConfigs)
final effectiveToolbarButtonConfigsProvider =
    EffectiveToolbarButtonConfigsFamily._();

final class EffectiveToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>
        >
    with $Provider<EquatableValue<List<ToolbarButtonConfig>>> {
  EffectiveToolbarButtonConfigsProvider._({
    required EffectiveToolbarButtonConfigsFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'effectiveToolbarButtonConfigsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$effectiveToolbarButtonConfigsHash();

  @override
  String toString() {
    return r'effectiveToolbarButtonConfigsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<ToolbarButtonConfig>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<ToolbarButtonConfig>> create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return effectiveToolbarButtonConfigs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<ToolbarButtonConfig>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<ToolbarButtonConfig>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveToolbarButtonConfigsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$effectiveToolbarButtonConfigsHash() =>
    r'6cd77c8af6df8943db6778b5222bb6ae9fb40025';

final class EffectiveToolbarButtonConfigsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  EffectiveToolbarButtonConfigsFamily._()
    : super(
        retry: null,
        name: r'effectiveToolbarButtonConfigsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  EffectiveToolbarButtonConfigsProvider call(ToolbarConfigLocation location) =>
      EffectiveToolbarButtonConfigsProvider._(argument: location, from: this);

  @override
  String toString() => r'effectiveToolbarButtonConfigsProvider';
}
