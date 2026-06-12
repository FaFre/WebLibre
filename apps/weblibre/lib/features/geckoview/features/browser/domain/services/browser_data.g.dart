// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BrowserDataService)
final browserDataServiceProvider = BrowserDataServiceProvider._();

final class BrowserDataServiceProvider
    extends $NotifierProvider<BrowserDataService, void> {
  BrowserDataServiceProvider._()
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
    r'b6586d14ef13ab2905072e1e26cabc17846eaf73';

abstract class _$BrowserDataService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
