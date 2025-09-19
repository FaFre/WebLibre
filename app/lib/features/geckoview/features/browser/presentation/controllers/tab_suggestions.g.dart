// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabSuggestionsController)
const tabSuggestionsControllerProvider = TabSuggestionsControllerProvider._();

final class TabSuggestionsControllerProvider
    extends $NotifierProvider<TabSuggestionsController, bool> {
  const TabSuggestionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabSuggestionsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabSuggestionsControllerHash();

  @$internal
  @override
  TabSuggestionsController create() => TabSuggestionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabSuggestionsControllerHash() =>
    r'5ce7f385b8aba14d432912cf0acb06aad04433fc';

abstract class _$TabSuggestionsController extends $Notifier<bool> {
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
