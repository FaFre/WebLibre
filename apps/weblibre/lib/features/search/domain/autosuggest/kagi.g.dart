// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kagi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KagiAutosuggestService)
final kagiAutosuggestServiceProvider = KagiAutosuggestServiceProvider._();

final class KagiAutosuggestServiceProvider
    extends $NotifierProvider<KagiAutosuggestService, void> {
  KagiAutosuggestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kagiAutosuggestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kagiAutosuggestServiceHash();

  @$internal
  @override
  KagiAutosuggestService create() => KagiAutosuggestService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$kagiAutosuggestServiceHash() =>
    r'039fe84dd480316eab38c80b41e16d16d6c14a7c';

abstract class _$KagiAutosuggestService extends $Notifier<void> {
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
