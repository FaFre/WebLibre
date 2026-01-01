// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BrowserDataService)
const browserDataServiceProvider = BrowserDataServiceProvider._();

final class BrowserDataServiceProvider
    extends $NotifierProvider<BrowserDataService, void> {
  const BrowserDataServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserDataServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserDataServiceHash();

  @$internal
  @override
  BrowserDataService create() => BrowserDataService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$browserDataServiceHash() =>
    r'861943be10c4dea325484b6a28ba21f3ff0d29fa';

abstract class _$BrowserDataService extends $Notifier<void> {
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
