// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifecycle.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BrowserViewLifecycle)
final browserViewLifecycleProvider = BrowserViewLifecycleProvider._();

final class BrowserViewLifecycleProvider
    extends $NotifierProvider<BrowserViewLifecycle, AppLifecycleState?> {
  BrowserViewLifecycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserViewLifecycleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserViewLifecycleHash();

  @$internal
  @override
  BrowserViewLifecycle create() => BrowserViewLifecycle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleState?>(value),
    );
  }
}

String _$browserViewLifecycleHash() =>
    r'9082d058611aaaae268b60b8ce130150f73d453d';

abstract class _$BrowserViewLifecycle extends $Notifier<AppLifecycleState?> {
  AppLifecycleState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLifecycleState?, AppLifecycleState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLifecycleState?, AppLifecycleState?>,
              AppLifecycleState?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
