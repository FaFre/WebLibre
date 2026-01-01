// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duckduckgo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DuckDuckGoAutosuggestService)
final duckDuckGoAutosuggestServiceProvider =
    DuckDuckGoAutosuggestServiceProvider._();

final class DuckDuckGoAutosuggestServiceProvider
    extends $NotifierProvider<DuckDuckGoAutosuggestService, void> {
  DuckDuckGoAutosuggestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'duckDuckGoAutosuggestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$duckDuckGoAutosuggestServiceHash();

  @$internal
  @override
  DuckDuckGoAutosuggestService create() => DuckDuckGoAutosuggestService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$duckDuckGoAutosuggestServiceHash() =>
    r'd9f30a577b276049b252be890bc73eb18aa118f2';

abstract class _$DuckDuckGoAutosuggestService extends $Notifier<void> {
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
