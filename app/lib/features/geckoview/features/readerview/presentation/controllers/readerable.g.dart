// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readerable.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReaderableScreenController)
final readerableScreenControllerProvider =
    ReaderableScreenControllerProvider._();

final class ReaderableScreenControllerProvider
    extends $AsyncNotifierProvider<ReaderableScreenController, void> {
  ReaderableScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerableScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerableScreenControllerHash();

  @$internal
  @override
  ReaderableScreenController create() => ReaderableScreenController();
}

String _$readerableScreenControllerHash() =>
    r'62b2167ff8f9fe21c3cf3339e135a50aa684160c';

abstract class _$ReaderableScreenController extends $AsyncNotifier<void> {
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
