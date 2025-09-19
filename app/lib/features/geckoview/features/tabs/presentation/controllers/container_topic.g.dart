// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_topic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContainerTopicController)
const containerTopicControllerProvider = ContainerTopicControllerProvider._();

final class ContainerTopicControllerProvider
    extends $NotifierProvider<ContainerTopicController, AsyncValue<void>> {
  const ContainerTopicControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerTopicControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerTopicControllerHash();

  @$internal
  @override
  ContainerTopicController create() => ContainerTopicController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$containerTopicControllerHash() =>
    r'e89fbdaaa9106f163ff00a829eb40752dd4af63a';

abstract class _$ContainerTopicController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
