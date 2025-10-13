// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_delete_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabDeleteCache)
const tabDeleteCacheProvider = TabDeleteCacheProvider._();

final class TabDeleteCacheProvider
    extends $NotifierProvider<TabDeleteCache, Set<String>> {
  const TabDeleteCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabDeleteCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabDeleteCacheHash();

  @$internal
  @override
  TabDeleteCache create() => TabDeleteCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$tabDeleteCacheHash() => r'd645d41fc2bf7b132f0cbdf1914289ca66783689';

abstract class _$TabDeleteCache extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
