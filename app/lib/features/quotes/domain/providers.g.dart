// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(randomQuote)
final randomQuoteProvider = RandomQuoteProvider._();

final class RandomQuoteProvider
    extends $FunctionalProvider<AsyncValue<Quote?>, Quote?, FutureOr<Quote?>>
    with $FutureModifier<Quote?>, $FutureProvider<Quote?> {
  RandomQuoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'randomQuoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$randomQuoteHash();

  @$internal
  @override
  $FutureProviderElement<Quote?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Quote?> create(Ref ref) {
    return randomQuote(ref);
  }
}

String _$randomQuoteHash() => r'045fe6256f03e90d2fa5e42c574d58b4aa2cc1d7';
