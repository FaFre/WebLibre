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
    r'8fd234229d0b3ab71d9952c84f66e53b928d5941';

abstract class _$DuckDuckGoAutosuggestService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
