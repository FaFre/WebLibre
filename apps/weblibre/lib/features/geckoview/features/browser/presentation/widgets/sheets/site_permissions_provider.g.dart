// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_permissions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to get the public suffix plus one (eTLD+1) for a host

@ProviderFor(publicSuffixPlusOne)
final publicSuffixPlusOneProvider = PublicSuffixPlusOneFamily._();

/// Provider to get the public suffix plus one (eTLD+1) for a host

final class PublicSuffixPlusOneProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provider to get the public suffix plus one (eTLD+1) for a host
  PublicSuffixPlusOneProvider._({
    required PublicSuffixPlusOneFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicSuffixPlusOneProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicSuffixPlusOneHash();

  @override
  String toString() {
    return r'publicSuffixPlusOneProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return publicSuffixPlusOne(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicSuffixPlusOneProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicSuffixPlusOneHash() =>
    r'2871740bee033e634047b1374ae8dfad508f2cb2';

/// Provider to get the public suffix plus one (eTLD+1) for a host

final class PublicSuffixPlusOneFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  PublicSuffixPlusOneFamily._()
    : super(
        retry: null,
        name: r'publicSuffixPlusOneProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get the public suffix plus one (eTLD+1) for a host

  PublicSuffixPlusOneProvider call(String host) =>
      PublicSuffixPlusOneProvider._(argument: host, from: this);

  @override
  String toString() => r'publicSuffixPlusOneProvider';
}
