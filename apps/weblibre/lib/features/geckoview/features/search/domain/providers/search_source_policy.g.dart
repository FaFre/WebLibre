// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_source_policy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The [SearchSourcePolicy] for a search typed into a private tab or not.

@ProviderFor(searchSourcePolicy)
final searchSourcePolicyProvider = SearchSourcePolicyFamily._();

/// The [SearchSourcePolicy] for a search typed into a private tab or not.

final class SearchSourcePolicyProvider
    extends
        $FunctionalProvider<
          SearchSourcePolicy,
          SearchSourcePolicy,
          SearchSourcePolicy
        >
    with $Provider<SearchSourcePolicy> {
  /// The [SearchSourcePolicy] for a search typed into a private tab or not.
  SearchSourcePolicyProvider._({
    required SearchSourcePolicyFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'searchSourcePolicyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchSourcePolicyHash();

  @override
  String toString() {
    return r'searchSourcePolicyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SearchSourcePolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchSourcePolicy create(Ref ref) {
    final argument = this.argument as bool;
    return searchSourcePolicy(ref, privateMode: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchSourcePolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchSourcePolicy>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSourcePolicyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchSourcePolicyHash() =>
    r'f41e098132a5df821f49ae5fb91d1b16a715cd1b';

/// The [SearchSourcePolicy] for a search typed into a private tab or not.

final class SearchSourcePolicyFamily extends $Family
    with $FunctionalFamilyOverride<SearchSourcePolicy, bool> {
  SearchSourcePolicyFamily._()
    : super(
        retry: null,
        name: r'searchSourcePolicyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The [SearchSourcePolicy] for a search typed into a private tab or not.

  SearchSourcePolicyProvider call({required bool privateMode}) =>
      SearchSourcePolicyProvider._(argument: privateMode, from: this);

  @override
  String toString() => r'searchSourcePolicyProvider';
}
