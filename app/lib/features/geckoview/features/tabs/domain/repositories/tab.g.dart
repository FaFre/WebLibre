// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabDataRepository)
const tabDataRepositoryProvider = TabDataRepositoryProvider._();

final class TabDataRepositoryProvider
    extends $NotifierProvider<TabDataRepository, void> {
  const TabDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabDataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabDataRepositoryHash();

  @$internal
  @override
  TabDataRepository create() => TabDataRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tabDataRepositoryHash() => r'3d9149efb88f256cc826eb538f13331b49438a7c';

abstract class _$TabDataRepository extends $Notifier<void> {
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
