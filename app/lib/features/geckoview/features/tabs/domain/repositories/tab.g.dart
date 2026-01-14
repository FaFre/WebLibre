// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabDataRepository)
final tabDataRepositoryProvider = TabDataRepositoryProvider._();

final class TabDataRepositoryProvider
    extends $NotifierProvider<TabDataRepository, void> {
  TabDataRepositoryProvider._()
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

String _$tabDataRepositoryHash() => r'c3632e0a2d91811103b329659cb0c6d778b14cea';

abstract class _$TabDataRepository extends $Notifier<void> {
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
