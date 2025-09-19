// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectionActionService)
const selectionActionServiceProvider = SelectionActionServiceProvider._();

final class SelectionActionServiceProvider
    extends
        $FunctionalProvider<
          GeckoSelectionActionService,
          GeckoSelectionActionService,
          GeckoSelectionActionService
        >
    with $Provider<GeckoSelectionActionService> {
  const SelectionActionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectionActionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectionActionServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoSelectionActionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoSelectionActionService create(Ref ref) {
    return selectionActionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoSelectionActionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoSelectionActionService>(value),
    );
  }
}

String _$selectionActionServiceHash() =>
    r'c89d981c2ba253ed940887fa59c11ad93d8589a8';

@ProviderFor(eventService)
const eventServiceProvider = EventServiceProvider._();

final class EventServiceProvider
    extends
        $FunctionalProvider<
          GeckoEventService,
          GeckoEventService,
          GeckoEventService
        >
    with $Provider<GeckoEventService> {
  const EventServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoEventService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoEventService create(Ref ref) {
    return eventService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoEventService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoEventService>(value),
    );
  }
}

String _$eventServiceHash() => r'166b01f636fbdd4355dbc55a18ca4f83e0006de8';

@ProviderFor(addonService)
const addonServiceProvider = AddonServiceProvider._();

final class AddonServiceProvider
    extends
        $FunctionalProvider<
          GeckoAddonService,
          GeckoAddonService,
          GeckoAddonService
        >
    with $Provider<GeckoAddonService> {
  const AddonServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addonServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addonServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoAddonService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoAddonService create(Ref ref) {
    return addonService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoAddonService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoAddonService>(value),
    );
  }
}

String _$addonServiceHash() => r'c7aca09b99c3810908176f3464f5f90a185aa5e7';

@ProviderFor(tabContentService)
const tabContentServiceProvider = TabContentServiceProvider._();

final class TabContentServiceProvider
    extends
        $FunctionalProvider<
          GeckoTabContentService,
          GeckoTabContentService,
          GeckoTabContentService
        >
    with $Provider<GeckoTabContentService> {
  const TabContentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabContentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabContentServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoTabContentService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoTabContentService create(Ref ref) {
    return tabContentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoTabContentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoTabContentService>(value),
    );
  }
}

String _$tabContentServiceHash() => r'd9a991add907ecc138c62790883e59d8e9aa9266';

@ProviderFor(engineSuggestionsService)
const engineSuggestionsServiceProvider = EngineSuggestionsServiceProvider._();

final class EngineSuggestionsServiceProvider
    extends
        $FunctionalProvider<
          GeckoSuggestionsService,
          GeckoSuggestionsService,
          GeckoSuggestionsService
        >
    with $Provider<GeckoSuggestionsService> {
  const EngineSuggestionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSuggestionsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSuggestionsServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoSuggestionsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoSuggestionsService create(Ref ref) {
    return engineSuggestionsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoSuggestionsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoSuggestionsService>(value),
    );
  }
}

String _$engineSuggestionsServiceHash() =>
    r'f7414b335564578b2c7f6a86baf8bf13f2d5ba2d';

@ProviderFor(EngineReadyState)
const engineReadyStateProvider = EngineReadyStateProvider._();

final class EngineReadyStateProvider
    extends $NotifierProvider<EngineReadyState, bool> {
  const EngineReadyStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineReadyStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineReadyStateHash();

  @$internal
  @override
  EngineReadyState create() => EngineReadyState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$engineReadyStateHash() => r'a892c48ffc29e3414de12e66d9bfec522e4f40a8';

abstract class _$EngineReadyState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
