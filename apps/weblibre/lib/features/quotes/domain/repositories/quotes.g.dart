// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuotesRepository)
final quotesRepositoryProvider = QuotesRepositoryProvider._();

final class QuotesRepositoryProvider
    extends $NotifierProvider<QuotesRepository, void> {
  QuotesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quotesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quotesRepositoryHash();

  @$internal
  @override
  QuotesRepository create() => QuotesRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$quotesRepositoryHash() => r'2e30c503da5619a1d15918029908890738bf5aab';

abstract class _$QuotesRepository extends $Notifier<void> {
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
