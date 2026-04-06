// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabList)
final tabListProvider = TabListProvider._();

final class TabListProvider
    extends $NotifierProvider<TabList, EquatableValue<List<String>>> {
  TabListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabListHash();

  @$internal
  @override
  TabList create() => TabList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<String>>>(value),
    );
  }
}

String _$tabListHash() => r'88c2598a4d586fee9e3d0f1b418cf88ea5c7da75';

abstract class _$TabList extends $Notifier<EquatableValue<List<String>>> {
  EquatableValue<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<EquatableValue<List<String>>, EquatableValue<List<String>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EquatableValue<List<String>>,
                EquatableValue<List<String>>
              >,
              EquatableValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
