// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_view_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabsViewModeController)
final tabsViewModeControllerProvider = TabsViewModeControllerProvider._();

final class TabsViewModeControllerProvider
    extends $NotifierProvider<TabsViewModeController, TabsViewMode> {
  TabsViewModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabsViewModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabsViewModeControllerHash();

  @$internal
  @override
  TabsViewModeController create() => TabsViewModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabsViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabsViewMode>(value),
    );
  }
}

String _$tabsViewModeControllerHash() =>
    r'e013b174218fcad81981f7d939cf161c3b002adc';

abstract class _$TabsViewModeController extends $Notifier<TabsViewMode> {
  TabsViewMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TabsViewMode, TabsViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TabsViewMode, TabsViewMode>,
              TabsViewMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabViewFilterController)
@JsonPersist()
final tabViewFilterControllerProvider = TabViewFilterControllerProvider._();

@JsonPersist()
final class TabViewFilterControllerProvider
    extends $NotifierProvider<TabViewFilterController, TabViewFilterOptions> {
  TabViewFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabViewFilterControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabViewFilterControllerHash();

  @$internal
  @override
  TabViewFilterController create() => TabViewFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabViewFilterOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabViewFilterOptions>(value),
    );
  }
}

String _$tabViewFilterControllerHash() =>
    r'95e8a03d60ebe05e0c5df38f810f951a4fe2ed78';

@JsonPersist()
abstract class _$TabViewFilterControllerBase
    extends $Notifier<TabViewFilterOptions> {
  TabViewFilterOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TabViewFilterOptions, TabViewFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TabViewFilterOptions, TabViewFilterOptions>,
              TabViewFilterOptions,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabsReorderableController)
final tabsReorderableControllerProvider = TabsReorderableControllerProvider._();

final class TabsReorderableControllerProvider
    extends $NotifierProvider<TabsReorderableController, bool> {
  TabsReorderableControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabsReorderableControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabsReorderableControllerHash();

  @$internal
  @override
  TabsReorderableController create() => TabsReorderableController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabsReorderableControllerHash() =>
    r'f169e9dc04055ef611f17ebe121f0f51f6a294cb';

abstract class _$TabsReorderableController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$TabViewFilterController extends _$TabViewFilterControllerBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "TabViewFilterController";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(TabViewFilterOptions state)? encode,
    TabViewFilterOptions Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    return NotifierPersistX(this).persist<String, String>(
      storage,
      key: key ?? this.key,
      encode: encode ?? $jsonCodex.encode,
      decode:
          decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return TabViewFilterOptions.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
