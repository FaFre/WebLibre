// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_website.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GenericWebsiteService)
const genericWebsiteServiceProvider = GenericWebsiteServiceProvider._();

final class GenericWebsiteServiceProvider
    extends $NotifierProvider<GenericWebsiteService, void> {
  const GenericWebsiteServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'genericWebsiteServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$genericWebsiteServiceHash();

  @$internal
  @override
  GenericWebsiteService create() => GenericWebsiteService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$genericWebsiteServiceHash() =>
    r'9bc32261abd76a79efb57f6d27832e949cb495a6';

abstract class _$GenericWebsiteService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
