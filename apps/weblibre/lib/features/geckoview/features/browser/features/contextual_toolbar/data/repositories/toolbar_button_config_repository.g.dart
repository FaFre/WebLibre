// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_button_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(toolbarConfigRepository)
final toolbarConfigRepositoryProvider = ToolbarConfigRepositoryFamily._();

final class ToolbarConfigRepositoryProvider
    extends
        $FunctionalProvider<
          ToolbarButtonConfigRepository,
          ToolbarButtonConfigRepository,
          ToolbarButtonConfigRepository
        >
    with $Provider<ToolbarButtonConfigRepository> {
  ToolbarConfigRepositoryProvider._({
    required ToolbarConfigRepositoryFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'toolbarConfigRepositoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toolbarConfigRepositoryHash();

  @override
  String toString() {
    return r'toolbarConfigRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ToolbarButtonConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ToolbarButtonConfigRepository create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return toolbarConfigRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolbarButtonConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolbarButtonConfigRepository>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ToolbarConfigRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toolbarConfigRepositoryHash() =>
    r'47129b30f01db6ea73d553a8fd1b4f6e8a7b4a3c';

final class ToolbarConfigRepositoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ToolbarButtonConfigRepository,
          ToolbarConfigLocation
        > {
  ToolbarConfigRepositoryFamily._()
    : super(
        retry: null,
        name: r'toolbarConfigRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ToolbarConfigRepositoryProvider call(ToolbarConfigLocation location) =>
      ToolbarConfigRepositoryProvider._(argument: location, from: this);

  @override
  String toString() => r'toolbarConfigRepositoryProvider';
}
