// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qwant.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QwantAutosuggestService)
const qwantAutosuggestServiceProvider = QwantAutosuggestServiceProvider._();

final class QwantAutosuggestServiceProvider
    extends $NotifierProvider<QwantAutosuggestService, void> {
  const QwantAutosuggestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'qwantAutosuggestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$qwantAutosuggestServiceHash();

  @$internal
  @override
  QwantAutosuggestService create() => QwantAutosuggestService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$qwantAutosuggestServiceHash() =>
    r'a942cd073289d20d43647de5c0f43fb08790045f';

abstract class _$QwantAutosuggestService extends $Notifier<void> {
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
