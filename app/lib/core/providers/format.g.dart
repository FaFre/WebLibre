// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'format.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Format)
final formatProvider = FormatProvider._();

final class FormatProvider extends $AsyncNotifierProvider<Format, void> {
  FormatProvider._()
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

String _$formatHash() => r'f132aabb20bf4df77d771d6c866bc413c00bd9ff';

abstract class _$Format extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
