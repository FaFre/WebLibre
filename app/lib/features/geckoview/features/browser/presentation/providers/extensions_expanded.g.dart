// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extensions_expanded.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExtensionsExpanded)
final extensionsExpandedProvider = ExtensionsExpandedProvider._();

final class ExtensionsExpandedProvider
    extends $NotifierProvider<ExtensionsExpanded, bool> {
  ExtensionsExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'extensionsExpandedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$extensionsExpandedHash();

  @$internal
  @override
  ExtensionsExpanded create() => ExtensionsExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$extensionsExpandedHash() =>
    r'c07d67f3d00a8c374b598664f7f54c1bcc6de5b7';

abstract class _$ExtensionsExpanded extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
