// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'format.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Format)
const formatProvider = FormatProvider._();

final class FormatProvider extends $AsyncNotifierProvider<Format, void> {
  const FormatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'formatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$formatHash();

  @$internal
  @override
  Format create() => Format();
}

String _$formatHash() => r'fe7fcdd19b512784a36f3838c57701030475e429';

abstract class _$Format extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
