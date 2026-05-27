// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_match.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReverseBangMatcher)
final reverseBangMatcherProvider = ReverseBangMatcherProvider._();

final class ReverseBangMatcherProvider
    extends $NotifierProvider<ReverseBangMatcher, void> {
  ReverseBangMatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reverseBangMatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reverseBangMatcherHash();

  @$internal
  @override
  ReverseBangMatcher create() => ReverseBangMatcher();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$reverseBangMatcherHash() =>
    r'52ce24b94a780612baa085ab07b7b3d88306b934';

abstract class _$ReverseBangMatcher extends $Notifier<void> {
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
