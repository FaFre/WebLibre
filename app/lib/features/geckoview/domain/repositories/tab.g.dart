// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabRepository)
final tabRepositoryProvider = TabRepositoryProvider._();

final class TabRepositoryProvider
    extends $NotifierProvider<TabRepository, void> {
  TabRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabRepositoryHash();

  @$internal
  @override
  TabRepository create() => TabRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tabRepositoryHash() => r'6a66c2f1f8d00767d19e6125d4eafc6d93381c8a';

abstract class _$TabRepository extends $Notifier<void> {
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
