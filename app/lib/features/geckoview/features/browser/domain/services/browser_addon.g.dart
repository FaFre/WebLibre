// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_addon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BrowserAddonService)
final browserAddonServiceProvider = BrowserAddonServiceProvider._();

final class BrowserAddonServiceProvider
    extends $NotifierProvider<BrowserAddonService, void> {
  BrowserAddonServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserAddonServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserAddonServiceHash();

  @$internal
  @override
  BrowserAddonService create() => BrowserAddonService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$browserAddonServiceHash() =>
    r'1485fd056ce32e142e342e920affb82a5c77a370';

abstract class _$BrowserAddonService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
