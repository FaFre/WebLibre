// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_addon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllowUnsignedExtensions)
final allowUnsignedExtensionsProvider = AllowUnsignedExtensionsProvider._();

final class AllowUnsignedExtensionsProvider
    extends $AsyncNotifierProvider<AllowUnsignedExtensions, bool> {
  AllowUnsignedExtensionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allowUnsignedExtensionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allowUnsignedExtensionsHash();

  @$internal
  @override
  AllowUnsignedExtensions create() => AllowUnsignedExtensions();
}

String _$allowUnsignedExtensionsHash() =>
    r'3b67f51cabf8e2f37d992320c5b93bb61c6dbe1f';

abstract class _$AllowUnsignedExtensions extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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
    r'b90e69ce77b846d6056c800f232a8aa50b4b21d0';

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
