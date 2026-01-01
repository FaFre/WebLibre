// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineBoundIntentStream)
final engineBoundIntentStreamProvider = EngineBoundIntentStreamProvider._();

final class EngineBoundIntentStreamProvider
    extends $StreamNotifierProvider<EngineBoundIntentStream, SharedContent> {
  EngineBoundIntentStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineBoundIntentStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineBoundIntentStreamHash();

  @$internal
  @override
  EngineBoundIntentStream create() => EngineBoundIntentStream();
}

String _$engineBoundIntentStreamHash() =>
    r'ab9804f97e0222b2306683d2fcfa71d3d57ecd21';

abstract class _$EngineBoundIntentStream
    extends $StreamNotifier<SharedContent> {
  Stream<SharedContent> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SharedContent>, SharedContent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SharedContent>, SharedContent>,
              AsyncValue<SharedContent>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
