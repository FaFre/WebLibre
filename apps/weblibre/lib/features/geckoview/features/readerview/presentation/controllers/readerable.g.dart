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
    r'46206cfb431c5d36dc6351a8fc52c3b98b86dd0f';

abstract class _$ReaderableScreenController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
