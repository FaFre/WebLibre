// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brave.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BraveAutosuggestService)
const braveAutosuggestServiceProvider = BraveAutosuggestServiceProvider._();

final class BraveAutosuggestServiceProvider
    extends $NotifierProvider<BraveAutosuggestService, void> {
  const BraveAutosuggestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'braveAutosuggestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$braveAutosuggestServiceHash();

  @$internal
  @override
  BraveAutosuggestService create() => BraveAutosuggestService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$braveAutosuggestServiceHash() =>
    r'3b2f465dcf4b44b0450975d3909fc7066d171bf2';

abstract class _$BraveAutosuggestService extends $Notifier<void> {
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
