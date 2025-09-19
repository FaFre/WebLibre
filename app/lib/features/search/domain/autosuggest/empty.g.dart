// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EmptyAutosuggestService)
const emptyAutosuggestServiceProvider = EmptyAutosuggestServiceProvider._();

final class EmptyAutosuggestServiceProvider
    extends $NotifierProvider<EmptyAutosuggestService, void> {
  const EmptyAutosuggestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emptyAutosuggestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emptyAutosuggestServiceHash();

  @$internal
  @override
  EmptyAutosuggestService create() => EmptyAutosuggestService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$emptyAutosuggestServiceHash() =>
    r'7fbe81807baf379cf621ef46fba00e46778978f8';

abstract class _$EmptyAutosuggestService extends $Notifier<void> {
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
