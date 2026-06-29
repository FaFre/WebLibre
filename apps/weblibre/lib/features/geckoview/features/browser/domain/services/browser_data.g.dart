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
    r'a10ac863a4c80e3ed882c3d2a2c1b8535a257ac0';

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
